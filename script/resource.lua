local D2D = require("draw2d")

local GRID = 16

local res = {
  char = nil,
  tile = nil,
}

function res.toUV(x, y, w, h, iw, ih)
  return {
    u1 = x/iw,
    u2 = (x+w)/iw,
    v1 = y/ih,
    v2 = (y+h)/ih,
  }
end

res.playerFrames = {
  down = {},
  left = {},
  right = {},
  up = {},
}

res.tileUVs = {}

for j=0,15,1 do
  for i=0,2,1 do
    table.insert(res.tileUVs, res.toUV(j*GRID, i*GRID, 16, 16, 256, 64))
  end
end

function res:loadTextures() 
  self.char = D2D.loadTexture("host:characters.tga", 256, 64)
  self.tile = D2D.loadTexture("host:tiles.tga", 256, 64)
end

return res
