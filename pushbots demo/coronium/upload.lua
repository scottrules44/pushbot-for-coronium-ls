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
local CloudUpload = Prototype:newClass("CloudUpload")

local url = require('socket.url')
local json = require('json')

function CloudUpload:initialize(init_tbl)

  self.host             = init_tbl.host or nil
  self.app_key          = init_tbl.app_key or nil
  self.cloud_key        = init_tbl.cloud_key or nil

  self.endpoint         = init_tbl.endpoint or nil
  self.file_source      = init_tbl.source or nil
  self.dest_source      = init_tbl.destination or nil
  self.base_directory   = init_tbl.baseDirectory or system.DocumentsDirectory

  self.Mimes = assert(require('coronium.mimes'):new(), "Could not load the CloudMimes class.")
  self.Utils = assert(require('coronium.utils'):new(), "Could not load the CloudUtils class.")

  -- Get upload extension
  local ext = self.Utils:getExt(self.file_source)
  -- Get upload mime type
  self.mime_type = self.Mimes:getType(ext)

  --debugger
  self.Debug = assert(init_tbl.Debug, "Debug module not found in CloudUpload.")
end

function CloudUpload:upload(listener, user_headers)

  local host = self.host or nil
  local app_key = self.app_key or nil
  local cloud_key = self.cloud_key or nil

  local CloudHeaders = require('coronium.headers'):new({
    host = host,
    app_key = app_key,
    cloud_key = cloud_key
  })

  user_headers = user_headers or {}
  user_headers['X-Cloud-File'] = self.file_source
  user_headers['X-Cloud-Dir'] =  self.dest_source

  local headers = CloudHeaders:get( user_headers )

  local params =
  {
    progress = true,
    headers = headers,
    bodyType = 'binary'
  }

  local function runListener(eventType, event)
    if type(listener) == 'function' then
      listener(event)
    elseif type(listener) == 'table' then
      if listener[eventType] then
        listener[eventType](event)
      end
    end
  end

  local function processListener(event)
    if event.isError then
      self.Debug:printResponse(event)
      runListener('onError', event)
    else
      if event.phase == 'ended' then
        --convert-0-tron
        local success, result_tblOrErr = pcall(json.decode, event.response)
        if result_tblOrErr.result then
          event['response'] = result_tblOrErr.result
        else
          event['response'] = result_tblOrErr
        end
        self.Debug:printResponse(event)
        runListener('onResponse', event)
      elseif event.phase == 'began' then
        self.Debug:printProgress(event)
        runListener('onBegan', event)
      elseif event.phase == 'progress' then
        self.Debug:printProgress(event)
        runListener('onProgress', event)
      end
    end
  end

  return network.upload(self.endpoint, "POST", processListener, params, self.file_source, self.base_directory, self.mime_type)
end

return CloudUpload
