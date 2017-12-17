ActiveButton = 5		  -- 鼠标侧键（前进）
ChangeButton = 4		  -- 鼠标侧键（后退）
CancelButton = 3


TableSkill = {
    ["deathArea"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "1",
        ["Interval"]   = 15000,
      },
    ["eating"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "3",
        ["Interval"]   = 2,
      },
	  
	   ["bodyShot"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "2",
        ["Interval"]   = 2,
      },
      ["boneComm"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "4",
        ["Interval"]   = 2,
      }
}

TableChangeSkill = {
    ["boneComm"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "4",
        ["Interval"]   = 700,
      }
}


-- ==========================================================================
-- 以下为框架代码，勿动
-- ==========================================================================

POLL_FAMILY = "mouse"	-- 当前鼠标没有 M 键状态，正好利用来制造轮询
POLL_INTERVAL = 10		-- 在开始下一个轮询前的延时(毫秒)，用于调节轮询速率
POLL_DEADTIME = 100	-- 旧的轮询事件被耗尽的时间

-- 为了避免鼠标自动点击后，无法还原鼠标按键先前状态，特设此函数，在自动点击前后保留并还原按键状态
function PressAndReleaseMouseButtonAccurate(mArg)
    if IsMouseButtonPressed(mArg) then
        ReleaseMouseButton(mArg)
        PressMouseButton(mArg)
    else
        PressAndReleaseMouseButton(mArg)
    end
end

-- 保持键盘自动按键 协程
function KeepPressAndReleaseKey(Task)
    while Task.Run do
        if Task.Modifier ~= nil then
            if (not IsModifierPressed(Task.Modifier)) then
                PressAndReleaseKey(Task.Arg)
            elseif Task.FFInterval ~= nil then
                PressAndReleaseKey(Task.Arg)
            end
        else
            PressAndReleaseKey(Task.Arg)
        end
        Task = coroutine.yield()
        Sleep(20)
    end
end

-- 保持鼠标自动点击 协程
function KeepPressAndReleaseMouseButton(Task)
    while Task.Run do
        if Task.Modifier ~= nil then
            if (not IsModifierPressed(Task.Modifier)) then
                PressAndReleaseMouseButtonAccurate(Task.Arg)
            elseif Task.FFInterval ~= nil then
                PressAndReleaseMouseButtonAccurate(Task.Arg)
            end
        else
            PressAndReleaseMouseButtonAccurate(Task.Arg)
        end
        Task = coroutine.yield()
        Sleep(20)
    end
end

function DoEvent(event, arg, family)
    local st = StateTimer
    if arg == ActiveButton then
     startSingleTask(TableSkill)
    elseif  arg == ChangeButton then
     startSingleTask(TableChangeSkill)
    elseif event == "MOUSE_BUTTON_PRESSED" and arg == CancelButton then
        -- 移除所有协程
        AbortAllTask()
    ---OutputLogMessage("Script middle !\n")
    elseif event == "PROFILE_ACTIVATED" then
        --  初始化
        ClearLog()
       -- OutputLogMessage("Script started !\n")
--        OutputLogMessage("Actual attack speed = "..ActualAttackSpeed.."\n")
        -- 轮询初始化
        InitPolling()
    elseif event == "PROFILE_DEACTIVATED" then
    end
    DoTasks()
    Poll(event, arg, family, st)
end
-- 轮询初始化
function InitPolling()
    ActiveState = GetMKeyState_Hook(POLL_FAMILY)
    SetMKeyState_Hook(ActiveState, POLL_FAMILY)
end

-- 轮询
function Poll(event, arg, family, st)
    if st == nil and StateTimer ~= nil then return end
    if st ~= nil then OutputLogMessage("event:"..event.."  arg:"..arg.."  family:"..family.."  st:"..st.."\n"); end
    local t = GetRunningTime()
    if family == POLL_FAMILY then
        if event == "M_PRESSED" and arg ~= ActiveState then
            if StateTimer ~= nil and t >= StateTimer then StateTimer = nil end
            if StateTimer == nil then ActiveState = arg end
            StateTimer = t + POLL_DEADTIME
        elseif event == "M_RELEASED" and arg == ActiveState then
            Sleep(POLL_INTERVAL)
            SetMKeyState_Hook(ActiveState, POLL_FAMILY)
        end
    end
end

GetMKeyState_Hook = GetMKeyState
GetMKeyState = function(family)
    family = family or "kb"
    if family == POLL_FAMILY then
        return ActiveState
    else
        return GetMKeyState_Hook(family)
    end
end

SetMKeyState_Hook = SetMKeyState
SetMKeyState = function(mkey, family)
    family = family or "kb"
    if family == POLL_FAMILY then
        if mkey == ActiveState then return end
        ActiveState = mkey
        StateTimer = GetRunningTime() + POLL_DEADTIME
    end
    return SetMKeyState_Hook(mkey, family)
end


-- 任务管理函数

TaskList = {}

-- 遍历任务列表，执行任务协程
function DoTasks()
    local t = GetRunningTime()
    for Key, Task in pairs(TaskList) do
        if t >= Task.Time then
            local s = coroutine.resume(Task.Task, Task)
            if (not s) then
                TaskList[Key] = nil
            else
                local tmpInterval = Task.Interval
                if Task.Modifier ~= nil then
                    if IsModifierPressed(Task.Modifier) then
                        if Task.FFInterval ~= nil then
                            tmpInterval = Task.FFInterval
                        end
                    end
                end
                Task.Time = Task.Time + tmpInterval
            end
        end
    end
end

-- 添加任务
function AddTask(Key, Parameters)
    local Task = {}
    Task.Time = GetRunningTime()
    if Parameters["Family"] == "mouse" then
        Task.Task = coroutine.create(KeepPressAndReleaseMouseButton)
    else
        Task.Task = coroutine.create(KeepPressAndReleaseKey)
    end

    Task.Arg = Parameters["Arg"]
    Task.Interval = Parameters["Interval"] - 20
    if Parameters["Modifier"] ~= nil then
        Task.Modifier = Parameters["Modifier"]
    end
    if Parameters["FFInterval"] ~= nil then
        Task.FFInterval = Parameters["FFInterval"] - 20
    end
    Task.Run = true

    TaskList[Key] = Task
end

function startSingleTask(TaskTable)
 -- 移除所有协程
      AbortAllTask()
      Sleep(400)
        -- 创建所需协程
        for Key, Parameters in pairs(TaskTable) do
            AddTask(Key, Parameters)
        end
end

-- 中止所有任务
function AbortAllTask()
	if next(TaskList) ~= nil then
		for Key, Task in pairs(TaskList) do
			if Task ~= nil then
				while true do
					Task.Run = false
					local s = coroutine.resume(Task.Task, Task)
					if (not s) then
						TaskList[Key] = nil
						break
					end
				end
			end
		end
	end
end