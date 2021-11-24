local D2D = require("draw2d")

local pb = {
  w = 6, h = 6,
  vx = 0, vy = 0,
  etype = "pbullet",
  life = 0.2,
  collides = true,
  collider = function() end
}

function PIR(x, y, rx, ry, rw, rh)
  return x>=rx and x<=rx+rw and y>=ry and y<=ry+rh
end

function makeRectCollider(x, y, w, h, action)
  return function(other)
    if PIR(other.x, other.y, x, y, w, h) or
         PIR(other.x+other.w, other.y, x, y, w, h) or
         PIR(other.x+other.w, other.y+other.h, x, y, w, h) or
         PIR(other.x, other.y+other.h, x, y, w, h) then
      action(other)
    end
  end
end

function selfGuard(id, so)
  return function(other)
    if id ~= other.id then so(other) end
  end
end


function pb:update(dt)
  self.x = self.x + self.vx*dt
  self.y = self.y + self.vy*dt
  self.life = self.life - dt
  if self.life < 0 then
    self.remove = true
  end
  self.collider = selfGuard(self.id, makeRectCollider(self.x, self.y, self.w, self.h,
    function(other)
      print("got " .. other.etype)
      if other.hurt then 
        other:hurt(self.etype, 1) 
        self.remove = true
      end
    end))
end

function pb:draw(cam)
  D2D:setColour(0xff, 0, 0, 0x20)
  D2D:rect(self.x, self.y, self.w, self.h)
end

return pb
