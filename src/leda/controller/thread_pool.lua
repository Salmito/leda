-----------------------------------------------------------------------------
-- Leda simple fixed thread pool controller
-- Author: Tiago Salmito, Noemi Rodriguez, Ana Lucia de Moura
-----------------------------------------------------------------------------

local base = _G
local debug=require("leda.debug")
local dbg = debug.get_debug("Controller: Fixed-thread-pool: ")
local kernel=leda.kernel
local table=table
local default_thread_pool_size=kernel.cpu()

local t={}

local pool_size=default_thread_pool_size
local th={}

-----------------------------------------------------------------------------
-- Controller init function
-----------------------------------------------------------------------------

local function get_init(n,affinity)
   return   function()
               pool_size=n
               for i=1,n do
               	local thread=kernel.thread_new()
               	if affinity then
  	                   thread:set_affinity(i)
               	end
                  table.insert(th,thread)
                  dbg("Thread %d created",i)
               end
            end
end
t.init=get_init(default_thread_pool_size)

function t.finish()
   for i,thread in ipairs(th) do
      thread:kill()
   end
	for i,thread in ipairs(th) do
      thread:join()
      dbg("Thread %d killed",i)
   end
   dbg "Controller finished"
end

function t.get(n,a)
   return {init=get_init(n,a),finish=t.finish}
end

if leda and leda.controller then
   leda.controller.thread_pool=t
end

return t
