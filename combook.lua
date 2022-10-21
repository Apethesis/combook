local args = {...}
local expect = require("cc.expect").expect
local fuzzy = require("fuzzy")
expect(1,args[1],"string")
expect(2,args[2],"string","nil") args[2] = args[2] or "text"
local links = assert(http.get("https://github.com/Apethesis/combook/raw/main/links.srt"), "Failed to download link list, perhaps you don't have internet?") links = links.readAll()
local ltbl = textutils.unserialize(links)
local res
for k,v in pairs(ltbl[args[2]]) do
    local fuzrez = fuzzy.fuzzy_match(k,args[1])
    if fuzrez == 100 then
        res = assert(http.get(v), "Failed to download book, perhaps you don't have internet?")
    elseif fuzrez >= 50 then
        print("Did you mean "..k.." (y/n)")
        local r = string.lower(read())
        if r == "y" then
            res = assert(http.get(v), "Failed to download book, perhaps you don't have internet?")
        else
            error("That book does not exist.",0)
        end
    else
        error("That book does not exist.",0)
    end
end
print("Press 1 to exit program.")
sleep(1)
print(res.readAll())
while true do
    local ex = {os.pullEvent("key")}
    if ex[2] == keys.one then
        os.queueEvent("terminate")
    end
end
