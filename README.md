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

The name passed to `extend` is optional. When given, it is used to produce
readable debug output (see [Readable debug output](#readable-debug-output)
below); when omitted the class inherits the name of the class it extends.

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
PairPrinter = Object:extend()

function PairPrinter:printPairs()
  for k, v in pairs(self) do
    print(k, v)
  end
end


Point = Object:extend()
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
Point = Object:extend()
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


### Readable debug output
By default classes and their instances produce readable output when printed,
making it easy to tell base classes, subclasses and instances apart in logs:

```lua
Shape = Object:extend("Shape")
Circle = Shape:extend("Circle")

print(Shape)      -- Shape
print(Circle)     -- Circle
print(Circle())   -- Circle: 0x55f0a1b2c3d4
print(Shape())    -- Shape: 0x55f0a1b2e5f6
```

A class prints its name, while an instance also prints its address so distinct
instances are distinguishable. Defining your own `__tostring` (see above)
overrides this for that class and the classes that extend it.


## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

