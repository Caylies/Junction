--!strict

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

function Pool.Mount(self: Pool, Name: string, Function: (...any) -> ())
	self.Functions[Name] = Function

	if self.Sleeping then
		self.Sleeping = false
		self:_Connect()
	end
end

function Pool.Unmount(self: Pool, Name: string)
	self.Functions[Name] = nil

	if next(self.Functions) == nil then
		self.Sleeping = true
		self.Connection:Disconnect()
	end
end

function Pool.BulkUnmount(self: Pool, Predicate: (Name: string) -> boolean)
	for Name, _ in self.Functions do
		if not Predicate(Name) then
			continue
		end

		self.Functions[Name] = nil
	end
end

function Pool.Destroy(self: Pool)
	if self.Connection then
		self.Connection:Disconnect()
	end
end

------------------------------------------------------------------------------------------------------------------------

return Pool
