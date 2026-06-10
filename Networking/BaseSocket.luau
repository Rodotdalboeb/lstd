const BaseSocket = {}
BaseSocket.__index = BaseSocket

export type BaseSocket = {
	Close: (self: BaseSocket) -> (),
	OnReceive: (self: BaseSocket, handler: (...any) -> ()) -> (() -> ()),
	Destroy: (self: BaseSocket) -> ()
}

--function BaseSocket:Close() error("[Standard.Networking.BaseSocket]: Cannot call virtual function 'Close()'!") end
--function BaseSocket:OnReceive(handler: (...any) -> ()) error("[Standard.Networking.BaseSocket]: Cannot call virtual function 'OnReceive()'!") end
--function BaseSocket:Destroy() error("[Standard.Networking.BaseSocket]: Cannot call virtual destructor of 'BaseSocket' class!") end

return BaseSocket
