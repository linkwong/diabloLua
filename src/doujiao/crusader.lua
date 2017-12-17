-- ����ű������趨
ActiveButton = 5      -- �������ǰ����
ChangeButton = 4      -- ����������ˣ�
CancelButton = 3      -- ����н�

--���׼���
TableBigSkill = {
  -- ÿ200����ǿ���ƶ������X����Ϊǿ���ƶ�
    ["yidong"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "x",
        ["Interval"]   = 200,
      },
    -- ÿ250����������2����������Ǵ��tianqian��
    ["tianqian"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "1",
        ["Interval"]   = 640,
      },
    -- ÿ200����������2�������ֳ���chaofeng��
    ["chaofeng"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "2",
        ["Interval"]   = 200,
      },
  -- ÿ200����������3���������ɷ���lvfa��
    ["lvfa"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "3",
        ["Interval"]   = 200,
      },
  -- ÿ250����������4�������ֱ���bianshen��
    ["bianshen"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "4",
        ["Interval"]   = 250,
      },
    -- ������������������ܣ�attacking��
    ["attacking"] = {
        ["Family"]     = "mouse",
        ["Arg"]        = 1,
        ["Interval"]   = 200,
      },
   -- �������Ҽ����������ܣ�attacking��
    ["rightclick"] = {
        ["Family"]     = "mouse",
        ["Arg"]        = 3,
        ["Interval"]   = 200,
      }
}
-- ������
TableSmallSkill = {
    ["yidong"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "x",
        ["Interval"]   = 200,
      },
    -- ÿ250����������2����������Ǵ��tianqian��
    ["tianqian"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "1",
        ["Interval"]   = 640,
      },
    -- ÿ200����������2�������ֳ���chaofeng��
    ["chaofeng"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "2",
        ["Interval"]   = 200,
      },
  -- ÿ200����������3���������ɷ���lvfa��
    ["lvfa"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "3",
        ["Interval"]   = 200,
      },
  -- ÿ250����������4�������ֱ���bianshen��
    ["bianshen"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "4",
        ["Interval"]   = 250,
      },
    -- ������������������ܣ�attacking��
    ["attacking"] = {
        ["Family"]     = "mouse",
        ["Arg"]        = 1,
        ["Interval"]   = 80,        
      }
}

-- ����Ҽ��Ĳ�
TableGambleSkill = {
    ["rightclick"] = {
        ["Family"]     = "mouse",
        ["Arg"]        = 3,
        ["Interval"]   = 20,
      }
}


-- ==========================================================================
-- ����Ϊ��ܴ��룬��
-- ==========================================================================

POLL_FAMILY = "mouse" -- ��ǰ���û�� M ��״̬������������������ѯ
POLL_INTERVAL = 10    -- �ڿ�ʼ��һ����ѯǰ����ʱ(����)�����ڵ�����ѯ����
POLL_DEADTIME = 100 -- �ɵ���ѯ�¼����ľ���ʱ��

-- Ϊ�˱�������Զ�������޷���ԭ��갴����ǰ״̬������˺��������Զ����ǰ��������ԭ����״̬
function PressAndReleaseMouseButtonAccurate(mArg)
    if IsMouseButtonPressed(mArg) then
        ReleaseMouseButton(mArg)
        PressMouseButton(mArg)
    else
        PressAndReleaseMouseButton(mArg)
    end
end

-- ���ּ����Զ����� Э��
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

-- ��������Զ���� Э��
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
    if event == "MOUSE_BUTTON_PRESSED" and arg == ActiveButton  then
        startSingleTask(TableSmallSkill)
    elseif event == "MOUSE_BUTTON_RELEASED" and arg == ActiveButton  then
        AbortAllTask()
    elseif arg == ChangeButton then
        startSingleTask(TableBigSkill)
    elseif event == "MOUSE_BUTTON_PRESSED" and  arg == CancelButton then
        for Key, Parameters in pairs(TableGambleSkill) do
            AddTask(Key, Parameters)
        end
    elseif event == "MOUSE_BUTTON_RELEASED" and  arg == CancelButton then
        AbortAllTask()
    elseif event == "PROFILE_ACTIVATED" then
        --  ��ʼ��
      --  ClearLog()
       -- OutputLogMessage("Script started !\n")
--        OutputLogMessage("Actual attack speed = "..ActualAttackSpeed.."\n")
        -- ��ѯ��ʼ��
        InitPolling()
    elseif event == "PROFILE_DEACTIVATED" then
    end
    DoTasks()
    Poll(event, arg, family, st)
end

function startSingleTask(TaskTable)
 -- �Ƴ�����Э��
      AbortAllTask()
      Sleep(400)
        -- ��������Э��
        for Key, Parameters in pairs(TaskTable) do
            AddTask(Key, Parameters)
        end
end

-- ��ѯ��ʼ��
function InitPolling()
    ActiveState = GetMKeyState_Hook(POLL_FAMILY)
    SetMKeyState_Hook(ActiveState, POLL_FAMILY)
end

-- ��ѯ
function Poll(event, arg, family, st)
    if st == nil and StateTimer ~= nil then return end
--    if st ~= nil then OutputLogMessage("event:"..event.."  arg:"..arg.."  family:"..family.."  st:"..st.."\n"); end
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


-- ���������

TaskList = {}

-- ���������б�ִ������Э��
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

-- �������
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

-- ��ֹ��������
function AbortAllTask()
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