
local vec2 = {
  x = 0,
  y = 0,
}

function vec2:length()
  return math.sqrt((self.x*self.x) + (self.y*self.y))
end

function vec2:normalize() 
  local len = self:length()
  self:scale(1/len)
  return self
end

function vec2:scale(s)
  self.x = self.x * s
  self.y = self.y * s
  return self
end

return {
  vec2 = function(x, y)
    local v = setmetatable({}, { __index = vec2 })
    v.x = x
    v.y = y
    return v
  end
}
