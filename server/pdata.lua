local json = require "json"
Events:Register( "ZEDReady" )
Events:Register( "GetPData" )

PData = {}
PData.Players = {} 
	
PData.Get = function(t,ply)
	if(self.Players[ply:GetId()])then
		return self.Players[ply:GetId()]
	else
		return {}
	end
end
PData.Set = function(t,ply, tbl)
	for k,v in pairs(tbl) do
		self.Players[ply:GetId()][k] = v
	end
end

PData.Exists = function( t,ply)
	if(ZED:file_exists("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt"))then
		return true
	else
		return false
	end
end

PData.Save = function(t,ply, tbl)
	if(tbl)then
		local str = json:encode(tbl)
		if(self:Get(ply))then
				local p = self:Get(ply)
				for k,v in pairs(tbl) do
						p[k] = v
				end
				str = json:encode(p)
		end
		local file = io.open("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt", "w")
		file:write(str)
		file:close()
	else
		local str = json:encode({})
		if(self:Get(ply))then
			str = json:encode(self:Get(ply))
		end
		local file = io.open("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt", "w")
		file:write(str)
		file:close()
	end
end

PData.Load = function(t,ply, default)
	local file = io.open("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt", "r")
	if(file)then
		local ret = json:decode(file:read("*all"))
		if(ret)then
			if(default)then
				for k,v in pairs(default) do
					local found = false
					for i,j in pairs(ret) do
						if i == k then
							found = true
						end
					end
					if not found then
						ret[k] = v
					end
				end
			end
			self.Players[ply:GetId()] = ret
		else
			if(default)then
				self.Players[ply:GetId()] = default
			else
				self.Players[ply:GetId()] = {}
			end
		end
	else
		if(default)then
			self.Players[ply:GetId()] = default
		else
			self.Players[ply:GetId()] = {}
		end
	end
end

Events:Subscribe("ZEDReady", function()
	Events:FireRegisteredEvent("GetPData", PData)
end)