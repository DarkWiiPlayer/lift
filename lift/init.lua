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

function lift.resume(co, ...)
	return intercept(co, coroutine.resume(co, ...))
end

function lift.yield(...)
	return coroutine.yield(nil, ...)
end

function lift.bypass(...)
	if type(...) == "thread" or type(...) == "nil" then
		error("First argument to bypass cannot be thread or nil")
	end
	return coroutine.yield(...)
end

function lift.yieldto(co, ...)
	if co ~= nil and type(co) ~= "thread" then
		error("Can only yield to thread or nil")
	end
	return coroutine.yield(co, ...)
end

return lift
