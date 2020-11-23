local lift = {}

for _, method in pairs{"create", "isyieldable", "running", "status", "wrap"} do
	lift[method] = coroutine[method]
end

local function intercept(co, success, target, ...)
	if coroutine.status(co) == "dead" then
		return success, target, ...
	elseif (not target) or target == coroutine.running() then
		return success, ...
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

function lift.yieldto(co, ...)
	-- todo: type check co
	return coroutine.yield(co, ...)
end

return lift
