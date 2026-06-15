-- smoke_test.lua – minimal verification of classic.lua after refactor
-- Run with: lua smoke_test.lua

local Object = require "classic"

local passed = 0
local failed = 0

local function assert_eq(name, got, expected)
  if got == expected then
    passed = passed + 1
  else
    failed = failed + 1
    io.stderr:write(
      string.format("FAIL  %-40s  expected=%s  got=%s\n", name, tostring(expected), tostring(got))
    )
  end
end

local function assert_true(name, value)
  assert_eq(name, not not value, true)
end

local function assert_false(name, value)
  assert_eq(name, not not value, false)
end

-- ---------------------------------------------------------------------------
-- 1. Basic extend + instantiation
-- ---------------------------------------------------------------------------
local Point = Object:extend()

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

local p = Point(10, 20)
assert_eq("Point.x after construct", p.x, 10)
assert_eq("Point.y after construct", p.y, 20)

-- ---------------------------------------------------------------------------
-- 2. Inheritance with super call
-- ---------------------------------------------------------------------------
local Rect = Point:extend()

function Rect:new(x, y, w, h)
  Rect.super.new(self, x, y)
  self.width  = w or 0
  self.height = h or 0
end

local r = Rect(1, 2, 30, 40)
assert_eq("Rect.x via super",  r.x, 1)
assert_eq("Rect.y via super",  r.y, 2)
assert_eq("Rect.width",        r.width, 30)
assert_eq("Rect.height",       r.height, 40)

-- ---------------------------------------------------------------------------
-- 3. Type checking (is)
-- ---------------------------------------------------------------------------
assert_true ("p:is(Object)",     p:is(Object))
assert_true ("p:is(Point)",      p:is(Point))
assert_false("p:is(Rect)",       p:is(Rect))

assert_true ("r:is(Object)",     r:is(Object))
assert_true ("r:is(Point)",      r:is(Point))
assert_true ("r:is(Rect)",       r:is(Rect))

-- ---------------------------------------------------------------------------
-- 4. Mixin via implement
-- ---------------------------------------------------------------------------
local PairPrinter = Object:extend()

function PairPrinter:sumValues()
  local total = 0
  for _, v in pairs(self) do
    if type(v) == "number" then
      total = total + v
    end
  end
  return total
end

Point:implement(PairPrinter)

-- p was created before implement, but the class table was mutated so the
-- method should still resolve via __index.
assert_eq("Point:sumValues via mixin", p:sumValues(), 30)   -- 10 + 20
assert_eq("Rect:sumValues via inherited mixin", r:sumValues(), 1 + 2 + 30 + 40)

-- ---------------------------------------------------------------------------
-- 5. implement must not overwrite existing methods
-- ---------------------------------------------------------------------------
local Overwriter = Object:extend()
function Overwriter:getValue()
  return "original"
end

local Mixin = Object:extend()
function Mixin:getValue()
  return "overwritten"
end

Overwriter:implement(Mixin)
assert_eq("implement does not overwrite", Overwriter:getValue(), "original")

-- ---------------------------------------------------------------------------
-- 6. __tostring
-- ---------------------------------------------------------------------------
function Point:__tostring()
  return self.x .. ", " .. self.y
end

assert_eq("Point __tostring", tostring(p), "10, 20")
-- Note: tostring(Object) itself falls back to the default table representation
-- because Object has no metatable with __tostring. Only subclasses that inherit
-- it via copyMetamethods get a custom string.
-- Verify that a subclass without a custom __tostring inherits "Object" from the base:
local Bare = Object:extend()
assert_eq("Bare (inherits Object:__tostring)", tostring(Bare), "Object")

-- ---------------------------------------------------------------------------
-- 7. Multi-level inheritance
-- ---------------------------------------------------------------------------
local Square = Rect:extend()

function Square:new(x, y, side)
  Square.super.new(self, x, y, side, side)
end

local sq = Square(5, 6, 7)
assert_eq("Square.x",    sq.x, 5)
assert_eq("Square.y",    sq.y, 6)
assert_eq("Square.width",  sq.width, 7)
assert_eq("Square.height", sq.height, 7)
assert_true("sq:is(Rect)",  sq:is(Rect))
assert_true("sq:is(Point)", sq:is(Point))
assert_true("sq:is(Object)", sq:is(Object))

-- ---------------------------------------------------------------------------
-- 8. Default Object:new is a no-op (no crash with zero args)
-- ---------------------------------------------------------------------------
local Plain = Object:extend()
local ok, plain = pcall(Plain)
assert_true("Plain() succeeds", ok)
assert_true("plain:is(Object)",  plain:is(Object))
assert_true("plain:is(Plain)",   plain:is(Plain))

-- ---------------------------------------------------------------------------
-- Summary
-- ---------------------------------------------------------------------------
print(string.format("smoke test: %d passed, %d failed", passed, failed))
if failed > 0 then
  os.exit(1)
end
