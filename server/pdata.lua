PData = {}
PData.Players = {} 
PData.Test = "FUCK THIS"
	
PData.Get = function(t,ply)
	if(PData.Players[ply:GetId()])then
		return PData.Players[ply:GetId()]
	else
		return {}
	end
end
PData.Set = function(t,ply, tbl)
	for k,v in pairs(tbl) do
		PData.Players[ply:GetId()][k] = v
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
		local str = json():encode(tbl)
		if(PData:Get(ply))then
				local p = PData:Get(ply)
				for k,v in pairs(tbl) do
						p[k] = v
				end
				str = json():encode(p)
		end
		local file = io.open("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt", "w")
		file:write(str)
		file:close()
	else
		local str = json():encode({})
		if(PData:Get(ply))then
			str = json():encode(PData:Get(ply))
		end
		local file = io.open("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt", "w")
		file:write(str)
		file:close()
	end
end

PData.Load = function(t,ply, default)
	local file = io.open("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt", "r")
	if(file)then
		local ret = json():decode(file:read("*all"))
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
			PData.Players[ply:GetId()] = ret
		else
			if(default)then
				PData.Players[ply:GetId()] = default
			else
				PData.Players[ply:GetId()] = {}
			end
		end
	else
		if(default)then
			PData.Players[ply:GetId()] = default
		else
			PData.Players[ply:GetId()] = {}
		end
	end
end