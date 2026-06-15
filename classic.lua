--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--


local Object = {}
Object.__index = Object
Object.name = "Object"


function Object:new()
end


function Object:extend(name)
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  cls.name = name
  -- Each class gets a default __tostring that returns its name for instances.
  -- Users can override this after extend() for custom stringification.
  cls.__tostring = function()
    return name or "Object"
  end
  -- A proxy metatable on the class itself handles tostring(ClassName) and
  -- preserves method inheritance via __index -> parent.
  -- __call is delegated so that ClassName(...) still constructs instances.
  local mt = {
    __index = self,
    __tostring = function()
      return name or "Object"
    end,
    __call = self.__call
  }
  -- Link proxy back into the class chain so is() can walk getmetatable().
  setmetatable(mt, self)
  setmetatable(cls, mt)
  return cls
end


function Object:implement(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end


function Object:is(T)
  if self == T then return true end
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end


function Object:__tostring()
  return "Object"
end


function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end


-- Make the base Object itself printable.
setmetatable(Object, {
  __tostring = function()
    return "Object"
  end
})

return Object
