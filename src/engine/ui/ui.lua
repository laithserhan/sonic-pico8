local input = require("engine/input/input")
local visual = require("game/resources/visual")

local ui = {
  show_mouse = false,
  cursor_sprite_data = nil
}

-- setup

-- injection function: call it from game to set the sprite data
-- for the mouse cursor. this avoids accessing game data
-- from an engine script
function ui:set_cursor_sprite_data(cursor_sprite_data)
  self.cursor_sprite_data = cursor_sprite_data
end

-- helper functions

function ui:render_mouse()
  if self.show_mouse and self.cursor_sprite_data then
    camera(0, 0)
    local cursor_position = input.get_cursor_position()
    self.cursor_sprite_data:render(cursor_position)
  end
end

-- label class: container for a text to draw at a given position
local label = new_class()

-- text      printable  text content to draw (mainly string or number)
-- position  vector     position to draw the label at
-- colour    int        color index to draw the label with
function label:_init(text, position, colour)
  self.text = text
  self.position = position
  self.colour = colour
end

function label:_tostring()
  return "label('"..self.text.."' @ "..self.position.." in "..color_tostring(self.colour)..")"
end

function label.__eq(lhs, rhs)
  return lhs.text == rhs.text and lhs.position == rhs.position and lhs.colour == rhs.colour
end


-- overlay class: allows to draw labels on top of the screen
local overlay = new_class()

-- parameters
-- layer       int              level at which the overlay should be drawn, higher on top
-- state vars
-- labels      {string, label}  table of labels to draw, identified by name
function overlay:_init(layer)
  self.layer = layer
  self.labels = {}
end

function overlay:_tostring()
  return "overlay(layer: "..self.layer..")"
end

-- add a label identified by a name, containing a text string,
-- at a position vector, with a given color
-- if a label with the same name already exists, replace it
function overlay:add_label(name, text, position, colour)
  if not colour then
    warn("overlay:add_label no colour passed, will default to black (0)")
  end
  if self.labels[name] == nil then
    -- create new label and add it
    self.labels[name] = label(text, position, colour)
  else
    -- set existing label properties
    local label = self.labels[name]
    label.text = text
    label.position = position
    label.colour = colour
  end
end

-- remove a label identified by a name
-- if the label is not found, fails with warning
function overlay:remove_label(name, text, position)
  if self.labels[name] ~= nil then
    self.labels[name] = nil
  else
    warn("overlay:remove_label: could not find label with name: '"..name.."'", "ui")
  end
end

-- remove all the labels
function overlay:clear_labels()
  clear_table(self.labels)
end

-- draw all labels in the overlay. order is not guaranteed
function overlay:draw_labels()
  for name, label in pairs(self.labels) do
    print(label.text, label.position.x, label.position.y, label.colour)
  end
end


-- export
ui.label = label
ui.overlay = overlay
return ui