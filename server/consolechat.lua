class 'ZEDConsoleChat'

function ZEDConsoleChat:__init()
	Console:Subscribe("zsay", self, self.CChat)
end
function ZEDConsoleChat:Broadcast(...)
	args = {...}
	if type(args[1]) == "table" then
		Events:Fire("ZEDBroadcast", args[1])
	else
		Events:Fire("ZEDBroadcast", {...})
	end
end
function ZEDConsoleChat:CChat(args)
	self.Broadcast(Color(255,255,255), "Console: " .. args)
end

local run = ZEDConsoleChat()