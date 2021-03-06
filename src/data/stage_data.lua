local audio = require("resources/audio")

return {

  -- common data

  -- delay between stage enter and showing stage title (s)
  show_stage_title_delay = 4.0,
  -- delay between reaching goal and going back to title menu (s)
  back_to_titlemenu_delay = 1.0,
  -- duration of bgm fade out after reaching goal (s)
  bgm_fade_out_duration = 1.0,

  -- stage-specific data, per id

  for_stage = {

    [1] = {
      -- stage title
      title = "angel island",

      width = 128,
      height = 32,

      -- where the player character spawns on stage start
      spawn_location = location(3, 24),

      -- the x to reach to finish the stage
      goal_x = 1024,  -- 128 tiles (full tilemap width, goal is at stage right edge unlike classic Sonic)

      -- bgm id
      bgm_id = audio.music_pattern_ids.green_hill
    }

  }

}
