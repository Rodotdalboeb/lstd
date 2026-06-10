const RunService = game:GetService("RunService")

const SocketClass = {}
const Socket = {}
Socket.__index = Socket

export type Socket = {
	Bind: (self: Socket, port: number, channel: number) -> (),
	Close: (self: Socket) -> (),
	
	GetPort: (self: Socket) -> number,
	GetChannel: (self: Socket) -> number,
	
	Send: (self: Socket, data: {Data: buffer, Raw: {any}?}, To: Player?) -> (),
	SendAll: (self: Socket, data: {Data: buffer, Raw: {any}?}) -> (),
	OnReceive: (self: Socket, handler: ({any}) -> ()) -> (() -> ()),
	
	Destroy: (self: Socket) -> ()
}

-- A basic, lightweight, socket. Used for everything that needs remote communaction.
function SocketClass.new(port: number?, channel: number?): Socket
	return setmetatable({
		_port = port,
		_channel = channel, 
		_event = nil,
		
		_on_event = {}
	}, Socket)
end

function Socket:Bind(port: number, channel: number)
	self._port = port
	self._channel = channel
end

function Socket:GetPort()
	return self._port
end

function Socket:GetChannel()
	return self._channel
end

function Socket:Send(data: {Data: buffer, Raw: {any}?, To: Player?})
	if not self._event then warn("[Standard.Networking.Socket]: Socket is not bound to the Context!") return end
	
	if RunService:IsServer() then
		if not data.To then return end
		self._event:FireClient(data.To, data.Data, data.Raw)
	else
		self._event:FireServer(data.Data, data.Raw)
	end
end

function Socket:SendAll(data: {Data: buffer, Raw: {any}?})
	if not RunService:IsServer() then error("[Standard.Networking.Socket]: Cannot call 'Socket.SendAll()' on non-server environment!") return end
	if not self._event then warn("[Standard.Networking.Socket]: Socket is not bound to the Context!") return end
	
	self._event:FireAllClients(data.Data, data.Raw)
end

function Socket:OnReceive(handler: ({any}) -> ())
	table.insert(self._on_event, handler)
	
	return function()
		const index = table.find(self._on_event, handler)
		
		if index then
			table.remove(self._on_event, index)
		end
	end
end

function Socket:Close()
	table.clear(self._on_event)
	self._port = 0
	self._channel = -1
end

function Socket:Destroy()
	self:Close()
	table.clear(self, nil)
	setmetatable(self, nil)
end

return SocketClass
