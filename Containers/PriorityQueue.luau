--!native
--!optimize 2
local PriorityQueueClass = {}

local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

export type PriorityQueue<T> = {
	IsEmpty:     (self: PriorityQueue<T>) -> boolean,
   
	At:          (self: PriorityQueue<T>, index: number) -> T?,
	
	Copy:        (self: PriorityQueue<T>) -> PriorityQueue<T>,
	CopyTo:      (self: PriorityQueue<T>, to: PriorityQueue<T>) -> (),
	Transform:   (self: PriorityQueue<T>, func: (index: number, value: T) -> T) -> PriorityQueue<T>, 
	ToArray:     (self: PriorityQueue<T>) -> {T},
    
    Pop:         (self: PriorityQueue<T>) -> T,
	Push:        (self: PriorityQueue<T>, value: T) -> PriorityQueue<T>,
	Clear:       (self: PriorityQueue<T>) -> (),
	
	GetFront:       (self: PriorityQueue<T>) -> T,
	GetBack:        (self: PriorityQueue<T>) -> T,
    GetSize:     (self: PriorityQueue<T>) -> number,
    GetStorage:  (self: PriorityQueue<T>) -> {T},
	
	Destroy:     (self: PriorityQueue<T>) -> ()
}

-- Creates a new <code>Priority Queue</code>. Very useful for tasks, quests, etc.
function PriorityQueueClass.new<T>(type_t: string, comparator: (T, T) -> (boolean)): PriorityQueue<T>
    return setmetatable({
      _type_t = type_t,
      _storage = {},
      _comparator = comparator,
    }, PriorityQueue)
end

function PriorityQueue:__iter()
    return ipairs(self._storage)
end

function PriorityQueue:__len()
	return #self._storage
end

function PriorityQueue:SiftUp(index: number)
    local data = self._storage
   
    while index > 1 do
        local parentIndex = math.floor(index / 2)
      
        if self._comparator(data[index], data[parentIndex]) then
            data[index], data[parentIndex] = data[parentIndex], data[index]
            index = parentIndex
        else
            break
        end
    end
end

function PriorityQueue:SiftDown(index: number)
   local size = #self._storage
   
    while true do
        local leftChild = 2 * index
        local rightChild = 2 * index + 1
        local priorityIndex = index
      
        if leftChild <= size and self._comparator(self._storage[leftChild], self._storage[priorityIndex]) then
           priorityIndex = leftChild
        end
      
        if rightChild <= size and self._comparator(self._storage[rightChild], self._storage[priorityIndex]) then
            priorityIndex = rightChild
        end
      
        if priorityIndex == index then
            break
        end
      
        self._storage[index], self._storage[priorityIndex] = self._storage[priorityIndex], self._storage[index]
        index = priorityIndex
    end
end

function PriorityQueue:Find<T>(v: T): any
	local index = table.find(self._storage, v)

	if index then
		return index
	end
end

function PriorityQueue:Copy()
	local queue = PriorityQueueClass.new(self._type_t, self._comparator)
	
	for _, v in self do
		queue:Push(v)
	end
	
	return queue
end

function PriorityQueue:CopyTo<T>(to: PriorityQueue<T>)
	for _, v in self do
		to:Push(v)
	end
end

function PriorityQueue:Transform<T>(func: (index: number, value: T) -> any)
	local newQueue = PriorityQueueClass.new(self._type_t, self._comparator)
	
	for i, old in self do
		local newValue = func(i, old)
		newQueue._storage[i] = newValue
	end
	
	return newQueue
end

function PriorityQueue:At(index: number)
    assert(self._storage[index] == nil, "[STD-priority_queue]: bad element access (BAD_ELEMENT_ACCESS).")
    return self._storage[index]
end

function PriorityQueue:GetSize()
	return #self._storage
end

function PriorityQueue:GetStorage()
    return self._storage
end

function PriorityQueue:IsEmpty()
    return #self._storage == 0
end

function PriorityQueue:Pop()
    if self:empty() then
        warn("[STD-priority_queue]: queue is empty!")
        return
    end
   
    local data = self._storage
    local root = data[1]
    local last = #data
   
    if last > 1 then
        data[1] = data[last]
	  
		self._storage[#data] = nil
        self:SiftDown(1)
    else
        self._storage[#data] = nil
    end
   
    return root
end

function PriorityQueue:Push<T>(value: T)
    if typeof(value) ~= self._type_t then
        error("[STD-priority_queue]: cannot store different types in priority_queue!")
        return self
    end
   
	self._storage[#self._storage + 1] = value
	
    self:SiftUp(#self._storage)
   
    return self
end

function PriorityQueue:GetFront()
	return self._storage[1]
end

function PriorityQueue:GetBack()
	return self._storage[#self._storage]
end

function PriorityQueue:ToArray()
	local array = table.create(#self._storage)
	table.move(self._storage, 1, #self._storage, #self._storage, array)
	return array
end

function PriorityQueue:Destroy()
	table.clear(self._storage)
	table.clear(self)
	setmetatable(self, nil)
end

return PriorityQueueClass
