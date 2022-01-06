
local D2D = require("draw2d")

PS2PROG = {}
function PS2PROG.logLevel(i) return end

-- dummy GS implementation
GS = {
  setOutput = function(w, h)
    love.window.setMode(w, h)
  end,
  setBuffers = function() end
}

-- dummy DMA implementation
DMA = {
  init = function() end,
  GIF = 0,
}

-- map keyboard input into PS2 pad input
local keyMap = {}
PAD = {
  UP = "up",
  LEFT = "left",
  DOWN = "down",
  RIGHT = "right",
  X = "x",
  SQUARE = "z",
  TRIANGE = "c",
  CIRCLE = "v", 
  SELECT = "m",
  L1 = "a",
  L2 = "q",
  R1 = "d",
  R2 = "e",
  held = function(i)
    return keyMap[i]
  end,
}

-- global for drawing FPS
FPS = 0

function love.keypressed(k)
  if k == "escape" then
    love.event.quit(0)
  end
  keyMap[k] = true
end

function love.keyreleased(k)
  keyMap[k] = false
end

function love.load()
  PS2PROG.start()
end

function love.update(dt)
  FPS = love.timer.getFPS()
  PS2PROG.frame(dt)
end

function love.draw()
  D2D:doLoveDraw()
end

