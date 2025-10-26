
gl.setup(3840, 2160)
util.no_globals()

local json = require "json"
local config = {
    duration_pierogi = 12,
    duration_default = 10,
    crossfade = 0.8,
    show_wisnia = false,
    show_leniwe = false,
}
local state = { slides = {}, cur = 1, start = sys.now() }
local playlist = {}

local function load_image_safe(path)
    local ok, res = pcall(resource.load_image, path)
    if ok then return res end
    print("cannot load image", path, res)
    return nil
end

local function build_slides()
    state.slides = {}
    for i, s in ipairs(playlist.slides or {}) do
        local path = s.file
        local dur = config.duration_default or 10
        if s.key == "pierogi" then
            path = (config.show_wisnia and s.on) or s.off
            dur = config.duration_pierogi or dur
        elseif s.key == "dania_maczne" then
            path = (config.show_leniwe and s.on) or s.off
        end
        local img = load_image_safe(path)
        if img then table.insert(state.slides, {img=img, duration=dur}) end
    end
    state.cur = 1
    state.start = sys.now()
end

util.json_watch("playlist.json", function(data)
    playlist = data or {}
    build_slides()
end)

util.json_watch("config.json", function(cfg)
    for k,v in pairs(cfg or {}) do config[k]=v end
    build_slides()
end)

function node.render()
    if #state.slides == 0 then return end
    local now = sys.now()
    local cur = state.slides[state.cur]
    local t = now - state.start
    local cf = config.crossfade or 0.8

    if t >= cur.duration then
        state.cur = state.cur % #state.slides + 1
        state.start = now
        cur = state.slides[state.cur]
        t = 0
    end

    local nexti = state.cur % #state.slides + 1
    local nxt = state.slides[nexti]
    local fade = math.max(0, t - (cur.duration - cf)) / cf

    cur.img:draw(0,0,WIDTH,HEIGHT, 1.0)
    if fade > 0 and nxt then
        nxt.img:draw(0,0,WIDTH,HEIGHT, math.min(fade, 1.0))
    end
end
