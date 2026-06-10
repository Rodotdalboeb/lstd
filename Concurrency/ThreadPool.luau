local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local Future = require("./Future")

local shTable = SharedTable.new()
SharedTableRegistry:SetSharedTable("Results", shTable)

local ThreadPoolClass = {}
local ThreadPool = {}
ThreadPool.__index = ThreadPool

export type ThreadPool = {
	CreateThreads: (self: ThreadPool) -> (),
	GetFreeThread: (self: ThreadPool) -> { actor: Actor, is_busy: boolean }?,
	
	AddTask: (self: ThreadPool, funcName: string, args: {any}) -> any,
	CancelTask: (self: ThreadPool, taskId: number) -> (),
	
	Destroy: (self: ThreadPool) -> ()
}

-- Returns a new <code>Thread Pool</code> class that used to execute tasks in parallel threads. Requires module script which contains functions. Executes tasks in parallel-programming model.
function ThreadPoolClass.new(threads: number)
	return setmetatable({
		_max_threads = threads,
		_tasks = {},
		_workers = {},
		_is_server = RunService:IsServer(),
		_thread_pool_id = HttpService:GenerateGUID(false),
		_search_index = 1,
		_poll_connection = nil,
	}, ThreadPool)
end

function ThreadPoolClass.ResetResultsTable()
	SharedTable.clear(shTable)
end

function ThreadPool:CreateThreads(onCreated: () -> ())
	for i = 1, self._max_threads do
	    local actor = Instance.new("Actor")
		actor.Name = `{self._thread_pool_id}_Worker_{i}`
		
		if self._is_server then
			actor.Parent = script.ServerThreads
				
			local serverTemplate = script.Templates.ServerTemplate:Clone()
			serverTemplate.Name = "ServerScriptWorker"
			serverTemplate.Enabled = true
			serverTemplate.Parent = actor
		else
			actor.Parent = script.ClientThreads
			 
			local clientTemplate = script.Templates.ClientTemplate:Clone()
			clientTemplate.Name = "ClientWorkerTemplate"
			clientTemplate.Enabled = true
			clientTemplate.Parent = actor
		end
		
		table.insert(self._workers, {
			is_busy = false,
			actor = actor,
			worker_id = i,
		})
	end
	
	--self._listen_connection = taskFinished.Event:Connect(function(workerId: number, taskId: number, result: {any})
	--	local tsk = self._tasks[taskId]
		
	--	if tsk then
	--		tsk.future._value = result
	--		tsk.future._is_ready = true
			
	--		self._workers[workerId].is_busy = false
	--	end
	--end)
	self._poll_connection = RunService.Heartbeat:Connect(function()
		for taskId, result in shTable do
			local tsk = self._tasks[taskId]
			
			print(taskId)
	
			if tsk then
				tsk.future._is_ready = true
				tsk.future._value = SharedTable.clone(result, true)
			end
		end
	end)
	
	task.delay(5, onCreated)
end

function ThreadPool:GetFreeThread()
	local startIndex = self._search_index
	
	for i = 1, self._max_threads do
		local worker = self._workers[startIndex]
		
		startIndex += 1
		
		if startIndex > self._max_threads then
			startIndex = 1
		end
		
		if not worker.is_busy then
			return worker
		end
	end
	
	return nil
end

function ThreadPool:AddTask(moduleInstance: ModuleScript, funcName: string, args: {any}?)
	args = args or {}
	
	local worker = self:GetFreeThread()
	
	if not worker then warn("[Standard.Concurrency.ThreadPool]: All workers are busy!") return end
	
	local taskId taskId= Random.new():NextInteger(1, 1000000)
	worker.actor:SendMessage("ExecuteTask", moduleInstance, worker.worker_id, taskId, funcName, args)
	
	worker.is_busy = true
	
	local future = Future.new()
	self._tasks[taskId] = {
		future = future,
		worker = worker.actor
	}
	
	return future, taskId
end

function ThreadPool:CancelTask(taskId: number)
	local tsk = self._tasks[taskId]
	
	if tsk then
		tsk.actor:SendMessage("CancelTask", taskId)
		tsk.future:Destroy()
		self._tasks[taskId] = nil
	end
end

function ThreadPool:DeleteTask(taskId: any)
	self._tasks[taskId] = nil
	shTable[taskId] = nil
end

function ThreadPool:Destroy()
	for _, worker in self._workers do
		worker.actor:Destroy()
	end
	
	table.clear(self._workers)
	
	for _, tsk in self._tasks do
		tsk.future:Destroy()
	end
	
	table.clear(self._tasks)
	
	self._listen_connection:Disconnect()
	
	table.clear(self)
	setmetatable(self, nil)
end

return ThreadPoolClass
