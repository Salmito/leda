-----------------------------------------------------------------------------
-- Leda's Connector Lua API
-- Author: Tiago Salmito, Noemi Rodriguez, Ana Lucia de Moura
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Declare module and import dependencies
-----------------------------------------------------------------------------
local string,table,kernel = string,table,leda.kernel
local getmetatable,setmetatable,type,tostring,assert=
      getmetatable,setmetatable,type,tostring,assert

local dbg = leda.debug.get_debug("Connector: ")
local dump = string.dump
local leda=leda

module("leda.l_connector")

-----------------------------------------------------------------------------
-- Connector metatable
-----------------------------------------------------------------------------
local connector = {__index = {}}

-----------------------------------------------------------------------------
-- Connector __tostring metamethod
-----------------------------------------------------------------------------
function connector.__tostring(c)
   if c.name then 
      return c.name
   else
      return string.format("Connector (%s)",kernel.to_pointer(c)) 
   end
end

-----------------------------------------------------------------------------
-- Connector __index metamethod
-----------------------------------------------------------------------------
local index=connector.__index

-----------------------------------------------------------------------------
-- Add a producer to a connector, 'producer' must be a stage
-----------------------------------------------------------------------------
function index.add_producer(self,producer)
   assert(leda.l_stage.is_stage(producer),"'producer' must be a stage")
   dbg("Adding producer '%s' on connector '%s'",tostring(producer),tostring(self))
   table.insert(self.producers,producer)
end

function index.method(self,sendf) 
    self.sendf=sendf
end

-----------------------------------------------------------------------------
-- Add a consumer to a connector, 'consumer' must be a stage
-----------------------------------------------------------------------------
function index.add_consumer(self,consumer)
   assert(leda.l_stage.is_stage(consumer),"'consumer' must be a stage")
   dbg("Adding consumer '%s' on connector '%s'",tostring(consumer),tostring(self))
   table.insert(self.consumers,consumer)
end

-----------------------------------------------------------------------------
-- Add pending data to the connector
-----------------------------------------------------------------------------    
function index.send(self,...)
   local v={...}
   table.insert(self.pending,v)
end

-----------------------------------------------------------------------------
-- Function that throw an event to each consumer of the connector
-----------------------------------------------------------------------------    
function emmit_func (con,...)  
   for _,c in ipairs(con) do
      local ret, err=__emmit(c,...) 
      if not ret then return nil,err end
   end 
   return true
end

-----------------------------------------------------------------------------
-- Function that pass the thread to each consumer of the connector in order
-- and wait for them to complete
-----------------------------------------------------------------------------    
function call_func(con,...) 
   for _,c in ipairs(con) do
      local ret, err=__call(c,...) 
      if not ret then return nil,err end
   end 
   return true
end

-----------------------------------------------------------------------------
-- Function that throws an event with the continuation of itself
-- and pass the thread to each consumer of the connector in order
-----------------------------------------------------------------------------    
function emmit_self_call_func(con,...) 
   for _,c in ipairs(con) do 
      local ret, err=__emmit_self_call(c,...)
      if not ret then return nil,err end
   end
   return true
end

-----------------------------------------------------------------------------
-- Creates a new connector and returns it
-- param:   'c': table used to hold the connector representation
-----------------------------------------------------------------------------    
function new_connector(c)
   c=c or {}
   if type(c[1])=="string" then
     c.name=c.name or c[1]
     table.remove(c,1)
   end
   c=setmetatable(c or {}, connector)
   
   c.consumers=c.consumers or {}
   c.producers=c.producers or {}
   c.pending=c.pending or {}
   c.sendf=c.sendf or emmit_func
    
   dbg("Created connector '%s'",tostring(c))
   return c
end

-----------------------------------------------------------------------------
-- Verify if parameter 'c' is a connector 
-- (i.e. has the connector metatable)
--
-- returns:       'true' if 'c' is a connector
--                'false' if not
-----------------------------------------------------------------------------
function is_connector(c)
   if getmetatable(c)==connector then return true end
   return false
end
