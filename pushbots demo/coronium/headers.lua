--[[
Coronium LS - client headers module
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
local Prototype = require('CoronaPrototype')
local CloudHeaders = Prototype:newClass("CloudHeaders")

function CloudHeaders:initialize( init_tbl )
  if init_tbl.cloud_key then
    init_tbl.cloud_key = tostring(init_tbl.cloud_key)
  end

  self.default_headers =
  {
    ['X-Cloud-Key'] = tostring(init_tbl.app_key),
    ['X-Cloud-Master'] = init_tbl.cloud_key,
    ['X-Cloud-Vendor'] = 'CoroniumLS',
    ['Content-Type'] = 'application/json',
    ['Accept'] = 'application/json',
    ['Host'] = tostring(init_tbl.host)
  }
end

function CloudHeaders:get( user_headers )
  if user_headers and type(user_headers) == 'table' then
    for k, v in pairs( user_headers ) do
      self.default_headers[ k ] = v
    end
  end
  self.default_headers['Date'] = self:httpTime()
  return self.default_headers
end

function CloudHeaders:httpTime()
  return os.date("%a, %d %b %Y %H:%M:%S %Z")
end

return CloudHeaders
