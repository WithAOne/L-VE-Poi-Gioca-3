local ecs = {}
local __ENTITY = {}
local __SYSTEM = {}
local __POOL = {}
local __EVENT = {
	systemcreated="load",
	systemdestroy="destroyed",
	poolcreated="created",
	pooldestroy="destroyed",
	poolentitydestroy="entityRemoved",
	entitydestroy="entityRemoved",
	entityremove="entityRemoved",
	entityadd="entityCreated",
	entitycreate="entityCreated"
}
local __EVENTREGISTER = {}
ecs.systemImportPath = "systems"
local __isDestroyed = false
local tempfunct = ''
local __DESTROYPOOL = {}



function ecs.globalCall(funct, ...) -- just calls the function with both ecs.call and ecs.iterateCall
	ecs.call(funct, ...)
	ecs.iterateCall("iterate"..funct:sub(1, 1):upper()..funct:sub(2, funct:len()), ...)
	--ecs.callEvent(funct, ...)
end
function ecs.call(funct, ...) -- calls given function with every system
	if not funct then return end
	
	for name, sys in pairs(__SYSTEM) do
		if type(sys) == "table" then
			if sys[funct] then 
				local v, vv = pcall(sys[funct], ...)
				if not v then print(funct, name, vv) end
			end
		end
	end
	for name, pool in pairs(__POOL) do
		if type(pool) == "table" then
			--local v, vv = pcall(pool[funct], ...)
			if pool[funct] then 
				local v, vv = pcall(pool[funct], ...)
				if not v then print(funct, name, vv) end
			end
		end
	end
end
function ecs.iterateCall(funct, ...) -- calls given function with every pool's callbacks for each entity
	if not funct then return end
	
	for name, pool in pairs(__POOL) do
		if pool[funct] then
			pool:iterateCall(funct, ...)
		end
	end
end
function ecs.importSystems() -- probably only works outside exe and love files
	local files = love.filesystem.getDirectoryItems(ecs.systemImportPath)
	for i, file in ipairs(files) do
		if file:find(".lua") then
			local filepath = file:gsub(".lua", "")
			
			local v, vv = require(ecs.systemImportPath .. '.' .. filepath)
			if v then
				ecs.newSystem(filepath, v)
			else
				print(vv)
			end
		end
	end
end
function ecs.quit() -- shuts down the entire ecs: destroy pools, systems, entities and so on
	
	__isDestroyed = true
	
	-- destroy systems
	for name, sys in pairs(__SYSTEM) do
		--sys:destroy()
		ecs.destroySystem(name)
	end
	
	-- destroy pools
	for name, pool in pairs(__POOL) do
		pool:destroy()
	end
	
	-- destroy entities
	for id, ent in pairs(__ENTITY) do
		ecs.getEntity(id):destroy()
	end
	
end
function ecs.isDestroyed()
	return __isDestroyed
end
function ecs.update()
	for i, id in ipairs(__DESTROYPOOL) do
		local ent = ent or ecs.getEntity(id)
		
		-- call the "destroyed" callback with the systems that contain this entity
		for i, pool in pairs(__POOL) do
			local index = table.contains(pool.contents, id)
			if index then
				--pool:call(__EVENT.entitydestroy, ent, id)
				table.remove(pool.contents, index)
			end
		end
		
		__ENTITY[id] = nil
	end
end

ecs.entity = {}
function ecs.entity:__index(key)
	if key == "__id" then return rawget(self, key) end
	
	if __ENTITY[rawget(self, "__id")][key] then 
		return __ENTITY[rawget(self, "__id")][key] 
	else
		return ecs.entity[key]
	end
end
function ecs.entity:__newindex(key, val)
	--print("setting ", key, val)
	__ENTITY[rawget(self, "__id")][key] = val
end
--[[function ecs.entity:__ipairs()
	return ipairs(__ENTITY[rawget(self, "__id")]), __ENTITY[rawget(self, "__id")]
end
function ecs.entity:__pairs()
	return pairs(__ENTITY[rawget(self, "__id")]), __ENTITY[rawget(self, "__id")]
end]]
function ecs.newEntity(components) -- returns id, ent
	local ent = components
	local id = table.uniqueId(__ENTITY)
	local ret = { __id = id }
	
	setmetatable(ret, ecs.entity)
	
	__ENTITY[id] = ent
	
	
	-- add to any pools it has the requirements for
	for name, pool in pairs(__POOL) do
		if (table.has(ent, pool.requires) or table.len(pool.requires) == 0) and
			(table.hasOne(ent, pool.requiresOne) or table.len(pool.requiresOne) == 0) and
			(table.hasAny(ent, pool.requiresAny) or table.len(pool.requiresAny) == 0) then
			table.insert(pool.contents, id)
			
			pool:call(__EVENT.entityadd, ret, id)
		end
	end
	
	
	return id, ret
end
function ecs.getEntity(id)
	local ret = { __id = id }
	setmetatable(ret, ecs.entity)
	return ret
end
function ecs.destroyEntity(id, ent)
	--[[local ent = ent or ecs.getEntity(id)
	
	-- call the "destroyed" callback with the systems that contain this entity
	for i, pool in pairs(__POOL) do
		local index = table.contains(pool.contents, id)
		if index then
			pool:call(__EVENT.entitydestroy, ent, id)
			table.remove(pool.contents, index)
		end
	end
	
	__ENTITY[id] = nil]]
	
	local ent = ent or ecs.getEntity(id)
	for i, pool in pairs(__POOL) do
		local index = table.contains(pool.contents, id)
		if index then
			pool:call(__EVENT.entitydestroy, ent, id)
			--table.remove(pool.contents, index)
		end
	end
	
	table.insert(__DESTROYPOOL, id)
end
function ecs.countEntity()
	local count = 0
	
	for id, ent in pairs(__ENTITY) do
		if ent then count = count + 1 end
	end
	
	return count
end
function ecs.entity:destroy()
	ecs.destroyEntity(self.__id, self)
end
function ecs.entity:addComponent(cname, comp)
	
	self[cname] = comp
	
	for name, pool in pairs(__POOL) do
		local index = table.contains(pool.contents, self.__id)
		
		-- add to any pools it has the requirements for them
		if (table.has(self, pool.requires) or table.len(pool.requires) == 0) and
			(table.hasOne(self, pool.requiresOne) or table.len(pool.requiresOne) == 0) and
			(table.hasAny(self, pool.requiresAny) or table.len(pool.requiresAny) == 0) then
			table.insert(pool.contents, self.__id)
			
			pool:call(__EVENT.entityadd, __ENTITY[self.__id], self.__id)
		elseif index then -- remove from pools it's in if it doesn't fit
			pool:call(__EVENT.entityremove, __ENTITY[self.__id], self.__id)
			table.remove(pool.contents, index)
		end
	end
	
end
function ecs.entity:removeComponent(cname)
	
	for name, pool in pairs(__POOL) do
		local index = table.contains(pool.contents, self.__id)
		
		-- add to any pools it has the requirements for them
		if (table.has(self, pool.requires) or table.len(pool.requires) == 0) and
			(table.hasOne(self, pool.requiresOne) or table.len(pool.requiresOne) == 0) and
			(table.hasAny(self, pool.requiresAny) or table.len(pool.requiresAny) == 0) then
			table.insert(pool.contents, self.__id)
			
			pool:call(__EVENT.entityadd, __ENTITY[self.__id], self.__id)
		elseif index then -- remove from pools it's in if it doesn't fit
			pool:call(__EVENT.entityremove, __ENTITY[self.__id], self.__id)
			table.remove(pool.contents, index)
		end
	end
	
	self[cname] = nil
	
end
function ecs.entity:call(funct, ...)
	for poolname, pool in pairs(__POOL) do
		if pool[funct] and table.contains(pool.contents, self.__id) then
			pool[funct](self, self.__id, ...)
		end
	end
end

ecs.pool = {}
function ecs.newPool(name, requires, requiresAny, requiresOne, tbl) -- string, ipairs table, ipairs table, ipairs table, table
	local pool = tbl or {}
	
	pool.name = name
	pool.requires = requires or {}
	pool.requiresAny = requiresAny or {}
	pool.requiresOne = requiresOne or {}
	pool.contents = {}
	
	setmetatable(pool, ecs.pool)
	ecs.pool.__index = ecs.pool
	
	__POOL[name] = pool
	
	__POOL[name]:call(__EVENT.poolcreated)
	
	return pool
end
function ecs.destroyPool(name, pool)
	local pool = pool or __POOL[name]
	pool:call(__EVENT.pooldestroy)
	
	pool:iterateCall(__EVENT.poolentitydestroy)
	
	__POOL[name] = nil
end
function ecs.pool:iterate(funct, ...) -- calls the function for each of the pool's contents with the item as an argument
	local r = {}
	
	for i, id in ipairs(self.contents) do
		local ent = ecs.getEntity(id)
		local v, vv = pcall(funct, ent, id, ...)
		
		-- if nil or false then print error, otherwise, add return to r
		if v then
			table.insert(r, vv)
		else
			print("ecs error: in pool iterate '"..tempfunct.."' in '"..self.name.."', '"..tostring(vv).."'")
			break --TODO: TEST
		end
	end
	
	return r
end
function ecs.pool:call(funct, ...) -- string
	--performanceAnalysis.startAnalysis("call:"..self.name..":"..funct)
	
	if self[funct] then
		local v, vv = pcall(self[funct], ...)
		if not v then print("ecs error: in pool call "..funct..": '"..vv.."'") end
	end
	
	--performanceAnalysis.endAnalysis("call:"..self.name..":"..funct)
	return v, vv
end
function ecs.pool:iterateCall(funct, ...) -- string
	--performanceAnalysis.startAnalysis("call:"..self.name..":"..funct)
	
	if self[funct] then
		tempfunct = funct
		self:iterate(self[funct], ...)
	end
	
	--performanceAnalysis.endAnalysis("call:"..self.name..":"..funct)
end
function ecs.pool:len()
	return table.len(self.contents)
end
function ecs.pool:destroy()
	ecs.destroyPool(self.name, self)
end

ecs.system = {}
function ecs.newSystem(name, tbl)
	print("	new system '"..name.."'")
	
	if __SYSTEM[name] then error("error in ecs: system with the identifier '"..name.."' already exists") end
	
	setmetatable(tbl, ecs.system)
	ecs.system.__index = ecs.system
	
	__SYSTEM[name] = tbl
	__SYSTEM[name].name = name
	
	__SYSTEM[name]:call(__EVENT.systemcreated)
	
end
function ecs.getSystem(name)
	return __SYSTEM[name]
end
function ecs.destroySystem(name, tbl)
	local tbl = tbl or __SYSTEM[name]
	tbl:call(__EVENT.systemdestroy)
	
	__SYSTEM[name] = nil
end
function ecs.exists(name)
	return __SYSTEM[name] ~= nil
end
function ecs.system:destroy()
	ecs.destroySystem(self.name, self)
end
function ecs.system:call(funct, ...)
	-- check if function exists in the system then call it
	if self[funct] then
		local v, vv = pcall(self[funct], ...)
		-- if it did not succeed; throw error into console
		if not v then print("ecs error: system call error ["..tostring(vv).."]") end
	else
		-- if the function does not exist; throw error
		--print("ecs error: function '"..funct.."' does not exist in system '"..self.name.."'")
	end
end
function ecs.countSystems()
	return table.len(__SYSTEM)
end

function ecs.callEvent(event, ...)
	for i, ty in pairs(__EVENTREGISTER) do
		if not ty[event] then break end
		for id, funct in ipairs(ty[event]) do
			if type(funct) == "function" then
				
				pcall(funct, ...)
				
			elseif type(funct) == "string" then
				
				if ty == "pool" then 
					pcall(__POOL[id][funct], ...)
				elseif ty == "system" then
					pcall(__SYSTEM[id][funct], ...)
				elseif ty == "entity" then
					pcall(__ENTITY[id][funct], ...)
				end
				
			end
		end
	end
end
function ecs.connectEvent(ty, event, id, funct)
	if type(funct) == "function" or type(funct) == "string" then
		if not __EVENTREGISTER[ty] then __EVENTREGISTER[ty] = {} end
		if not __EVENTREGISTER[ty][event] then __EVENTREGISTER[ty][event] = {} end
		__EVENTREGISTER[ty][event][id] = funct
	end
end
function ecs.disconnectEvent(ty, event, id)
	if not __EVENTREGISTER[ty] or
		not __EVENTREGISTER[ty][event] or
		not __EVENTREGISTER[ty][event][id]
		then
		return
	end
	__EVENTREGISTER[ty][event][id] = nil
end

-- to call a character cast:
-- register cast (name)
-- call cast (name, subject)
--
-- a subject is a pool or entity that the cast is called for
-- with entities, all systems with that entity and the cast will be called
-- with pools, all entity... (TODO)
function ecs.registerCast(name)
	
end
function ecs.callCast(cast, subject, ...)
	for poolname, pool in pairs(__POOL) do
		if pool[cast] and table.contains(pool.contents, subject) then
			pool[cast](subject, ...)
		end
	end
end



return ecs