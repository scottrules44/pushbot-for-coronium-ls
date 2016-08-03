--[[
Coronium LS - client cloud module
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
local Cloud = Prototype:newClass("Cloud")

local json = require('json')

function Cloud:initialize( user_config )

  self._version = '1.x.x-beta'

  self.config = {}
  --defaults
  self.config.https             = true
  self.config.globalize         = true
  self.config.runtime_event     = false
  self.config.runtime_event_id  = 'CloudEvent'
  self.config.show_response     = nil
  self.config.show_progress     = nil
  self.config.show_verbose      = nil

  --merge user_config
  for name, val in pairs( user_config ) do
    self.config[name] = val
  end

  self.CloudRequest   = assert(require('coronium.request'), "Could not load CloudRequest class.")
  self.CloudUpload    = assert(require('coronium.upload'), "Could not load CloudUpload class.")
  self.CloudDownload  = assert(require('coronium.download'), "Could not load CloudDownload class.")

  --set up debug output
  local CloudDebug = assert(require('coronium.debug'), "Could not load CloudDebug class.")
  self.Debug = CloudDebug:new({
    show_response  = self.config.show_response or nil,
    show_progress  = self.config.show_progress or nil,
    show_verbose   = self.config.show_verbose or nil,
  })

  --make global
  if self.config.globalize then
    _G['cloud'] = self
  end
end

function Cloud:getHostUri( uri )
  local prefix = 'https://'
  if not self.config.https then
    prefix = 'http://'
  end

  return tostring(prefix..uri)
end

function Cloud:getEndpoint(path, https)
  assert(path, "An valid path is required.")

  local prefix = 'https://'
  if not https then
    prefix = 'http://'
  end

  return tostring(prefix .. self.config.host .. path)
end

function Cloud:request(path, args_tbl, listener, headers)
  assert(path, "A app/module path is required.")

  self.config.path = path or nil
  self.config.headers = headers or {}
  self.config.Debug = self.Debug

  local req = self.CloudRequest:new(self.config)
  return req:send(args_tbl, listener)
end

function Cloud:upload(local_source, listener, remote_file_dir, baseDirectory, headers)
  local endpoint = self:getEndpoint('/_file/upload/')
  local app_key = self.config.app_key
  local cloud_key = self.config.cloud_key
  local host = self.config.host
  local up = self.CloudUpload:new({
    endpoint = endpoint or nil,
    source = local_source or nil,
    destination = remote_file_dir or nil,
    baseDirectory = baseDirectory or system.DocumentsDirectory,
    headers = headers or nil,
    app_key = app_key,
    cloud_key = cloud_key,
    host = host,
    Debug = self.Debug
  })

  return up:upload(listener, headers)
end

function Cloud:download(remote_path, local_path, listener, baseDirectory, headers)
  local endpoint = self:getEndpoint('/files'..remote_path)
  local app_key = self.config.app_key
  local cloud_key = self.config.cloud_key
  local host = self.config.host
  local down = self.CloudDownload:new({
    endpoint = endpoint or nil,
    source = remote_path or nil,
    destination = local_path or nil,
    baseDirectory = baseDirectory or system.DocumentsDirectory,
    headers = headers or nil,
    app_key = app_key,
    cloud_key = cloud_key,
    host = host,
    Debug = self.Debug
  })
  return down:download(listener, headers)
end

function Cloud:cancel(request_id)
  if request_id then
    network.cancel(request_id)
  end
end

function Cloud:getVersion(do_print)
  local str = string.format("Coronium LS v%s", self._version)

  if not do_print then
    return str
  end

  print( str )
end

return Cloud
