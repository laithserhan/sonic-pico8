local lu = require("game/luaunit")

-- lu.LuaUnit.run()

require("engine/core/math")

-- caveats

-- syntax error: malformed number near 27..d
-- this error will block the output stream, getting picotest stuck!
-- printh(27..vector(11, 45))  -- incorrect
-- correct:
printh("27"..vector(11, 45))
-- or
-- printh(tostr(27)..vector(11, 45))