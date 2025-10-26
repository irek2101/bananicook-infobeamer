
gl.setup(1920, 1080)
util.no_globals()

local json = require "json"

-- Safe font loader
local function safe_font(path)
  local ok, res = pcall(resource.load_font, path)
  if ok then return res end
  print("font load failed:", path, res)
  return nil
end

local FONT_H1  = safe_font("fonts/DejaVuSans-Bold.ttf")
local FONT_CAT = FONT_H1
local FONT_ITM = safe_font("fonts/DejaVuSans.ttf")
local FONT_SUB = FONT_ITM
local FONT_FTR = FONT_ITM

local W, H = 1920, 1080

local function has_fonts() return FONT_H1 and FONT_ITM end

-- Colors
local palette = {
  {1.00,0.90,0.47},
  {0.47,0.86,1.00},
  {0.55,1.00,0.78},
  {1.00,0.67,0.47},
  {0.82,0.75,1.00},
  {0.71,1.00,0.47},
  {1.00,0.59,0.90},
  {1.00,0.82,0.37},
}
local WHITE = {0.98,0.98,0.98}
local MUTED = {0.67,0.71,0.75}

-- Config with defaults
local cfg = {
  duration_pierogi = 12,
  duration_default = 10,
  crossfade = 0.7,
  show_promo = true,
}

-- Static menu data
local DATA = {
  { key="promo",    title="PROMOCJE / NEW", items={{key="promo_golabki", name="Gołąbki", price="35 zł"}}, bg="assets/bg_1.jpg", promo=true },

  { key="pierogi",  title="Pierogi • 8 szt / 500 g", bg="assets/bg_6.jpg", items={
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

  { key="dania",    title="Dania mączne", bg="assets/bg_3.jpg", items={
      {key="dania_pielmieni", name="Pielmieni • 15 szt / 500 g", price="38 zł"},
      {key="dania_pyzy", name="Pyzy z mięsem • 6 szt / 500 g", price="36 zł"},
      {key="dania_knedle", name="Knedle ze śliwką • 6 szt / 500 g", price="36 zł"},
      {key="dania_leniwe", name="Leniwe • 500 g", price="33 zł"},
  }},

  { key="golabki",  title="Gołąbki", bg="assets/bg_2.jpg", items={
      {key="golabki_miesne_wege", name="Gołąbki mięsne lub wege • 2 szt / 500 g", price="35 zł"},
  }},

  { key="nalesniki",title="Naleśniki", bg="assets/bg_4.jpg", items={
      {key="nalesniki_twarog", name="Twaróg na słodko • 2 szt", price="20 zł"},
      {key="nalesniki_pieczarki_cheddar", name="Pieczarki + ziemniaki + ser cheddar • 2 szt", price="25 zł"},
  }},

  { key="krokiety", title="Krokiety", bg="assets/bg_5.jpg", items={
      {key="krokiety_mieso", name="Mięso • 3 szt", price="36 zł"},
      {key="krokiety_szpinak_feta", name="Szpinak i ser feta • 3 szt", price="36 zł"},
      {key="krokiety_pieczarki_cheddar", name="Pieczarki + ziemniaki + ser cheddar • 3 szt", price="36 zł"},
  }},

  { key="zupy",     title="Zupy", bg="assets/bg_7.jpg", items={
      {key="zupa_rosol_makaron", name="Rosół z makaronem", price="20 zł"},
      {key="zupa_rosol_pielmieni", name="Rosół z pielmieni", price="25 zł"},
      {key="zupa_barszcz_ukr", name="Barszcz ukraiński", price="27 zł"},
  }},

  { key="napoje",   title="Napoje", bg="assets/bg_8.jpg", items={
      {key="napoje_soki", name="Soki • 300 ml", price="9 zł"},
      {key="napoje_barszcz_czysty", name="Barszcz czysty • 300 ml", price="9 zł"},
      {key="napoje_kefir", name="Kefir • 300 ml", price="6 zł"},
  }},

  { key="dodatki",  title="Dodatki", bg="assets/bg_9.jpg", items={
      {key="dod_boczek", name="Boczek", price="10 zł"},
      {key="dod_cebulka", name="2× cebula", price="3 zł"},
      {key="dod_smietana", name="Śmietana", price="4 zł"},
      {key="dod_sztucce", name="Sztućce", price="1 zł"},
      {key="dod_opakowanie", name="Dodatkowe opakowanie", price="2 zł"},
  }},

  { key="specjal",  title="Specjał", bg="assets/bg_1.jpg", items={
      {key="specjal_panko", name="Pierogi smażone w panko • 6 szt", price="33–35 zł"},
  }},
}

-- defaults: all items ON
local defaults = { show_promo = true }
for _,cat in ipairs(DATA) do
  for _,it in ipairs(cat.items) do defaults[it.key] = true end
end

-- images
local function load_image(path)
  local ok, res = pcall(resource.load_image, path)
  if ok then return res end
  print("cannot load image", path, res)
  return nil
end
local LOGO = load_image("assets/logo.png")
local BG = {}
local function get_bg(path)
  if not path then return nil end
  if not BG[path] then BG[path] = load_image(path) end
  return BG[path]
end

-- playlist / config
local ORDER = {}
util.json_watch("playlist.json", function(p)
  ORDER = {}
  if p and p.slides then
    for i,s in ipairs(p.slides) do ORDER[i] = s.key or "pierogi" end
  else
    local i=1; for _,c in ipairs(DATA) do ORDER[i]=c.key; i=i+1 end
  end
end)

util.json_watch("config.json", function(c)
  c = c or {}
  for k,v in pairs(defaults) do if c[k]==nil then c[k]=v end end
  for k,v in pairs(c) do cfg[k]=v end
end)

-- helpers
local function color(c,a) gl.color(c[1], c[2], c[3], a or 1) end
local function text_w(font, size, txt) local w,h = font:measure(txt, size); return w end

local function draw_header()
  if not has_fonts() then return end
  color({1,0.88,0.51}); FONT_H1:write(80, 60, "BANANICOOK • MENU", 70, 1,1,1,1)
  gl.color(1,0.88,0.51,1); gl.rect(80,140, W-80,144)
end

local function draw_category(title, col)
  if not has_fonts() then return end
  color(col); FONT_CAT:write(100, 170, title, 56, 1,1,1,1)
  gl.color(col[1]*.7, col[2]*.7, col[3]*.7, 1)
  gl.rect(100, 235, W-100, 238)
end

local function write_price(price, y, col)
  if not has_fonts() then return end
  local size = 46
  local w = text_w(FONT_ITM, size, price)
  color(col); FONT_ITM:write(W-120-w, y, price, size, 1,1,1,1)
end

local function write_item(name, price, y, col, available)
  if not has_fonts() then return end
  local size = 46
  color(available and col or MUTED); FONT_ITM:write(120, y, name, size, 1,1,1,1)
  write_price(price, y, available and col or MUTED)
  if not available then
    local w = text_w(FONT_ITM, size, name)
    gl.color(1, .5, .5, 1); gl.rect(120, y+size*0.55, 120+w, y+size*0.58)
    -- label (prostokąt bez zaokrąglania)
    local lbl = "brak dziś"
    local lw = text_w(FONT_SUB, 34, lbl)
    gl.color(.24,.12,.12,1); gl.rect(120+w+16, y+8, 120+w+16+lw+20, y+size-6)
    gl.color(1,.63,.63,1); FONT_SUB:write(120+w+24, y+8, lbl, 34, 1,1,1,1)
  end
end

local function render_category(cat, clear_bg)
  if clear_bg ~= false then gl.clear(0.07,0.08,0.09,1) end
  local bg = get_bg(cat.bg); if bg then bg:draw(0,0,W,H, 0.45) end
  draw_header()
  local col = palette[(1 + math.floor(sys.now()*10)) % #palette + 1]
  draw_category(cat.title, col)
  local y = 250
  local idx = 1
  for _,it in ipairs(cat.items) do
    local show = cfg[it.key]; if show == nil then show = true end
    local c = palette[(idx-1)%#palette + 1]
    write_item(it.name, it.price, y, c, show)
    y = y + 74
    idx = idx + 1
  end
  if has_fonts() then
    gl.color(0.86,0.88,0.90,1)
    FONT_FTR:write(W/2-500, H-70, "1080p • Ceny w PLN • 'brak dziś' sterujesz w konfiguracji", 30, 1,1,1,1)
  end
  if LOGO then LOGO:draw(W-260, 40, W-60, 220, 1.0) end
end

local cur_idx, start_t = 1, sys.now()

function node.render()
  if #ORDER == 0 then
    local i=1; for _,c in ipairs(DATA) do ORDER[i]=c.key; i=i+1 end
  end

  local key = ORDER[cur_idx]
  if key == "promo" and not cfg.show_promo then
    cur_idx = cur_idx % #ORDER + 1
    start_t = sys.now()
    key = ORDER[cur_idx]
  end

  local cat = nil
  for _,c in ipairs(DATA) do if c.key==key then cat=c; break end end
  if not cat then cat = DATA[1] end

  local dur = cfg.duration_default or 10
  if key == "pierogi" then dur = cfg.duration_pierogi or dur end

  local t = sys.now() - start_t
  if t >= dur then
    cur_idx = cur_idx % #ORDER + 1
    start_t = sys.now()
    t = 0
  end

  local cf = cfg.crossfade or 0.7
  render_category(cat, true)
  local fade = math.max(0, t - (dur - cf)) / cf
  if fade > 0 then
    local nexti = cur_idx % #ORDER + 1
    local nextkey = ORDER[nexti]
    local nextcat = nil
    for _,c in ipairs(DATA) do if c.key==nextkey then nextcat=c; break end end
    gl.color(1,1,1, math.min(fade,1.0))
    render_category(nextcat, false)
  end
end
