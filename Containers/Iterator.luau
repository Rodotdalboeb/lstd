local IteratorClass = {}
IteratorClass.IterationModes = {
	Default = 0,
	Reverse = 1,
}

local Iterator = {}
Iterator.__index = Iterator

export type Iterator = {
	Iterate: (self: Iterator, mode: any?) -> (() -> (any, any)),
	GetContainer: (self: Iterator) -> any,
	
	Destroy: (self: Iterator) -> ()
}

-- Creates a new universal <code>Iterator</code> class for all standard containers.
function IteratorClass.new(container: any, size: number): Iterator
	return setmetatable({
		_size = size,
		_container = container,
	}, Iterator)
end

function Iterator:__iter()
	return self:Iterate(IteratorClass.IterationModes.Default)
end

function Iterator:Iterate(mode: any)
	if not mode or mode == IteratorClass.IterationModes.Default then
		local index = 0

		return function()
			index += 1
			if index > self._size then return nil end
			return index, self._container._storage and self._container._storage[index] or self._container[index]
		end
	else
		local index = self._size + 1

		return function()
			index -= 1

			if index <= 0 then return nil end
			return index, self._container._storage and self._container._storage[index] or self._container[index]
		end
	end
end

function Iterator:GetContainer()
	return self._container
end

function Iterator:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return IteratorClass
