--!native
--!optimize 2
local QueueClass = {}

local Queue = {}
Queue.__index = Queue

export type Queue<T> = {
	IsEmpty:         (self: Queue<T>) -> boolean,
	
	At:              (self: Queue<T>, i: number) -> T,
	Find:            (self: Queue<T>, value: number) -> number,
	
	Copy:            (self: Queue<T>) -> Queue<T>,
	CopyTo:          (self: Queue<T>, to: Queue<T>) -> (),
	Transform:       (self: Queue<T>, func: (index: number, value: T) -> T) -> Queue<T>,
	ToArray:         (self: Queue<T>) -> {T},
	
	Pop:         (self: Queue<T>) -> T,
	Push:         (self: Queue<T>, value: T) -> Queue<T>,
	Clear:           (self: Queue<T>) -> (),
	Reserve:         (self: Queue<T>, size: number) -> (),
	
	GetFront:           (self: Queue<T>) -> T,
	GetBack:            (self: Queue<T>) -> T,
	GetSize:         (self: Queue<T>) -> number,
	GetStorage:      (self: Queue<T>) -> {T},
	
	Destroy:         (self: Queue<T>) -> ()
}

-- Creates a new basic <code<Queue</code> data structure. Good for organizing tasks.
function QueueClass.new<T>(queue_type: string): Queue<T>
   local q = {}
   q._type = queue_type
   q._storage = {}
   q._first = 1
   q._last = 0
   return setmetatable(q, Queue)
end

function Queue:__iter()
    return ipairs(self._storage)
end

function Queue:__len()
	return #self._storage
end

function Queue:Find<T>(v: T): any
    local index = table.find(self._storage, v)
   
    if index then
        return index
    end
end

function Queue:Copy()
    local new = Queue.new(self._type)
   
    for _, v in self do
        new:Push(v)
    end
   
    return new
end

function Queue:CopyTo<T>(to: Queue<T>)
    for _, v in self do
        to:Push(v)
    end
end

function Queue:Transform<T>(func: (index: number, value: T) -> T)
    local newQueue = Queue.new(self._type)
   
    for i, old in self:data() do
		local newValue = func(i, old)
		newQueue:Push(newValue)
    end
   
    return newQueue
end

function Queue:Reserve(size: number)
    if #self._storage == 0 then
        self._storage = table.create(size)
    else
        local old = self._storage
        local first = self._first
        local last  =  self._last
      
        self._storage = table.create(size)
      
        table.move(old, 1, #old, #self._storage + 1, self._storage)
      
        self._last  =  last
        self._first = first
    end
end

function Queue:Clear()
    table.clear(self:data())
   
    self._first = 1
    self._last = 0
end

function Queue:At(i: number)
	assert(self._storage[i] == nil, `[Standard.Containers.Queue]: Failed to get element at index {i}!`)
	return self._storage[i]
end

function Queue:GetSize()
    return #self._storage
end

function Queue:GetStorage()
    return self._storage
end

function Queue:IsEmpty()
    return self._first > self._last
end

function Queue:ToArray()
	local array = table.create(#self._storage)
	table.move(self._storage, 1, #self._storage, #self._storage, array)
	return array
end

function Queue:Push<T>(value: T)
    local last = self._last + 1
    self._last = last
    self._storage[last] = value
    return self
end

function Queue:Pop<T>(): T
    if #self._storage == 0 then
        error("[STD-queue]: cannot dequeue empty queue!")
        return nil
    end
   
    local first = self._first
    local val   = self._storage[first]
    self._storage[first] = nil
    self._first += 1
   
    return val
end

function Queue:GetFront()
	return self._storage[1]
end

function Queue:GetBack()
	return self._storage[#self._storage]
end

function Queue:Destroy()
	table.clear(self._storage)
    setmetatable(self, nil)
end

return QueueClass
