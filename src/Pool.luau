--!strict

--[[
	Handles connection pool logic.

	@class Pool
]]
local Pool = {}
Pool.__index = Pool

------------------------------------------------------------------------------------------------------------------------

export type Pool = setmetatable<{
	read Event: RBXScriptSignal,
	Connection: RBXScriptConnection,
	Functions: { [string]: (...any) -> () },
	Sleeping: boolean,
}, typeof(Pool)>

------------------------------------------------------------------------------------------------------------------------

function Pool.new(Event: RBXScriptSignal): Pool
	local self: Pool = setmetatable(
		{
			Event = Event,
			Functions = {},
		} :: Pool,
		Pool
	)

	self:_Connect()

	return self
end

------------------------------------------------------------------------------------------------------------------------

function Pool._Connect(self: Pool)
	self.Connection = self.Event:Connect(function(...)
		local Args = { ... }

		for _, Function in self.Functions do
			task.spawn(Function, table.unpack(Args))
		end
	end)
end

------------------------------------------------------------------------------------------------------------------------

--[[
	Binds a function to the pool.
	
	@param Name string -- Identifier used for unmounting.
	@param Function (...any) -> () -- Function invoked when the event fires.
]]
function Pool.Mount(self: Pool, Name: string, Function: (...any) -> ())
	self.Functions[Name] = Function

	if self.Sleeping then
		self.Sleeping = false
		self:_Connect()
	end
end

--[[
	Unbinds a function from the pool.
	If no functions remain, the connection is temporarily disconnected until one is added again.
	
	@param Name string -- Identifier of the function to unbind.
]]
function Pool.Unmount(self: Pool, Name: string)
	self.Functions[Name] = nil

	if next(self.Functions) == nil then
		self.Sleeping = true
		self.Connection:Disconnect()
	end
end

--[[
	Unbinds multiple functions based on a predicate.
	
	@param Predicate (Name: string) -> boolean -- Return `true` to unmount the function.
]]
function Pool.BulkUnmount(self: Pool, Predicate: (Name: string) -> boolean)
	for Name, _ in self.Functions do
		if not Predicate(Name) then
			continue
		end

		self.Functions[Name] = nil
	end
end

--[[
	Disconnects the pool's connection.
]]
function Pool.Destroy(self: Pool)
	if self.Connection then
		self.Connection:Disconnect()
	end
end

------------------------------------------------------------------------------------------------------------------------

return Pool
