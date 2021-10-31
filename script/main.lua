
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
    elseif p == "text" then p = "script/lovedraw"
    else p = "script/" .. p
    end
    return coreRequire(p, ...)
  end
  table.unpack = unpack
  print("loading love2d main")
  print("inserting fennel searchers")
  table.insert(package.loaders or package.searchers, fennel.make_searcher{correlate=true})
  fennel.dofile("script/lovemain.fnl")
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
local mainmenu = require("mainmenu")

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

function PS2PROG.start()
  T.font = D2D.loadTexture("host:bigfont.tga", 256, 64)
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
  state = mainmenu.new()
  state:addEntry("Foo1", function() print("foo1") end)
  state:addEntry("Foo2", function() print("foo2") end)
  state:addEntry("Foo3", function() print("foo3") end)
  state:addEntry("Foo4", function() print("foo4") end)
end

local dt = 1/60
function PS2PROG.frame()
  updatePadInputs(state)
  state:update(dt) 
  D2D:frameStart()
  state:draw()
  D2D:setColour(255, 255, 255, 0x80)
  T.printLines(10, 10, "FPS: 0")
  D2D:frameEnd()
end

