local HttpService = game:GetService("HttpService")

local TaskPool = require("../Concurrency/TaskPool")
local Future = require("../Concurrency/Future")
local Enums = require("./Enums")

local HttpSocketClass = {}
local HttpSocket = {}
HttpSocket.__index = HttpSocket

export type HttpSocket<T> = {
	Request: (self: HttpSocket<T>, requestOptions: {[string]: any}) -> (any),
	Get: (self: HttpSocket<T>, url: string, compress: any?, timeout: number?, headers: {[string]: any}?) -> (any, any),
	Head: (self: HttpSocket<T>, url: string, compress: any?, timeout: number?, headers: {[string]: any}?) -> (any),
	Post: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> (any, any),
	Put: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> (any, any),
	Patch: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> (any, any),
	Delete: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> (any, any),
	Trace: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> (any, any),
	Options: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> (any, any),
	
	RequestAsync: (self: HttpSocket<T>, requestOptions: {[string]: any}) -> Future.Future<T>,
	GetAsync: (self: HttpSocket<T>, url: string, compress: any?, timeout: number?, headers: {[string]: any}?) -> Future.Future<T>,
	HeadAsync: (self: HttpSocket<T>, url: string, compress: any?, timeout: number?, headers: {[string]: any}?) -> Future.Future<T>,
	PostAsync: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> Future.Future<T>,
	PutAsync: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> Future.Future<T>,
	PatchAsync: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> Future.Future<T>,
	DeleteAsync: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> Future.Future<T>,
	TraceAsync: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> Future.Future<T>,
	OptionsAsync: (self: HttpSocket<T>, url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any}?) -> Future.Future<T>,
	
	Close: (self: HttpSocket<T>) -> (),
	Destroy: (self: HttpSocket<T>) -> ()
}

-- Creates a new <code>Http Socket</code>. Used to access external services via GET, POST, PUT, PATCH, TRACE, HEAD and OPTIONS HTTP-methods. Supports -Async methods which all returns <code>Future</code>.
function HttpSocketClass.new(responseThreads: number)
	local http = setmetatable({
		_pool = TaskPool.new(responseThreads)
	}, HttpSocket)
	http._pool:CreateThreads()
	return http
end


function HttpSocket:Request(requestOptions: {[string]: any})
	local success, data = pcall(function() 
		return HttpService:RequestAsync(requestOptions)
	end)

	if not success then
		warn(`[Standard.Networking.HttpSocket]: Error occurred while perforiming HTTP request, error code: {data}`)
		return Enums.HttpStatus.Error
	end

	return Enums.HttpStatus.Success, data
end

function HttpSocket:Get(url: string, compress: any?, timeout: number?, headers: {[string]: any}?)
	return self:Request({
		Url = url,
		Method = "GET",
		Headers = headers,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:Head(url: string, compress: any?, timeout: number?, headers: {[string]: any}?)
	return self:Request({
		Url = url,
		Method = "HEAD",
		Headers = headers,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:Post(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?})
	return self:Request({
		Url = url,
		Method = "POST",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:Put(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?})
	return self:Request({
		Url = url,
		Method = "PUT",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:Patch(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?})
	return self:Request({
		Url = url,
		Method = "PATCH",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:Delete(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?})
	return self:Request({
		Url = url,
		Method = "DELETE",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:Trace(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?})
	return self:Request({
		Url = url,
		Method = "TRACE",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:Options(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?})
	return self:Request({
		Url = url,
		Method = "OPTIONS",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:RequestAsync<T>(requestOptions: {[string]: any})
	local future = self._pool:AddTask(function()
		return HttpService:RequestAsync(requestOptions)
	end)

	return future
end

function HttpSocket:GetAsync<T>(url: string, compress: any?, timeout: number?, headers: {[string]: any?}): Future.Future<T>
	return self:RequestAsync({
		Url = url,
		Method = "GET",
		Headers = headers,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:HeadAsync<T>(url: string, compress: any?, timeout: number?, headers: {[string]: any?}): Future.Future<T>
	return self:RequestAsync({
		Url = url,
		Method = "HEAD",
		Headers = headers,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:PostAsync<T>(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?}): Future.Future<T>
	return self:RequestAsync({
		Url = url,
		Method = "POST",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:DeleteAsync<T>(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?}): Future.Future<T>
	return self:RequestAsync({
		Url = url,
		Method = "DELETE",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:PutAsync<T>(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?}): Future.Future<T>
	return self:RequestAsync({
		Url = url,
		Method = "PUT",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:PatchAsync<T>(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?}): Future.Future<T>
	return self:RequestAsync({
		Url = url,
		Method = "PATCH",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:TraceAsync<T>(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?}): Future.Future<T>
	return self:RequestAsync({
		Url = url,
		Method = "TRACE",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:OptionsAsync<T>(url: string, body: any, compress: any?, timeout: number?, headers: {[string]: any?}): Future.Future<T>
	return self:RequestAsync({
		Url = url,
		Method = "OPTIONS",
		Headers = headers,
		Body = body,
		Timeout = timeout,
		Compress = if compress == Enums.HttpCompression.GZip then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	})
end

function HttpSocket:Close()
	self._pool:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

-- Destructor. Same as <code>HttpSocket:Close()</code>.
function HttpSocket:Destroy()
	self:Close()
end

return HttpSocketClass
