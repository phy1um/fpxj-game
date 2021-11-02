
local D2D = require("draw2d")

local player = {
  w = 20, h = 20,
  etype = "player",
  walk = 146.2
}

function player:update(dt, st) 
  local dx = 0
  local dy = 0
  for _, ev in pairs(st.events) do
    if ev.key == PAD.LEFT then
      dx = dx - self.walk
    elseif ev.key == PAD.RIGHT then
      dx = dx + self.walk
    elseif ev.key == PAD.UP then
      dy = dy - self.walk
    elseif ev.key == PAD.DOWN then
      dy = dy + self.walk
    end
  end
  self.x = self.x + dx*dt
  self.y = self.y + dy*dt
end

function player:draw(cam)
  D2D:setColour(0x90, 0x0a, 0x55, 0x80)
  D2D:rect(self.x - cam.x, self.y - cam.y, self.w, self.h)
end

return player
