local args = {...}
local expect = require("cc.expect").expect
local fuzzy = require("fuzzy")
local dfpwm = require("cc.audio.dfpwm")
expect(1,args[1],"string")
expect(2,args[2],"string","nil") args[2] = args[2] or "text"
local links = assert(http.get("https://github.com/Apethesis/combook/raw/main/links.srt"), "Failed to download link list, perhaps you don't have internet?") links = links.readAll()
local ltbl = textutils.unserialize(links)
local res
for k,v in pairs(ltbl[args[2]]) do
    local fuzrez = fuzzy.fuzzy_match(k,args[1])
    if fuzrez == 100 then
        if args[2] == "text" then
            res = assert(http.get(v), "Failed to download book, perhaps you don't have internet?")
        else
            res = assert(http.get(v,nil,true), "Failed to download book, perhaps you don't have internet?")
        end
        break
    elseif fuzrez >= 50 then
        print("Did you mean "..k.." (y/n)")
        local r = string.lower(read())
        if r == "y" then
            if args[2] == "text" then
                res = assert(http.get(v), "Failed to download book, perhaps you don't have internet?")
            else
                res = assert(http.get(v,nil,true), "Failed to download book, perhaps you don't have internet?")
            end
            break
        else
            error("That book does not exist.",0)
        end
    else
        error("That book does not exist.",0)
    end
end
if args[2] == "text" then
    print("Press 1 to exit program.")
    sleep(1)
    print(res.readAll())
    while true do
        local ex = {os.pullEvent("key")}
        if ex[2] == keys.one then
            os.queueEvent("terminate")
        end
    end
elseif args[2] == "audio" then
    -- Code here mostly copied from Musicify 2 (by EmmaKnijn#0043)
    local even = true
    local decoder = dfpwm.make_decoder()
    local speaker = assert(peripheral.find("speaker"), "Speaker not attached.")
    while true do
        local chunk = res.read(16 * 1024) if not chunk then break end
        local buffer = decoder(tostring(chunk))
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
        if even then
            even = false
        else
            even = true
        end
    end
    res.close()
else
    print("The mode you entered is currently supported.")
end