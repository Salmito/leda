local tostring = tostring
local pcall = pcall
local antgr=graph
graph=nil
module ("leda.utils.plot", package.seeall)
local gr = require "graph"
graph=antgr

local node, edge, subgraph, cluster, digraph, strictdigraph =
  gr.node, gr.edge, gr.subgraph, gr.cluster, gr.digraph, gr.strictdigraph

function plot_graph(leda_graph,out)
   local g = strictdigraph{
      tostring(leda_graph),
      compound = "1",
      textwrap="auto",    
      rankdir = "LR",
   }
   g.label=tostring(leda_graph)
   local start_node=nil
   local nodes={}
   if leda_graph.start then
      start_node=g:node{"START",shape='Mdiamond'}
   end

   local clusters={}
   
   for s in pairs(leda_graph:stages()) do
      local sname=tostring(s)
      if s.serial then
         sname="["..sname.."]"
      end
      local s_cl=leda_graph:get_cluster(s)
      if s_cl then
--         if #s_cl.process_addr==0 then         
            clusters[s]=clusters[s] or g:cluster{tostring(s_cl)}
            cl=clusters[s]
            clusters[s].label=tostring(s_cl)
            if s_cl:has_serial() then
               clusters[s].label="["..tostring(s_cl).."]"
            end
--         else
--             for i,addr in ipairs(s_cl.process_addr) do    
--             end                   
--         end
      else 
         cl=g 
      end
      nodes[s]=cl:node{sname}
--      s.cluster=g:cluster("Sub"..tostring(leda_graph.stages[i]))
   end
   for c in pairs(leda_graph.conns) do
      local node=start_node
      if c.producer then
         node=nodes[c.producer]
      end
      local color=nil
      local style=nil
      local arrowType=nil
      if c:get_type()=='coupled' then
         color="#FF0000"
         arrowType="dot"
      elseif c:get_type()=='decoupled' then
         if not c.producer or leda_graph:get_cluster(c.producer) ~= leda_graph:get_cluster(c.consumer) then
            style="dashed"
         end
      elseif c:get_type()=='cohort' then
         color="#0000FF"
         arrowType="invdot"
      end
      g:edge{node,nodes[c.consumer],label=tostring(c),color=color,fontcolor=color,style=style,arrowhead=arrowType}
   end
   if not out then
      g:show()
   elseif type(out)=="string" then
      ext=out:reverse():gmatch("[^\.]*")():reverse()
      if ext then
         g:layout()
         g:render(ext, out)
      end
   else
      error("Invalid parameter type")
   end
   g:close()
end
leda.plot_graph=plot_graph
