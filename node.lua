
gl.setup(3840, 2160)
util.no_globals()

local json = require "json"
local slides = {}
local current = 1
local start = sys.now()
local crossfade = 0.8

local function load_playlist()
    local data = json.decode(resource.load_file("playlist.json"))
    slides = {}
    crossfade = data.crossfade or 0.7
    for i, s in ipairs(data.slides) do
        slides[i] = {
            img = resource.load_image(s.file),
            duration = s.duration or 10
        }
    end
    current = 1
    start = sys.now()
end

node.event("content_update", function(filename, file)
    if filename == "playlist.json" then
        load_playlist()
    end
end)

function node.render()
    if #slides == 0 then return end
    local t = sys.now() - start
    local cur = slides[current]
    local nexti = current % #slides + 1
    local nxt = slides[nexti]
    local fade = math.max(0, t - (cur.duration - crossfade)) / crossfade
    if fade > 1 then
        current = nexti
        start = sys.now()
        cur = slides[current]
        nexti = current % #slides + 1
        nxt = slides[nexti]
        fade = 0
    end
    cur.img:draw(0,0,WIDTH,HEIGHT, 1.0)
    if fade > 0 then
        nxt.img:draw(0,0,WIDTH,HEIGHT, fade)
    end
end

load_playlist()
