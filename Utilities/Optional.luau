local OptionalClass = {}

local Optional = {}
Optional.__index = Optional

export type Optional = {
   HasValue: (self: Optional) -> boolean,
   GetValue: (self: Optional) -> any?,
   GetValueType: (self: Optional) -> string,
   
   SetValue: (self: Optional, value: any) -> any?,
   
   Destroy: (self: Optional) -> (),
}

-- Creates a new <code>Optional</code> container. Type safe and can store different values
function OptionalClass.new<T>(types: {string}, value: T?): Optional
   return setmetatable({
      _types = types,
      _value = if not table.find(types, typeof(value)) then "nullopt" else value
   }, Optional)
end

function Optional:__tostring()
	return tostring(self._value)
end

function Optional:HasValue()
   return self._value == nil or self._value == "nullopt"
end

function Optional:SetValue<T>(value: T)
   if not table.find(self._types, typeof(value)) then
      error("[Standard.Utilities.Optional]: Provided value is not specified in constructor")
      return nil
   end
   
   local old = self._value
   self._value = value
   
   return old
end

function Optional:GetValue()
   return self._value
end

function Optional:GetValueType()
   if self._value == "nullopt" or self._value == nil then
      return "nullopt"
   end
   
   local types = self._types
   local valueType = typeof(self._value)
   
   local index = table.find(types, valueType)
   return types[index]
end

function Optional:Destroy()
   self._value = nil
   table.clear(self._types)
  
   setmetatable(self, nil)
end

return OptionalClass
