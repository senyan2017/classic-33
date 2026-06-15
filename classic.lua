--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--


-- --------------------------------------------------------------------------
-- Internal conventions
--
-- The whole module rests on two recurring rules about how a class table is
-- wired up. Naming them here means the public methods below can express
-- intent instead of repeating the mechanics.
-- --------------------------------------------------------------------------

-- A class is a table that serves as the lookup target (`__index`) for both
-- its instances and its subclasses.
local function init_class(cls)
  cls.__index = cls
  return cls
end

-- Metamethods (keys named "__xxx") are read raw from an object's metatable at
-- dispatch time, so they are *not* reached through the `__index` chain. For a
-- subclass's instances to inherit them they must be copied onto the subclass
-- explicitly. Must run before `init_class`, since `__index` is itself a "__"
-- key that we then want to repoint at the subclass.
local function inherit_metamethods(cls, parent)
  for k, v in pairs(parent) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
end


-- --------------------------------------------------------------------------
-- Base class
-- --------------------------------------------------------------------------

local Object = init_class({})


-- Default constructor; subclasses override this.
function Object:new()
end


-- --------------------------------------------------------------------------
-- Inheritance
-- --------------------------------------------------------------------------

-- Build a subclass that delegates missing members to `self` (its parent).
function Object:extend()
  local cls = {}
  inherit_metamethods(cls, self)
  init_class(cls)
  cls.super = self
  return setmetatable(cls, self)
end


-- --------------------------------------------------------------------------
-- Mixins
-- --------------------------------------------------------------------------

-- Copy the functions of each source into this class, without overriding
-- members it already provides directly or through inheritance.
function Object:implement(...)
  for _, mixin in pairs({...}) do
    for k, v in pairs(mixin) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end


-- --------------------------------------------------------------------------
-- Type checking
-- --------------------------------------------------------------------------

-- True when `T` appears anywhere in this object's class/metatable chain.
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


function Object:__tostring()
  return "Object"
end


-- --------------------------------------------------------------------------
-- Instantiation
-- --------------------------------------------------------------------------

-- Calling a class creates a new instance and runs its constructor.
function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end


return Object
