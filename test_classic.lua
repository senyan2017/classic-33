-- test_classic.lua - Verification tests for enhanced classic.lua
local Object = require "classic"

local pass, fail = 0, 0

local function check(cond, msg)
  if cond then
    pass = pass + 1
  else
    fail = fail + 1
    print("  FAIL: " .. msg)
  end
end

local function section(name)
  print("\n== " .. name .. " ==")
end


-- 1. Root Object class
section("Root Object")
check(Object.name == "Object", "Object.name should be 'Object'")
check(tostring(Object) == "Object", "tostring(Object) should be 'Object'")


-- 2. Named class
section("Named class")
Point = Object:extend("Point")
check(Point.name == "Point", "Point.name should be 'Point'")
check(Point.super == Object, "Point.super should be Object")
check(tostring(Point) == "Point", "tostring(Point) should be 'Point'")


-- 3. Anonymous class (auto-generated name)
section("Anonymous class")
Anonymous = Object:extend()
check(type(Anonymous.name) == "string", "Anonymous class should have a string name")
check(Anonymous.name:find("Object_") == 1, "Anonymous name should start with 'Object_'")
check(Anonymous.super == Object, "Anonymous.super should be Object")


-- 4. Deep inheritance chain
section("Deep inheritance chain")
Shape = Object:extend("Shape")
Rect = Shape:extend("Rect")
Square = Rect:extend("Square")

check(Shape.super == Object, "Shape.super == Object")
check(Rect.super == Shape, "Rect.super == Shape")
check(Square.super == Rect, "Square.super == Rect")
check(Square.name == "Square", "Square.name == 'Square'")


-- 5. isSubclassOf
section("isSubclassOf")
check(Rect:isSubclassOf(Shape), "Rect is subclass of Shape")
check(Rect:isSubclassOf(Object), "Rect is subclass of Object")
check(Square:isSubclassOf(Shape), "Square is subclass of Shape")
check(Square:isSubclassOf(Rect), "Square is subclass of Rect")
check(Square:isSubclassOf(Object), "Square is subclass of Object")
check(not Rect:isSubclassOf(Rect), "Rect is NOT subclass of itself (strict)")
check(not Shape:isSubclassOf(Rect), "Shape is NOT subclass of Rect")
check(not Object:isSubclassOf(Shape), "Object is NOT subclass of Shape")


-- 6. isAncestorOf
section("isAncestorOf")
check(Object:isAncestorOf(Shape), "Object is ancestor of Shape")
check(Object:isAncestorOf(Rect), "Object is ancestor of Rect")
check(Object:isAncestorOf(Square), "Object is ancestor of Square")
check(Shape:isAncestorOf(Rect), "Shape is ancestor of Rect")
check(Shape:isAncestorOf(Square), "Shape is ancestor of Square")
check(Rect:isAncestorOf(Square), "Rect is ancestor of Square")
check(not Rect:isAncestorOf(Rect), "Rect is NOT ancestor of itself (strict)")
check(not Rect:isAncestorOf(Shape), "Rect is NOT ancestor of Shape")


-- 7. Instance creation and :is()
section("Instance :is()")
function Shape:new() end
function Rect:new(w, h) self.w = w; self.h = h end
function Square:new(s) Rect.new(self, s, s) end

local sq = Square(5)
check(sq:is(Square), "sq:is(Square)")
check(sq:is(Rect), "sq:is(Rect)")
check(sq:is(Shape), "sq:is(Shape)")
check(sq:is(Object), "sq:is(Object)")

local r = Rect(3, 4)
check(r:is(Rect), "r:is(Rect)")
check(r:is(Shape), "r:is(Shape)")
check(not r:is(Square), "r is NOT Square")


-- 8. Instance :class()
section("Instance :class()")
check(sq:class() == Square, "sq:class() == Square")
check(r:class() == Rect, "r:class() == Rect")
check(sq:class().name == "Square", "sq:class().name == 'Square'")


-- 9. Instance __tostring
section("Instance __tostring")
local sq_str = tostring(sq)
check(sq_str:find("^Square: 0x%x+$") ~= nil,
  "tostring(sq) should match 'Square: 0x...' (got: " .. sq_str .. ")")

local r_str = tostring(r)
check(r_str:find("^Rect: 0x%x+$") ~= nil,
  "tostring(r) should match 'Rect: 0x...' (got: " .. r_str .. ")")


-- 10. implement still works
section("implement")
Serializable = Object:extend()
function Serializable:serialize() return "ok" end

Rect:implement(Serializable)
check(r:serialize() == "ok", "instance can call implemented method")


-- 11. Anonymous subclass naming
section("Anonymous subclass naming")
AnonSub = Shape:extend()
check(AnonSub.name:find("^Shape_%d+$") ~= nil,
  "Anonymous subclass of Shape should match 'Shape_N' (got: " .. AnonSub.name .. ")")
check(AnonSub.super == Shape, "AnonSub.super == Shape")


-- 12. Custom __tostring on class still works
section("Custom __tostring")
Point2 = Object:extend("Point2")
function Point2:new(x, y) self.x = x; self.y = y end
function Point2:__tostring() return "(" .. self.x .. ", " .. self.y .. ")" end

local p = Point2(1, 2)
check(tostring(p) == "(1, 2)", "custom __tostring on instance works (got: " .. tostring(p) .. ")")
check(tostring(Point2) == "Point2", "class-level tostring still returns name")


-- Summary
print("\n" .. string.rep("=", 40))
print(string.format("Results: %d passed, %d failed", pass, fail))
print(string.rep("=", 40))

os.exit(fail == 0 and 0 or 1)
