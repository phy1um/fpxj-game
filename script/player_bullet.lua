local D2D = require("draw2d")

local pb = {
  w = 6, h = 6,
  vx = 0, vy = 0,
  etype = "pbullet",
  life = 0.2,
}

function pb:update(dt)
  self.x = self.x + self.vx*dt
  self.y = self.y + self.vy*dt
  self.life = self.life - dt
  if self.life < 0 then
    self.remove = true
  end
end

function pb:draw(cam)
  D2D:setColour(0xff, 0, 0, 0x20)
  D2D:rect(self.x, self.y, self.w, self.h)
end

return pb
