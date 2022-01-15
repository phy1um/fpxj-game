
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
  if from == nil then
    return rnd()
  elseif to == nil then
    return from*rnd()
  else
    return from + (to * rnd())
  end
end


print("go go go")
if love ~= nil then
  require = function(p, ...)
    if p == "draw2d" then p = "script/lovedraw"
    elseif p == "vram" then return FAKE_VRAM
    else p = "script/" .. p
    end
    return coreRequire(p, ...)
  end
  table.unpack = unpack
  print("loading love2d main")
  dofile("script/lovemain.lua")
else
  require = function(p, ...)
    print("REQ+" .. p)
    local rr = coreRequire(p, ...)
    print("REQ-" .. p)
    return rr
  end
end

--PS2PROG.slow2d = false

local D2D = require("draw2d")
local VRAM = require("vram")
local V = require("vector")
local T = require("text")
local menu = require("menu")
local game = require("game")
local room = require("room")
local entity = require("entity")
local player = require("player")
local bat = require("bat")
local player_bullet = require("player_bullet")
local resources = require("resource")
local dungeon = require("generate")

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
  entity:defineClass("bat", bat)
  entity:defineClass("player_bullet", player_bullet)
  local g = game.new()
  local d = dungeon.makeFloor({
    w = 4, h = 4,
    pathLength = 4, 
    roomWidth = 640,
    roomHeight = 448,
  })
  local rl = d:generate()
  g.rooms = rl
  local px, py = d:playerStart()
  print("focus camera")
  g:focusCamera(V.vec2(px, py))
  print("focussed")
  g:spawn(entity:instance("player", {x = px, y = py}))
  state = g
end


local mainmenu = menu.new()

function PS2PROG.start()
  math.randomseed(os.time())
  DMA.init(DMA.GIF)
  GS.setOutput(640, 448, GS.NONINTERLACED, GS.NTSC)
  local fb1 = VRAM.mem:framebuffer(640, 448, GS.PSM24, 256)
  local fb2 = VRAM.mem:framebuffer(640, 448, GS.PSM24, 256)
  local zb = VRAM.mem:framebuffer(640, 448, GS.PSMZ24, 256)
  GS.setBuffers(fb1, fb2, zb)
  D2D:screenDimensions(640, 448)
  D2D:clearColour(0x2b, 0x2b, 0x2b)
  T.font = D2D.loadTexture("host:bigfont.tga", 256, 64)
  VRAM.mem:texture(T.font)
  resources:loadTextures()
  for _, b in ipairs(buttons) do
    buttonState[b] = false  
  end
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
  if not T.font.resident then 
    D2D:uploadTexture(T.font) 
    T.font.resident = true
  end
  state:draw()
  D2D:setColour(255, 255, 255, 0x80)
  T.printLines(10, 10, "FPS: " .. (FPS or 0))
  D2D:frameEnd()
  if PAD.held(PAD.L1) then
    state = mainmenu
  end
end

