
local room = require("room")

local game = {
  rooms = {},
  elist = {},
  camera = {x=0, y=0},
  activeRoom = nil,
  focusType = "player",
  events = {},
}

function game:focusCamera(f)
  for _, r in ipairs(self.rooms) do
    if r:pointInBounds(f.x, f.y) then 
      print("move from ", self.activeRoom.id, " to ", r.id)
      self.activeRoom = r
      self.camera.x = r.offsetX
      self.camera.y = r.offsetY
      r:onenter()
      return
    end
  end
  error("could not find room for " .. f.x .. ", " .. f.y)
end

function game:update(dt)
  local cs = {}
  local focus = nil
  for _, e in ipairs(self.elist) do
    e:update(dt, self)
    if e.collides then
      table.insert(cs, e.collider)
    end
    if e.etype == self.focusType then focus = e end
  end
  for _, e in ipairs(self.elist) do
    for _, c in ipairs(cs) do
      c(e)
    end
  end
  -- refocus the camera if we left the room bounds!
  if focus ~= nil then
    if not self.activeRoom:pointInBounds(focus.x, focus.y) then
      self:focusCamera(focus)
    end
  end
end

function game:draw()
  if self.activeRoom == nil then return end
  room.drawTiles(self.activeRoom)
  for _, e in ipairs(self.elist) do
    e:draw(self.camera)
  end
end

function game:addRoom(r)
  table.insert(self.rooms, r)
end

function game:spawn(e)
  table.insert(self.elist, e)
end

function game:inputEvent(k, s) 
  if s == true then
    self.events[k] = {key = k}
  else
    self.events[k] = nil
  end
end

function game:find(t)
  for _, e in ipairs(self.elist) do
    if e.etype == t then return e end
  end
  return nil
end

return {
  new = function()
    return setmetatable({}, { __index = game })
  end,
}
