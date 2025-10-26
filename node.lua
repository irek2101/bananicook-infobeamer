
gl.setup(1920, 1080)
-- Minimalny node diagnostyczny: granatowe tło + biały ruchomy pasek
local t0 = sys.now()
function node.render()
  local t = sys.now() - t0
  gl.clear(0.05, 0.08, 0.18, 1)
  local w = 200 + 300*math.abs(math.sin(t*0.8))
  gl.color(1,1,1,1)
  gl.rect(100, 480, 100 + w, 600)
end
