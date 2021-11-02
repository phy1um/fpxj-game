
local entity = {
  x = 0, y = 0,
  w = 0, h = 0,
  collides = false,
  etype = "generic",
  update = function() end,
  draw = function() end,
}

local estate = {
  classes = {
    generic = entity
  }
}

function tableFillMissing(to, from)
  for k,v in pairs(from) do
    if to[k] == nil then 
      print("filling class var:", k, v)
      to[k] = v 
    end
  end
  return to
end

function tableMerge(to, from)
  for k, v in pairs(from) do
    to[k] = v
  end
end

function estate:defineClass(name, template)
  tableFillMissing(template, entity)
  self.classes[name] = template
end

function estate:instance(name, args)
  -- get class
  local cls = self.classes[name]
  if cls == nil then error("unknown class " .. name) end
  -- instance of this class
  local e = setmetatable({}, { __index = cls })
  -- merge/override with extra fields (eg x and y)
  if args ~= nil then tableMerge(e, args) end
  return e
end

return estate
