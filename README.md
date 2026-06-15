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
Point = Object:extend()

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end
```

`extend` also takes an optional name. Naming a class lets it describe itself in
logs and `tostring`, which is handy once a project grows a lot of classes:

```lua
Point = Object:extend("Point")
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

### Naming classes and inspecting the hierarchy
Every class carries a `__name` and a reference to its parent via `super`, so a
class — or any instance of it — can describe itself without extra bookkeeping in
your own code:

```lua
print(Point.__name)        -- "Point"
print(Rect.__name)         -- "Rect"
print(Rect.super)          -- Point  (printing a class shows its name)
print(Rect.super.__name)   -- "Point"

local r = Rect(0, 0, 4, 8)
print(r.__name)            -- "Rect" (instances report their class name)
print(r)                   -- "Rect" (tostring uses __name)
```

A class created without a name inherits the name of its nearest named ancestor
(ultimately `"Object"`), so `tostring` always prints something meaningful:

```lua
local Anon = Object:extend()
print(Anon.__name)         -- "Object"

local Tagged = Rect:extend() -- anonymous subclass of Rect
print(Tagged.__name)       -- "Rect"
```

You can walk the whole chain by following `super`:

```lua
local names, c = {}, Rect
while c do
  names[#names + 1] = c.__name
  c = c.super
end
print(table.concat(names, " -> ")) -- "Rect -> Point -> Object"
```

### Checking an object's type
`is` walks the inheritance chain for you, so you never have to poke at
metatables by hand. It works on instances:

```lua
local p = Point(10, 20)
print(p:is(Object)) -- true
print(p:is(Point)) -- true
print(p:is(Rect)) -- false
```

...and on classes, to ask whether one derives from another:

```lua
print(Rect:is(Point))  -- true
print(Rect:is(Object)) -- true
print(Point:is(Rect))  -- false
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


## Tests

A small self-contained verification script is included. Run it with any Lua
interpreter from the project directory:

```sh
lua test.lua
```

It exercises named classes, anonymous classes, the inheritance chain and
instance behaviour, and prints `classic.lua: all N checks passed` on success.


## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

