--!strict

------------------------------------------------------------------------------------------------------------------------

--[[

	Junction - Manages functions between events under a single shared connection.
	By @Cayla

]]

------------------------------------------------------------------------------------------------------------------------

local Junction = {
	Pools = {},
}

------------------------------------------------------------------------------------------------------------------------

local Pool = require("@self/Pool")

------------------------------------------------------------------------------------------------------------------------

--[[
	Returns a connection pool for the given event. If no pool exists, one will be created automatically.

	@param Event RBXScriptSignal -- The event associated with the connection pool.
	@return Pool -- The connection pool.
]]
function Junction.GetPool(Event: RBXScriptSignal): Pool.Pool
	if not Junction.Pools[Event] then
		Junction.Pools[Event] = Pool.new(Event)
	end

	return Junction.Pools[Event]
end

------------------------------------------------------------------------------------------------------------------------

return Junction
