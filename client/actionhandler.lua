class 'ZEDActionHandler'

function ZEDActionHandler:__init()
	self.blacklist = {Action.Kick,Action.Evade}--,Action.FireGrapple,Action.ParachuteOpenClose}
    Network:Subscribe( "ZEDDisableAction", self, self.DisableAction )
    Network:Subscribe( "ZEDEnableAction", self, self.EnableAction )
    Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
end

function ZEDActionHandler:EnableAction( args )
	for k,v in pairs(self.blacklist) do
		if v == args.action then
			self.blacklist[k] = nil
		end
	end
end

function ZEDActionHandler:DisableAction( args )
	for k,v in pairs(self.blacklist) do
		if v == args.action then
			return
		end
	end
	table.insert(self.blacklist, args.action)
end

function ZEDActionHandler:LocalPlayerInput( args )
	for index, action in ipairs(self.blacklist) do
		if action == args.input then
			return false
		end
	end
 
	return true
end

local zedactionhandler = ZEDActionHandler()