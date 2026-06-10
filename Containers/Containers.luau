local Stack = require("./Stack")
local Array = require("./Array")
local Queue  = require("./Queue")
local PriorityQueue = require("./PriorityQueue")

local Iterator = require("./Iterator")

export type Stack = Stack.Stack
export type Array<T> = Array.Array<T>
export type Queue<T> = Queue.Queue<T>
export type PriorityQueue<T> = PriorityQueue.PriorityQueue<T>

export type Iterator = Iterator.Iterator

return {
	Stack = Stack,
	Array = Array,
	Queue = Queue,
	PriorityQueue = PriorityQueue,
	
	Iterator = Iterator,
}
