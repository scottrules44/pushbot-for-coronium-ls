--[[
Coronium LS - client request module
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
local CloudRequest = Prototype:newClass("CloudRequest")

local json = require('json')
local crypto = require('crypto')

function CloudRequest:initialize(init_tbl)

  assert(init_tbl, "A request configuration table is required.")
  assert(init_tbl.host, "A cloud host address is required.")
  assert(init_tbl.path, "A app/module path is required.")
  assert(init_tbl.app_key, "An app key is required.")

  local CloudHeaders = require('coronium.headers'):new({
    host = init_tbl.host or nil,
    app_key = init_tbl.app_key or nil,
    cloud_key = init_tbl.cloud_key or nil
  })
  local headers = CloudHeaders:get()

  --prebake
  self.request =
  {
    host            = init_tbl.host or nil,
    https           = init_tbl.https or nil,
    app_key         = init_tbl.app_key or nil,
    cloud_key       = init_tbl.cloud_key or nil,
    path            = init_tbl.path or nil,
    method          = init_tbl.method or "POST",
    prefix          = 'https://', --default
    headers         = headers,
    endpoint        = nil, --assigned later
    body            = nil, --assigned later
  }

  --debugger
  self.Debug = assert(init_tbl.Debug, "Debug module not found in CloudRequest.")

  --runtime event flag
  self.runtime_event = init_tbl.runtime_event or nil
  self.runtime_event_id = init_tbl.runtime_event_id or 'CloudEvent'

  --generate prefix
  if not self.request.https then
    self.request.prefix = 'http://'
  end

  --generate endpoint
  self.request.endpoint = self.request.prefix .. self.request.host .. self.request.path


end

function CloudRequest:send(args_tbl, listener )
  local args_tbl = args_tbl or {}
  local listner = listener or nil

  --massage args
  if args_tbl then
    local success, result_JsonOrErr = pcall(json.encode, args_tbl)

    if not success then
      return nil, result_JsonOrErr
    end

    self.request.body = result_JsonOrErr

    --hash it
    local function makeHash(body)
      local normalized = self.request.host .. self.request.app_key .. self.request.path
      return crypto.digest(crypto.md5, normalized)
    end

    self.request.headers['X-Cloud-Hash'] = makeHash(self.request.body)

    self.Debug:printRequest(self.request)
  end

  local function runListener(eventType, event)
    if type(listener) == 'function' then
      listener(event)
    elseif type(listener) == 'table' then
      if listener[eventType] then
        listener[eventType](event)
      end
    end

    if self.runtime_event then
      Runtime:dispatchEvent({name=self.runtime_event_id, evt=event})
    end
  end

  --network process listener
  local function processListener(event)
    if event.isError then
      self.Debug:printResponse(event)
      runListener('onError', event)
    else
      if event.phase == 'ended' then
        --convert-o-tron
        local success, result_TblOrErr = pcall(json.decode, event.response)
        if not success then
          event['response'] = { error = result_TblOrErr }
          self.Debug:printResponse(event)
          runListener('onError', event)
        else
          event['response'] = result_TblOrErr.result
          self.Debug:printResponse(event)
          runListener('onResponse', event)
        end
      elseif event.phase == 'began' then
        self.Debug:printProgress(event)
        runListener('onBegan', event)
      elseif event.phase == 'progress' then
        self.Debug:printProgress(event)
        runListener('onProgress', event)
      end
    end
  end

  --set up network request
  local req_params =
  {
    body = tostring(self.request.body),
    progress = 'download',
    headers = self.request.headers
  }

  return network.request(self.request.endpoint, "POST", processListener, req_params)
end

function CloudRequest:httpTime()
  return os.date("%a, %d %b %Y %H:%M:%S %Z")
end

return CloudRequest
