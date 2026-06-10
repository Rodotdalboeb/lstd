local Future = require("./Future")
local TaskPool = require("./TaskPool")
const ThreadPool = require("./ThreadPool")

local Concurrency = {}

export type Future<T> = Future.Future<T>
export type TaskPool = TaskPool.TaskPool
export type ThreadPool = ThreadPool.ThreadPool

Concurrency.Future = Future
Concurrency.TaskPool = TaskPool
Concurrency.ThreadPool = ThreadPool

return Concurrency
