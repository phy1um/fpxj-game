local D2D = require("draw2d")
local R = require("resource")
local V = require("vector")

local SEEK=0
local STRAFE=1
local FLEE=2
local AIMLESS=3

local bat = {
  w = 28, h = 14,
  vx = 0, vy = 0,
  speed = 56,
  state = AIMLESS,
  stateTimer = 0.2,
  etype = "enemy",
  health = 3,
  frame = R.batFrames[1],
  tgt = nil,
}

function bat:moveAimless(speed)
  self.x = self.x + speed
end

function bat:moveSeek(v)
  local d = V.vec2(self.tgt.x - self.x, self.tgt.y - self.y)
  d:normalize()
  d:scale(v)
  self.x = self.x + d.x
  self.y = self.y + d.y
end

function bat:moveStrafe(v)
  local d = V.vec2(self.tgt.x - self.x, self.tgt.y - self.y)
  local arcx = self.tgt.x + (d.x * math.cos(0.01)) - (d.y * math.sin(0.01))
  local arcy = self.tgt.y + (d.x * math.sin(0.01)) - (d.y * math.cos(0.01))
  local move = V.vec2(arcx - self.x, arcy - self.y)
  move:normalize()
  move:scale(v)
  self.x = self.x + move.x
  self.y = self.y + move.y
end


function bat:update(dt, st)
  if self.tgt == nil and self.state ~= AIMLESS then
    self.tgt = st:find("player")
    if self.tgt == nil then
      self.state = AIMLESS
      self.stateTimer = 1
    end
  end

  if self.state == AIMLESS then
    self:moveAimless(10*dt)
  elseif self.state == SEEK then
    self:moveSeek(self.speed*dt)
  elseif self.state == STRAFE then
    self:moveStrafe(self.speed*0.8*dt)
  elseif self.state == FLEE then
    self:moveSeek(-1 * self.speed*dt)
    print("FLEE")
  else
    print("bat in unknown state ", self.state)
    self.state = AIMLESS
  end

  self.stateTimer = self.stateTimer - dt
  if self.stateTimer <= 0 then
    self.state = (self.state + 1) % 2
    self.stateTimer = 5
    print("BAT->", self.state)
  end
end

function bat:draw(cam)
  D2D:setColour(0x80, 0x80, 0x80, 0x80)
  D2D:sprite(R.char, self.x - cam.x, self.y - cam.y, 28, 14,
   self.frame.u1, self.frame.v1, self.frame.u2, self.frame.v2)
end

return bat
