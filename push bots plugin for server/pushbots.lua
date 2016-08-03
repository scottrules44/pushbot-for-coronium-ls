-- copyright Scott Harrison(scottrules44) Aug 3 2016
local http = require("ssl.https")
local json = require("cjson")
local ltn12 = require("ltn12")
local mime = require("mime")
local url = require("socket.url")

local m = {}

local appId = "appId"
local secretId = "secretId"

function m.formatResponse(result, status)
    pcall(function()
        result = json.decode(result)
    end)
    if result == "" or not result then
        result = "Invalid Response"
    end
    if status ~= 200 then
        return nil, result.message or result
    end
    return result
end

function m.apiRequest(path, data, myMethod, myToken, secret)
    local body = json.encode(data)
    local output = {}
    local request =
    {
        url = "https://api.pushbots.com/".. path,
        source = ltn12.source.string(body),
        method = myMethod,
        headers =
        {
            ["x-pushbots-appid"] = appId,
            ["Content-type"] = "application/json",
            --["Content-length"] = #body,
        },
        sink = ltn12.sink.table(output),
        protocol = "sslv23"
    }
    if (myToken) then
        request =
        {
            url = "https://api.pushbots.com/".. path,
            source = ltn12.source.string(body),
            method = myMethod,
            headers =
            {
                ["x-pushbots-appid"] = appId,
                ["Content-type"] = "application/json",
                ["token"] = myToken
                --["Content-length"] = #body,
            },
            sink = ltn12.sink.table(output),
            protocol = "sslv23"
        }
    elseif (secret and secret == true) then
        request =
        {
            url = "https://api.pushbots.com/".. path,
            source = ltn12.source.string(body),
            method = myMethod,
            headers =
            {
                ["x-pushbots-appid"] = appId,
                ["x-pushbots-secret"] = secretId,
                ["Content-type"] = "application/json",
                --["Content-length"] = #body,
            },
            sink = ltn12.sink.table(output),
            protocol = "sslv23"
        }
    end
    local _, status = http.request(request)
    return m.formatResponse(table.concat(output), status)
end

function m.unRegisterDevice( data )--https://pushbots.com/developer/docs/api-unregister
    local myData = {
        token = data.token,
        platform = data.platform,
    }
    return m.apiRequest("deviceToken/del", myData, "PUT")
end
function m.updateAlias( data )--https://pushbots.com/developer/docs/api-alias
    local myData = {
        token = data.token,
        platform = data.platform,
        alias = data.alias,
        current_alias = data.current_alias,
    }
    return m.apiRequest("alias", myData, "PUT")
end
function m.tagDevice( data )--https://pushbots.com/developer/docs/api-tag
    local myData = {
        token = data.token,
        platform = data.platform,
        alias = data.alias,
        tag = data.tag,
    }
    return m.apiRequest("tag", myData, "PUT")
end
function m.deleteTag( data )--https://pushbots.com/developer/docs/api-deltag
    local myData = {
        token = data.token,
        platform = data.platform,
        alias = data.alias,
        tag = data.tag,
    }
    return m.apiRequest("tag/del", myData, "PUT")
end
function m.updateLocation( data )--https://pushbots.com/developer/docs/api-geo
    local myData = {
        token = data.token,
        platform = data.platform,
        lat = data.lat,
        lng = data.lng,
    }
    return m.apiRequest("geo", myData, "PUT")
end
function m.deviceInfo( token )--https://pushbots.com/developer/docs/api-OneToken
    local myData = {}
    return m.apiRequest("deviceToken/one", myData, "GET", token)
end
function m.push( data )--https://pushbots.com/developer/docs/api-PushOne
    local myData = {
        token = data.token,
        platform = data.platform,
        msg = data.msg,
        sound = data.sound,
        badge = data.badge,
        payload = data.payload,
    }
    return m.apiRequest("push/one", myData, "POST", nil, true)
end
function m.pushAll( data )--https://pushbots.com/developer/docs/api-batch_push
    local myData = {
        platform = data.platform,
        msg = data.msg,
        sound = data.sound,
        badge = data.badge,
        schedule = data.schedule,
        except_tags = data.except_tags,
        alias = data.alias,
        except_alias = data.except_alias,
        tags = data.tags,
        payload = data.payload,
    }
    return m.apiRequest("push/all", myData, "POST", nil, true)
end
function m.badgeDevice( data )--https://pushbots.com/developer/docs/api-badge
    -- note setbadgecount is used instead of badgecount
    local myData = {
        token = data.token,
        platform = data.platform,
        setbadgecount = data.setbadgecount,
    }
    return m.apiRequest("badge", myData, "PUT")
end
function m.getAnalytics(  )--https://pushbots.com/developer/docs/api-getAnalytics
    local myData = {}
    return m.apiRequest("badge", myData, "GET", nil, true)
end
function m.setAnalytics( data )--https://pushbots.com/developer/docs/api-analytics
    local myData = {
        platform = data.platform,
    }
    return m.apiRequest("stats", myData, "PUT")
end
function m.registerDevice( data )--https://pushbots.com/developer/docs/api-register
    local myData = {
        token = data.token,
        platform = data.platform,
        lat = data.lat,
        lng = data.lng,
        active = data.active,
        tag = data.tag,
        alias = data.alias,
        carrier = data.carrier,
        osVersion = data.osVersion,
        lib = data.lib,
        resolution = data.resolution,
        locale = data.locale,
        device = data.device,
    }
    return m.apiRequest("deviceToken", myData, "PUT")
end
function m.deleteByAlias( data )--https://pushbots.com/developer/docs/api-remove_by_alias
    local myData ={
        alias = data.alias,
    }
    return m.apiRequest("alias/del", myData, "PUT", nil, true)
end
function m.updateTagsByAlias( data )--https://pushbots.com/developer/docs/api-update_tag_by_alias
    local myData ={
        alias = data.alias,
        tags = data.tags,
    }
    return m.apiRequest("tag/alias", myData, "PUT")
end
function m.updateTagByAlias( data )--https://pushbots.com/developer/docs/api-tag_one_by_alias
    local myData ={
        alias = data.alias,
        tag = data.tags,
    }
    return m.apiRequest("tag/one/alias", myData, "PUT")
end
function m.removeTagByAlias( data )--https://pushbots.com/developer/docs/api-untag_one_by_alias
    local myData ={
        alias = data.alias,
        tag = data.tag,
    }
    return m.apiRequest("tag/one/alias/del", myData, "PUT")
end
function m.registerDevices( data )--https://pushbots.com/developer/docs/api-batch_import
    local myData ={
        tokens = data.tokens,
        platform = data.platform,
        tags = data.tags,
    }
    return m.apiRequest("deviceToken/batch", myData, "PUT")
end
function m.aliasDeviceNumber( data )--https://pushbots.com/developer/docs/api-count_by_alias
    local myData ={
        platform = data.platform,
        alias = data.alias,
    }
    return m.apiRequest("deviceToken/alias", myData, "POST")
end
function m.addOrDeleteTags( data )--https://pushbots.com/developer/docs/api-update_tags
    local myData ={
        token = data.token,
        alias = data.alias,
        platform = data.platform,
        tags_add = data.tags_add,
        tags_remove = data.tags_remove,
    }
    return m.apiRequest("tags/update", myData, "PUT")
end
return m