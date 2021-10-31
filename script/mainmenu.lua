local D2D = require("draw2d")
local T = require("text")

local mm = {
  cursorPos = 1,
  actions = {},
}

function mm:addEntry(name, action)
  table.insert(self.actions, {name=name, action=action})
end

function mm:update(dt)

end

function mm:draw()
  for i, v in ipairs(self.actions) do
    if i == self.cursorPos then
      D2D:setColour(0xff, 0, 0, 0x80)
    else
      D2D:setColour(0xff, 0xff, 0xff, 0x80)
    end
    T.printLines(100, 60 + (i-1)*30, v.name) 
  end
end

function mm:inputEvent(b, s)
  print(b, s)
  if b == PAD.UP and s == true then
    self.cursorPos = math.max(1, self.cursorPos - 1)
  elseif b == PAD.DOWN and s == true then
    self.cursorPos = math.min(#self.actions, self.cursorPos + 1)
  elseif b == PAD.X and s == true then
    self.actions[self.cursorPos].action()
  end
end

return {
  new = function()
    return setmetatable({}, { __index = mm })
  end
}
