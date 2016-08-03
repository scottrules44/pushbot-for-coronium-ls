--[[
Coronium LS - client upload module
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
local CloudUtils = Prototype:newClass("CloudUtils")

local url = require('socket.url')

function CloudUtils:initialize()
end

function CloudUtils:basename(path)
  local parts = url.parse_path(path)
  return table.remove(parts)
end

function CloudUtils:getExt(path)
  local basename = self:basename(path)
  return self:split(basename, '.')[2]
end

function CloudUtils:split(inputstr, sep)
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

return CloudUtils
