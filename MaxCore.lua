-- MainKit Framework - A Lua-based core module addon for task management, event handling and more.
-- Author: Maximus Farvour | Github: @GMM-rgb
-- MaxCore Initialization Suite v1.0

-- MaxCore.lua

-- Copyright (c) 2025 Maximus Farvour
-- Licensed under the MIT License.

-- ======= Core ========

local function getLine()
    local info = debug.getinfo(2, "l")
    return info and info.currentline or -1
end

-- Lenum is property definition for color codes and font types. etc.
-- WIP - still needs more properties, as well as implimenting it into the coreModule.
local lenum = {
    Font = {
        DEFAULT = "default",
        MONOSPACE = "monospace",
        SANS_SERIF = "sans-serif",
        SERIF = "serif"
    },
    Color = {
        RED = "31",       -- red
        CYAN = "36",      -- cyan
        YELLOW = "33",    -- yellow
        MAGENTA = "35",   -- magenta
        GREEN = "32",     -- green
        WHITE_ON_RED = "41;37", -- white on red
        WHITE = "37"      -- white
    },
}

-- This module provides color printing functionality.
-- It allows printing text in different colors to the console.
---@alias LogLevel
---| "ERROR"
---| "INFO"
---| "WARNING"
---| "DEBUG"
---| "SUCCESS"
---| "CRITICAL"

---Prints the message in ANSI color based on log level keyword.
---@param level LogLevel
---@param message string
local function colorPrint(level, message)
    local colorKeywords = {
        ERROR = "31",       -- red
        INFO = "36",        -- cyan
        WARNING = "33",     -- yellow
        DEBUG = "35",       -- magenta
        SUCCESS = "32",     -- green
        CRITICAL = "41;37", -- white on red
    }

    local code = colorKeywords[level] or "37" -- default to white
    print("\27[" .. code .. "m" .. message .. "\27[0m")
end

-- This module provides a simple task management system with wait functionality.
local function sleep(timeWait)
    local t = os.clock()
    while os.clock() - t <= timeWait do end
end

local MainKit = {}
MainKit.__index = MainKit

-- WaitUtilitys module
function MainKit.new()
    local selfModule = setmetatable({}, MainKit)
    return selfModule
end

-- Task module
local task = MainKit.new()
task.__index = task

-- Thread spawning (core)
function task.spawn(fn, ...)
    local debugMode = false -- debug mode flag
    local coro = coroutine.create(fn)
    local s, err = coroutine.resume(coro, ...)

    if not s then
        colorPrint("ERROR", "Task Error: " .. err)
    end

    if debugMode then
        if coroutine.status(coro) == "dead" then
            colorPrint("SUCCESS", "Thread task completed. - " .. string.upper("core.lua") .. " - " .. tostring(getLine()))
            colorPrint("DEBUG", "Task result: " .. tostring(coro))
        else
            colorPrint("INFO", "Thread task is still running.")
        end
    end
end

-- Destroy function for cleanup of objects.
function MainKit:Destroy(object)
    if not object then
        return error("Destroy function requires an object to clean up.")
    end

    print("Destroying object: " .. tostring(object))
end

-- Universal proxy to allow :Wait() on any value or objects
local function WithWait(value)
    local proxy = {}
    function proxy:Wait(n)
        return task:Wait(n)
    end
    setmetatable(proxy, {
        __index = function(_, k)
            return value[k]
        end,
        __call = function(_, ...)
            if type(value) == "function" then
                return value(...)
            end
        end
    })
    -- Allow direct access to the value
    return proxy
end

-- Wait function (core)
function MainKit:Wait(n)
    if not n then
        n = 0
    end
    task.spawn(function()
        sleep(n)
        return true
    end)
end

-- Wait for a condition to be true with a timeout
function MainKit:WaitForCondition(condition, timeout)
    local startTime = os.clock()
    while not condition() do
        if os.clock() - startTime > timeout then
            return false
        end
        task:Wait(0.1) -- Yield to allow other tasks to run
    end
    -- Condition met
    colorPrint("SUCCESS", "Condition met within timeout.")
    return true
end

local Event = {}
Event.__index = Event

function Event.new()
    return setmetatable({
        _listeners = {},
        _nextId = 1,
    }, Event)
end

function Event:Connect(fn)
    local id = self._nextId
    self._nextId = self._nextId + 1
    self._listeners[id] = fn
    return {
        Disconnect = function()
            self._listeners[id] = nil
        end
    }
end

function Event:Once(fn)
    local connection
    connection = self:Connect(function(...)
        fn(...)
        connection.Disconnect()
    end)
end

function Event:Fire(...)
    for _, listener in pairs(self._listeners) do
        listener(...)
    end
end

local test = Event.new()
local connection = test:Connect(function(...)
    colorPrint("INFO", "Value: " .. tostring(...))
end)

test:Fire("Hello World")
connection:Disconnect()

task.spawn(function()
    WithWait(colorPrint("SUCCESS", string.upper("core system online - core.lua - " .. tostring(getLine())))):Wait()
end)

return {
    __call = function(_, env)
        return {
            WaitUtilitys = MainKit,
            lenum = lenum,
            sleep = sleep,
            colorPrint = colorPrint,
            WithWait = WithWait,
            traceback = getLine,
            -- Events
            newEvent = Event.new,
            Event = Event,
            Fire = Event.Fire,
            Once = Event.Once,
            Connect = Event.Connect,
            Disconnect = Event.Disconnect,
            -- Include all functions directly
            WaitForCondition = MainKit.WaitForCondition,
            task = task,
            spawn = task.spawn,
        }
    end
}
