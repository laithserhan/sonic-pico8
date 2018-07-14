require("engine/core/math")
-- require("engine/ui/ui")

button_ids = {
  left = 0,
  right = 1,
  up = 2,
  down = 3,
  o = 4,
  x = 5
}

button_states = {
  released = 0,
  just_pressed = 1,
  pressed = 2,
  just_released = 3
}

input_modes = {
  native = 0,     -- use pico8 input (or pico8api for utests)
  simulated = 1   -- use hijacking simulated input
}

local input = {
  mode = input_modes.native,
  mouse_active = false         -- is the mouse specifically active? only useful when active is true
}

local mouse_devkit_address = 0x5f2d
local cursor_x_stat = 32
local cursor_y_stat = 33



-- generate the initial player_button_states table for a player
function generate_initial_button_states()
  return {
    [button_ids.left] = button_states.released,
    [button_ids.right] = button_states.released,
    [button_ids.up] = button_states.released,
    [button_ids.down] = button_states.released,
    [button_ids.o] = button_states.released,
    [button_ids.x] = button_states.released
  }
end

-- player_button_states tables, indexed by played ID
input.players_button_states = {
  [0] = generate_initial_button_states(),
  [1] = generate_initial_button_states()
}

-- activate mouse devkit
function input:toggle_mouse(active)
  if active == nil then
    -- no argument => reverse value
    active = not self.mouse_active
  end
  value = active and 1 or 0
  self.mouse_active = active
  poke(mouse_devkit_address, value)
end

-- return the current cursor position
function input.get_cursor_position()
  return vector(stat(cursor_x_stat), stat(cursor_y_stat))
end

-- return a button state for player id (0 by default)
function input:get_button_state(button_id, player_id)
  assert(type(button_id) == "number" and button_id >= 0 and button_id < 6, "input:get_button_state: button_id ("..tostr(button_id)..") is not between 0 and 5")
  player_id = player_id or 0
  return self.players_button_states[player_id][button_id]
end

-- return true if button is released or just released for player id (0 by default)
function input:is_up(button_id, player_id)
  local button_state = self:get_button_state(button_id, player_id)
  return button_state == button_states.released or button_state == button_states.just_released
end

-- return true if button is pressed or just pressed for player id (0 by default)
function input:is_down(button_id, player_id)
  return not self:is_up(button_id, player_id)
end

-- return true if button is just released for player id (0 by default)
function input:is_just_released(button_id, player_id)
  local button_state = self:get_button_state(button_id, player_id)
  return button_state == button_states.just_released
end

-- return true if button is just pressed for player id (0 by default)
function input:is_just_pressed(button_id, player_id)
  local button_state = self:get_button_state(button_id, player_id)
  return button_state == button_states.just_pressed
end

-- update button states for each player based on previous and current button states
function input:process_players_inputs()
  for player_id = 0, 1 do
    self:_process_player_inputs(player_id)
  end
end

-- update button states for a specific player based on previous and current button states
function input:_process_player_inputs(player_id)
  local player_button_states = self.players_button_states[player_id]
  for button_id, _ in pairs(player_button_states) do
    -- note that btnp should always return true when just pressed, but the reverse is not true because pico8
    -- has a repeat input feature, that we are not reproducing
    assert(player_button_states[button_id] ~= button_states.released and player_button_states[button_id] ~= button_states.just_released or
      not btn(button_id, player_id) or btnp(button_id, player_id), "input:_update_button_state: button "..button_id.." was released and is now pressed, but btnp("..button_id..") returns false")
    player_button_states[button_id] = self:_compute_next_button_state(player_button_states[button_id], btn(button_id, player_id))
  end
end

-- return the next button state of a button based on its previous dynamic state (stored) and current static state (pico8 input)
function input:_compute_next_button_state(previous_button_state, is_down)
  if previous_button_state == button_states.released then
    if is_down then
      return button_states.just_pressed
    end
  elseif previous_button_state == button_states.just_pressed then
    if is_down then
      return button_states.pressed
    else
      return button_states.just_released
    end
  elseif previous_button_state == button_states.pressed then
    if not is_down then
      return button_states.just_released
    end
  else  -- previous_button_state == button_states.just_released
    if is_down then
      return button_states.just_pressed
    else
      return button_states.released
    end
  end

  -- no change detected
  return previous_button_state
end

return input
