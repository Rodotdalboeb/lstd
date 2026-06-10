local BufferStream = {}
BufferStream.__index = BufferStream

local BufferStreamClass = {}

export type BufferStream = {
   Reset: (self: BufferStream) -> (),
   SeekTo: (self: BufferStream, cursor: number) -> (),
   
   WriteU8:  (self: BufferStream, v: number) -> (),
   WriteU16: (self: BufferStream, v: number) -> (),
   WriteU32: (self: BufferStream, v: number) -> (),
   
   WriteI8:  (self: BufferStream, v: number) -> (),
   WriteI16: (self: BufferStream, v: number) -> (),
   WriteI32: (self: BufferStream, v: number) -> (),
   
   WriteF32: (self: BufferStream, v: number) -> (),
   WriteF64: (self: BufferStream, v: number) -> (),
   
   WriteString: (self: BufferStream, str: string) -> (),
   WriteVector: (self: BufferStream, v: vector) -> (),
   
   ReadU8:  (self: BufferStream) -> number?,
   ReadU16: (self: BufferStream) -> number?,
   ReadU32: (self: BufferStream) -> number?,
   
   ReadI8:  (self: BufferStream) -> number?,
   ReadI16: (self: BufferStream) -> number?,
   ReadI32: (self: BufferStream) -> number?,
   
   ReadF32: (self: BufferStream) -> number?,
   ReadF64: (self: BufferStream) -> number?,
   
   ReadString: (self: BufferStream) -> string?,
   ReadVector: (self: BufferStream) -> vector?,
   
   GetBuffer: (self: BufferStream) -> buffer,
   
   Destroy: (self: BufferStream) -> (),
}

-- Creates a new buffer stream. Very useful to pack data in binary format.
function BufferStreamClass.new(b: buffer?): BufferStream
    return setmetatable({
        _capacity = (b ~= nil and buffer.len(b)) or 32,
	    _buffer = b or buffer.create(32),
	    _read_cursor = 0,
        _write_cursor = 0,
     -- p_storage = {}
    }, BufferStream)
end

--function bfstream.realloc()
--   
--end

function BufferStream:SeekToRead(cursor: number)
	self._read_cursor = cursor
end

function BufferStream:SeekToWrite(cursor: number)
	self._write_cursor = cursor
end

function BufferStream:SeekTo(cursor: number)
	cursor = math.clamp(cursor, 0, buffer.len(self._buffer))
    self._read_cursor = cursor
    self._write_cursor = cursor
end

function BufferStream:ResetRead()
   self._read_cursor = 0
end

function BufferStream:ResetWrite()
	self._write_cursor = 0
end

function BufferStream:Reset()
	self._read_cursor = 0
	self._write_cursor = 0
end

function BufferStream:WriteU8(v: number)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end

    buffer.writeu8(self._buffer, self._write_cursor, v)
    self._write_cursor += 1
end

function BufferStream:WriteU16(v: number)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end
   
    buffer.writeu16(self._buffer, self._write_cursor, v)
    self._write_cursor += 2
end

function BufferStream:WriteU32(v: number)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end

    buffer.writeu32(self._buffer, self._write_cursor, v)
    self._write_cursor += 4
end

function BufferStream:WriteI8(v: number)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end

    buffer.writei8(self._buffer, self._write_cursor, v)
    self._write_cursor += 1
end

function BufferStream:WriteI16(v: number)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end

    buffer.writei16(self._buffer, self._write_cursor, v)
    self._write_cursor += 2
end

function BufferStream:WriteI32(v: number)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end

    buffer.writei16(self.p_buffer, self._write_cursor, v)
    self._write_cursor += 4
end

function BufferStream:WriteF32(v: number)
    if self._write_cursor >= self._capacity then
        warn("[STD-bufstream]: buffer overflow!")
        return
    end

    buffer.writeu16(self._buffer, self._write_cursor, v)
    self._write_cursor += 4
end

function BufferStream:WriteF64(v: number)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end

    buffer.writeu16(self._buffer, self._write_cursor, v)
    self._write_cursor += 8
end

function BufferStream:WriteString(str: string)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end
   
    local len = #str
    buffer.writei32(self._buffer, self._write_cursor, len)
    self._write_cursor += 4
   
    buffer.writestring(self._buffer, self._write_cursor, str, len)
    self._write_cursor += len
end

function BufferStream:WriteVector(v: vector)
    if self._write_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
        return
    end
   
    local x = v.x -- 4 bytes
    local y = v.y -- 4 bytes
    local z = v.z -- 4 bytes, total: 12 bytes
   
    local arr = {x, y, z}
  
    for _, component in arr do
        buffer.writef32(self._buffer, self._write_cursor, component)
        self._write_cursor += 4
    end
end

function BufferStream:ReadU8()
   if self._read_cursor >= self._capacity then
      warn("[Standard.Io.BufferStream]: Buffer overflow")
      return
   end

   local v = buffer.readu8(self._buffer, self._read_cursor)
   self._read_cursor += 1
   return v
end

function BufferStream:ReadU16()
	if self._read_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
		return
	end

	local v = buffer.readu16(self._buffer, self._read_cursor)
	self._read_cursor += 2
	return v
end

function BufferStream:ReadU32()
	if self._read_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
		return
	end

	local v = buffer.readu32(self._buffer, self._read_cursor)
	self._read_cursor += 4
	return v
end

function BufferStream:ReadI8()
	if self._read_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
		return
	end

	local v = buffer.readi8(self._buffer, self._read_cursor)
	self._read_cursor += 1
	return v
end

function BufferStream:ReadI16()
	if self._read_cursor >= self._capacity then
		function BufferStream:ReadU8()
			if self._read_cursor >= self._capacity then
				warn("[Standard.Io.BufferStream]: Buffer overflow")
				return
			end

			local v = buffer.readu8(self._buffer, self._read_cursor)
			self._read_cursor += 1
			return v
		end
		return
	end

	local v = buffer.readi16(self._buffer, self._read_cursor)
	self._read_cursor += 2
	return v
end

function BufferStream:ReadI32()
	if self._read_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
		return
	end

	local v = buffer.readi32(self._buffer, self._read_cursor)
	self._read_cursor += 4
	return v
end

function BufferStream:ReadF32()
	if self._read_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
		return
	end

	local v = buffer.readf32(self._buffer, self._read_cursor)
	self._read_cursor += 4
	return v
end

function BufferStream:ReadF64()
	if self._read_cursor >= self._capacity then
		warn("[Standard.Io.BufferStream]: Buffer overflow")
		return
	end

	local v = buffer.readf64(self._buffer, self._read_cursor)
	self._read_cursor += 8
	return v
end

function BufferStream:ReadString()
    if self._read_cursor >= self._capacity then
        warn("[STD-bufstream]: buffer overflow!")
        return
    end
   
    local len = buffer.readu32(self._buffer, self._read_cursor)
    self._read_cursor += 4
    
    local string = buffer.readstring(self._buffer, self._read_cursor, len)
    self._read_cursor += len
   
    return string
end

function BufferStream:ReadVector()
    if self._read_cursor >= self._capacity then
        warn("[STD-bufstream]: buffer overflow!")
        return
    end
   
    local arr = {}
   
    for i = 0, 3 do
        local component = buffer.readf32(self._buffer, self._read_cursor)
        self._read_cursor += 4
        table.insert(arr, component)
    end
   
    local vector = vector.create(arr[1], arr[2], arr[3])
    return vector
end

function BufferStream:GetBuffer()
    return self._buffer
end

function BufferStream:Destroy()
    setmetatable(self, nil)
end

return BufferStreamClass
