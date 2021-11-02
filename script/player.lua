
local D2D = require("draw2d")
local V = require("vector")

local player = {
  w = 20, h = 20,
  vx = 0, vy = 0,
  etype = "player",
  walk = 146.2,
  walkAccel = 800,
  friction = 200,
}

function clampf(v, min, max)
  if v <= min then return min
  elseif v >= max then return max
  else return v end
end

function move_to_zero(v, d)
  if v > 0 then
    return math.max(0, v-d)
  elseif v < 0 then
    return math.min(0, v+d)
  else return 0
  end
end

function player:update(dt, st) 
  local impulse = V.vec2(0,0)
  for _, ev in pairs(st.events) do
    if ev.key == PAD.LEFT then
      impulse.x = -1
    elseif ev.key == PAD.RIGHT then
      impulse.x = impulse.x + 1
    elseif ev.key == PAD.UP then
      impulse.y = -1
    elseif ev.key == PAD.DOWN then
      impulse.y = impulse.y + 1
    end
  end

  local moveLen = impulse:length()
  if moveLen > 0 then
    local move = impulse:scale(self.walk/moveLen)
    self.vx = move.x
    self.vy = move.y
  else
    self.vx = move_to_zero(self.vx, self.friction*dt)
    self.vy = move_to_zero(self.vy, self.friction*dt)
  end

  self.x = self.x + self.vx*dt
  self.y = self.y + self.vy*dt
end

function player:draw(cam)
  D2D:setColour(0x90, 0x0a, 0x55, 0x80)
  D2D:rect(self.x - cam.x, self.y - cam.y, self.w, self.h)
end

return player
