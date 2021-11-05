
local D2D = require("draw2d")
local entity = require("entity")
local V = require("vector")
local R = require("resource")

local player = {
  w = 20, h = 20,
  vx = 0, vy = 0,
  etype = "player",
  walk = 146.2,
  walkAccel = 800,
  friction = 800,
  action_debounce = 0,
  dir = DIR_DOWN,
  frame = R.playerFrames.left[1],
  animTimer = 0,
}

local animTimerMax = 1.2

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
      self.frame = R.playerFrames.left[1]
    elseif ev.key == PAD.RIGHT then
      impulse.x = impulse.x + 1
      self.dir = PAD.RIGHT
      self.frame = R.playerFrames.right[1]
    elseif ev.key == PAD.UP then
      impulse.y = -1
      self.dir = PAD.UP
      self.frame = R.playerFrames.up[1]
    elseif ev.key == PAD.DOWN then
      impulse.y = impulse.y + 1
      self.dir = PAD.DOWN
      self.frame = R.playerFrames.down[1]
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
    self.animTimer = self.animTimer + dt
  else
    self.vx = move_to_zero(self.vx, 90)
    self.vy = move_to_zero(self.vy, 90)
    self.animTimer = 0
  end

  local animFrame = 4 * (self.animTimer % animTimerMax)/animTimerMax
  -- local animFrame = 0
  local animDir = nil
  if self.dir == PAD.LEFT then
    animDir = R.playerFrames.left
  elseif self.dir == PAD.RIGHT then
    animDir = R.playerFrames.right
  elseif self.dir == PAD.UP then
    animDir = R.playerFrames.up
  else
    animDir = R.playerFrames.down
  end
  self.frame = animDir[math.floor(animFrame) + 1]

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
  D2D:setColour(0x80, 0x80, 0x90, 0x80)
  -- D2D:rect(self.x - cam.x, self.y - cam.y, self.w, self.h)
  D2D:sprite(R.char, self.x - cam.x, self.y - cam.y,
    self.w, self.h, self.frame.u1, self.frame.v1, self.frame.u2,
    self.frame.v2)
end

return player
