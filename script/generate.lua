
local V = require("vector")
local R = require("room")

local exports = {}

local ROOM = {
    x = -1, y = -1,
    joinLeft = false,
    joinRight = false,
    joinUp = false,
    joinDown = false,
  }

function room()
  return setmetatable({}, {__index = ROOM})
end

function ROOM:join(x, y)
  if x == self.x + 1 and y == self.y then
    self.joinRight = true
  elseif x == self.x - 1 and y == self.y then
    self.joinLeft = true
  elseif x == self.x and y == self.y - 1 then
    self.joinUp = true
  elseif x == self.x and y == self.y + 1 then
    self.joinDown = true
  else
    error("cannot join room, not adjacent")
  end
end

-- https://www.programming-idioms.org/idiom/10/shuffle-a-list/2019/lua
function randomShuffle(x)
  for i = #x, 2, -1 do
    local j = math.random(i)
    x[i], x[j] = x[j], x[i]
  end
  return x
end

function randint(a, b)
  return math.floor(math.random(a, b+1))
end

function randomPoint(v1, v2)
  return V.vec2(randint(v1.x, v2.x), randint(v1.y, v2.y))
end

local dungeon = {}

function dungeon.new(w, h, params)
  local d = setmetatable({
    w = w,
    h = h,
    params = params,
  }, { __index = dungeon })
  d.rooms = {}
  return d
end

function dungeon:neighbours(p)
  local nn = {
    V.vec2(p.x-1, p.y),
    V.vec2(p.x, p.y-1),
    V.vec2(p.x+1, p.y),
    V.vec2(p.x, p.y+1),
  }
  local adj = {}
  for i, n in ipairs(nn) do
    if n.x >= 0 and n.x < self.w and n.y >= 0 and n.y < self.h then
      table.insert(adj, n)
    end
  end
  return randomShuffle(adj)
end

function dungeon:tryConnect(c, p)
  local adj = self:neighbours(c)
  for i, at in ipairs(adj) do
    if self:free(at.x, at.y) then
      print(" & step @ " .. at.x .. ", " .. at.y)
      self:populate(at.x, at.y, room()) 
      self:connect(c.x, c.y, at.x, at.y)
      return at, false
    end
  end
  return c, true
end

function dungeon:populate(x, y, r)
  if not self:free(x, y) then
    error("cannot populate room, place taken")
  end
  self.rooms[y * self.w + x] = r
  r.x = x
  r.y = y
  return r
end

function dungeon:free(x, y)
  return self:get(x, y) == nil
end

function dungeon:get(x, y)
  return self.rooms[y * self.w + x]
end

function dungeon:connect(x1, y1, x2, y2)
  if self:free(x1, y1) or self:free(x2, y2) then
    error("cannot connect rooms, one place is empty")
  end
  self:get(x1, y1):join(x2, y2)
  self:get(x2, y2):join(x1, y1)
end

function dungeon:generate()
  local roomOutList = {}
  local start = nil
  for i, rr in pairs(self.rooms) do
    if rr ~= nil then
      local r = R.new(rr.x * self.params.roomWidth, rr.y * self.params.roomHeight)
      print(" * generated room " .. r.offsetX .. ", " .. r.offsetY)
      table.insert(roomOutList, r)
      r:outline() 
      if rr.x == self.startX and rr.y == self.startY then
        start = r
      end
      if rr.joinLeft then
        r:set(0, 6, 0)
        r:set(0, 7, 0)
      end
      if rr.joinRight then
        r:set(R.GW-1, 6, 0)
        r:set(R.GW-1, 7, 0)
      end
      if rr.joinUp then
        r:set(9, 0, 0)
        r:set(10, 0, 0)
      end
      if rr.joinDown then
        r:set(9, R.GH-1, 0)
        r:set(10, R.GH-1, 0)
        r:set(9, R.GH-2, 0)
        r:set(10, R.GH-2, 0)
      end
    end
  end
  return roomOutList, start
end

function dungeon:playerStart()
  return (self.entry.x + 0.5) * self.params.roomWidth, (self.entry.y + 0.5) * self.params.roomHeight
end

function exports.makeFloor(p)
  print("GENERATE DUNGEON FLOOR")
  local d = dungeon.new(p.w, p.h, p)
  local exit = randomPoint(V.vec2(0, 0), V.vec2(p.w, p.h))
  print("EXIT @ " .. exit.x .. ", " .. exit.y)
  d:populate(exit.x, exit.y, room())
  local c = V.vec2(exit.x, exit.y)
  local mainPathSteps = p.pathLength
  while mainPathSteps > 0 do
    local nxt, err = d:tryConnect(c, p)
    d:tryConnect(c, p)
    mainPathSteps = mainPathSteps - 1
    if res == false then
      error("failed to place adjacent room")
    end
    c = nxt
  end
  d.entry = c
  return d
end

return exports
