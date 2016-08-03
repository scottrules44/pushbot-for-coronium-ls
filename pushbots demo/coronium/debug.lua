--[[
Coronium LS - client debug module
Copyright 2016 C.Byerley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
local Prototype = require( "CoronaPrototype" )
local CloudDebug = Prototype:newClass("CloudDebug")

function CloudDebug:initialize(init_tbl)

  local init_tbl = init_tbl or {}

  self.debug_verbose  = init_tbl.show_verbose or nil
  self.debug_progress = init_tbl.show_progress or nil
  self.debug_response = init_tbl.show_response or nil

  --== For design blocks
  self.design_char    = '+'
  self.design_bumper  = '--'
  self.design_prefix  = '=='
  self.design_length  = 80

end

function CloudDebug:printRequest(request)
  if self.debug_verbose then
    self:header('Cloud Network Request')
    self:printTable(request, ' ')
    self:bar()
  end
end

function CloudDebug:printProgress(event)
  if self.debug_progress then
    local str = "Network Progress\tBytes: %d | Estimated: %d [%s]"
    local output = string.format(str, event.bytesTransferred, event.bytesEstimated, event.phase)
    self:title(output)
  end
end

function CloudDebug:printResponse(event)
  if self.debug_verbose then
    self:header('Cloud Network Response')
    self:printTable(event, ' ')
    self:bar()
  end

  if self.debug_response then
    self:header('Response Values')
    print '-> event.response'
    self:printTable(event.response, '   ')
    self:bar()
  end
end

--=========================================================================--
--== "Design" bits
--=========================================================================--
function CloudDebug:bar(noprint)
  --adjust for bumper
  local bumper_len = string.len(self.design_bumper) * 2
  local offset = self.design_length - bumper_len
  local bar_str = string.rep(self.design_char, offset)
  local output = self.design_bumper .. bar_str .. self.design_bumper
  if noprint then
    return output
  end
  print( output )
end

function CloudDebug:title(title_str, noprint)
  assert(title_str, "A title string is requried.")
  local output = self.design_bumper .. self.design_prefix .. ' ' .. title_str
  if noprint then
    return output
  end
  print( output:upper() )
end

function CloudDebug:header(title_str, noprint)
  self:bar()
  self:title(title_str)
  self:bar()
end

--=========================================================================--
--== Table print
--=========================================================================--
function CloudDebug:printTable( t, indent )
  -- Type checks
  if type( t ) == 'userdata' then
    print('Cannot output Lua userdata.')
  end

  if type( t ) ~= 'table' then
    print( tostring( t ) )
    return
  end

-- print contents of a table, with keys sorted. second parameter is optional, used for indenting subtables
  local names = {}
  if not indent then indent = "" end
  for n,g in pairs(t) do
      table.insert(names,n)
  end
  table.sort(names)
  for i,n in pairs(names) do
      local v = t[n]
      if type(v) == "table" then
          if(v==t) then -- prevent endless loop if table contains reference to itself
              print(indent..tostring(n)..": <-")
          else
              print(indent..tostring(n)..":")
              self:printTable(v,indent.."   ")
          end
      else
          if type(v) == "function" then
              print(indent..tostring(n).."()")
          else
              print(indent..tostring(n)..": "..tostring(v))
          end
      end
  end
end

function CloudDebug:split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

return CloudDebug
