const StopwatchClass = {}
const Stopwatch = {}
Stopwatch.__index = Stopwatch

export type Stopwatch = {
	Start: (self: Stopwatch) -> (),
	Stop: (self: Stopwatch) -> number,
	Reset: (self: Stopwatch) -> (),
	Destroy: (self: Stopwatch) -> ()
}

-- Creates a new <code>Stopwatch</code> class. Used for profiling, and measuring execution time.
function StopwatchClass.new()
	return setmetatable({
		_start = 0,
		_end = 0,
	}, Stopwatch)
end

function Stopwatch:Start()
	self._start = os.clock()
end

function Stopwatch:Stop()
	self._end = os.clock()
	return self._end - self._start
end

function Stopwatch:Reset()
	self._start = 0
	self._end = 0
end

function Stopwatch:Destroy()
	self._start = 0
	self._end = 0
	
	setmetatable(self, nil)
end

return StopwatchClass
