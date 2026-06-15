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

-- Internal counter used to generate names for anonymous classes.
local _anonCounter = 0


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

  -- Assign a name: use the provided one, or generate "ParentName_N".
  if name then
    cls.name = name
  else
    _anonCounter = _anonCounter + 1
    cls.name = tostring(self.name or "Object") .. "_" .. _anonCounter
  end

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
    local nxt = getmetatable(mt)
    if nxt == mt then break end  -- root class points to itself
    mt = nxt
  end
  return false
end


--- Returns the class table of this instance.
function Object:class()
  return getmetatable(self)
end


--- Returns true if this class is a (strict) subclass of T, i.e. T appears
--- somewhere in the ancestor chain but this class is not T itself.
function Object:isSubclassOf(T)
  local parent = rawget(self, "super")
  while parent do
    if parent == T then
      return true
    end
    parent = rawget(parent, "super")
  end
  return false
end


--- Returns true if this class is a (strict) ancestor of T, i.e. this class
--- appears in T's ancestor chain but is not T itself.
function Object:isAncestorOf(T)
  return T:isSubclassOf(self)
end


function Object:__tostring()
  -- Class tables carry 'name' as a direct (rawget) field.
  if rawget(self, "name") then
    return self.name
  end
  -- Instance path: show "ClassName: <address>".
  local cls = getmetatable(self)
  if cls and cls.name then
    -- Temporarily strip the metatable to avoid __tostring recursion.
    local mt = getmetatable(self)
    setmetatable(self, nil)
    local s = tostring(self)
    setmetatable(self, mt)
    return cls.name .. ": " .. s:gsub("table: ", "")
  end
  return "Object"
end


function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end


-- Name the root class itself and give it a lightweight metatable so that
-- tostring(Object) resolves through __tostring like any other class.
-- We use a separate table (not Object itself) to avoid __index loops.
Object.name = "Object"
setmetatable(Object, {
  __tostring = function() return "Object" end,
})


return Object
