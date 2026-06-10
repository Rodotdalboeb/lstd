return table.freeze({
	NetworkContexts = { Server = 0, Client = 1 },
	ReliabilityChannels = { Reliable = 0, Unreliable = 1 },
	HttpCompression = { None = 0, GZip = 1 },
	HttpStatus = { Success = 0, Error = 1 }
})
