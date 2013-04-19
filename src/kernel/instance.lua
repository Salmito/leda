leda={output={}}
leda.encode=__encode
leda.decode=__decode
leda.clone=__clone
leda.io=__io
leda.epoll=__epoll
leda.aio=__aio
leda.stage=__stage
local stage=leda.stage
leda.mutex=__mutex
leda.gettime=__gettime
leda.getmetatable=__getmetatable;
leda.setmetatable=__setmetatable;
leda.nice=function (...) return coroutine.yield(__yield_code,...) end
leda.debug={wait_event=__wait_event,peek_event=__peek_event}
leda.sleep=__sleep
leda.quit=__quit
function leda.get_output(key)
   key = key or 1
   --try to get the provided key
   if leda.output[key] then 
      return leda.output[key]
   end
   return nil,"Output key not found"
end
function leda.send(key,...)
   if not leda.output[key] then return nil, "Output key not found: "..tostring(key) end
   return leda.output[key]:send(...)
end
for key,connector in pairs(leda.stage.__output) do
   local c,err={}
   if connector.__sendf=="cohort" then 
      c.sendf=__cohort
   else
      c.sendf=__emmit
   end
   assert(type(c.sendf)=="function","Sendf field must be a function")
   c.consumer=connector.__consumer;
   c.id=connector.__id;
   c.send=function(self,...) return self.sendf(c.consumer,c.id,...) end
   leda.output[key]=c
end
local __handler=leda.decode(leda.stage.__handler)
if not (type(__handler)=='function' or type(__handler)=='string') then 
   error("Error loading handler function for stage: "..tostring(leda.stage.name).." type:"..type(__handler))
end
if type(__handler)=="string" then
	__handler,err=loadstring(__handler)
	if not __handler then 
	   error("Error loading handler function for stage "..tostring(leda.stage.name).."': "..tostring(err))
	end
end
leda.stage.handler=__handler
if leda.stage.__init and leda.stage.__init~="" then
	local init,err=leda.decode(leda.stage.__init)
	if init then
		if type(init)=="string" then
			init,err=loadstring(init)
			if not init then 
			   error(string.format("Error loading init function for stage '%s': %s", stage.__name,err))
	   	end
	   elseif not setfenv and type(init)=="function" then
	      local debug=require 'debug'
         local upname,old_env = debug.getupvalue (init, 1)
         if upname == '_ENV' then
           debug.setupvalue (init, 1,_ENV)
         end
      end
	   local ok,err=init() 
	end
end
__handler=leda.stage.handler
local debug=nil
if not setfenv then
   debug=require('debug')
end
local coroutine=coroutine
local function main_coroutine()
   local end_code=__end_code
   while true do
		if not stage.serial then
         local env=setmetatable({},{__index=_G})
         --clean environment --DISABLED on lua 5.2
         if setfenv then       
            setfenv(__handler,env)
         else
            local upname,old_env = debug.getupvalue (__handler, 1)
            if upname == '_ENV' then
              debug.setupvalue (__handler, 1,env)
            end
         end
   	end
      __handler(coroutine.yield(end_code))
   end 
end
handler=coroutine.wrap(main_coroutine)
local status=handler()
assert(status==__end_code,"Unexpected error")
