const RunService = game:GetService("RunService")

const Enums = require("./Enums")

const ContextClass = {}

local Context = {}
Context.__index = Context

export type Context = {
	AddSocket: (self: Context, socket: any) -> any,
	GetSocket: (self: Context, port: number, channel: number) -> any,
	RemoveSocket: (self: Context, port: number, channel: number) -> (),
	
	Run: (self: Context) -> (),
	Destroy: (self: Context) -> ()
}

const REMOTE_EVENTS_FOLDER = script:WaitForChild("RemoteEvents")
const MAX_SOCKETS = 2_147_483_647

local function executorServer(self: any, player: Player, channel: number, data: buffer, rawData: {any}?)
	const port = buffer.readu16(data, 0)
	if not port then return end

	const key = `{port}:{channel}`
	const socket = self._sockets[key]
	if not socket then return end

	for _, handler in socket._on_event do
		local func = type(handler) == "function" and handler or handler.func
		task.spawn(func, {Player = player, Data = data, Table = rawData})
	end
end

local function executorClient(self: any, channel: number, data: buffer, rawData: {any}?)
	const port = buffer.readu16(data, 0)
	if not port then return end

	const key = `{port}:{channel}`
	const socket = self._sockets[key]
	if not socket then return end

	for _, handler in socket._on_event do
		local func = type(handler) == "function" and handler or handler.func
		task.spawn(func, {Data = data, Table = rawData})
	end
end

-- A main <code>Network Context</code> for all non-external sockets (Socket, PrioritySocket).
function ContextClass.new(remoteEventsFolder: Folder?, maxSockets: number?): Context
	return setmetatable({
		_max = maxSockets or MAX_SOCKETS,
		_sockets = {},
		_sockets_size = 0,
		_folder = remoteEventsFolder or REMOTE_EVENTS_FOLDER,
		_context = RunService:IsServer() and Enums.NetworkContexts.Server or Enums.NetworkContexts.Client,
		_connections = {}
	}, Context)
end

function Context:GetSocket(port: number, channel: number)
	const key = `{port}:{channel}`
	return self._sockets[key]
end

function Context:AddSocket(socket: any)
	if self._sockets_size > self._max then
		warn("[Standard.Networking.Context]: Cannot insert new socket because socket limit is reached!")
		return
	end
	
	const port = socket._port
	const channel = socket._channel
	const key = `{port}:{channel}`
	self._sockets[key] = socket
	
	if channel == Enums.ReliabilityChannels.Reliable then
		socket._event = self._folder.ReliableRemoteEvent
	elseif channel == Enums.ReliabilityChannels.Unreliable then
		socket._event = self._folder.UnreliableRemoteEvent
	else
		error("[Standard.Networking.Context]: Invalid remote channel (available: Reliable & Unreliable)")
	end
end

function Context:RemoveSocket(port: number, channel: number)
	if self._sockets_size > 0 then
		self._sockets_size -= 1
	end
	
	const key = `{port}:{channel}`
	self._sockets[key] = nil
end

function Context:Run()
	if self._context == Enums.NetworkContexts.Server then
		table.insert(self._connections, self._folder.ReliableRemoteEvent.OnServerEvent:Connect(function(player: Player, data: buffer, rawData: {any}?)
			task.spawn(executorServer, self, player, Enums.ReliabilityChannels.Reliable, data, rawData)
		end))
		
		table.insert(self._connections, self._folder.UnreliableRemoteEvent.OnServerEvent:Connect(function(player: Player, data: buffer, rawData: {any}?)
			task.spawn(executorServer, self, player, Enums.ReliabilityChannels.Unreliable, data, rawData)
		end))
	else
		table.insert(self._connections, self._folder.ReliableRemoteEvent.OnClientEvent:Connect(function(data: buffer, rawData: {any}?)
			task.spawn(executorClient, self, Enums.ReliabilityChannels.Reliable, data, rawData)
		end))
		
		table.insert(self._connections, self._folder.UnreliableRemoteEvent.OnClientEvent:Connect(function(data: buffer, rawData: {any}?)
			task.spawn(executorClient, self, Enums.ReliabilityChannels.Unreliable, data, rawData)
		end))
	end
end

function Context:Destroy()
	for _, conn in self._connections do
		conn:Disconnect()
	end
	
	table.clear(self._connections)
	
	for _, socket in self._sockets do
		socket:Destroy()
	end
	
	table.clear(self._sockets)
	
	table.clear(self)
	setmetatable(self, nil)
end

return ContextClass
