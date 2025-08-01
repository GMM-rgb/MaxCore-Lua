-- Terminal UI Demo using MaxCore Framework
-- A simple menu-driven interface showcasing MaxCore features

-- Import MaxCore
local core = setmetatable(require("./MaxCore"), {__call = function(t) return t.__call() end})()

-- UI State Management
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({
        currentMenu = "main",
        isRunning = true,
        taskList = {},
        eventLog = {},
    }, UI)
    
    -- Create events for UI interactions
    self.onMenuChange = core.newEvent()
    self.onTaskComplete = core.newEvent()
    
    return self
end

-- Clear screen function (cross-platform)
local function clearScreen()
    os.execute("cls || clear")
end

-- Draw a fancy header
function UI:drawHeader()
    core.colorPrint("CYAN", "╔══════════════════════════════════════════════════════════╗")
    core.colorPrint("CYAN", "║                    MaxCore Terminal UI                   ║")
    core.colorPrint("CYAN", "║                  Powered by MainKit v1.0                 ║")
    core.colorPrint("CYAN", "╚══════════════════════════════════════════════════════════╝")
    print()
end

-- Draw menu options
function UI:drawMenu()
    if self.currentMenu == "main" then
        core.colorPrint("WHITE", "Main Menu:")
        core.colorPrint("SUCCESS", "  [1] Task Manager")
        core.colorPrint("SUCCESS", "  [2] Event System Demo")
        core.colorPrint("SUCCESS", "  [3] Color Print Test")
        core.colorPrint("SUCCESS", "  [4] Wait Functions Demo")
        core.colorPrint("SUCCESS", "  [5] System Info")
        core.colorPrint("ERROR", "  [0] Exit")
        
    elseif self.currentMenu == "tasks" then
        core.colorPrint("WHITE", "Task Manager:")
        core.colorPrint("INFO", "  Current Tasks: " .. #self.taskList)
        for i, task in ipairs(self.taskList) do
            core.colorPrint("YELLOW", "    " .. i .. ". " .. task.name .. " (" .. task.status .. ")")
        end
        core.colorPrint("SUCCESS", "  [1] Add Task")
        core.colorPrint("SUCCESS", "  [2] Complete Task")
        core.colorPrint("SUCCESS", "  [3] Clear All Tasks")
        core.colorPrint("WARNING", "  [9] Back to Main Menu")
        
    elseif self.currentMenu == "events" then
        core.colorPrint("WHITE", "Event System Demo:")
        core.colorPrint("INFO", "  Event Log Entries: " .. #self.eventLog)
        for i = math.max(1, #self.eventLog - 5), #self.eventLog do
            if self.eventLog[i] then
                core.colorPrint("DEBUG", "    " .. self.eventLog[i])
            end
        end
        core.colorPrint("SUCCESS", "  [1] Fire Test Event")
        core.colorPrint("SUCCESS", "  [2] Create Timed Event")
        core.colorPrint("SUCCESS", "  [3] Clear Event Log")
        core.colorPrint("WARNING", "  [9] Back to Main Menu")
    end
    
    print()
    core.colorPrint("CYAN", "Enter your choice: ")
end

-- Handle user input
function UI:handleInput(choice)
    if self.currentMenu == "main" then
        if choice == "1" then
            self.currentMenu = "tasks"
            self.onMenuChange:Fire("tasks")
        elseif choice == "2" then
            self.currentMenu = "events"
            self.onMenuChange:Fire("events")
        elseif choice == "3" then
            self:colorPrintDemo()
        elseif choice == "4" then
            self:waitFunctionsDemo()
        elseif choice == "5" then
            self:showSystemInfo()
        elseif choice == "0" then
            self.isRunning = false
            core.colorPrint("SUCCESS", "Thanks for using MaxCore Terminal UI!")
        else
            core.colorPrint("ERROR", "Invalid choice! Please try again.")
        end
        
    elseif self.currentMenu == "tasks" then
        if choice == "1" then
            self:addTask()
        elseif choice == "2" then
            self:completeTask()
        elseif choice == "3" then
            self:clearTasks()
        elseif choice == "9" then
            self.currentMenu = "main"
            self.onMenuChange:Fire("main")
        else
            core.colorPrint("ERROR", "Invalid choice! Please try again.")
        end
        
    elseif self.currentMenu == "events" then
        if choice == "1" then
            self:fireTestEvent()
        elseif choice == "2" then
            self:createTimedEvent()
        elseif choice == "3" then
            self:clearEventLog()
        elseif choice == "9" then
            self.currentMenu = "main"
            self.onMenuChange:Fire("main")
        else
            core.colorPrint("ERROR", "Invalid choice! Please try again.")
        end
    end
end

-- Task Management Functions
function UI:addTask()
    print("Enter task name: ")
    local taskName = io.read()
    if taskName and taskName ~= "" then
        table.insert(self.taskList, {
            name = taskName,
            status = "pending",
            created = os.time()
        })
        core.colorPrint("SUCCESS", "Task '" .. taskName .. "' added successfully!")
        
        -- Fire task creation event
        self.onTaskComplete:Fire("Task created: " .. taskName)
    else
        core.colorPrint("ERROR", "Task name cannot be empty!")
    end
    
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

function UI:completeTask()
    if #self.taskList == 0 then
        core.colorPrint("WARNING", "No tasks available to complete!")
    else
        print("Enter task number to complete (1-" .. #self.taskList .. "): ")
        local taskNum = tonumber(io.read())
        
        if taskNum and taskNum >= 1 and taskNum <= #self.taskList then
            local task = self.taskList[taskNum]
            task.status = "completed"
            core.colorPrint("SUCCESS", "Task '" .. task.name .. "' completed!")
            
            -- Fire completion event
            self.onTaskComplete:Fire("Task completed: " .. task.name)
        else
            core.colorPrint("ERROR", "Invalid task number!")
        end
    end
    
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

function UI:clearTasks()
    self.taskList = {}
    core.colorPrint("SUCCESS", "All tasks cleared!")
    
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

-- Event System Functions
function UI:fireTestEvent()
    local testEvent = core.newEvent()
    
    -- Connect a listener
    local connection = testEvent:Connect(function(message)
        table.insert(self.eventLog, os.date("%H:%M:%S") .. " - " .. message)
        core.colorPrint("INFO", "Event fired: " .. message)
    end)
    
    -- Fire the event
    testEvent:Fire("Test event triggered by user!")
    
    connection:Disconnect()
    
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

function UI:createTimedEvent()
    core.colorPrint("INFO", "Creating a timed event that will fire in 3 seconds...")
    
    core.task.spawn(function()
        core.WaitUtilitys:Wait(3)
        table.insert(self.eventLog, os.date("%H:%M:%S") .. " - Timed event completed!")
        core.colorPrint("SUCCESS", "Timed event fired!")
    end)
    
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

function UI:clearEventLog()
    self.eventLog = {}
    core.colorPrint("SUCCESS", "Event log cleared!")
    
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

-- Demo Functions
function UI:colorPrintDemo()
    clearScreen()
    self:drawHeader()
    
    core.colorPrint("WHITE", "Color Print Demonstration:")
    print()
    
    core.colorPrint("ERROR", "This is an ERROR message")
    core.colorPrint("WARNING", "This is a WARNING message")
    core.colorPrint("INFO", "This is an INFO message")
    core.colorPrint("SUCCESS", "This is a SUCCESS message")
    core.colorPrint("DEBUG", "This is a DEBUG message")
    core.colorPrint("CRITICAL", "This is a CRITICAL message")
    
    print()
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

function UI:waitFunctionsDemo()
    clearScreen()
    self:drawHeader()
    
    core.colorPrint("WHITE", "Wait Functions Demonstration:")
    print()
    
    core.colorPrint("INFO", "Testing 2-second wait...")
    local startTime = os.clock()
    core.WaitUtilitys:Wait(2)
    local endTime = os.clock()
    
    core.colorPrint("SUCCESS", "Wait completed! Duration: " .. string.format("%.2f", endTime - startTime) .. " seconds")
    
    print()
    core.colorPrint("INFO", "Testing condition wait (will succeed after 1 second)...")
    
    local testCondition = false
    core.task.spawn(function()
        core.WaitUtilitys:Wait(1)
        testCondition = true
    end)
    
    local success = core.WaitUtilitys:WaitForCondition(function() return testCondition end, 5)
    
    if success then
        core.colorPrint("SUCCESS", "Condition wait succeeded!")
    else
        core.colorPrint("ERROR", "Condition wait timed out!")
    end
    
    print()
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

function UI:showSystemInfo()
    clearScreen()
    self:drawHeader()
    
    core.colorPrint("WHITE", "System Information:")
    print()
    
    core.colorPrint("INFO", "Lua Version: " .. _VERSION)
    core.colorPrint("INFO", "OS Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
    core.colorPrint("INFO", "MaxCore Features Loaded:")
    core.colorPrint("SUCCESS", "  ✓ Color Printing")
    core.colorPrint("SUCCESS", "  ✓ Task Management")
    core.colorPrint("SUCCESS", "  ✓ Event System")
    core.colorPrint("SUCCESS", "  ✓ Wait Utilities")
    core.colorPrint("SUCCESS", "  ✓ Debug Utilities")
    
    print()
    core.colorPrint("INFO", "Current UI State:")
    core.colorPrint("DEBUG", "  Tasks: " .. #self.taskList)
    core.colorPrint("DEBUG", "  Event Log Entries: " .. #self.eventLog)
    core.colorPrint("DEBUG", "  Current Menu: " .. self.currentMenu)
    
    print()
    core.colorPrint("INFO", "Press Enter to continue...")
    io.read()
end

-- Main UI Loop
function UI:run()
    -- Set up event listeners
    self.onMenuChange:Connect(function(newMenu)
        table.insert(self.eventLog, os.date("%H:%M:%S") .. " - Menu changed to: " .. newMenu)
    end)
    
    self.onTaskComplete:Connect(function(message)
        table.insert(self.eventLog, os.date("%H:%M:%S") .. " - " .. message)
    end)
    
    core.colorPrint("SUCCESS", "MaxCore Terminal UI initialized successfully!")
    
    while self.isRunning do
        clearScreen()
        self:drawHeader()
        self:drawMenu()
        
        local choice = io.read()
        self:handleInput(choice)
        
        if self.isRunning and (self.currentMenu == "main") then
            core.WaitUtilitys:Wait(0.5) -- Small delay for better UX
        end
    end
end

-- Initialize and run the UI
local function main()
    core.colorPrint("INFO", "Starting MaxCore Terminal UI...")
    
    local ui = UI.new()
    ui:run()
    
    core.colorPrint("SUCCESS", "MaxCore Terminal UI terminated successfully!")
end

-- Start the application
main()
