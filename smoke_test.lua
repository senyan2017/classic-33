--
-- Minimal smoke test for classic.lua
--
-- Run with:  lua smoke_test.lua
--
-- Exercises the full public contract: extend, implement (mixins),
-- instantiation via __call, super calls, and is() type checking.
--

-- Resolve classic.lua relative to this script, so the test runs from any cwd.
local here = arg and arg[0] and arg[0]:match("^(.*[/\\])") or "./"
package.path = here .. "?.lua;" .. package.path

local Object = require("classic")

local passed = 0
local function check(label, cond)
  assert(cond, "FAIL: " .. label)
  passed = passed + 1
  print("ok - " .. label)
end


-- 1. extend + instantiation -------------------------------------------------
local Point = Object:extend()

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Point:__tostring()
  return self.x .. ", " .. self.y
end

local p = Point(10, 20)
check("constructor runs on instantiation", p.x == 10 and p.y == 20)
check("default constructor args", (function() local q = Point() return q.x == 0 and q.y == 0 end)())
check("instance metamethod (__tostring)", tostring(p) == "10, 20")

-- The base Object is meant to be extended, not called directly (it carries no
-- metatable of its own); a plain subclass inherits its default __tostring.
local Plain = Object:extend()
check("default __tostring is inherited", tostring(Plain()) == "Object")


-- 2. super calls through an inheritance chain -------------------------------
local Rect = Point:extend()

function Rect:new(x, y, width, height)
  Rect.super.new(self, x, y)
  self.width = width or 0
  self.height = height or 0
end

local r = Rect(1, 2, 3, 4)
check("super.new initialises inherited fields", r.x == 1 and r.y == 2)
check("subclass constructor initialises own fields", r.width == 3 and r.height == 4)
check("inherited metamethod flows to grandchild instance", tostring(r) == "1, 2")


-- 3. is() type checking -----------------------------------------------------
check("instance is its own class", p:is(Point))
check("instance is the base class", p:is(Object))
check("instance is not an unrelated class", not p:is(Rect))
check("grandchild is every ancestor", r:is(Rect) and r:is(Point) and r:is(Object))


-- 4. implement() mixins -----------------------------------------------------
local Shouter = Object:extend()
function Shouter:shout()
  return "AT " .. self.x .. "," .. self.y
end
-- A method that would clash with an existing one must NOT override it.
function Shouter:new()
  error("mixin new() should never replace the host class constructor")
end

local Marker = Point:extend()
Marker:implement(Shouter)

function Marker:new(x, y)
  Marker.super.new(self, x, y)
end

local m = Marker(5, 6)
check("mixin method is copied in", m:shout() == "AT 5,6")
check("mixin does not clobber existing constructor", m.x == 5 and m.y == 6)


print(("\n%d checks passed."):format(passed))
