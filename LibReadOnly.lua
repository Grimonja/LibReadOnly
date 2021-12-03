local addOnName,addon = ...;

local MAJOR = "LibReadOnly";
local MINOR = "1.0.0";
local LibReadOnly;

local lib, minor = LibStub:GetLibrary(MAJOR, true);
if lib and minor and minor >= MINOR then
	return lib;
else
	LibReadOnly = LibStub:NewLibrary(MAJOR, MINOR);
end

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

			return t[k];
		end,
		__newindex = function(self, k, v)
			error("attempt to update " .. k .. " of read-only table.");
		end,
		__metatable = false,
	})

	return proxy;
end

LibReadOnly.New = makeReadOnly;