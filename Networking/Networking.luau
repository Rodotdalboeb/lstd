const Context = require("./Context")
const BaseSocket = require("./BaseSocket")
const Socket = require("./Socket")
const HttpSocket = require("./HttpSocket")
const PrioritySocket = require("./PrioritySocket")
const Enums = require("./Enums")

export type Context = Context.Context
export type Socket = Socket.Socket
export type BaseSocket = BaseSocket.BaseSocket
export type HttpSocket<T> = HttpSocket.HttpSocket<T>
export type PrioritySocket = PrioritySocket.PrioritySocket

const Networking = {}

Networking.Socket = Socket
Networking.Context = Context
Networking.HttpSocket = HttpSocket
Networking.PrioritySocket = PrioritySocket

Networking.HttpStatus = Enums.HttpStatus
Networking.HttpCompression = Enums.HttpCompression

Networking.NetworkContexts = Enums.NetworkContexts
Networking.ReliabilityChannels = Enums.ReliabilityChannels

return Networking
