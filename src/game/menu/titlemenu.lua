require("engine/render/color")
local flow = require("engine/application/flow")
local input = require("engine/input/input")
local ui = require("engine/ui/ui")

local titlemenu = {}

-- game state
local titlemenustate = {
  type = gamestate_type.titlemenu,

  -- parameters

  -- number of items in the menu
  items_count = 2,

  -- state vars

  -- current cursor index (0: start, 1: credits)
  current_cursor_index = 0,
}

function titlemenustate:on_enter()
  ui.show_mouse = true
  self.current_cursor_index = 0
end

function titlemenustate:on_exit()
  ui.show_mouse = false
end

function titlemenustate:update()
  if btnp(input.button_ids.up) then
    self:move_cursor_up()
  elseif btnp(input.button_ids.down) then
    self:move_cursor_down()
  elseif btnp(input.button_ids.x) then
    self:confirm_current_selection()
  end
end

function titlemenustate:render()
  color(colors.white)
  print("start", 4*11, 6*12)
  print("credits", 4*11, 6*13)
  print(">", 4*10, 6*(12+self.current_cursor_index))
end

function titlemenustate:move_cursor_up()
  -- move cursor up, clamped
  self.current_cursor_index = max(self.current_cursor_index - 1, 0)
end

function titlemenustate:move_cursor_down()
  -- move cursor down, clamped
  self.current_cursor_index = min(self.current_cursor_index + 1, self.items_count - 1)
end

function titlemenustate:confirm_current_selection()
  if self.current_cursor_index == 0 then
    flow:query_gamestate_type(gamestate_type.stage)
  else  -- current_cursor_index == 1
    flow:query_gamestate_type(gamestate_type.credits)
  end
end

-- export
titlemenu.state = titlemenustate
return titlemenu
