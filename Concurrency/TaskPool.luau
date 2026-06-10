local RunService = game:GetService("RunService")

local TaskPoolClass = {}

local Queue = require("../Containers/Queue")
local Future = require("./Future")

local TaskPool = {}
TaskPool.__index = TaskPool

export type TaskPool = {
	CreateThreads: (self: TaskPool) -> (),
	
	AddTask: (self: TaskPool) -> number,
	GetResult: (self: TaskPool, taskId: number) -> (),
}

-- An object that manages a tasks. Tasks executed by cooperative-multithreading model (via task.spawn() to create threads).
function TaskPoolClass.new(threads: number)
	return setmetatable({
		_max_threads = threads,
		_tasks = Queue.new("table"),
		_threads = {},
	}, TaskPool)
end

function TaskPool:CreateThreads()
	for i = 0, self._max_threads do
		table.insert(self._threads, task.spawn(function()
			while self do
				while self._tasks:IsEmpty() do task.wait() end
				
				local currentTask = self._tasks:Pop()
				local success, data = pcall(currentTask.fn, table.unpack(currentTask.args))
				
				if success then
					currentTask.future._value = data
					currentTask.future._is_ready = true
				end
			end
		end))
	end
end

function TaskPool:AddTask<T>(fn: (...any) -> {any}, args: {any}): Future.Future<T>
	local newTask = {
		fn = fn,
		args = args or {},
		future = Future.new()
	}
	
	self._tasks:Push(newTask)
	
	return newTask.future
end

function TaskPool:AddTasks<T>(fns: {(...any) -> {any}}, args: {{any}}): {Future.Future<T>}
	args = args or {}
	local futures = {}
	
	
	for index, func in fns do
		local funcArgs = args[index]
		if not funcArgs then funcArgs = {} end
		
		local future = self:AddTask(func, funcArgs) :: Future.Future<T>
	    table.insert(futures, future)
	end
	
	return futures
end

function TaskPool:Destroy()
	table.clear(self._returns)
	table.clear(self._tasks)
	
	for _, thread in self._threads do
		coroutine.close(thread)
	end
	
	table.clear(self)
	setmetatable(self, nil)
end

return TaskPoolClass
