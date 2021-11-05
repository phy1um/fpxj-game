
local coreRequire = require


function reload(p, ...)
  if package.loaded[p] ~= nil then
    package.loaded[p] = nil
  end
  return require(p, ...)
end

-- ps2 outdated lua compat... :(
local rnd = math.random
function math.random(from, to)
  return from + (to * rnd())
end

print("go go go")
if love ~= nil then
  local fennel = require("script/fennel")
  require = function(p, ...)
    if p == "draw2d" then p = "script/lovedraw"
    else p = "script/" .. p
    end
    return coreRequire(p, ...)
  end
  table.unpack = unpack
  print("loading love2d main")
  print("inserting fennel searchers")
  dofile("script/lovemain.lua")
else
  require = function(p, ...)
    print("REQ+" .. p)
    local rr = coreRequire(p, ...)
    print("REQ-" .. p)
    return rr
  end
end

local D2D = require("draw2d")
local VRAM = require("vram")
local T = require("text")
local menu = require("menu")
local game = require("game")
local room = require("room")
local entity = require("entity")
local player = require("player")
local player_bullet = require("player_bullet")
local resources = require("resource")

local state = nil
local buttons = {PAD.X, PAD.LEFT, PAD.RIGHT, PAD.UP, PAD.DOWN}
local buttonState = {}

function updatePadInputs(s)
  for _, b in ipairs(buttons) do
    local st = PAD.held(b)
    if st ~= buttonState[b] then
      s:inputEvent(b, st)
      buttonState[b] = st
    end
  end
end

function testEntity(cx, cy)
  return {
    cx = cx,
    cy = cy,
    r = 100,
    x = cx+100,
    y = cy,
    etype = "player",
    ct = 0,
    update = function(self, dt)
      self.x = self.cx + math.cos(self.ct)*self.r
      self.y = self.cy + math.sin(self.ct)*self.r
      self.ct = self.ct + dt
    end,
    draw = function(self, cam)
      D2D:setColour(255, 0, 0, 0x80)
      D2D:rect(self.x - cam.x, self.y - cam.y, 20, 20)
      D2D:rect(self.cx - cam.x, self.cy - cam.y, 2, 2)
    end
  }
end

function startGame()
  print("starting game state")
  entity:defineClass("player", player)
  entity:defineClass("player_bullet", player_bullet)
  local r1 = room.new(0, 0)
  local r2 = room.new(640, 0)
  local g = game.new()
  g:addRoom(r1)
  g:addRoom(r2)
  g.activeRoom = r1
  for i=1,3,1 do
    for j=1,3,1 do
      local vv = math.floor(rnd()*24) + 1
      r1:set(i, j, vv)
    end
  end
  g:spawn(testEntity(320, 224))
  g:spawn(entity:instance("player", {x = 100, y = 100}))
  state = g
end

function PS2PROG.start()
  math.randomseed(123)
  T.font = D2D.loadTexture("host:bigfont.tga", 256, 64)
  resources:loadTextures()
  DMA.init(DMA.GIF)
  GS.setOutput(640, 448, GS.NONINTERLACED, GS.NTSC)
  local fb1 = VRAM.buffer(640, 448, GS.PSM24, 256)
  local fb2 = VRAM.buffer(640, 448, GS.PSM24, 256)
  local zb = VRAM.buffer(640, 448, GS.PSMZ24, 256)
  GS.setBuffers(fb1, fb2, zb)
  D2D:clearColour(0x2b, 0x2b, 0x2b)
  for _, b in ipairs(buttons) do
    buttonState[b] = false  
  end
  local mainmenu = menu.new()
  mainmenu:addEntry("New Game", startGame)
  mainmenu:addEntry("Foo2", function() print("foo2") end)
  mainmenu:addEntry("Foo3", function() print("foo3") end)
  mainmenu:addEntry("Foo4", function() print("foo4") end)
  state = mainmenu
end

local dt = 1/60
function PS2PROG.frame()
  updatePadInputs(state)
  state:update(dt) 
  D2D:frameStart()
  state:draw()
  D2D:setColour(255, 255, 255, 0x80)
  T.printLines(10, 10, "FPS: " .. (FPS or 0))
  D2D:frameEnd()
end

