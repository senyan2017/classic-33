-- Minimal verification for classic.lua's readable debug output.
-- Run with: lua verify.lua   (or luajit verify.lua)

local Object = require "classic"

local function header(title)
  print("\n== " .. title .. " ==")
end

-- 1. Default tostring: base class, subclass and instances are all
--    distinguishable instead of every value printing as "Object".
header("default tostring")

local Shape = Object:extend("Shape")
local Circle = Shape:extend("Circle")

local s1 = Shape()
local c1 = Circle()
local c2 = Circle()

print("Object  ->", tostring(Object))
print("Shape   ->", tostring(Shape))
print("Circle  ->", tostring(Circle))
print("Shape() ->", tostring(s1))
print("Circle()->", tostring(c1))
print("Circle()->", tostring(c2))

assert(tostring(Object) == "Object", "base class should print its name")
assert(tostring(Shape) == "Shape", "named class should print its name")
assert(tostring(Circle) == "Circle", "subclass should print its own name")

-- Instances carry their class name plus a unique address.
assert(tostring(s1):match("^Shape: 0x%x+$"), "Shape instance format")
assert(tostring(c1):match("^Circle: 0x%x+$"), "Circle instance format")
assert(tostring(c2):match("^Circle: 0x%x+$"), "Circle instance format")
assert(tostring(c1) ~= tostring(c2), "two instances must be distinguishable")
assert(tostring(c1) ~= tostring(s1), "different classes must differ")

-- 2. Inheritance: an unnamed subclass falls back to its parent's name, and a
--    deeper named subclass keeps reporting its own identity (consistent).
header("inheritance / metamethod propagation")

local Anonymous = Shape:extend()           -- no explicit name
print("anon class    ->", tostring(Anonymous))
print("anon instance ->", tostring(Anonymous()))
assert(tostring(Anonymous) == "Shape", "unnamed subclass inherits parent name")
assert(tostring(Anonymous()):match("^Shape: 0x%x+$"), "unnamed subclass instance")

-- `is()` relationships must be unaffected by the readable-output changes.
assert(c1:is(Circle) and c1:is(Shape) and c1:is(Object), "Circle() type chain")
assert(s1:is(Shape) and s1:is(Object), "Shape() type chain")
assert(not s1:is(Circle), "Shape() is not a Circle")

-- 3. Custom __tostring: overrides the default for that class and propagates to
--    classes that extend it (parent and subclass behave consistently).
header("custom __tostring")

local Point = Object:extend("Point")
function Point:new(x, y) self.x, self.y = x or 0, y or 0 end
function Point:__tostring() return "(" .. self.x .. ", " .. self.y .. ")" end

local Vec = Point:extend("Vec")            -- inherits the custom __tostring

local p = Point(10, 20)
local v = Vec(3, 4)
print("Point(10,20) ->", tostring(p))
print("Vec(3,4)     ->", tostring(v))

assert(tostring(p) == "(10, 20)", "custom __tostring is used for the instance")
assert(tostring(v) == "(3, 4)", "custom __tostring propagates to the subclass")

print("\nAll checks passed.")
