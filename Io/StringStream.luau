local StringStream = {}

local bufstream = require("./BufferStream")

local Stream = {}
Stream.__index = Stream

export type StringStream = {
   Read: (self: StringStream) -> string?,
   Write: (self: StringStream, str: string) -> StringStream,
   Clear: (self: StringStream) -> (),
   
   Reset: (self: StringStream) -> (),
   ResetRead: (self: StringStream) -> (),
   ResetWrite: (self: StringStream) -> (),
   
   SeekTo: (self: StringStream, cursor: number) -> (),
   SeekToRead: (self: StringStream, cursor: number) -> (),
   SeekToWrite: (self: StringStream, cursor: number) -> (),
   
   GetString: (self: StringStream) -> string,
}

-- Creates a new string stream object. Used for storing strings like in C++.
function StringStream.new(): StringStream
    return setmetatable({
        _buffer = {},
		_write_cursor = 0,
		_read_cursor = 1,
    }, Stream)
end

function Stream:__add(str: string)
	if type(str) ~= "string" then
		error("[Standard.Io.StringStream]: Cannot insert non-string object!")
		return self
	end
	
	self:Write(str)
	return self
end

function Stream:Write(str: string)
   table.insert(self._buffer, str)
   self._write_cursor += 1
   return self
end

function Stream:Read()
    if self._read_cursor > #self._buffer then
		warn("[Standard.Io.StringStream]: Insert a new string before reading!")
		return ""
    end
   
    local str = self._buffer[self._read_cursor]
    self._read_cursor += 1
    return str
end

function Stream:Clear()
	self:Reset()
	table.clear(self._buffer)
end

function Stream:Reset()
	self._read_cursor = 1
	self._write_crusor = 0
end

function Stream:ResetRead()
    self._read_cursor = 1
end

function Stream:ResetWrite()
	self._write_cursor = 0
end

function Stream:SeekTo(cursor: number)
	self._read_cursor = cursor
	self._write_cursor = cursor
end

function Stream:SeekToRead(cursor: number)
    self._read_cursor = cursor
end

function Stream:SeekToWrite(cursor: number)
	self._write_cursor = cursor
end

function Stream:GetString()
    return table.concat(self._buffer, " ")
end

-- Creates a buffer from the strings.
function Stream:GetBuffer(size: number?)
    local stream = bufstream.new(buffer.create(size or 1024))
   
    for _, str in self._buffer do
        stream:write_string(str)
    end
   
    local buf = stream:get_buf()
    stream:destroy()
   
    return buf
end

function Stream:GetSize()
    return #self._buffer
end

function Stream:Destroy()
    table.clear(self._buffer)
    table.clear(self)
    setmetatable(self, nil)
end

return StringStream
