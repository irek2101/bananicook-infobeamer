
gl.setup(1920, 1080)

function node.render()
  -- navy background
  gl.clear(0.05, 0.08, 0.18, 1)
  -- big white rectangle in the middle
  gl.color(1,1,1,1)
  local margin = 200
  gl.rect(margin, margin, 1920 - margin, 1080 - margin)
end
