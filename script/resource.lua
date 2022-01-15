local D2D = require("draw2d")
local VRAM = require("vram")

local GRID = 32

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

function uv(x, y)
  return res.toUV(x, y, 16, 16, 256, 64)
end

res.playerFrames = {
  down = {
    uv(0, 0),
    uv(0, 16),
    uv(0, 0),
    uv(0, 32),
  },
  up = {
    uv(16, 0),
    uv(16, 16),
    uv(16, 0),
    uv(16, 32),
  },
  right = {
    uv(32, 0),
    uv(32, 16),
    uv(32, 0),
    uv(32, 32),
  },
  left = {
    uv(48, 0),
    uv(48, 16),
    uv(48, 0),
    uv(48, 32),
  },
}

function uv(x, y)
  return res.toUV(x, y, 28, 14, 256, 64)
end

res.batFrames = {
  uv(64, 24),
  uv(92, 24),
}

res.tileUVs = {}

for j=0,8,1 do
  for i=0,8,1 do
    table.insert(res.tileUVs, res.toUV(i*GRID, j*GRID, 32, 32, 256, 256))
  end
end

function res:loadTextures() 
  self.char = D2D.loadTexture("host:characters.tga", 256, 64)
  VRAM.mem:texture(self.char)
  self.tile = D2D.loadTexture("host:dtiles.tga", 256, 256)
  VRAM.mem:texture(self.tile)
end

return res
