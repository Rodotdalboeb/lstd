local RunService = game:GetService("RunService")

local FutureClass = {}
FutureClass.DefaultWaitTime = math.huge

local Future = {}
Future.__index = Future

export type Future<T> = {
	Wait: (self: Future<T>, waitTime: number?) -> number,
	Get:  (self: Future<T>) -> T,
	
	IsReady: (self: Future<T>) -> boolean,
	
	Destroy: (self: Future<T>) -> ()
}

-- Creates a new <code>Future</code> object. Returned by asynchronous tasks, which provides a simple interface to get data, or wait.
function FutureClass.new()
	return setmetatable({
		_is_ready = false,
		_value = nil
	}, Future)
end

function Future:Wait(waitTime: number?)
	waitTime = waitTime or FutureClass.DefaultWaitTime
	
	local timeWait = 0
	
	while not self._value do
		timeWait += task.wait(1)
		
		if timeWait >= waitTime then
			warn("[Standard.Concurrency.Future]: Future not ready!")
			break
		end
	end

	return timeWait
end

function Future:IsReady()
	return self._is_ready
end

function Future:Get()
	if self._is_ready then
		return self._value
	end
	
	self:Wait()
	return self._value
end

function Future:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return FutureClass
