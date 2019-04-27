require("engine/test/bustedhelper")
local sprite_data = require("engine/render/sprite_data")
local animated_sprite_data = require("engine/render/animated_sprite_data")
local animated_sprite = require("engine/render/animated_sprite")

describe('animated_sprite', function ()

  local spr_data1 = sprite_data(sprite_id_location(1, 0), tile_vector(1, 2), vector(4, 6))
  local spr_data2 = sprite_data(sprite_id_location(2, 0), tile_vector(1, 2), vector(4, 6))
  local anim_spr_data = animated_sprite_data({spr_data1, spr_data2}, 10, true)
  local anim_spr_data_no_loop = animated_sprite_data({spr_data1, spr_data2}, 10, false)
  local anim_spr_data_table = {
    loop = anim_spr_data,
    no_loop = anim_spr_data_no_loop
  }

  describe('_init', function ()
    it('should init an animated sprite with data, automatically playing from step 1, frame 0', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      assert.are_same({anim_spr_data_table, false, nil, nil, nil},
        {anim_spr.data_table, anim_spr.playing, anim_spr.current_anim_key, anim_spr.current_step, anim_spr.local_frame})
    end)
  end)

  describe('_tostring', function ()

    it('should return a string describing data, current step and local frame', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.playing = true
      anim_spr.current_anim_key = "idle"
      anim_spr.current_step = 2
      anim_spr.local_frame = 5
      assert.are_equal("animated_sprite({loop = animated_sprite_data([2 sprites], 10, true), no_loop = animated_sprite_data([2 sprites], 10, false)}, true, idle, 2, 5)", anim_spr:_tostring())
    end)

  end)

  describe('play', function ()

    it('should assert if the anim_key is not found', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)

      assert.has_error(function() anim_spr:play("unknown") end,
        "animated_sprite:play: self.data_table['unknown'] doesn't exist")
    end)

    it('should start playing a new anim from the first step, first frame', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)

      anim_spr:play("loop")

      assert.are_same({true, "loop", 1, 0},
        {anim_spr.playing, anim_spr.current_anim_key, anim_spr.current_step, anim_spr.local_frame})
    end)

    it('should start playing the current anim from the first step, first frame if passing the current anim and from_start is true', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.playing = true
      anim_spr.current_anim_key = "loop"
      anim_spr.current_step = 2
      anim_spr.local_frame = 5

      anim_spr:play("loop", true)

      assert.are_same({true, "loop", 1, 0},
        {anim_spr.playing, anim_spr.current_anim_key, anim_spr.current_step, anim_spr.local_frame})
    end)

    it('should continue playing the current anim if passing the current anim and from_start is false', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.playing = true
      anim_spr.current_anim_key = "no_loop"
      anim_spr.current_step = 2
      anim_spr.local_frame = 5

      anim_spr:play("no_loop", false)

      assert.are_same({true, "no_loop", 2, 5},
        {anim_spr.playing, anim_spr.current_anim_key, anim_spr.current_step, anim_spr.local_frame})
    end)

    it('should not resume the current anim if paused, passing the current anim and from_start is false', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.playing = false
      anim_spr.current_anim_key = "no_loop"
      anim_spr.current_step = 2
      anim_spr.local_frame = 5

      anim_spr:play("no_loop", false)

      assert.are_same({false, "no_loop", 2, 5},
        {anim_spr.playing, anim_spr.current_anim_key, anim_spr.current_step, anim_spr.local_frame})
    end)

  end)

  describe('update', function ()

    it('should do nothing when not playing', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.playing = false
      anim_spr.current_step = 9
      anim_spr.local_frame = 99

      anim_spr:update()

      assert.are_same({false, 9, 99},
        {anim_spr.playing, anim_spr.current_step, anim_spr.local_frame})
    end)

    it('should increment the local frame if under the animation step_frames', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.playing = true
      anim_spr.current_anim_key = "loop"
      anim_spr.current_step = 1
      anim_spr.local_frame = 8  -- data.step_frames is 10, so frames play from 0 to 9

      anim_spr:update()

      assert.are_same({1, 9},
        {anim_spr.current_step, anim_spr.local_frame})
    end)

    it('should reset local frame and enter next step when step_frames is reached', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.playing = true
      anim_spr.current_anim_key = "loop"
      anim_spr.current_step = 1
      anim_spr.local_frame = 9  -- data.step_frames - 1

      anim_spr:update()

      assert.are_same({2, 0},
        {anim_spr.current_step, anim_spr.local_frame})
    end)

    it('should continue playing from the start when looping and end of animation has been reached', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.playing = true
      anim_spr.current_anim_key = "loop"
      anim_spr.current_step = 2
      anim_spr.local_frame = 9  -- data.step_frames - 1

      anim_spr:update()

      assert.are_same({true, 1, 0},
        {anim_spr.playing, anim_spr.current_step, anim_spr.local_frame})
    end)

    it('should stop playing when not looping and end of animation has been reached', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.current_anim_key = "no_loop"
      anim_spr.playing = true
      anim_spr.current_step = 2
      anim_spr.local_frame = 9  -- data.step_frames - 1

      anim_spr:update()

      assert.are_same({false, 2, 9},
        {anim_spr.playing, anim_spr.current_step, anim_spr.local_frame})
    end)

  end)

  describe('render', function ()

    setup(function ()
      sprite_data_render = stub(sprite_data, "render")
    end)

    teardown(function ()
      sprite_data_render:revert()
    end)

    after_each(function ()
      sprite_data_render:clear()
    end)

    it('should not render the sprite when not playing', function ()
      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.current_anim_key = nil

      anim_spr:render(vector(41, 80), false, true)

      assert.spy(sprite_data_render).was_called(0)
    end)

    it('should render the sprite for current animation and step, with passed arguments', function ()

      local anim_spr = animated_sprite(anim_spr_data_table)
      anim_spr.current_anim_key = "no_loop"
      anim_spr.current_step = 2
      anim_spr.local_frame = 5

      anim_spr:render(vector(41, 80), false, true)

      assert.spy(sprite_data_render).was_called(1)
      assert.spy(sprite_data_render).was_called_with(match.ref(spr_data2), vector(41, 80), false, true)
    end)

  end)

end)