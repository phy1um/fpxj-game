
local D2D = require("draw2d")

local W = 640
local H = 448
local GRID = 16
local GW = math.floor(W/GRID)
local GH = math.floor(H/GRID)
local gri = 0


local room = {
  offsetX = 0,
  offsetY = 0,
  boundX = W,
  boundY = H,
  tiles = {},
  onenter = function() end
}

function room:pointInBounds(x, y)
  return x >= self.offsetX and y >= self.offsetY 
    and x < self.boundX and y < self.boundY
end

function room:set(x, y, v)
  self.tiles[x + (y*GW)] = v
end

function room:get(x, y)
  return self.tiles[x + (y*GW)]
end

function constructor(x, y)
  local rr = setmetatable({}, {__index = room})
  rr.id = gri
  gri = gri + 1
  rr.offsetX = x
  rr.offsetY = y
  rr.boundX = x + W
  rr.boundY = y + H
  rr.tiles = {}
  for i=0,GW,1 do
    for j=0,GH,1 do
      rr:set(i, j, 0)
    end
  end
  return rr
end

function drawTiles(r)
  for i=0,GW,1 do
    for j=0,GH,1 do
      if r:get(i,j) > 0 then
        D2D:setColour(0xff,0xff,0,0x80)
        D2D:rect(i*GRID, j*GRID, 16, 16)
      end
    end
  end
end

return {
  new = function(x, y)
    return constructor(x, y)
  end,
  drawTiles = drawTiles,
}
