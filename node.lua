
gl.setup(1920, 1080)

-- white texture
local white = resource.create_colored_texture(1,1,1,1)
local red   = resource.create_colored_texture(1,0,0,1)

function node.render()
  gl.clear(0.05, 0.08, 0.18, 1) -- navy
  -- big white box
  white:draw(200, 200, 1720, 880, 1.0)
  -- small red corner marker (should be clearly visible)
  red:draw(40, 40, 140, 100, 1.0)
end
