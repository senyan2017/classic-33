--
-- Minimal verification for classic.lua
--
-- Run from anywhere with any interpreter:
--   lua test.lua   (also works with lua5.4 / lua5.3 / luajit)
--

local here = (arg and arg[0] or ""):match("^(.*)[/\\]") or "."
package.path = here .. "/?.lua;" .. package.path

local Object = require("classic")

local count = 0
local function check(cond, msg)
  count = count + 1
  if not cond then
    error("FAILED: " .. tostring(msg), 2)
  end
end

-- The base object is named. (tostring() of the root itself is Lua's default,
-- since the root Object intentionally has no metatable; instances and
-- subclasses below do route through __tostring.)
check(Object.__name == "Object", "base Object should be named 'Object'")

-- A named class knows its own name and its parent.
local Point = Object:extend("Point")
function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

check(Point.__name == "Point", "Point.__name")
check(Point.super == Object, "Point.super should be Object")
check(Point.super.__name == "Object", "Point parent name")
check(tostring(Point) == "Point", "tostring(class) uses __name")

-- Instances report their class name (handy for logs / tostring).
local p = Point(10, 20)
check(p.__name == "Point", "instance inherits class name")
check(tostring(p) == "Point", "tostring(instance)")
check(p.x == 10 and p.y == 20, "constructor still runs")

-- A named subclass: the full chain is introspectable.
local Rect = Point:extend("Rect")
function Rect:new(x, y, w, h)
  Rect.super.new(self, x, y)
  self.w = w or 0
  self.h = h or 0
end

check(Rect.__name == "Rect", "Rect.__name")
check(Rect.super == Point, "Rect.super should be Point")
check(Rect.super.super == Object, "Rect grandparent should be Object")
check(tostring(Rect) == "Rect", "tostring(subclass) uses __name")

-- Inheritance checks work from instances ...
local r = Rect(1, 2, 3, 4)
check(r:is(Rect) == true, "r is Rect")
check(r:is(Point) == true, "r is Point")
check(r:is(Object) == true, "r is Object")

-- ... and from classes, without hand-rolling metatable walks.
check(Rect:is(Point) == true, "Rect derives from Point")
check(Rect:is(Object) == true, "Rect derives from Object")
check(Point:is(Rect) == false, "Point does not derive from Rect")

-- A Point instance is not a Rect.
check(p:is(Rect) == false, "Point instance is not a Rect")

-- Anonymous classes still work and fall back to the nearest named ancestor.
local Anon = Object:extend()
check(Anon.__name == "Object", "anonymous class falls back to Object")

local Mid = Point:extend() -- anonymous subclass of a named class
check(Mid.__name == "Point", "anonymous subclass falls back to Point")
check(Mid:is(Point) == true, "anonymous subclass still derives from Point")
local m = Mid()
check(tostring(m) == "Point", "anonymous subclass instance tostring")

-- Walking the hierarchy by name (what you'd do in a log line).
local names, c = {}, Rect
while c do
  names[#names + 1] = c.__name
  c = c.super
end
check(table.concat(names, " -> ") == "Rect -> Point -> Object",
  "hierarchy walk via super/__name")

print(("classic.lua: all %d checks passed"):format(count))
print("hierarchy: " .. table.concat(names, " -> "))
print("tostring(Rect(1, 2, 3, 4)): " .. tostring(r))
