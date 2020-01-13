--
-- This is the core library I use for everything
-- Poi and my other libraries do not work without it
-- Lots of it may not work or be useless
-- That said, I needed them at some point so I wrote them
-- 
-- There are more in the file I use personally but
-- it's longer and contains things like manifold
-- generation, polygon spliting and handling,
-- easing functions, command rubbish and so on.
--

function math.choose(...)
	local ran = love.math.random(select("#", ...))
	return select(ran, ...)
end
function table.choose(tbl)
	local ran = love.math.random(#tbl)
	return tbl[ran]
end
function math.clamp(var, mi, ma)
	if var<mi then var = mi end
	if var>ma then var = ma end
	return var
end
function math.sign(v)
	return (v > 0) and 1 or -1
end
function math.wrap(var, mi, ma)
	if var<mi then var = ma end
	if var>ma then var = mi end
	return var
end
function math.chooseBool(chance)
	local r = false
	if love.math.random() <= chance then r=true end
	return r
end
function table.num(tbl)
	local retn = 0
	for i in pairs(tbl) do
		retn = retn + 1
	end
	return retn
end
function table.has(tbl, requirements) -- table, table -- returns true if the table includes each and every one of the requirements
	for _, req in ipairs(requirements) do
		if tbl[req] == nil and not table.contains(tbl, req) then return false end
	end
	return true
end
function table.hasAny(tbl, requirements) -- table, table -- returns true if the table includes any of the requirements
	for _, req in ipairs(requirements) do
		if tbl[req] ~= nil then return true end
	end
	return false
end
function table.hasOne(tbl, requirements) -- table, table -- returns true if the table include only one of the requirements
	local c = 0
	for _, req in ipairs(requirements) do
		if tbl[req] ~= nil then c = c + 1 end
	end
	return (c == 1)
end


function table.smash(tbl) -- takes all values inside tables in a table and returns them as a single table
	if type(tbl) ~= "table" then return end
	local r = {}
	
	for _, i in ipairs(tbl) do
		if type(i) == "table" then
			local t = table.smash(i)
			for __, ii in ipairs(t) do
				table.insert(r, ii)
			end
		else
			table.insert(r, i)
		end
	end
	
	return r
end
function table.val_to_str ( v )
	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )
		-- may be a tad broken
		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
			return "[[" .. v .. "]]"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and table.tostring( v ) or
		tostring( v )
	end
end
function table.key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. table.val_to_str( k ) .. "]"
	end
end
function table.tostring( tbl )
	if type(tbl) == "table" then
		local result, done = {}, {}
		for k, v in ipairs( tbl ) do
			table.insert( result, table.val_to_str( v ) )
			done[ k ] = true
		end
		for k, v in pairs( tbl ) do
			if not done[ k ] then
				table.insert( result,
				table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
			end
		end
		return "{" .. table.concat( result, "," ) .. "}"
	end
	return "nil"
end
function table.tostringExclude( tbl, exclude ) -- table, components to exclude...
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, table.val_to_str( v ) )
		done[ k ] = true
	end
	for k, v in pairs( tbl ) do
		if not done[ k ] and not keyResults(k, exclude) then
			table.insert( result,
			table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
		end
	end
	return "{" .. table.concat( result, "," ) .. "}"
end
function table.keyResults(value, keys)
	for _, key in ipairs(keys) do
		if value == key then return true end
	end
	return false
end
function table.findKey(table, value) -- (pairs) returns the position it was found or false
	local index={}
	for k,v in pairs(table) do
	   index[v]=k
	end
	return index[value]
end
function table.contains(table, check) -- (ipairs) returns the position it was found; if not found will return false
	for i, entry in ipairs(table) do
		if entry == check then return i end
	end
	return false
end
function table.copy(tbl)
	local ret = {}
	
	for i, entry in ipairs(tbl) do
		if type(entry) == "table" then
			table.insert(ret, table.copy(entry))
		else
			table.insert(ret, entry)
		end
	end
	for i, entry in pairs(tbl) do
		if type(entry) == "table" then
			ret[i] = table.copy(entry)
		else
			ret[i] = entry
		end
	end
	
	return ret
end
function table.extractipairs(tbl)
	local r = {}
	for i, entry in ipairs(tbl) do
		table.insert(r, i)
	end
	return r
end
function table.extractpairs(tbl)
	local r = {}
	for i, entry in pairs(tbl) do
		table.insert(r, i)
	end
	return r
end
function table.extractvalues(tbl)
	local r = {}
	for i, entry in pairs(tbl) do
		table.insert(r, entry)
	end
	return r
end
function table.findfilled(tbl, value)
	local r = {}
	
	for x = 1, #tbl, 1 do
		r[x] = {}
		for y = 1, #tbl[x], 1 do
			if tbl[x][y] == value then
				r[x][y] = false
			else
				tbl[x][y] = true
			end
		end
	end
	
	return r
end
function table.findfilledlist(tbl, value, sub, sub2)
	local r = {}
	if sub2 then
		for itm, val in pairs(tbl) do
			r[itm] = not (val[sub][sub2] == value or val[sub][sub2] == -1 or val[sub][sub2] == nil)
		end
	elseif sub then
		for itm, val in pairs(tbl) do
			r[itm] = not (val[sub] == value or val[sub] == -1 or val[sub] == nil)
		end
	else
		for itm, val in pairs(tbl) do
			r[itm] = not (val == value or val == -1 or val == nil)
		end
	end
	return r
end
function table.len(tbl)
	local count = 0
	
	for i, v in pairs(tbl) do
		if v ~= nil then count = count + 1 end
	end
	--[[for i, v in ipairs(tbl) do
		if v ~= nil then count = count + 1 end
	end]]
	
	return count
end
function table.readonly(table)
   return setmetatable({}, {
     __index = table,
     __newindex = function(table, key, value)
                    error("Attempt to modify read-only table")
                  end,
     __metatable = false
   })
end
function table.combine(tbl1, tbl2)
	local r = {}
	
	for i, v in ipairs(tbl1) do
		table.insert(r, t)
	end
	for i, v in pairs(tbl1) do
		r[i] = v
	end
	for i, v in ipairs(tbl2) do
		table.insert(r, t)
	end
	for i, v in pairs(tbl2) do
		r[i] = v
	end
	
	return r
end
function table.lineup(...)
	local r = {}
	
	for i = 1, select("#", ...), 1 do
		local v = select(i, ...)
		table.insert(r, v)
	end
	
	return r
end
function table.merge(tbl1, tbl2)
	local r = table.copy(tbl1)
	for i, entry in ipairs(tbl2) do
		table.insert(r, entry)
	end
	return r
end
function table.softMerge(tbl1, tbl2)
	--local r = tbl1
	for i, entry in ipairs(tbl2) do
		table.insert(tbl1, entry)
	end
	--return r
end
function table.weightedchoose(tbl) -- format: pairs, key = return, value = weight
	local sum = 0
	for _, v in pairs(tbl) do
		assert(v >= 0, "weight value less than one")
		sum = sum + v
	end
	assert(sum ~= 0, "all weights are zero")
	local rnd = math.random(1, sum)
	for k, v in pairs(tbl) do
		if rnd <= v then return k end
		rnd = rnd - v
	end
end
function table.fuse(data, tbl, owtbl) -- data, table to fuse into -- owtbl is whether to overwrite tables with single values
	for key, value in pairs(data) do
		if type(value) == 'table' then
			if tbl[key] then
				table.fuse(value, tbl[key])
			else
				tbl[key] = value
			end
		else
			if type(tbl[key]) == 'table' then
				if (owtbl == nil or owtbl == true) then
					tbl[key] = value
				end
			else
				tbl[key] = value
			end
		end
	end
end

function string.uniqueId(length, key)
	-- key defaults to ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 (alphanumerical) if nil
	-- length defaults to 10 if nil
	local key = key or "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local length = length or 10
	local str = ""
	
	for i = 1, length, 1 do
		local ii = math.floor(math.random(string.len(key)))
		str = str .. string.sub(key, ii, ii)
	end
	
	return str
end
function table.uniqueId(tbl, length, key) -- generates a unique identifier that is not in supplied table
	-- if supplied table is nil then this will just return a generated identifier
	local id = string.uniqueId(length, key)
	
	if tbl and type(tbl) ~= "table" then return id end
	if tbl[id] then id = table.uniqueId(tbl, length, key) end
	
	return id
end
local _mutateid = function(id, key)
	local n = math.random(1, #id)
	local n2 = math.random(1, #key)
	
	return string.sub(id, 1, n-1)..string.sub(key, n2, n2)..string.sub(id, n, #id+1)
end
local _makeid = function(length, key)
	local r = ''
	for i=1, length do
		local n = math.random(1, #key)
		r = r .. string.sub(1, n)
	end
	return r
end
function table.instanceId(tbl, length, key)
	length = length or 8
	key = key or 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	
	local id = _makeid(length, key)
	while tbl[id] do id=_mutateid(id, key) end
	
	return id
end

function table.prioritySort(_t, rev, comp)
	-- makes sure comp returns a value
    if comp == nil then
        comp = function(a, b) return a < b end
    elseif type(comp) ~= 'function' then
        local k = comp
        comp = function(a, b) return a[k] < b[k] end
    end
	
	-- reverses comp
    if rev then
        _comp = comp
        comp = function(a, b) return not _comp(a, b) end
    end
	
	-- make new table
    local t = {}
	
	-- sort
    for i=1, #_t do
        local v = _t[i]
        local j = i - 1
        while j > 0 and not comp(t[j], v) do
            t[j+1] = t[j]
            j = j - 1
        end
        t[j+1] = v
    end
	
    return t
end
function table.yprioritySort(_t, rev, comp) -- only works for y depth
	-- makes sure comp returns a value
    if comp == nil then
        comp = function(a, b) return a < b end
    elseif type(comp) ~= 'function' then
        local k = comp
        comp = function(a, b) return a[k] < b[k] end
    end
	
	-- reverses comp
    if rev then
        _comp = comp
        comp = function(a, b) return not _comp(a, b) end
    end
	
	-- make new table
    local t = {}
	
	-- sort
    for i=1, #_t do
        local v = _t[i]
        local j = i - 1
		--print("find a", _t[t[j]])
        while j > 0 and not comp(_t[t[j]], _t[v]) do
            t[j+1] = t[j]
            j = j - 1
        end
        t[j+1] = v
    end
	local ii = 1
	local keys = table.extractpairs(_t)
    for i, entry in pairs(_t) do
        local v = entry
		local c = i
        local j = ii - 1
		--print("find a", table.tostring(_t[keys[j]]))
		--print("find b", table.tostring(_t[c]))
        while j > 0 and not comp(_t[keys[j]], _t[c]) do
			--print("find", _t[t[j]])
            t[j+1] = t[j]
            j = j - 1
        end
        t[j+1] = v
		ii = ii + 1
    end
	
    return t
end
