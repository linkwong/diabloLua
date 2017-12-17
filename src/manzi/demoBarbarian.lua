ActiveButton = 5      -- �������ǰ����
ChangeButton = 4		  -- ����������ˣ�
CancelButton = 3      -- ����н�
RmouseButton = 2      -- ����Ҽ�


TableSkill = {
    ["speedRun"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "1",
        ["Interval"]   = 2300,
      },
    ["battleAngry"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "2",
        ["Interval"]   = 100000,
      },
	  
	   ["rage"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "3",
        ["Interval"]   = 500,
      },
      ["forceMove"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "x",
        ["Interval"]   = 50,
      }
      
}

TableChangeSkill = {
     ["speedRun"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "1",
        ["Interval"]   = 2300,
      },
    ["battleAngry"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "2",
        ["Interval"]   = 100000,
      },
    
     ["rage"] = {
        ["Family"]     = "kb",
        ["Arg"]        = "3",
        ["Interval"]   = 500,
      }
}

TableMouseSkill = {
      ["charge"] = {
        ["Family"]     = "mouse",
        ["Arg"]        = 3,
        ["Interval"]   = 750,  
      }
}

moveForceSin={
        ["Family"]     = "kb",
        ["Arg"]        = "x",
        ["Interval"]   = 50,
      }
--�Ƿ����ǿ���ƶ�
mfExist = false


-- ==========================================================================
-- ����Ϊ��ܴ��룬��
-- ==========================================================================

POLL_FAMILY = "mouse"	-- ��ǰ���û�� M ��״̬������������������ѯ
POLL_INTERVAL = 10		-- �ڿ�ʼ��һ����ѯǰ����ʱ(����)�����ڵ�����ѯ����
POLL_DEADTIME = 100	-- �ɵ���ѯ�¼����ľ���ʱ��

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

-- ��ѯ��ʼ��
function InitPolling()
    ActiveState = GetMKeyState_Hook(POLL_FAMILY)
    SetMKeyState_Hook(ActiveState, POLL_FAMILY)
end

-- ��ѯ
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


-- �����������

TaskList = {}

-- ���������б���ִ������Э��
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

-- ��������
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
    if Parameters["MoveF"] ~= nil then
        Task.MoveF = Parameters["MoveF"]
    end
    Task.Run = true

    TaskList[Key] = Task
end

function RemoveTask(TaskTable)
  for Key, Parameters in pairs(TaskTable) do
    if TaskList[Key] ~= nil then
      while true do
        TaskList[Key].Run = false
        local s = coroutine.resume(Task.Task, Task)
        if (not s) then
          TaskList[Key] = nil
          break
        end
      end
    end
  end
end

--ǿ���ƶ����
function checkTaskMoveF(TaskTable)
    if next(TaskList) ~= nil then
      for Key, Task in pairs(TaskList) do
        if Task ~= nil then
           if Task.MoveF ~= nil then
              mfExist = true
              return
           end
        end
      end
      mfExist = false;
    end
end


function startMouseTask(TaskTable)
    -- ��������Э��
    for Key, Parameters in pairs(TaskTable) do
        AddTask(Key, Parameters)
    end
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

-- ��ֹ��������
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