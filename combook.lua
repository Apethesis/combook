local args = {...}
local expect = require("cc.expect").expect
expect(1,args[1],"string")
expect(2,args[2],"string","nil") args[2] = args[2] or "text"
