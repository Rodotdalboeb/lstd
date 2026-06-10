--!native
--!optimize 2

local StackClass = {}
local Stack = {}

export type Stack = {
	Push: (self: Stack, val: any) -> (),
	Pop: (self: Stack) -> any,
	Clear: (self: Stack) -> (),
	
	At: (self: Stack, index: number) -> any?,
	GetFront: (self: Stack) -> any,
	GetBack: (self: Stack) -> any,
	GetStorage: (self: Stack) -> {any},
	GetSize: (self: Stack) -> number,
	
	Destroy: (self: Stack) -> ()
}

-- Returns a new <code>Stack</code> data structure. Can be preallocated. Very useful structure like <code>Queue or PriorityQueue</code>.
function StackClass.new(capacity: number?): Stack
	return setmetatable({
		_size = 0,
		_capacity = capacity,
		_storage = capacity and table.create(capacity) or {}
	}, Stack)
end

function Stack:__iter()
	return ipairs(self._storage)
end

function Stack:__index(key: any)
	if typeof(key) == "number" then
		if key > self._size then
			error("[Standard.Containers.Stack]: Access Violation")
			return nil
		end

		return self._storage[key]
	else
		return rawget(getmetatable(self), key)
	end
end

function Stack:__len()
	return self._size
end

function Stack:Push(val: any)
	if self._capacity and self._size >= self._capacity then
		warn("[Standard.Containers.Stack]: Stack reached capacity limit")
		return
	end
	
	self._size += 1
	self._storage[self._size] = val
end

function Stack:Pop()
	if self._size <= 0 then
		warn("[Standard.Containers.Stack]: Stack has not items")
		return nil
	end
	
	local val = self._storage[self._size]
	self._storage[self._size] = nil
	self._size -= 1
	
	return val
end

function Stack:Clear()
	table.clear(self._storage)
	self._size = 0
end

function Stack:At(index: number)
	if index > self._size then
		error("[Standard.Containers.Stack]: Access Violation")
		return nil
	end
	
	return self._storage[index]
end

function Stack:GetFront()
	return self._storage[1]
end

function Stack:GetBack()
	return self._storage[self._size]
end

function Stack:GetStorage()
	return self._storage
end

function Stack:GetSize()
	return self._size
end

function Stack:Destroy()
	table.clear(self._storage)
	self._size = 0
	table.clear(self)
	setmetatable(self, nil)
end

return StackClass
