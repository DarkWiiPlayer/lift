--- Allows coroutines to yield several layers through the stack.
-- All functions of the `coroutine` module are available in `lift`,
-- but some (listed below) work slightly differently.
-- @module lift

local lift = {}

for _, method in pairs{"create", "isyieldable", "running", "status", "wrap"} do
	lift[method] = coroutine[method]
end

--- Analyzes the return value of a yielding coroutine.
local function intercept(co, success, target, ...)
	-- Coroutine completed: Stay on current level
	if coroutine.status(co) == "dead" then
		return success, target, ...
	-- No target or matching level: Stay on current level
	elseif (target == nil) or target == coroutine.running() then
		return success, ...
	-- Non-matching Target: lift through
	else
		return lift.resume(co, coroutine.yield(target, ...))
	end
end

--- Resumes a lift coroutine.
-- This function must be used for other lift functions to work correctly.
function lift.resume(co, ...)
	return intercept(co, coroutine.resume(co, ...))
end

--- Yields up one level.
-- This function must be used for lift.resume to work correctly.
function lift.yield(...)
	return coroutine.yield(nil, ...)
end

--- Yields to the closest vanilla resume.
-- This yield will never be caught by `lift.resume` and will always go all
-- the way to the next `coroutine.resume`.
-- The first argument can never be `nil` or a coroutine.
function lift.bypass(...) if type(...) == "thread" or type(...) == "nil"
	then error("First argument to bypass cannot be thread or nil") end
	return coroutine.yield(...) end

--- Yields up to a certain level.  This function yields through several
--layers of `lift.resume` calls until it arrives at the target coroutine or
--a vanilla `coroutine.resume` call.  If it reaches a `lift.resume` call in
--the main thread, it will attempt to yield out of the main thread and
--cause an error.
function lift.yieldto(co, ...)
	if co ~= nil and type(co) ~= "thread" then
	error("Can only yield to thread or nil")
	end
	return coroutine.yield(co, ...)
end

return lift
