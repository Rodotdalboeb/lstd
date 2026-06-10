const Stopwatch = require("./Stopwatch")
const Exception = require("./Exception")

export type Stopwatch = Stopwatch.Stopwatch
export type Exception = Exception.Exception

local Profiling = { Logging = {} }
Profiling.Logging.LogLevel = { Message = 0, Warning = 1, Error = 2 }

Profiling.Stopwatch = Stopwatch
Profiling.Exception = Exception

function Profiling.Benchmark(func: (...any) -> (), iters: number, ...)
	local start = os.clock()
	
	for i = 0, iters do
		func(...)
	end
	
	local _end = os.clock() - start
	return _end
end

function Profiling.GetMemoryUsage()
	return collectgarbage("count")
end

function Profiling.GetHeapAllocatedMemory()
	return gcinfo()
end

function Profiling.GetFunctionAllocations(func: (...any) -> (...any), ...)
	local before = collectgarbage("count")
	
	local result = {pcall(func, ...)}
	
	local after = collectgarbage("count")
	local overall = math.max(0, after - before)
	
	local success = result[1]
	
	if success then
		return overall, true, table.unpack(result, 2)
	else 
		return overall, true, result[2]
	end
end

function Profiling.SetLabelAndExecute(label: string, func: (...any) -> (...any), ...)
	debug.profilebegin(label)
	
	local res = {pcall(func, ...)}
	
	debug.profileend()
	
	return res[1], table.unpack(res, 2)
end

function Profiling.Logging.ThrowException(e: Exception, level: any?)
	if #e._catch_handlers > 0 then
		for _, fn in e._catch_handlers do
			task.spawn(fn, e:What(), level)
		end
		
		return
	end
	
	if level == Profiling.Logging.LogLevel.Message then
		print(e:What())
	elseif level == Profiling.Logging.LogLevel.Warning then
		warn(e:What())
	elseif level == Profiling.Logging.LogLevel.Error then
		error(e:What())
	else
		warn(e:What())
	end
end

return Profiling
