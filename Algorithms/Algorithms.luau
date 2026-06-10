--!native
--!optimize 2

local Algorithms = {}

local Iterator = require("../Containers/Iterator")

-- Copies a <code>Lua table</code> and returns it, used for inventories, trades, etc.
function Algorithms:Deepcopy(tbl: {})
   local new = table.clone(tbl)
   
   for k, v in new do
      if typeof(v) == "table" then
         new[k] = Algorithms:Deepcopy(v)
      end
   end
   
   return new
end

-- Iterates over a container, if it has an <code>iterator function</code>.
function Algorithms:ForEach(container: any, callback: (any, any) -> ())
    for k, v in container do
		callback(k, v)
    end
end

-- Finds an element key (index) by value.
function Algorithms:Find<T>(container: any, v: any?): T
	if container.Find then
		return container:Find(v)
	end
	
    for k, value in container do
	    if value == v then
			return k, value
	    end
    end
   
    return nil
end

-- Returns an element IF predicate returns <code>true</code>.
function Algorithms:FindIf<T>(container: any, predicate: (k: any, v: any) -> boolean): T
    for key, value in container do
		if predicate(key, value) then
			return key, value
		end
    end
   
    return nil
end

-- Returns an element IF predicate returns <code>false</code>
function Algorithms:FindIfNot<T>(container: any, predicate: (k: any, v: any) -> boolean): T
	for key, value in container do
		if not predicate(key, value) then
			return key, value
		end
	end
   
    return nil
end

-- Iterates over a container BY <code>reverse iterator function</code> AND returns a key (index) IF predicate returns <code>true</code>.
function Algorithms:FindLastIf<T>(container: any, predicate: (k: any, v: any) -> boolean): T
	local size = (function()
		if container.GetSize then
			return container:GetSize()
		else
			return #container
		end
	end)()
	
	local it = Iterator.new(container, size)
	
	for key, value in it:Iterate(Iterator.IterationModes.Reverse) do
		if predicate(key, value) then
			return key, value
		end
	end
	
	it:Destroy()
   
    return nil
end

-- Returns true IF ALL elements met the condtion of predicate.
function Algorithms:AllOf(container: any, predicate: (k: any, v: any) -> boolean)
   --if types.is_iterable(container) then
   --   for key, value in container do
   --      if not predicate(key, value) then
   --         return false
   --      end
   --   end
   --end
	for key, value in container do
		if not predicate(key, value) then
			return false
		end
	end
   
    return true
end

-- Returns true IF ANY element met the condition of predicate.
function Algorithms:AnyOf(container: any, predicate: (k: any, v: any) -> boolean)
	for key, value in container do
		if predicate(key, value) then
			return true
		end
	end

    return false
end

-- Returns true IF NONE of elements met the condition of predicate.
function Algorithms:NoneOf(container: any, predicate: (k: any, v: any) -> boolean)
	for key, value in container do
		if predicate(key, value) then
			return false
		end
	end

    return true
end

-- Applies a </code> transform function</code> to all elements in container and returns copy of that container with new changes.
function Algorithms:Transform(container: any, transformFunction: (k: any, v: any) -> (any)): any
	if container.Transform then
		return container:Transform(transformFunction)
	end
   
    local newContainer = {}
   
    for key, value in container do
		local newValue = transformFunction(value)
		newContainer[key] = newValue
	end
	
	return newContainer
end

return Algorithms
