#!/usr/bin/python3.6
# -*- coding: utf-8 -*-
import argparse
import os
import re
from enum import Enum

# This script applies preprocessor directives on the code.
# It will strip all code between #if [symbol] and #endif if symbol is not defined for this config.

# Config to defined symbols
defined_symbols = {
    'debug': ['debug', 'test'],
    'release': []
}

# Parsing state machine modes
class ParsingMode(Enum):
    NORMAL      = 1
    IF_ACCEPTED = 2
    IF_IGNORED  = 3

# Regex patterns
if_pattern = re.compile("--#if (\w+)")  # ! ignore anything after 1st symbol
endif_pattern = re.compile("--#endif")

def preprocess_dir(dirpath, config):
    """Apply preprocessor directives to all the source files inside the given directory, for the given config"""
    for root, dirs, files in os.walk(dirpath):
        for file in files:
            if file.endswith(".lua"):
                preprocess_file(os.path.join(root, file), config)

def preprocess_file(filepath, config):
    """
    Apply preprocessor directives to a single file, for the given config

    test.lua:
        print("always")
        --#if debug
        print("debug")
        --#endif
        if true:
            print("hello")

    >>> preprocess_file('test.lua', 'debug')

    test.lua:
        print("always")
        print("debug")
        if true:
            print("hello")

    or

    >>> preprocess_file('test.lua', 'release')

    test.lua:
        print("always")
        if true:
            print("hello")

    """
    with open(filepath, 'r+') as f:
        preprocessed_lines = preprocess_lines(f, config)
        f.seek(0)
        f.truncate(0)  # after preprocessing, file tends to have fewer lines so it's important to remove previous content
        for line in preprocessed_lines:
            f.write(line)

def preprocess_lines(lines, config):
    """
    Apply preprocessor directives to iterable lines of source code, for the given config
    It is possible to pass a file as lines iterator

    """
    preprocessed_lines = []
    current_mode = ParsingMode.NORMAL
    for line in lines:
        match = if_pattern.match(line)
        if match:
            if current_mode is not ParsingMode.NORMAL:
                print('Warning: --#if found inside previous --#if block, ignoring directive')
                continue
            symbol = match.group(1)
            if symbol in defined_symbols[config]:
                # symbol is defined, keep the surrounded lines
                # still remove the preprocessor directives (don't add it to accepted lines)
                current_mode = ParsingMode.IF_ACCEPTED
            else:
                current_mode = ParsingMode.IF_IGNORED
        elif endif_pattern.match(line):
            if current_mode is ParsingMode.NORMAL:
                print('Warning: --#endif found outside --#if block, ignoring directive')
                continue
            current_mode = ParsingMode.NORMAL
        elif current_mode in (ParsingMode.NORMAL, ParsingMode.IF_ACCEPTED):
            preprocessed_lines.append(line)
    if current_mode is not ParsingMode.NORMAL:
        print('Warning: file ended inside an --#if block. Make sure the block is closed by an --#endif directive')
    return preprocessed_lines

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Apply preprocessor directives.')
    parser.add_argument('path', type=str, help='path containing source files to preprocess')
    parser.add_argument('config', type=str, help="config used: 'debug' or 'release'")
    args = parser.parse_args()
    preprocess_dir(args.path, args.config)