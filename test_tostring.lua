-- test_tostring.lua
-- Minimal verification: parent class, subclass, instance, custom __tostring

local Object = require "classic"

-- 1. Base Object itself
assert(tostring(Object) == "Object",
  "FAIL: tostring(Object) should be 'Object', got: " .. tostring(Object))

-- 2. Named parent class
local Point = Object:extend("Point")
function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

assert(tostring(Point) == "Point",
  "FAIL: tostring(Point) should be 'Point', got: " .. tostring(Point))

-- 3. Instance of named class
local p = Point(3, 4)
assert(tostring(p) == "Point",
  "FAIL: tostring(Point instance) should be 'Point', got: " .. tostring(p))

-- 4. Subclass
local Rect = Point:extend("Rect")
function Rect:new(x, y, w, h)
  Rect.super.new(self, x, y)
  self.w = w or 0
  self.h = h or 0
end

assert(tostring(Rect) == "Rect",
  "FAIL: tostring(Rect) should be 'Rect', got: " .. tostring(Rect))

-- 5. Instance of subclass
local r = Rect(1, 2, 10, 20)
assert(tostring(r) == "Rect",
  "FAIL: tostring(Rect instance) should be 'Rect', got: " .. tostring(r))

-- 6. Custom __tostring on a class
local Vec = Object:extend("Vec")
function Vec:new(x, y)
  self.x = x or 0
  self.y = y or 0
end
function Vec:__tostring()
  return string.format("Vec(%g, %g)", self.x, self.y)
end

local v = Vec(5, 6)
assert(tostring(v) == "Vec(5, 6)",
  "FAIL: custom __tostring should give 'Vec(5, 6)', got: " .. tostring(v))
-- The class itself should still show its name
assert(tostring(Vec) == "Vec",
  "FAIL: tostring(Vec) should be 'Vec', got: " .. tostring(Vec))

-- 7. Subclass of a class with custom __tostring does NOT inherit the custom one
local Vec3 = Vec:extend("Vec3")
function Vec3:new(x, y, z)
  Vec3.super.new(self, x, y)
  self.z = z or 0
end

local v3 = Vec3(1, 2, 3)
assert(tostring(v3) == "Vec3",
  "FAIL: Vec3 instance should default to 'Vec3', got: " .. tostring(v3))
assert(tostring(Vec3) == "Vec3",
  "FAIL: tostring(Vec3) should be 'Vec3', got: " .. tostring(Vec3))

-- 8. is() still works correctly after the metatable changes
assert(p:is(Object),  "FAIL: Point instance should be Object")
assert(p:is(Point),   "FAIL: Point instance should be Point")
assert(not p:is(Rect), "FAIL: Point instance should not be Rect")
assert(r:is(Object),  "FAIL: Rect instance should be Object")
assert(r:is(Point),   "FAIL: Rect instance should be Point")
assert(r:is(Rect),    "FAIL: Rect instance should be Rect")
assert(Rect:is(Point), "FAIL: Rect class should be Point")
assert(Rect:is(Object), "FAIL: Rect class should be Object")
assert(Object:is(Object), "FAIL: Object should be Object")

-- 9. Unnamed extend (backward compatibility)
local Anon = Object:extend()
local a = Anon()
assert(tostring(Anon) == "Object",
  "FAIL: unnamed class should fall back to 'Object', got: " .. tostring(Anon))
assert(tostring(a) == "Object",
  "FAIL: instance of unnamed class should fall back to 'Object', got: " .. tostring(a))

-- Print summary
print("=== All tests passed ===")
print("tostring(Object):       " .. tostring(Object))
print("tostring(Point):        " .. tostring(Point))
print("tostring(Point(3,4)):   " .. tostring(Point(3,4)))
print("tostring(Rect):         " .. tostring(Rect))
print("tostring(Rect(1,2,..)): " .. tostring(Rect(1,2,10,20)))
print("tostring(Vec):          " .. tostring(Vec))
print("tostring(Vec(5,6)):     " .. tostring(Vec(5,6)))
print("tostring(Vec3):         " .. tostring(Vec3))
print("tostring(Vec3(1,2,3)):  " .. tostring(Vec3(1,2,3)))
print("tostring(Anon):         " .. tostring(Anon))
print("tostring(Anon()):       " .. tostring(Anon()))
