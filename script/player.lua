
local D2D = require("draw2d")
local entity = require("entity")
local V = require("vector")

local player = {
  w = 20, h = 20,
  vx = 0, vy = 0,
  etype = "player",
  walk = 146.2,
  walkAccel = 800,
  friction = 800,
  action_debounce = 0,
  dir = DIR_DOWN,
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

function accel_to(v, accel, limit)
  if limit > 0 then
    return math.min(limit, v + accel)
  elseif limit < 0 then
    return math.max(limit, v - accel)
  else
    return move_to_zero(v, accel)
  end
end

function player:update(dt, st) 
  local impulse = V.vec2(0,0)
  local do_action = false
  if self.action_debounce > 0 then
    self.action_debounce = self.action_debounce - dt
  end
  for _, ev in pairs(st.events) do
    if ev.key == PAD.LEFT then
      impulse.x = -1
      self.dir = PAD.LEFT
    elseif ev.key == PAD.RIGHT then
      impulse.x = impulse.x + 1
      self.dir = PAD.RIGHT
    elseif ev.key == PAD.UP then
      impulse.y = -1
      self.dir = PAD.UP
    elseif ev.key == PAD.DOWN then
      impulse.y = impulse.y + 1
      self.dir = PAD.DOWN
    elseif ev.key == PAD.X then
      if self.action_debounce <= 0 then
        do_action = true
        self.action_debounce = 0.09
      end
    end
  end

  local moveLen = impulse:length()
  if moveLen > 0 then
    local move = impulse:scale(self.walk)
    self.vx = accel_to(self.vx, 90, move.x)
    self.vy = accel_to(self.vy, 90, move.y)
  else
    self.vx = move_to_zero(self.vx, 90)
    self.vy = move_to_zero(self.vy, 90)
  end

  if do_action then
    local proj = entity:instance("player_bullet")
    if self.dir == PAD.LEFT then
      proj.x = self.x - 4
      proj.y = self.y + (self.h/2)
      proj.vx = -400
    elseif self.dir == PAD.RIGHT then
      proj.x = self.x + self.w + 4
      proj.y = self.y + (self.h/2)
      proj.vx = 400
    elseif self.dir == PAD.UP then
      proj.y = self.y - 4
      proj.x = self.x + (self.w/2)
      proj.vy = -400
    elseif self.dir == PAD.DOWN then
      proj.y = self.y + self.h + 4
      proj.x = self.x + (self.w/2)
      proj.vy = 400
    end
    st:spawn(proj)
  end

  self.x = self.x + self.vx*dt
  self.y = self.y + self.vy*dt
end

function player:draw(cam)
  D2D:setColour(0x90, 0x0a, 0x55, 0x80)
  D2D:rect(self.x - cam.x, self.y - cam.y, self.w, self.h)
end

return player
