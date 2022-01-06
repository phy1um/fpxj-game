
local room = require("room")

local game = {
  rooms = {},
  elist = {},
  camera = {x=0, y=0},
  activeRoom = nil,
 focusType = "player",
  eventHeld = {},
  eventPress = {},
  eventRelease = {},
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

local lastLog = 5
function game:update(dt)

  --PS2PROG.logLevel(15)
  local cs = {}
  local dlist = {}
  local focus = nil

  for i, e in ipairs(self.elist) do
    e:update(dt, self)
    if e.collides then
      table.insert(cs, e.collider)
    end
    if e.etype == self.focusType then focus = e end
    if e.remove == true then
      table.insert(dlist, i)
    end
  end

  for i=1,#dlist,1 do
    local di = dlist[#dlist - i]
    -- i am suspicious of this code
    -- print("remove ", i, di)
    table.remove(self.elist, di)
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

  for i, _ in pairs(self.eventPress) do
    self.eventPress[i] = false
  end
  for i, _ in pairs(self.eventRelease) do
    self.eventRelease[i] = false
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

local ids = 0
function getUID()
  local r = ids
  ids = ids + 1
  return r
end

function game:spawn(e)
  e.id = getUID()
  table.insert(self.elist, e)
end

function game:inputEvent(k, s) 
  if s == true then
    self.eventHeld[k] = true
    self.eventPress[k] = true
    if k == PAD.CIRCLE then
      if lastLog == 5 then
        PS2PROG.logLevel(15)
        lastLog = 15
      else
        PS2PROG.logLevel(5)
        lastLog = 5
      end
  end

  else
    self.eventHeld[k] = false
    self.eventRelease[k] = true
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
