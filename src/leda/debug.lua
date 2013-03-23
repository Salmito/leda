-----------------------------------------------------------------------------
-- Leda's debug API
-- Author: Tiago Salmito, Noemi Rodriguez, Ana Lucia de Moura
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Declare module and import dependencies
-----------------------------------------------------------------------------
local string = string
local io=io
local DEBUG=DEBUG
--module("leda.debug")
local t={}

-----------------------------------------------------------------------------
-- Function to get a debug handler
-----------------------------------------------------------------------------
function t.get_debug(prefix,sufix)
   if DEBUG then
      sufix=sufix or "\n"
      return function (fmt, ...)
         io.stderr:write(prefix)
         io.stderr:write(string.format(fmt, ...))
         io.stderr:write(sufix)
      end
   end
   return function () end
end

return t
