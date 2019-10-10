-- this script is similar to tile_test_data, but has some parts
--  useful for itest in pico8, whereas tile_test_data is only for busted utests/itests
-- it is used by tilemap for the dsl
--#if busted
local tile_test_data = require("test_data/tile_test_data")
--#endif

tile_symbol_to_ids = {
  ['.']  = 0,   -- empty
  ['#']  = 64,  -- full tile
  ['/']  = 65,  -- ascending slope 45
  ['\\'] = 66,  -- descending slope 45
  ['<']  = 67,  -- ascending slope 22.5
}

-- for itests that need map setup, we exceptionally not teardown
--  the map since we would need to store a backup of the original map
--  and we don't care, since each itest will build its own mock map
function setup_map_data()
--#if busted
  tile_test_data.setup()
--#endif
end

function teardown_map_data()
--#if busted
  tile_test_data.teardown()
--#endif
end