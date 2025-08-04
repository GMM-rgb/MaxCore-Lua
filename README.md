To Import the modules within the same path, from the core use:

```Lua
local core = setmetatable(require("./MaxCore"), {__call = function(t) return t.__call() end})() -- Load core modules as a package
```
