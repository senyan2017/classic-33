--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--


-- ---------------------------------------------------------------------------
-- Internal helpers
-- ---------------------------------------------------------------------------

-- Copy metamethods (keys starting with "__") from parent into child table.
local function copyMetamethods(parent, child)
  for k, v in pairs(parent) do
    if k:find("__") == 1 then
      child[k] = v
    end
  end
end

-- Build a new class table whose metatable is `parent`, so that the child
-- inherits metamethods and can reach parent methods via `self.super`.
local function makeClass(parent)
  local cls = {}
  copyMetamethods(parent, cls)
  cls.__index = cls
  cls.super   = parent
  setmetatable(cls, parent)
  return cls
end

-- Walk the metatable chain of `subject` and return true if `target` is found.
local function isInstanceOf(subject, target)
  local mt = getmetatable(subject)
  while mt do
    if mt == target then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end

-- Inject functions from one or more mixin tables into `self`, skipping keys
-- that already exist (so a class's own methods are never overwritten).
local function applyMixins(self, ...)
  for _, mixin in pairs({...}) do
    for k, v in pairs(mixin) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end


-- ---------------------------------------------------------------------------
-- Base class
-- ---------------------------------------------------------------------------

local Object = {}
Object.__index = Object


-- Constructor hook – override in subclasses to initialise instances.
function Object:new()
end


-- Create a subclass that inherits from this class.
function Object:extend()
  return makeClass(self)
end


-- Mix one or more classes/modules into this class (functions only).
function Object:implement(...)
  applyMixins(self, ...)
end


-- Type check: walk the metatable chain and return true if `T` is an ancestor.
function Object:is(T)
  return isInstanceOf(self, T)
end


function Object:__tostring()
  return "Object"
end


-- Instantiation: calling a class as a function creates a new instance.
function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end


return Object
