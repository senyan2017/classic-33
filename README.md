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

The `extend()` method accepts an optional name string which is used by
`tostring()` for debugging:
```lua
print(Point)        -- Point
local p = Point()
print(p)            -- Point
print(Object)       -- Object
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

### Using mixins
```lua
PairPrinter = Object:extend("PairPrinter")

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

Note that when a class defines a custom `__tostring`, it applies to its
instances. The class itself (e.g. `print(Point)`) always prints the name
passed to `extend()`. Subclasses do not inherit a parent's custom
`__tostring` — each class gets a default that prints its own name.


## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

