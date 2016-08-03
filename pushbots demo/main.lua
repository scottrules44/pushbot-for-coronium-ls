local hostIP = "" -- Your cloud host IP
local appKey = "0000000-0000-0000-0000-0000000000" -- Your cloud app ke
local appName = "echo" -- Your app name
local pushToken
local deviceType = 0 -- default ios
local os = system.getInfo( "platformName" )
if os == "Android" then
    deviceType = 1
elseif os ~= "iPhone OS" then
    error( "platform not supported for pushbot" )
end
local json = require("json")
local notifications = require( "plugin.notifications" )

-- Require and initialize your Coronium LS Cloud
local coronium = require('coronium.cloud')
local cloud = coronium:new(
{
    host = hostIP,
    app_key = appKey,
    is_local = false, -- true when working on a local server, false when on AWS/DigitalOcean
    https = true -- false when working on a local server, true when on AWS/DigitalOcean
})

-- Create a sendEmail listener function
local function check1(event)
    if event.phase == "ended" then
        local response = event.response
        print( "check 1" )
        print( "------------------" )
        print(json.encode(response))
    end
end

local function check2(event)
    if event.phase == "ended" then
        local response = event.response
        print( "check 2" )
        print( "------------------" )
        print(json.encode(response))
    end
end
local button = display.newGroup( )
button.rect = display.newRect( button, 0, 0, 100, 30 )
button.rect:setFillColor( 1 )
button.myText = display.newText( button, "push", 0, 0 , native.systemFont , 12 )
button.myText:setFillColor( 0 )
button.x,button.y = display.contentCenterX, display.contentCenterY
button.rect:addEventListener( "tap", function (  )
    cloud:request("/" .. appName .. "/push", {
        token = deviceToken,
        platform = deviceType,
        msg = "hello from pushbot",
        sound = data.sound,
        badge = data.badge,
        payload = data.payload,
    }, check2)
end )
local function notificationListener( event )

    if ( event.type == "remote" or event.type == "local" ) then
        print( "push info" )
        print( "------------------" )
        print( json.encode( event ) )

    elseif ( event.type == "remoteRegistration" ) then

        deviceToken = event.token
        cloud:request("/" .. appName .. "/registerDevice", {
        token = deviceToken,
        platform = deviceType,
        --[[lat = data.lat,
        lng = data.lng,
        active = data.active,
        tag = data.tag,
        alias = data.alias,
        carrier = data.carrier,
        osVersion = data.osVersion,
        lib = data.lib,
        resolution = data.resolution,
        locale = data.locale,
        device = data.device,]]--
        }, check1)
    end
end

Runtime:addEventListener( "notification", notificationListener )