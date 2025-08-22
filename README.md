To Import the modules within the same path, from the core use:

old: do not use!
```Lua
local core = setmetatable(require("./MaxCore"), {__call = function(t) return t.__call() end})() -- Load core modules as a package
```

new:
```Lua
local core = require("MaxCore")
local core.MainKit:Load({...})
```

Event Creation:
Use of this addon can be used by doing
```Lua
-- Assuming that the import is called "Core"
local newEvent = core.Event.new()
```

Using Events:
continued...
