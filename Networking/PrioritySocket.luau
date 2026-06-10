const RunService = game:GetService("RunService")

const PriorityQueue = require("../Containers/PriorityQueue")

const PrioritySocketClass = {}
const PrioritySocket = {}
PrioritySocket.__index = PrioritySocket

export type PrioritySocket = {
	Bind: (self: PrioritySocket, port: number, channel: number) -> (),
	Close: (self: PrioritySocket) -> (),

	GetPort: (self: PrioritySocket) -> number,
	GetChannel: (self: PrioritySocket) -> number,

	Send: (self: PrioritySocket, data: {Data: buffer, Raw: {any}?}, To: Player?) -> (),
	SendAll: (self: PrioritySocket, data: {Data: buffer, Raw: {any}?}) -> (),
	OnReceive: (self: PrioritySocket, priority: number, handler: ({any}) -> ()) -> (() -> ()),

	Destroy: (self: PrioritySocket) -> ()
}

-- Creates a new <code>Priority Socket</code>. A type of socket which uses priority queue to manage on receive handlers.
function PrioritySocketClass.new(comparator: ({priority: number, func: any}, {priority: number, func: any}) -> (), port: number?, channel: number?): PrioritySocket
	return setmetatable({
		_port = port,
		_channel = channel, 
		_event = nil,

		_on_event = PriorityQueue.new("table", comparator)
	}, PrioritySocket)
end

function PrioritySocket:Bind(port: number, channel: number)
	self._port = port
	self._channel = channel
end

function PrioritySocket:GetPort()
	return self._port
end

function PrioritySocket:GetChannel()
	return self._channel
end

function PrioritySocket:Send(data: {Data: buffer, Raw: {any}?, To: Player?})
	if not self._event then warn("[Standard.Networking.Socket]: Socket is not bound to the Context!") return end

	if RunService:IsServer() then
		if not data.To then return end
		self._event:FireClient(data.To, data.Data, data.Raw)
	else
		self._event:FireServer(data.Data, data.Raw)
	end
end

function PrioritySocket:SendAll(data: {Data: buffer, Raw: {any}?})
	if not RunService:IsServer() then error("[Standard.Networking.Socket]: Cannot call 'Socket.SendAll()' on non-server environment!") return end
	if not self._event then warn("[Standard.Networking.Socket]: Socket is not bound to the Context!") return end

	self._event:FireAllClients(data.Data, data.Raw)
end

function PrioritySocket:OnReceive(priority: number, handler: ({any}) -> ())
	self._on_event:Push({
		priority = priority,
		func = handler
	})

	return function()
		for idx, index in self._on_event do
			if index.priority == priority and index.func == handler then
				table.remove(self._on_event._storage, idx)
				return
			end
		end
	end
end

function PrioritySocket:Close()
	self._on_event:Clear()
	self._port = 0
	self._channel = -1
end

function PrioritySocket:Destroy()
	self:Close()
	table.clear(self, nil)
	setmetatable(self, nil)
end

return PrioritySocketClass
