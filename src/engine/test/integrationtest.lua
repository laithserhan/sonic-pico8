require("engine/application/constants")
require("engine/core/class")
require("engine/test/assertions")
local debug = require("engine/debug/debug")
local input = require("engine/input/input")

test_result = {
  none    = 'none',       -- no test started or the test is not over yet
  success = 'success',    -- the test has just succeeded
  failure = 'failure'     -- the test has just failed
}

-- integration test runner singleton
integration_test_runner = singleton {
  current_test = nil,
  current_frame = 0.,
  _last_trigger_frame = 0.,
  _next_action_index = 1,
  current_result = test_result.none
}

function integration_test_runner:start(test)
  if self.current_test then
    self:stop()
  end
  self.current_test = test
  if test.setup then
    test:setup()
  end
  -- edge case: 0 actions in the action sequence. check end
  -- immediately to avoid out of bounds index in _check_next_action
  if not self:_check_end() then
    self:_check_next_action()
  end
end

function integration_test_runner:update()
  assert(self.current_test, "integration_test_runner:update: current_test is not set")
  if self.current_result ~= test_result.none then
    -- the current test is over and we already got the result
    -- do nothing and fail silently (to avoid crashing just because we repeated update a bit too much)
    return
  end

  -- advance time
  self.current_frame = self.current_frame + 1
  self:_check_end()
  self:_check_next_action()
end

function integration_test_runner:_check_next_action()
  -- check if next action should be applied
  local next_action = self.current_test.action_sequence[self._next_action_index]
  should_trigger_next_action = next_action.trigger:_check(self.current_frame - self._last_trigger_frame)
  if should_trigger_next_action then
    -- apply next action and update time/index
    next_action.callback()
    self._last_trigger_frame = self.current_frame
    self._next_action_index = self._next_action_index + 1
    self:_check_end()
  end
end

function integration_test_runner:_check_end()
  -- check if last action was applied, end now
  -- this means you can define an 'end' action just by adding an empty action at the end
  if self._next_action_index > #self.current_test.action_sequence then
    self:_end_with_final_assertion()
    return true
  end
  return false
end

function integration_test_runner:_end_with_final_assertion()
  -- check the final assertion so we know if we should end with success or failure
  result, message = self.current_test:_check_final_assertion()
  if result then
    self.current_result = test_result.success
    log("itest '"..self.current_test.name.."': final assertion succeeded", "itest")
  else
    self.current_result = test_result.failure
    log("itest '"..self.current_test.name.."': final assertion failed: "..message, "itest")
  end
end

-- stop the current test and reset all values
-- this is different from ending the test properly via update
-- in particular, you won't be able to retrieve the test result
function integration_test_runner:stop()
  self.current_test = nil
  self.current_frame = 0.
  self._last_trigger_frame = 0.
  self._next_action_index = 1
  self.current_result = test_result.none
end

-- time trigger struct
time_trigger = new_class()

-- parameters
-- frames      int   number of frames to wait before running callback after last trigger (defined from float time in s)
function time_trigger:_init(time)
  self.frames = flr(time * fps)
end

function time_trigger:_tostring()
  return "time_trigger("..self.frames..")"
end

function time_trigger.__eq(lhs, rhs)
  return lhs.frames == rhs.frames
end

-- return true if the trigger condition is verified in this context
-- else return false
-- elapsed_frames     int   number of frames elapsed since the last trigger
function time_trigger:_check(elapsed_frames)
  if elapsed_frames >= self.frames then
    return true
  else
    return false
  end
end


-- scripted action struct
scripted_action = new_class()

-- parameters
-- trigger           trigger             trigger that will run the callback
-- callback          function            callback called on trigger
-- name              string | nil        optional name for debugging
function scripted_action:_init(trigger, callback, name)
  self.trigger = trigger
  self.callback = callback
  self.name = name or "unnamed"
end

function scripted_action:_tostring()
  return "[scripted_action ".."'"..self.name.."' ".."@ "..self.trigger.."]"
end


-- integration test class
integration_test = new_class()

-- parameters
-- name               string                         test name
-- setup              function                       setup callback - called on test start
-- action_sequence    [scripted_action]              sequence of scripted actions - run during test
-- final_assertion    function () => (bool, string)  assertion function that returns (assertion passed, error message if failed) - called on test end
function integration_test:_init(name)
  self.name = name
  self.setup = nil
  self.action_sequence = {}
  self.final_assertion = nil
end

function integration_test:_tostring()
  return "[integration_test '"..self.name.."']"
end

function integration_test:add_action(trigger, callback, name)
  assert(trigger ~= nil, "integration_test:add_action: passed trigger is nil")
  assert(callback ~= nil, "integration_test:add_action: passed callback is nil")
  add(self.action_sequence, scripted_action(trigger, callback, name))
end

-- return true if final assertion passes, (false, error message) else
function integration_test:_check_final_assertion()
  if self.final_assertion then
    return self.final_assertion()
  else
   return true
  end
end
