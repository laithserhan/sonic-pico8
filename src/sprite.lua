require("math")

-- sprite class
sprite_data = {}
sprite_data.__index = sprite_data

setmetatable(sprite_data, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

-- id_loc   sprite_id_location                      sprite location on the spritesheet
-- span     tile_vector         tile_vector(1, 1)   sprite span on the spritesheet
-- pivot    vector              (0, 0)              reference center to draw (top-left is (0 ,0))
function sprite_data:_init(id_loc, span, pivot)
  self.id_loc = id_loc
  self.span = span or tile_vector(1, 1)
  self.pivot = pivot or vector(0, 0)
end

function sprite_data:_tostring()
  return "sprite_data("..(self.id_loc:_tostring())..", "..(self.span:_tostring())..", "..
    (self.pivot:_tostring())..")"
end

function sprite_data.__eq(lhs, rhs)
  return lhs.id_loc == rhs.id_loc and
    lhs.span == rhs.span and
    lhs.pivot == rhs.pivot
end

-- draw this sprite at position, optionally flipped
function sprite_data:render(position, flip_x, flip_y)
  local draw_pos = position - self.pivot
  spr(self.id_loc:to_sprite_id(),
    draw_pos.x, draw_pos.y,
    self.span.i, self.span.j,
    flip_x, flip_y)
end
