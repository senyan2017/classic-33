# Classic

A tiny class module for Lua. Attempts to stay simple and provide decent
performance by avoiding unnecessary over-abstraction.


## Usage

The [module](classic.lua) should be dropped in to an existing project and
required by it:

```lua
Object = require "classic"
```

The module returns the object base class which can be extended to create any
additional classes.


### Creating a new class
```lua
Point = Object:extend("Point")

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end
```

Passing a name to `extend()` is optional. If omitted, a name is generated
automatically from the parent class name:

```lua
Thing = Object:extend()       -- Thing.name == "Object_1"
Point = Object:extend("Point") -- Point.name == "Point"
```


### Creating a new object
```lua
local p = Point(10, 20)
```

### Extending an existing class
```lua
Rect = Point:extend("Rect")

function Rect:new(x, y, width, height)
  Rect.super.new(self, x, y)
  self.width = width or 0
  self.height = height or 0
end
```

### Checking an object's type
```lua
local p = Point(10, 20)
print(p:is(Object)) -- true
print(p:is(Point)) -- true
print(p:is(Rect)) -- false
```

### Getting an object's class
```lua
local p = Point(10, 20)
print(p:class() == Point) -- true
print(p:class().name)     -- "Point"
```

### Class names and self-description
Every class has a `.name` field. Printing a class returns its name; printing
an instance returns `"ClassName: 0xaddr"`:

```lua
print(Point)           -- "Point"
print(Rect)            -- "Rect"
local p = Point(1, 2)
print(p)               -- "Point: 0x55a1b3c7d0e8"
```

### Inheritance chain queries
Use `:isSubclassOf()` and `:isAncestorOf()` to walk the class hierarchy
without needing an instance:

```lua
print(Rect:isSubclassOf(Point))  -- true
print(Rect:isSubclassOf(Object)) -- true
print(Rect:isSubclassOf(Rect))   -- false  (strict)

print(Point:isAncestorOf(Rect))  -- true
print(Object:isAncestorOf(Rect)) -- true
```

Each class also carries a `.super` reference to its direct parent:

```lua
print(Rect.super == Point)   -- true
print(Point.super == Object) -- true
```

### Using mixins
```lua
PairPrinter = Object:extend()

function PairPrinter:printPairs()
  for k, v in pairs(self) do
    print(k, v)
  end
end


Point = Object:extend("Point")
Point:implement(PairPrinter)

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end


local p = Point()
p:printPairs()
```

### Using static variables
```lua
Point = Object:extend("Point")
Point.scale = 2

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Point:getScaled()
  return self.x * Point.scale, self.y * Point.scale
end
```

### Creating a metamethod
```lua
function Point:__tostring()
  return self.x .. ", " .. self.y
end
```


## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
