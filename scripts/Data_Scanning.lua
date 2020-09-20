-- #TODO Copyright here

local Arma = _G.Arma;

local Data = Arma.Data;
local Logger = Arma.Logger;
local Misc = Arma.Misc;
local Style = Arma.Style;
local Colors = Arma.Style.Colors;

local MAX_ITEM_ID = 25000;



--   function receive (connection)
--     connection:timeout(0)   -- do not block
--     local s, status = connection:receive(2^10)
--     if status == "timeout" then
--       coroutine.yield(connection)
--     end
--     return s, status
--   end

  function scan (i, j)
    -- local
    -- for i,j do end
  end
  
local threads = {}    -- list of all live threads
function get (i, j)
    -- create coroutine
    local co = coroutine.create(function ()
        scan(i, j)
    end)
    -- insert it in the list
    table.insert(threads, co)
end

function dispatcher ()
    while true do
      local n = table.getn(threads)
      if n == 0 then break end   -- no more threads to run
      for i=1,n do
        local result = coroutine.resume(threads[i])
        if result then    -- thread finished its task?
          table.remove(threads, i)
          break
        end
      end
    end
  end

  ------------------
 

function Data:ScanItems()
    Logger:Print("Scanning...");

    if true then
        -- get(0, 1000000);
        -- get(0, 1000000);
        -- get(0, 1000000);
        -- get(0, 1000000);
        -- get(0, 1000000);
        -- dispatcher();

        self:Test(10000);
        return
    end

    -- Reset item database.
    self:ResetItemDatabase();
    local itemDB = Arma.db.global.itemDB;

    local totalItems = 0;
    local testItemIDs = {873, 16797, 19721, 13952, 19348, 21603}
    -- Iterate over all items and add only valid ones.
    -- for itemID=1,MAX_ITEM_ID do
    for i = 1, #testItemIDs do
        local itemID = testItemIDs[i];
        itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
            itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemID);

        if (itemName ~= nil) then
            if (not self:ValidateItem(itemName)) then
                itemDB.deprecatedItems = itemDB.deprecatedItems + 1;
            else
                itemDB.validItems = itemDB.validItems + 1;
                self:AddItem(itemID, itemName, itemLink, itemRarity, itemType, itemSubtype);
            end
        else
            itemDB.invalidIDs = itemDB.invalidIDs + 1;
        end
    end

    Logger:Printf("- Found %d items", itemDB.validItems);
    Logger:Printf("- Found %d deprecated/old/test items", itemDB.deprecatedItems);
    Logger:Printf("- Found %d invalid IDs", itemDB.invalidIDs);

    Data:PrintDatabase();
end

function Data:ResetItemDatabase()
    Arma.db.global.itemDB = {};

    local itemDB = Arma.db.global.itemDB;

    itemDB.idMap = {};              -- maps item ID to item link
    itemDB.nameMap = {};            -- maps words in item name to item IDs
    itemDB.rarityMap = {};          -- maps item rarity to item IDs
    itemDB.typeMap = {};            -- maps item type to item IDs
    itemDB.subtypeMap = {};         -- maps item subtype to item IDs
    itemDB.classMap = {};           -- maps eligible class to item IDs or to "all" if there's no requirement
    itemDB.propertyMap = {};      -- maps item ID to parsed list of properties this item has

    itemDB.unscannedItems = {};
    itemDB.validItems = 0;
    itemDB.deprecatedItems = 0;
    itemDB.invalidIDs = 0;          -- If invalidIDS > 0, we need to rescan them once again, just to be sure.
end

-- Create the tooltip for parsing.
local ParsingTooltip = CreateFrame("GameTooltip", "ArmaParsingTooltip", nil, "GameTooltipTemplate")
ParsingTooltip:SetOwner(UIParent, "ANCHOR_NONE")

function Data:GetTooltipText(link)
    -- Pass the item link to the tooltip.
    ParsingTooltip:SetHyperlink(link)

    -- Scan the tooltip:
    local tooltipText = "";
    for i = 2, ParsingTooltip:NumLines() do -- Line 1 is always the name so you can skip it.
        local left = _G["ArmaParsingTooltipTextLeft"..i]:GetText()
        local right = _G["ArmaParsingTooltipTextRight"..i]:GetText()
        if left and left ~= "" then
            tooltipText = tooltipText .. left;
        end

        if right and right ~= "" then
            tooltipText = tooltipText .. " " .. right .. "\n";
        else
            tooltipText = tooltipText .. "\n";
        end
    end

    return tooltipText;
end

function Data:AddItem(id, itemName, itemLink, itemRarity, itemType, itemSubtype)
    Logger:Print(itemLink);

    -- Map id to link
    Arma.db.global.itemDB.idMap[id] = itemLink;

    local tooltipText = self:GetTooltipText(itemLink);

    self:ProcessItemName(id, itemName);
    self:ProcessItemRarity(id, itemRarity);
    self:ProcessItemType(id, itemType);
    self:ProcessItemSubtype(id, itemSubtype);
    self:ParseItemTooltip(id, itemType, itemSubtype, tooltipText);
end

-- Filters out invalid, deprecated, old or test items.
function Data:ValidateItem(name)
    if (not name) then
        return false;
    end

    local lname = strlower(name);
    if (strfind(lname, "deprecated") ~= nil or strfind(lname, "deptecated") ~= nil) then
        return false;
    end

    if (strfind(lname, "test") ~= nil) then
        return false;
    end
    
    if (strfind(name, "OLD") ~= nil or strfind(lname, "(old)") ~= nil) then
        return false;
    end

    return true;
end

function Data:ProcessItemName(id, itemName)
    local itemDB = Arma.db.global.itemDB;

    words = {};
    for w in itemName:gmatch("%S+") do table.insert(words, w) end

    for i = 1, #words do
        if (not itemDB.nameMap[words[i]]) then
            itemDB.nameMap[words[i]] = {};
        end

        table.insert(itemDB.nameMap[words[i]], id);
    end
end

function Data:ProcessItemRarity(id, itemRarity)
    local itemDB = Arma.db.global.itemDB;

    if (not itemDB.rarityMap[Misc:GetRarityName(itemRarity)]) then
        itemDB.rarityMap[Misc:GetRarityName(itemRarity)] = {};
    end

    table.insert(itemDB.rarityMap[Misc:GetRarityName(itemRarity)], id);
end

function Data:ProcessItemType(id, itemType)
    local itemDB = Arma.db.global.itemDB;

    if (not itemDB.typeMap[itemType]) then
        itemDB.typeMap[itemType] = {};
    end

    table.insert(itemDB.typeMap[itemType], id);
end

function Data:ProcessItemSubtype(id, itemSubtype)
    local itemDB = Arma.db.global.itemDB;

    if (not itemDB.subtypeMap[itemSubtype]) then
        itemDB.subtypeMap[itemSubtype] = {};
    end

    table.insert(itemDB.subtypeMap[itemSubtype], id);
end

function Data:ParseItemTooltip(id, itemType, itemSubtype, tooltipText)
    -- Split the text into lines.
    lines = {}
    for s in tooltipText:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    -- Create new property entry for this item.
    local itemDB = Arma.db.global.itemDB;
    if (not itemDB.propertyMap[id]) then
        itemDB.propertyMap[id] = {};
    end

    for i = 1, #lines do
        self:ParseItemTooltipLine(id, itemType, itemSubtype, lines[i]);
    end
end

function Data:ParseItemTooltipLine(id, itemType, itemSubtype, tooltipLine)
    local itemDB = Arma.db.global.itemDB;

    if (tooltipLine:find("Soulbound") or tooltipLine:find("Soulbound") or tooltipLine:find("Soulbound")) then
        -- do nothing...
    elseif (tooltipLine:find("Unique")) then
        -- do nothing...
    else
        if (itemType == "Weapon") then
            -- Basic weapon damage values and optional type. Example: 57 - 105 (Arcane) Damage
            -- Condition to distinguish from extra damage
            if (tooltipLine:find("%+") == nil) then
                local minDamage, maxDamage, damageType = tooltipLine:match("(%d+)%s%-%s(%d+)%s*(%a*)%sDamage");
                if (minDamage and maxDamage) then
                    self:AddItemProperty(id, PROPERTY_DAMAGE_MIN, minDamage);
                    self:AddItemProperty(id, PROPERTY_DAMAGE_MAX, maxDamage);
                end
                if (damageType) then
                    if (damageType == "") then
                        damageType = DAMAGE_TYPE_PHYSICAL;
                    end
                    self:AddItemProperty(id, PROPERTY_DAMAGE_TYPE, damageType);
                end
            end

            -- Weapon speed. Example: Speed 2.40
            local weaponSpeed = tooltipLine:match("Speed%s(%d+%.%d+)");
            if (weaponSpeed) then
                self:AddItemProperty(id, PROPERTY_DAMAGE_SPEED, weaponSpeed);
                return;
            end

            -- Extra elemental damage. Example: + 1 - 5 Frost Damage
            local extraMinDamage, extraMaxDamage, extraDamageType = tooltipLine:match("%+%s(%d+)%s%-%s(%d+)%s*(%a*)%sDamage");
            if (extraMinDamage and extraMaxDamage) then
                self:AddItemProperty(id, PROPERTY_EXTRA_DAMAGE_MIN, extraMinDamage);
                self:AddItemProperty(id, PROPERTY_EXTRA_DAMAGE_MAX, extraMaxDamage);
            end
            if (extraDamageType and extraDamageType ~= "") then
                self:AddItemProperty(id, PROPERTY_EXTRA_DAMAGE_TYPE, extraDamageType);
            end

            -- Damage per second. Example (42.2 damage per second)
            local weaponDPS = tooltipLine:match("(%d+%.%d)%sdamage per second");
            if (weaponDPS) then
                self:AddItemProperty(id, PROPERTY_DPS, weaponDPS);
            end

        elseif (itemType == "Armor") then
            -- Armor value: Example: 2345 Armor
            local armor = tooltipLine:match("(%d+) Armor");
            if (armor) then
                self:AddItemProperty(id, PROPERTY_ARMOR, armor);
            end

            if (itemSubtype == "Shields") then
                -- Block value. Example: 39 Block
                local block = tooltipLine:match("(%d+) Block");
                if (block) then
                    self:AddItemProperty(id, PROPERTY_BLOCK, block);
                end    
            end

        elseif (itemType == "Projectile") then
        else
        end

        -- Attributes. Example: +8 Stamina | +16 Intellect
        local attributeBonus, attributeName, resistance = tooltipLine:match("%+(%d+)%s(%a+)%s*(%a*)");
        if (attributeBonus and attributeName) then
            if (resistance and resistance ~= "") then
                local resistanceNameAndType = attributeName .. " " .. resistance;
                self:AddItemProperty(id, resistanceNameAndType, attributeBonus);
            else
                self:AddItemProperty(id, attributeName, attributeBonus);
            end
        end

        -- Level requirement. Example: Requires Level 55
        local levelReq = tooltipLine:match("Requires Level (%d+)");
        if (levelReq) then
            self:AddItemProperty(id, PROPERTY_LEVEL_REQUIRED, levelReq);
        end

        -- Eligible classes. Example: Classes: Mage | Classes: Mage, Warlock
        if (tooltipLine:find("Classes: .+")) then
            tooltipLine = tooltipLine:gsub(",", "");
            tooltipLine = tooltipLine:gsub("Classes: ", "");
            
            local classes = {};
            tooltipLine:gsub("(%a+)", function (w)
                table.insert(classes, w)
            end)

            for i = 1, #classes do
                if (not itemDB.classMap[classes[i]]) then
                    itemDB.classMap[classes[i]] = {};
                end
            
                table.insert(itemDB.classMap[classes[i]], id);
            end
        end

        -- Equip, Chance on hit and Use bonuses. Examples:
        -- Equip: Increases damage and healing done by magical spells and effects by up to 29
        -- Chance on hit: Delivers a fatal wound for 240 damage
        -- Use: Restores 375 to 625 mana. (5 Mins Cooldown)
        local equipBonus = tooltipLine:match("Equip: (.+)");
        if (equipBonus) then
            -- Logger:Print("Equip: " .. equipBonus);
            self:ProcessItemTooltipLineEquip(id, tooltipLine);
        end
        local chanceOnHitBonus = tooltipLine:match("Chance on hit: (.+)");
        if (chanceOnHitBonus) then
            Logger:Print("Chance on hit: " .. chanceOnHitBonus);
        end
        local useBonus = tooltipLine:match("Use: (.+)");
        if (useBonus) then
            Logger:Print("Use: " .. useBonus);
        end
    end
end

function Data:ProcessItemTooltipLineEquip(id, tooltipLine)
    -- Spell power. Example: Increases damage and healing done by magical spells and effects by up to 29
    local spellPower = tooltipLine:match("Increases damage and healing done by magical spells and effects by up to (%d+)");
end

-- These two will not be used right now.
function Data:ProcessItemTooltipLineChanceOnHit(id, tooltipLine)
end
function Data:ProcessItemTooltipLineUse(id, tooltipLine)
end

function Data:AddItemProperty(id, propertyKey, propertyValue)
    local itemDB = Arma.db.global.itemDB;
    itemDB.propertyMap[id][propertyKey] = propertyValue;
    Logger:Verb("[" .. id .. "] - " .. propertyKey .. ": " .. propertyValue);
end

-- Debug purposes only.
function Data:PrintDatabase()
    local itemDB = Arma.db.global.itemDB;

    for k,v in pairs(itemDB.nameMap) do
        for i = 1, #v do
            Logger:Print(k .. " -> " .. v[i]);
        end
    end
    for k,v in pairs(itemDB.rarityMap) do
        for i = 1, #v do
            Logger:Print(k .. " -> " .. v[i]);
        end
    end
    for k,v in pairs(itemDB.typeMap) do
        for i = 1, #v do
            Logger:Print(k .. " -> " .. v[i]);
        end
    end
    for k,v in pairs(itemDB.subtypeMap) do
        for i = 1, #v do
            Logger:Print(k .. " -> " .. v[i]);
        end
    end
    for k,v in pairs(itemDB.propertyMap) do
        Logger:Print(k);
        for k1,v1 in pairs(v) do
            Logger:Print(k1 .. " -> " .. v1);
        end
    end
end

-------------------------------
-------------------------------
-------------------------------

--- Async/Await for Lua 5.1
--  This script implements async/await functions for Lua, allowing tasks to
--  be queued and scheduled independently.
--
--  This is just an example and has a bunch of issues, isn't tested, isn't
--  even actually used anywhere; I basically just got bored and had one of
--  those "what if?" type ideas 6 hours ago.

local co_create = coroutine.create
local co_resume = coroutine.resume
local co_running = coroutine.running
local co_status = coroutine.status
local co_yield = coroutine.yield

-- Packs the given arguments into a table with an `n` key denoting the number
-- of elements.
local function pack(...)
    return { n = select("#", ...), ... }
end

-- Invokes a given function with the given arguments.
local function invoke(fn, ...)
    return fn(...)
end

--- Thread API
--  Implements a basic thread pool of coroutines that can execute functions.

-- Pool of threads that can be acquired. These are allowed to be GC'd.
local thread_pool = setmetatable({}, { __mode = "k" })

-- Internal function used by thread pool coroutines to execute tasks and
-- return their results until the thread dies.
local function thread_main()
    while true do
        co_yield(invoke(co_yield()))
    end
end

-- Creates a new thread for task execution and returns it.
local function thread_create()
    -- Create and resume immediately so that thread_main yields in the loop
    -- to wait for tasks.
    local thread = co_create(thread_main)
    co_resume(thread)
    return thread
end

-- Acquires or creates a thread from the pool. The thread should have a task
-- function submitted to it via coroutine.resume, which will be executed
-- and its result returned.
--
-- When your task has finished, it is the responsibility of the caller to
-- release the thread back into the pool via thread_release.
--
-- If an error is raised, the thread follows standard coroutine semantics
-- and will die. A dead thread should not be released.
local function thread_acquire()
    local thread = next(thread_pool) or thread_create()
    thread_pool[thread] = nil
    return thread
end

-- Releases a given thread back into the pool. The given thread must not
-- be dead. Releasing a thread into the pool before it has finished executing
-- a function will lead to undefined behaviour.
local function thread_release(thread)
    assert(co_status(thread) ~= "dead", "attempted to release a dead thread")

    -- We need to resume a thread to get it back to the inner coroutine.yield
    -- call and make it wait for tasks again.
    co_resume(thread)
    thread_pool[thread] = true
end

--- Task API
--  Implements a basic task system around the coroutine thread pool.
--
--  This API exposes a lot of functions, most of which should be treated as
--  internal only due to invariants that need to be maintained. The following
--  functions are safe for public use:
--
--    task_create
--    task_start
--    task_join
--    task_yield
--    task_schedule
--    task_schedule_all
--
--  Task tables have the following fields which may be publicly inspected,
--  but not modified. Any field not listed here should be considered internal.
--
--    state:  State of the task, as documented below.
--    error:  If non-nil, the error that arose during task execution.
--    result: The result from the task function. This is a table of results
--            unless no values are returned, in which case it should be
--            assumed that if error == nil and result == nil that the task
--            returned no values.
--
--  Tasks may be in one of the following states:
--
--    pending:   task has been created but not yet started
--    runnable:  task has been started and can be resumed
--    running:   task has been started and is in-progress
--    suspended: task has been started but is blocked awaiting completion of
--               another task, and cannot be resumed
--    dead:      task has finished executing

-- Marker value for a successful task execution.
local TASK_SUCCESS = {}
-- Marker value for a task that yielded.
local TASK_YIELDED = {}

-- Stack of actively resumed tasks.
local task_stack = {}
-- Mapping of tasks that are considered runnable.
local task_runnable = {}
-- Counter used to forcefully join tasks due to external threads.
local task_join_count = 0

-- Returns the actively running task.
local function task_stack_top()
    return task_stack[#task_stack]
end

-- Pushes the given task to the top of the stack.
local function task_stack_push(task)
    task_stack[#task_stack + 1] = task
end

-- Pops the task at the top of the stack.
local function task_stack_pop()
    task_stack[#task_stack] = nil
end

-- Enqueues a given runnable task, allowing the scheduler to dispatch it.
local function task_enqueue(task)
    assert(task.state == "runnable", "attempted to queue a non-runnable task")
    task_runnable[task] = true
end

-- Dequeues a given task, preventing the scheduler from dispatching it.
local function task_dequeue(task)
    task_runnable[task] = nil
end

-- Marks a given task as having a dependent task that should be notified
-- upon completion.
local function task_wait(task, dependent_task)
    if not task.notify then
        task.notify = {}
    end

    task.notify[#task.notify + 1] = dependent_task
end

-- Notifies all dependents of a task of completion, marking them as runnable
-- and allowing them to be scheduled.
local function task_notify(task)
    if not task.notify then
        return
    end

    for i = #task.notify, 1, -1 do
        local dependent_task = task.notify[i]
        dependent_task.state = "runnable"
        task_enqueue(dependent_task)

        task.notify[i] = nil
    end
end

-- Internal function used by tasks to invoke their function and uphold the
-- invariants of the task API.
local function task_main(task)
    return TASK_SUCCESS, invoke(unpack(task.target, 1, task.target.n))
end

-- Internal function called when a task thread has returned from a resumption.
local function task_postresume(task, ok, result, ...)
    -- Pop this task from the stack.
    assert(task_stack_top() == task, "internal task stack error")
    task_stack_pop()

    -- Process the results from the task.
    if not ok or result == TASK_SUCCESS then
        -- If the task completed successfully we can recycle the thread.
        if result == TASK_SUCCESS then
            thread_release(task.thread)
        end

        -- Notify any dependent tasks that they're now unblocked.
        task_notify(task)

        task.state  = "dead"
        task.thread = nil
        task.error  = (not ok and result or nil)
        task.result = (ok and select("#", ...) > 0 and pack(...) or nil)
    elseif result == TASK_YIELDED then
        if (...) ~= nil then
            -- Task yielded due to blocking on another task. The task we're
            -- waiting on will be returned, so we just need to wait on it.
            task_wait((...), task)
            task.state = "suspended"
        else
            -- The task yielded explicitly. Nothing is blocking it so allow
            -- it to be rescheduled.
            task.state = "runnable"
            task_enqueue(task)
        end
    else
        -- Don't allow coroutine.yield() to be called blindly from within
        -- the body of a task; simplifies our invariants. Such code wouldn't
        -- work if it were a standard Lua function outside of a coroutine,
        -- after all.
        error("attempted to yield from a task function body")
    end
end

-- Internal function used to resume a task. Requires that the given task
-- is runnable.
local function task_resume(task)
    assert(task.state == "runnable", "attempted to resume a non-runnable task")

    -- Dequeue the task so the scheduler doesn't see it, then mark it as our
    -- current running task.
    task_dequeue(task)
    task_stack_push(task)
    task.state = "running"

    -- Acquire or resume the thread this task is running on.
    if not task.thread then
        task.thread = thread_acquire()
        return task_postresume(task, co_resume(task.thread, task_main, task))
    else
        return task_postresume(task, co_resume(task.thread))
    end
end

-- Creates a new task that will execute the given function with the supplied
-- arguments. The task must be started via task_start before it can be
-- scheduled and joined upon.
local function task_create(fn, ...)
    return {
        state  = "pending",      -- State of this task.
        target = pack(fn, ...),  -- Target function and arguments.
        thread = nil,            -- Thread used by this task.
        notify = nil,            -- Array of tasks to notify upon completion.
        error  = nil,            -- Error result for this task.
        result = nil,            -- Success result data for this task.
    }
end

-- Starts the given task, allowing it to be scheduled and joined upon.
-- Raises an error if the task has already been started.
local function task_start(task)
    assert(task.state == "pending", "attempted to start a non-pending task")
    task.state = "runnable"
    task_enqueue(task)
end

-- Blocks on a given task, either immediately executing it if in the context
-- of a non-task thread, or suspending the current task.
--
-- If the given task has already executed to completion, this function does
-- nothing. Raises an error if the given task has not been started.
local function task_join(task)
    -- Dead tasks tell no tales.
    assert(task.state ~= "pending", "cannot join a pending task")
    assert(task.state ~= "running", "cannot join a running task")
    if task.state == "dead" then
        return
    end

    local current_task = task_stack_top()
    if not current_task
        or current_task.thread ~= co_running()
        or task_join_count > 0 then
        -- If there's no current task or we're joining from an external
        -- thread, we need to forcefully resume the task now and execute
        -- it to completion. To prevent blocking, we increment a counter
        -- (task_join_count) so that if the task tries to join other tasks
        -- we don't park and instead execute those fully too.
        task_join_count = task_join_count + 1
        task_resume(task)
        task_join_count = task_join_count - 1
    else
        -- We're running inside of a task so we can mark it as blocked and
        -- yield, allowing the scheduler to execute our dependency.
        co_yield(TASK_YIELDED, task)
    end
end

-- Yields the active task, suspending its execution. The task will be set in
-- a state that allows it to be resumed via task_schedule or task_join at
-- any point without waiting upon any dependencies.
--
-- The request to yield a task will be ignored if the user has explicitly
-- requested that this task, or a dependent of this task, to be joined.
--
-- Does nothing if there is no actively running task.
local function task_yield()
    local task = task_stack_top()
    if task_join_count > 0 or not task then
        -- task_join was called and we're forcefully resolving this task,
        -- or there's no task to be yielded.
        return
    end

    co_yield(TASK_YIELDED)
end

-- Schedules an unspecified runnable task and executes it. This function will
-- return when the task either completes, or yields due to blocking upon
-- another task.
--
-- This function should not be called in a non-terminating loop; tasks that
-- explicitly yield may be immediately re-executed by the scheduler if so
-- and the you'd end up in a deadlock if the task doesn't stop yielding.
local function task_schedule()
    local task = next(task_runnable)
    if not task then
        return
    end

    task_resume(task)
end

-- Schedules all tasks, executing them fully to completion. Any subtasks that
-- are created during execution of this function are themselves also executed.
local function task_schedule_all()
    -- We collect the runnable tasks into a new list and execute it fully,
    -- and keep doing so until we run out of them. This prevents edge cases
    -- where a task yields explicitly without a dependency and gets executed
    -- in a loop because Lua's table ordering decided it wanted to constantly
    -- put it at the start of the runnable tasks mapping.
    local runnables = {}
    while next(task_runnable) do
        for task in pairs(task_runnable) do
            runnables[#runnables + 1] = task
        end

        for i = #runnables, 1, -1 do
            local task = runnables[i]
            runnables[i] = nil

            task_resume(task)
        end
    end
end

--- Futures API
--  Futures provide a lighter weight read-only view of tasks to allow
--  accessing and storing their result data. All fields on futures are
--  considered internal.

-- Creates a future that monitors the given task.
local function future_create(task)
    return {
        task   = task, -- Task that this future is monitoring.
        error  = nil,  -- Error data received from the task.
        result = nil,  -- Result data received from the task.
    }
end

-- Returns the result of the task this future is watching. The task must
-- have been started via task_start, or an error will be raised.
--
-- If the result of the task isn't yet ready, the task will be joined and
-- waited upon for completion.
--
-- If the task fails with an error, the error is re-raised via the error()
-- function, otherwise the return values of the task are returned as-is.
local function future_get(future)
    local task = future.task
    if task and task.state ~= "dead" then
        task_join(task)
        assert(task.state == "dead", "internal error: joined task must die")

        future.task   = nil
        future.result = task.result
        future.error  = task.error
    end

    if future.error ~= nil then
        error(future.error)
    elseif future.result ~= nil then
        return unpack(future.result, 1, future.result.n)
    end
end

--- Async/Await API
--  Provides a lightweight way of declaring async functions and awaiting upon
--  their results.

-- Marker value indicating an async function should run immediately and not
-- spawn a task. This is used as an optimization when the user would want to
-- await upon an async function immediately.
local RUN_MODE_IMMEDIATE = {}

-- Wraps the given function in an async task wrapper. Calling the returned
-- function will return a future that may be queried for a result via the
-- future_get function.
local function async(fn)
    return function(...)
        if (...) == RUN_MODE_IMMEDIATE then
            return fn(select(2, ...))
        else
            local task = task_create(fn, ...)
            local future = future_create(task)

            task_start(task)
            return future
        end
    end
end

-- Awaits upon a given future, returning its result or raising an error if
-- an async function failed.
--
-- Optionally, users may provide an async function in place of a future. This
-- will cause the function to be executed immediately, rather than creating
-- a future.
local function await(future, ...)
    if type(future) == "function" then
        -- future in this case is assumed to be an async function, we'll
        -- optimize by just running it directly and skipping all task/future
        -- management.
        return future(RUN_MODE_IMMEDIATE, ...)
    else
        return future_get(future)
    end
end

--- Usage Examples
--
--  In a WoW environment you'd typically want to set up an OnUpdate script or
--  a timer that calls task_schedule() as many times as desired to process
--  tasks asynchronously. You can also force all outstanding tasks to be
--  executed to completion via task_schedule_all().

-- Generates several batches of numbers and strings and prints them in
-- whatever order the scheduler feels like. The print_value async function
-- is used to demonstrate that we can await upon tasks from within other
-- tasks (print_values), which waits for the scheduler to print a number
-- and yields allowing the non-deterministic ordering of output.

local print_value = async(function(value)
    print("Value: ", value)
end)

local generate_numbers = async(function(count)
    -- Generate the requested number of random numbers and yield this task
    -- on each one, allowing other tasks to be executed.
    local numbers = {}
    for i = 1, count do
        numbers[i] = math.random(25, 75)
    end

    return numbers
end)

local print_values = async(function(values)
    for i = 1, #values do
        if i % 2 == 1 then
            -- Run the print_value function immediately inside this task.
            await(print_value, values[i])
        else
            -- Spawn print_value as a new task and await upon it.
            await(print_value(values[i]))
        end
    end
end)

local generate_strings = async(function(count)
    local strings = {}
    for i = 1, count do
        strings[i] = string.format("%08x", math.random(2^8, 2^24))
    end

    return strings
end)

function Data:Test(n)
    for _ = 1, 2 do
        print_values(await(generate_numbers(n)))
        print_values(await(generate_strings(n)))
    end
    
    task_schedule_all()    
end


-- Parking a task and awaiting an external event: For this we set an external
-- boolean flag up and toggle its state, a task polls this periodically when
-- scheduled and if it isn't set then it will yield.

-- local event_fired = false
-- local wait_for_event = async(function()
--     while not event_fired do
--         print("Checking...")
--         task_yield() -- Explicitly yield to allow other things to happen.
--     end
-- end)

-- local do_work_after_event = async(function()
--     print("Waiting for event...")
--     await(wait_for_event())
--     print("Event fired!")
-- end)

-- local fire_event = async(function()
--     while not event_fired do
--         if math.random(1, 25) < 10 then
--             print("Firing event...")
--             event_fired = true
--         else
--             print("Sleeping...")
--             os.execute("sleep 0.1")
--             task_yield() -- Explicitly yield to allow other things to happen.
--         end
--     end
-- end)

-- fire_event()
-- do_work_after_event()
-- task_schedule_all()