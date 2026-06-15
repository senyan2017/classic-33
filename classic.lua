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
Object.__name = "Object"


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
  cls.__name = name or self.__name
  cls.super = self
  setmetatable(cls, self)
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
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end


-- Returns the default "table: 0x..." representation of `t`, bypassing any
-- `__tostring` metamethod. The metatable is removed only for the duration of
-- the call (and only on `t` itself), so this is recursion-safe and portable
-- across Lua 5.1-5.4 and LuaJIT.
local function rawtostring(t)
  local mt = getmetatable(t)
  setmetatable(t, nil)
  local s = tostring(t)
  setmetatable(t, mt)
  return s
end


function Object:__tostring()
  local name = self.__name or "Object"
  if rawget(self, "__index") == self then
    -- `self` is a class table; show just its name.
    return name
  end
  -- `self` is an instance; append its address so instances are identifiable.
  local s = rawtostring(self)
  return name .. ": " .. (s:match("0x%x+") or s)
end


function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end


-- Subclasses inherit `Object` as their metatable, so their `__tostring` fires
-- automatically. `Object` itself has no such metatable, so give it a minimal
-- one (only `__tostring`, so the base class stays non-callable) to keep its
-- printed form consistent with the classes that extend it.
setmetatable(Object, { __tostring = Object.__tostring })


return Object
