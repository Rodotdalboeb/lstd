--!native
--!optimize 2

local BufferStream = require("../InputOutput/BufferStream")

local validDataTypes = {"number", "string", "boolean"}

local ArrayClass = {}

export type Array<T> = {
	IsEmpty: (self: Array<T>) -> boolean,
	
	At: (self: Array<T>, index: number) -> any,
	Set: (self: Array<T>, index: number, value: T) -> (),
	Fill: (self: Array<T>, value: T) -> (),
	Clear: (self: Array<T>) -> (),
	
	GetBack: (self: Array<T>) -> any,
	GetFront: (self: Array<T>) -> any,
	GetSize: (self: Array<T>) -> number,
	GetStorage: (self: Array<T>) -> {any},
	GetCapacity: (self: Array<T>) -> number,
	
	Destroy: (self: Array<T>) -> ()
}

local Array = {}

-- Creates a new <code>Array</code> data structure. Memory allocated once for all object lifetime, which means it's a static array.
function ArrayClass.new<T>(capacity: number): Array<T>
	return setmetatable({
		_capacity = capacity,
		_storage = table.create(capacity),
		_size = 0
	}, Array)
end

function ArrayClass.fromBuffer<T>(capacity: number, buf: buffer, dataType: string, count: number): Array<T>
	if not table.find(validDataTypes, dataType) then 
		error("[Standard.Containers.Array]: Cannot construct Array from buffer with not valid types!") 
		return nil
	end
	
	if buffer.len(buf) > capacity then 
		error("[Standard.Containers.Array]: Buffer overflow")
		return nil
	end
	
	if count > capacity  then
		error("[Standard.Containers.Array]: Count is larger than capacity!")
		return nil
	end
	
	local storage = table.create(capacity)
	
	local stream = BufferStream.new(buf)
	
	if dataType == "string" then
		for i = 1, count do
			local str = stream:read_string()
			storage[i] = str
		end
	elseif dataType == "number" then
		for i = 1, count do
			local number = stream:read_f32()
			storage[i] = number
		end
	elseif dataType == "boolean" then
		for i = 1, count do
			local bool = stream:read_u8()
			storage[i] = bool
		end
	end
	
	return setmetatable({
		_capacity = capacity,
		_storage = storage,
		_size = count
	}, Array)
end

function Array:__index(index: any)
	if typeof(index) == "number" then
		if index < 1 or index > self._capacity then error("[Standard.Containers.Array]: Out of bounds!") end
		return self._storage[index]
	else
		return rawget(getmetatable(self), index)
	end
end

function Array:__newindex(index: any, value: any)
	if typeof(index) == "number" then
		if index < 1 or index > self._capacity then error("[Standard.Containers.Array]: Out of bounds!") end
		self._storage[index] = value
		self._size += 1
	else
		error("[Standard.Containers.Array]: Access Violation")
	end
end

function Array:__iter()
	return ipairs(self._storage)
end

function Array:__len()
	return self._size
end

function Array:IsEmpty()
	return self._size == 0 or #self._storage == 0
end

function Array:At(index: number): any
	if index < 1 or index > self._capacity then error("[Standard.Containers.Array]: Out of bounds!") return nil end
	if not self._storage[index] then error("[Standard.Containers.Array]: This item does not exist!") return nil end
	return self._storage[index]
end

function Array:Set<T>(index: number, value: T)
	if index < 1 or index > self._capacity then error("[Standard.Containers.Array]: Out of bounds!") return end
	self._storage[index] =  value
	self._size += 1
end

function Array:Fill<T>(value: T)
	for i = 1, self._capacity do
		self._storage[i] = value
		self._size += 1
	end
end

function Array:Clear()
	table.clear(self._storage)
	self._size = 0
end

function Array:GetFront(): any
	return self._storage[1]
end

function Array:GetBack(): any
	return self._storage[self._size]
end

function Array:GetData(): {any}
	return self._storage
end

function Array:GetSize()
	return self._size
end

function Array:GetCapacity()
	return self._capacity
end

function Array:Destroy()
	table.clear(self._storage)
	table.clear(self)
	setmetatable(self, nil)
end

return ArrayClass
