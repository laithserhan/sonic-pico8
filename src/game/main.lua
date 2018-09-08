local gameapp = require("game/application/gameapp")
local gamestate_proxy = require("game/application/gamestate_proxy")

--#if log
local logging = require("engine/debug/logging")
logging.logger:register_stream(logging.console_log_stream)

--#if visual_logger
local visual_logger = require("engine/debug/visual_logger")
logging.logger:register_stream(visual_logger.visual_log_stream)
visual_logger.window:show()
--#endif

--#endif

--#if profiler
local profiler = require("engine/debug/profiler")
profiler.window:show()
--#endif

--#if tuner
local codetuner = require("engine/debug/codetuner")
codetuner:show()
codetuner.active = true
--#endif

-- pico-8 functions must be placed at the end to be parsed by p8tool

function _init()
  -- require all gamestate modules, according to preprocessing step
  gamestate_proxy:require_gamestates()
  gameapp.init()
end

function _update60()
  gameapp.update()
end

function _draw()
  gameapp.draw()
end
