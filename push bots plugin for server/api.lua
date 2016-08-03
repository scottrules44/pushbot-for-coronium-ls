-- copyright Scott Harrison(scottrules44) Aug 3 2016
local pushbots = require("pushbots")

local api = cloud.api()


function api.post.unRegisterDevice( data )
	local results, error=pushbots.unRegisterDevice(data)
	return {result = result, error = error}
end

function api.post.updateAlias( data )
	local results, error=pushbots.updateAlias(data)
	return {result = result, error = error}
end

function api.post.tagDevice( data )
	local results, error=pushbots.tagDevice(data)
	return {result = result, error = error}
end

function api.post.deleteTag( data )
	local results, error=pushbots.deleteTag(data)
	return {result = result, error = error}
end

function api.post.updateLocation( data )
	local results, error=pushbots.updateLocation(data)
	return {result = result, error = error}
end

function api.post.deviceInfo( data )
	local results, error=pushbots.deviceInfo(data.token)
	return {result = result, error = error}
end

function api.post.push( data )
	local results, error=pushbots.push(data)
	return {result = result, error = error}
end

function api.post.pushAll( data )
	local results, error=pushbots.pushAll(data)
	return {result = result, error = error}
end

function api.post.getAnalytics(  )
	local results, error=pushbots.getAnalytics()
	return {result = result, error = error}
end

function api.post.setAnalytics( data )
	local results, error=pushbots.setAnalytics(data)
	return {result = result, error = error}
end

function api.post.registerDevice( data )
	local results, error=pushbots.registerDevice(data)
	return {result = result, error = error}
end

function api.post.deleteByAlias( data )
	local results, error=pushbots.deleteByAlias(data)
	return {result = result, error = error}
end

function api.post.updateTagsByAlias( data )
	local results, error=pushbots.updateTagsByAlias(data)
	return {result = result, error = error}
end

function api.post.updateTagByAlias( data )
	local results, error=pushbots.updateTagByAlias(data)
	return {result = result, error = error}
end

function api.post.removeTagByAlias( data )
	local results, error=pushbots.updateTagByAlias(data)
	return {result = result, error = error}
end

function api.post.registerDevices( data )
	local results, error=pushbots.registerDevices(data)
	return {result = result, error = error}
end

function api.post.aliasDeviceNumber( data )
	local results, error=pushbots.aliasDeviceNumber(data)
	return {result = result, error = error}
end

function api.post.addOrDeleteTags( data )
	local results, error=pushbots.addOrDeleteTags(data)
	return {result = result, error = error}
end

return api