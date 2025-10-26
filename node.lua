
gl.setup(3840, 2160)
util.no_globals()

local json = require "json"

-- fonts
local FONT_H1  = resource.load_font("fonts/DejaVuSans-Bold.ttf")
local FONT_CAT = resource.load_font("fonts/DejaVuSans-Bold.ttf")
local FONT_ITM = resource.load_font("fonts/DejaVuSans.ttf")
local FONT_SUB = resource.load_font("fonts/DejaVuSans.ttf")
local FONT_FTR = resource.load_font("fonts/DejaVuSans.ttf")

local W, H = 3840, 2160

-- palette
local palette = {
    {255/255,230/255,120/255},
    {120/255,220/255,255/255},
    {140/255,255/255,200/255},
    {255/255,170/255,120/255},
    {210/255,190/255,255/255},
    {180/255,255/255,120/255},
    {255/255,150/255,230/255},
    {255/255,210/255, 95/255},
}
local WHITE = {250/255,250/255,250/255}
local MUTED = {170/255,180/255,190/255}

local cfg = {
  duration_pierogi = 12,
  duration_default = 10,
  crossfade = 0.8,
  -- item switches will be merged in from config.json
  show_promo = true,
}

-- static data (names+prices)
local DATA = {
  { key="promo",    title="PROMOCJE / NEW", items={{name="Gołąbki", price="35 zł"}}, bg="assets/photo_1.jpg", promo=true },

  { key="pierogi",  title="Pierogi • 8 szt / 500 g", bg="assets/photo_6.jpg", items={
      {key="pierogi_polskie", name="Polskie", price="33 zł"},
      {key="pierogi_mieso", name="Mięso", price="35 zł"},
      {key="pierogi_szpinak_feta", name="Szpinak z fetą", price="35 zł"},
      {key="pierogi_losos", name="Łosoś", price="38 zł"},
      {key="pierogi_pieczarki", name="Pieczarki z ziemniakami", price="35 zł"},
      {key="pierogi_kapusta_grzyby", name="Kapusta z grzybami", price="39 zł"},
      {key="pierogi_wisnia", name="Wiśnia", price="37 zł"},
      {key="pierogi_borowka", name="Borówka", price="37 zł"},
      {key="pierogi_malina", name="Malina", price="39 zł"},
      {key="pierogi_twarog", name="Twaróg", price="33 zł"},
  }},

  { key="dania",    title="Dania mączne", bg="assets/photo_3.jpg", items={
      {key="dania_pielmieni", name="Pielmieni • 15 szt / 500 g", price="38 zł"},
      {key="dania_pyzy", name="Pyzy z mięsem • 6 szt / 500 g", price="36 zł"},
      {key="dania_knedle", name="Knedle ze śliwką • 6 szt / 500 g", price="36 zł"},
      {key="dania_leniwe", name="Leniwe • 500 g", price="33 zł"},
  }},

  { key="golabki",  title="Gołąbki", bg="assets/photo_2.jpg", items={
      {key="golabki_miesne_wege", name="Gołąbki mięsne lub wege • 2 szt / 500 g", price="35 zł"},
  }},

  { key="nalesniki",title="Naleśniki", bg="assets/photo_4.jpg", items={
      {key="nalesniki_twarog", name="Twaróg na słodko • 2 szt", price="20 zł"},
      {key="nalesniki_pieczarki_cheddar", name="Pieczarki + ziemniaki + ser cheddar • 2 szt", price="25 zł"},
  }},

  { key="krokiety", title="Krokiety", bg="assets/photo_5.jpg", items={
      {key="krokiety_mieso", name="Mięso • 3 szt", price="36 zł"},
      {key="krokiety_szpinak_feta", name="Szpinak i ser feta • 3 szt", price="36 zł"},
      {key="krokiety_pieczarki_cheddar", name="Pieczarki + ziemniaki + ser cheddar • 3 szt", price="36 zł"},
  }},

  { key="zupy",     title="Zupy", bg="assets/photo_7.jpg", items={
      {key="zupa_rosol_makaron", name="Rosół z makaronem", price="20 zł"},
      {key="zupa_rosol_pielmieni", name="Rosół z pielmieni", price="25 zł"},
      {key="zupa_barszcz_ukr", name="Barszcz ukraiński", price="27 zł"},
  }},

  { key="napoje",   title="Napoje", bg="assets/photo_8.jpg", items={
      {key="napoje_soki", name="Soki • 300 ml", price="9 zł"},
      {key="napoje_barszcz_czysty", name="Barszcz czysty • 300 ml", price="9 zł"},
      {key="napoje_kefir", name="Kefir • 300 ml", price="6 zł"},
  }},

  { key="dodatki",  title="Dodatki", bg="assets/photo_9.jpg", items={
      {key="dod_boczek", name="Boczek", price="10 zł"},
      {key="dod_cebulka", name="2× cebula", price="3 zł"},
      {key="dod_smietana", name="Śmietana", price="4 zł"},
      {key="dod_sztucce", name="Sztućce", price="1 zł"},
      {key="dod_opakowanie", name="Dodatkowe opakowanie", price="2 zł"},
  }},

  { key="specjal",  title="Specjał", bg="assets/photo_1.jpg", items={
      {key="specjal_panko", name="Pierogi smażone w panko • 6 szt", price="33–35 zł"},
  }},
}

-- derive default ON states (true)
local defaults = {}
for _,cat in ipairs(DATA) do
  for _,it in ipairs(cat.items) do
    defaults[it.key] = true
  end
end
defaults.show_promo = true

-- logo
local function load_image(path)
    local ok, res = pcall(resource.load_image, path)
    if ok then return res end
    print("cannot load image", path, res)
    return nil
end

local LOGO = load_image("assets/logo.png")

-- background cache
local BG = {}
local function get_bg(path)
    if not path then return nil end
    if not BG[path] then BG[path] = load_image(path) end
    return BG[path]
end

-- config watchers
util.json_watch("config.json", function(c)
    if not c then return end
    for k,v in pairs(defaults) do
        if c[k] == nil then c[k] = v end
    end
    cfg = setmetatable(c, { __index = cfg })
end)

-- playlist (order)
local ORDER = {}
util.json_watch("playlist.json", function(p)
    ORDER = {}
    if not p or not p.slides then
        -- fallback order
        for i=1,#DATA do ORDER[i] = DATA[i].key end
    else
        for i,s in ipairs(p.slides) do
            ORDER[i] = s.key or s.file or "pierogi"
        end
    end
end)

-- draw helpers
local function color(c) gl.color(c[1], c[2], c[3], 1) end
local function draw_header()
    color({1, 225/255, 130/255})
    FONT_H1:write(140, 120, "BANANICOOK • MENU", 110, 1,1,1,1)
    gl.rect(140, 240, W-140, 246)
end
local function draw_category(title, col)
    color(col); FONT_CAT:write(160, 280, title, 90, 1,1,1,1)
    color({col[1]*.7,col[2]*.7,col[3]*.7}); gl.rect(160, 370, W-160, 374)
end
local function text_width(font, size, txt)
    local w, h = font:measure(txt, size)
    return w
end
local function write_price(price, y, col)
    color(col)
    local size = 72
    local w = text_width(FONT_ITM, size, price)
    FONT_ITM:write(W-180-w, y, price, size, 1,1,1,1)
end
local function write_item(name, price, y, col, available)
    local size = 72
    color(available and col or MUTED)
    FONT_ITM:write(190, y, name, size, 1,1,1,1)
    write_price(price, y, available and col or MUTED)
    if not available then
        -- strike-through
        local w = text_width(FONT_ITM, size, name)
        color({1, .5, .5}); gl.rect(190, y+size*0.55, 190+w, y+size*0.58)
        -- label
        local lbl = "brak dziś"
        local lw = text_width(FONT_SUB, 46, lbl)
        color({.24,.12,.12}); gl.rounded_rect(190+w+24, y+12, 190+w+24+lw+28, y+size-10, 20)
        color({1, .63, .63}); FONT_SUB:write(190+w+38, y+12, lbl, 46, 1,1,1,1)
    end
end

-- slide renderer
local function render_category(cat)
    -- background
    gl.clear(0.07,0.08,0.09,1)
    local bg = get_bg(cat.bg)
    if bg then bg:draw(0,0,W,H, 0.45) end
    draw_header()
    local col = palette[(math.random(#palette))]
    draw_category(cat.title, col)
    local y = 390
    local idx = 1
    for _,it in ipairs(cat.items) do
        local show = cfg[it.key]
        if show == nil then show = true end
        local c = palette[(idx-1)%#palette + 1]
        write_item(it.name, it.price, y, c, show)
        y = y + 96
        idx = idx + 1
    end
    color({0.86,0.88,0.90}); FONT_FTR:write(W/2-700, H-120, "4K UHD • Ceny w PLN • Pozycje 'brak dziś' sterujesz w konfiguracji", 40, 1,1,1,1)

    -- logo
    if LOGO then LOGO:draw(W-420, 80, W-100, 300, 1.0) end
end

-- state for crossfade
local cur_idx, start = 1, sys.now()
math.randomseed(os.time())

function node.render()
    if #ORDER == 0 then
        -- build default order if not ready
        for i=1,#DATA do ORDER[i] = DATA[i].key end
    end

    local key = ORDER[cur_idx]
    local cat = nil
    for _,c in ipairs(DATA) do if c.key == key then cat = c break end end
    if not cat then cat = DATA[1] end

    local dur = cfg.duration_default or 10
    if key == "pierogi" then dur = cfg.duration_pierogi or dur end

    local t = sys.now() - start
    if t >= dur then
        cur_idx = cur_idx % #ORDER + 1
        start = sys.now()
        t = 0
    end

    -- fade to next
    local cf = cfg.crossfade or 0.8
    render_category(cat)
    local fade = math.max(0, t - (dur - cf)) / cf
    if fade > 0 then
        local nexti = cur_idx % #ORDER + 1
        local nextkey = ORDER[nexti]
        local nextcat = nil
        for _,c in ipairs(DATA) do if c.key == nextkey then nextcat = c break end end
        if not nextcat then nextcat = DATA[1] end
        gl.pushMatrix()
        gl.color(1,1,1, math.min(fade,1.0))
        render_category(nextcat)
        gl.popMatrix()
    end
end
