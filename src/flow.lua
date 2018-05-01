-- global enums
gamestate_type = {
 titlemenu = 1,
 credits = 2,
 stage = 3,
}

local flow = {
 -- parameters
 gamestates = {},

 -- state vars
 current_gamestate = nil,
 next_gamestate = nil,
}

-- add a gamestate
function flow:add_gamestate(gamestate)
 assert(gamestate ~= nil, "passed gamestate is nil")
 self.gamestates[gamestate.type] = gamestate
 printh("[flow] added gamestate "..gamestate.type)
end

-- query a new gamestate
function flow:query_gamestate_type(gamestate_type)
 assert(current_gamestate == nil or current_gamestate.type ~= gamestate_type, "[flow] cannot query the current gamestate type "..gamestate_type.." again")
 self.next_gamestate = self.gamestates[gamestate_type]
 assert(self.next_gamestate ~= nil, "[flow] gamestate type "..gamestate_type.." has not been added to the flow gamestates")
end

-- check if a new gamestate was queried, and enter it if so
function flow:check_next_gamestate(gamestate_type)
 if self.next_gamestate then
  self:change_gamestate(self.next_gamestate)
  self.next_gamestate = nil
 end
end

-- enter a new gamestate
function flow:change_gamestate(gamestate)
 self.current_gamestate = gamestate
 self.current_gamestate.on_enter()
 printh("[flow] entered gamestate "..gamestate.type)
end

-- export
return flow
