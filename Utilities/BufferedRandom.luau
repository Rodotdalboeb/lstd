local BufferedRandomClass = {}

local BufferedRandom = {}
BufferedRandom.__index = BufferedRandom

export type BufferedRandom = {
   GetLast: (self: BufferedRandom) -> number,
   GetBuffer: (self: BufferedRandom) -> buffer,
   GetBufferSize: (self: BufferedRandom) -> number,
   
   Fill: (self: BufferedRandom) -> (),
   Next: (self: BufferedRandom) -> number,
   Reset: (self: BufferedRandom) -> (),
   
   Destroy: (self: BufferedRandom) -> ()
}

-- Creates a new <code>BufferedRandom</code>. It is just a normal random, but stores results of operations.
function BufferedRandomClass.new(dist0: number, dist1: number, buffer_size: number, seed: number?): BufferedRandom
    return setmetatable({
        _size = buffer_size,
        _range0 = dist0,
        _range1 = dist1,
        _random = Random.new(seed),
      
        _ptr = 0,
        _last = 0,
        _buffer = buffer.create(buffer_size)
    }, BufferedRandom)
end

function BufferedRandom:Reset(newSize: number?)
   self._ptr = 0
   self._last = 0
   self._buffer = buffer.create( (newSize ~= nil and newSize) or self._size )
end

function BufferedRandom:Next(float: boolean?): number
    if self._ptr < buffer.len(self._buffer) then
	    local num = 0
	  
	    if float then
			num = self._random:NextNumber(self._range0, self._range1)
	    else
			num = self._random:NextInteger(self._range0, self._range1)
		end
		
        self._last = num

		if float then
			buffer.writef32(self._buffer, self._ptr, num)
			self._ptr += 4
		else
			buffer.writeu32(self._buffer, self._ptr, num)
            self._ptr += 4
		end

        return num
	end
	
    return 0
end

function BufferedRandom:Fill()
   for i = 0, buffer.len(self._buffer) do
      self:Next()
   end
end

function BufferedRandom:GetLast()
   return self._last
end

function BufferedRandom:GetBuffer()
   return self._buffer
end

function BufferedRandom:GetBufferSize()
	return buffer.len(self._buffer)
end

function BufferedRandom:Destroy()
   table.clear(self)
   
   setmetatable(self, nil)
end

return BufferedRandomClass
