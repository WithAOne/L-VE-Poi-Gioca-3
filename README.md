# LÖVE-Poi-Gioca-3
This is the updated version of the LÖVE Poi Gioca ECS.
It is made to be simple but effective.
Poi was just my attempt at making an ECS at first but it's become a lot larger.
Though it will likely have oversights, errors and inefficiencies.
Any suggestions and critisisms are appriciated.



# How to use
To set up the ECS, just import the library as a variable.
```LUA
poi = require'ecs'
poi.importSystems() -- This was made mostly for my own ease of use. It imports all .lua files in the /systems directory into the ecs.
```

Create a pool
```LUA
poi.newPool(name, requires, requiresAny, requiresOne, tbl)
-- requires: all the components that are required for an entity to be added to the pool.
-- requiresAny: if an entity has at least one of the components listed, it will be added to the pool.
-- requiresOne: entities that have only one of the listed components will be added to the pool.
-- all the requires must be followed or else the entity will not be added.
-- so an entity that has all the requires but multiple of the requiresOne, it will not be added.
-- any and all of the requires can be left blank for any entity to be added or just ignore the require.
-- the table as the last argument can be an existing table that contains entity ids.
```

Create an entity
```LUA
ecs.newEntity(components)
-- the components are the components that are added to the entity
-- this returns the entities id and the entity itself (only the id should be stored)
```

To call any callbacks in pools and systems
```LUA
ecs.globalCall(funct, ...)
-- funct is a string that is to be called
-- the following arguments are any values to be passed to the callbacks when called
-- this will call the 'iterateFunct' for each entity in a pool
-- and the 'funct' in all systems and pools
```


That's mostly it. Any further tutorials will be added and a wiki (which I think is possible on github) will be added.
I've been using this ecs for nearly two years and older versions for even longer.
Even though it says it's only the third version, I'm exluding the other Poi Gioca that is uploaded on github.
I have many many premade systems that I may release in the future, including a multiplayer system that uses SOCK, a 3D system that uses 3Dream, a custom made AABB physics engine, ecs saving and loading, and more. As well as a handful of libraries I usually use in accompany with Poi such as viewports, gui, idinfo (for basic modding support, but it's very out of date at the moment), and more.
Either way, I'm glad to finally release this since I've been wanting to for nearly a year. It has a few unfinished functions that where originally for when I released it but they're incomplete or untested.

Ask if you need anything and tell me any comments you have!
I hope you like or at least try Poi out. It's being used to make pretty much all my games in LÖVE.
Thank you for reading~!
