const ExceptionClass = {}
const Exception = {}
Exception.__index = Exception

export type Exception = {
	What: (self: Exception) -> (),
	Destroy: (self: Exception) -> ()
}

-- Creates a new <code>Exception</code> object. Can be catched by <code>Exception:Catch()</code> method with provided callback.
function ExceptionClass.new(exception: string, msg: string?)
	return setmetatable({
		_msg = msg,
		_exception = exception,
		_catch_handlers = {}
	}, Exception)
end

function Exception:What()
	const msg = self._msg or "Exception not handled"
	
	local dateTime = DateTime.now()
	local localTime = dateTime:ToLocalTime()
	
	--local alloc = collectgarbage("count")
	local heap = gcinfo()

	const str = string.format(
		"[%s]: %s\n\t\t\tAt: %s\t\t\tTime: %02d:%02d:%02d\n\t\t\tHeap: %i\n",
		self._exception,
		msg, debug.traceback(),
		
		localTime.Hour,
		localTime.Minute,
		localTime.Second,
		
		heap
	)
	
	return str
end

function Exception:Catch(fn: (msg: string, exceptionLevel: number) -> ())
	table.insert(self._catch_handlers, fn)
end

function Exception:Destroy()
	table.clear(self._catch_handlers)
	table.clear(self)
	setmetatable(self, nil)
end

return ExceptionClass
