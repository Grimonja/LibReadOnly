local MAJOR = "LibReadOnly";
local MINOR = "1.0.0";

local LibReadOnly = LibStub:NewLibrary(MAJOR, MINOR);
if not LibReadOnly then return; end

local makeReadOnly;

local function safePairs(t)
	local lastKey;
	local function iter()
		local nextKey, nextValue = next(t,lastKey or nil);
		if(nextValue)then
			lastKey = nextKey;
			if(type(nextValue) == "table")then
				return nextKey, makeReadOnly(nextValue);
			else
				return nextKey, nextValue;
			end
		end
	end

	return iter;
end

local function safeIPairs(t)
	local lastIndex = 0;
	local function iter()
		lastIndex = lastIndex + 1;
		local value = t[lastIndex];
		if(value)then
			if(type(value) == "table")then
				return lastIndex, makeReadOnly(value);
			else
				return lastIndex, value;
			end
		end
	end

	return iter;
end

function makeReadOnly(lib,t)
	local proxy = {};
	setmetatable(proxy, {
		__index = function(self, k)
			if k == "pairs" then
				return function() return safePairs(t); end
			elseif k == "ipairs" then
				return function() return safeIPairs(t); end
			elseif k == "IsReadOnly" then
				return function() return true; end
			end

			local requestedValue = t[k];
			if(type(requestedValue) == "table")then
				return makeReadOnly(lib,requestedValue);
			else
				return requestedValue;
			end
		end,
		__newindex = function(self, k, v)
			error("attempt to update " .. k .. " of read-only table.");
		end,
		__metatable = false,
	})

	return proxy;
end

LibReadOnly.New = makeReadOnly;