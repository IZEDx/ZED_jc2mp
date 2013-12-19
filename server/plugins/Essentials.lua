if( not ZED ) then ZED = {}	ZED.Plugins = {} end


MOD = {}
MOD.Initialize = function()
	local FreezeActions = {39, 152, 48, 47, 67, 66, 68, 69, 36, 118, 146, 76, 19, 37, 116, 113, 115, 114, 117, 45, 46, 11, 81, 12, 13, 14, 82, 43, 57, 132, 50, 56, 49, 55, 53, 54, 51, 52, 78, 35, 4, 5, 6, 3, 1, 137, 31, 30, 32, 33, 70, 17, 72, 71, 147, 148, 65, 64, 59, 62, 63, 60, 61, 18, 144, 145, 16, 7, 40, 9, 126, 125, 128, 127, 44, 119, 75, 73, 74, 77, 10, 15, 41, 42, 38, 8, 138, 139, 34, 29, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 83, 84 }

	ZED:AddCommand("veh", function(ply, args)
		if(args[2])then
			status, veh = pcall(Vehicle.Create, tonumber(args[2]), ply:GetPosition(), ply:GetAngle())
			if status then
				ply:EnterVehicle(veh, 0)
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Invalid ID.")
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /veh <id>")
		end
	end)
	
	ZED:AddCommand("wep", function(ply, args)
		if(args[2] and args[3])then
			if pcall(ply.GiveWeapon, ply, tonumber(args[2]), Weapon(tonumber(args[3]), 999, 999)) then
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Invalid ID.", Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /wep <slot> <id>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("model", function(ply, args)
		if(args[2])then
			if pcall(ply.SetModelId, ply, tonumber(args[2])) then
				ZED:SetPData(ply, {modelId = tonumber(args[2])})
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Invalid ID.", Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /model <id>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("slay", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				target:SetHealth(0)
				ZED:SendChatMessage(target, Color(0,200,0,255),"You have been slayed by " .. ply:GetName())
				ZED:SendChatMessage(ply, Color(0,200,0,255),"You have succesfully slayed " .. target:GetName())
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2])
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /slay <name>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("jump", function(ply, args)
		if(args[2])then
			ply:SetPosition(ply:GetPosition() + Vector3(0,tonumber(args[2]),0))
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /jump <distance>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("delveh", function(ply, args)
		if(ply:InVehicle())then
			ply:GetVehicle():Remove()
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"You must be sitting in a vehicle.")
		end
	end)
	
	ZED:AddCommand("delallveh", function(ply, args)
		for vehicle in Server:GetVehicles() do
			vehicle:Remove()
		end
	end)
	
	ZED:AddCommand("info", function(ply, args)
		ZED:SendChatMessage(ply, Color(200,200,0),"Info:", Color(200,200,0))
		local perm = ""
		for k,v in pairs(ZED:GetPData(ply).permission) do
			perm = perm .. v .. ","
		end
		ZED:SendChatMessage(ply, Color(200,200,0),"Permissions:" .. perm)
		ZED:SendChatMessage(ply, Color(200,200,0),"Group:" .. ZED:GetPData(ply).group, Color(200,200,0))
		perm = ""
		for k,v in pairs(ZED:GetPlayerGroup(ply).permission) do
			perm = perm .. v .. ","
		end
		ZED:SendChatMessage(ply, Color(200,200,0),"Grouppermission:" .. perm, Color(200,200,0))
	end)
	
	ZED:AddCommand("getpos", function(ply, args)
		ZED:SendChatMessage(ply, Color(200,200,0),"Your Position: " .. tostring(ply:GetPosition()), Color(200,200,0))
	end)
	
	ZED:AddCommand("goto", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				ply:SetPosition(target:GetPosition())
				ZED:SendChatMessage(target,Color(0,200,0),ply:GetName() .. " teleported to you.", Color(0,200,0,255))
				ZED:SendChatMessage(ply, Color(0,200,0),"You teleported to " .. target:GetName(), Color(0,200,0,255))
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /goto <name>", Color(200,0,0,255))
		end
	end)	
	
	ZED:AddCommand("tppos", function(ply, args)
		if (not args[2]) or (not args[4]) or (not args[3]) then
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /tppos <x> <y> <z>")
			return
		end
		pos = Vector3(tonumber(args[2]), tonumber(args[3]), tonumber(args[4]))
		if(pos)then
			ply:SetPosition(pos)
			ZED:SendChatMessage(ply, Color(0,200,0,255),"You teleported to " .. args[2] .. ", " .. args[3] .. ", " .. args[4], Color(0,200,0,255))
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /tppos <x> <y> <z>", Color(200,0,0,255))
		end
	end)

	ZED:AddCommand("bring", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				target:SetPosition(ply:GetPosition())
				ZED:SendChatMessage(target, Color(0,200,0,255),ply:GetName() .. " teleported you to him.")
				ZED:SendChatMessage(ply, Color(0,200,0,255),"You teleported " .. target:GetName() .. " to you.", Color(0,200,0,255))
			elseif args[2] == "*" then
				for target in Server:GetPlayers() do
					target:SetPosition(ply:GetPosition())
				end
				ZED:Broadcast(Color(0,200,0,255), ply:GetName(), " teleported everyone to him.")
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(pl, Color(200,0,0,255),"Syntax: /bring <name>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("disact", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				if(args[3])then
					target = ZED:GetPlayer(args[2])
					Network:Send(target, "ZEDDisableAction", {action=tonumber(args[3])})
				else
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Please specify an action", Color(200,0,0,255))
				end
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /disact <name> <id>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("enact", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				if(args[3])then
					target = ZED:GetPlayer(args[2])
					Network:Send(target, "ZEDEnableAction", {action=tonumber(args[3])})
				else
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Please specify an action", Color(200,0,0,255))
				end
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /enact <name> <id>", Color(200,0,0,255))
		end
	end)

	ZED:AddCommand("freeze", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				for k,v in pairs(FreezeActions) do
					Network:Send(target, "ZEDDisableAction", {action=v})
				end
				ZED:SendChatMessage(ply, Color(200,0,0,255),ply:GetName() .. " froze you.", Color(200,0,0,255))
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /freeze <name>", Color(200,0,0,255))
		end
		
	end)
	ZED:AddCommand("unfreeze", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				for k,v in pairs(FreezeActions) do
					Network:Send(target, "ZEDEnableAction", {action=v})
				end
				ZED:SendChatMessage(ply, Color(0,200,0,255),ply:GetName() .. " unfrozed you.", Color(200,0,0,255))
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /unfreeze <name>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("kick", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				if(args[3])then
					target = ZED:GetPlayer(args[2])
					ZED:Broadcast(Color(0,200,0,255), "[ZED] " .. ply:GetName() .. " kicked ".. target:GetName() .. ". Reason: " .. args[3])
					target:Kick(args[3])
				else
					target = ZED:GetPlayer(args[2])
					ZED:Broadcast(Color(0,200,0,255), "[ZED] " .. ply:GetName() .. " kicked ".. target:GetName() .. ".")
					target:Kick("No reason specified.")
				end
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /kick <name> <reason>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("ban", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				if(args[3])then
					target = ZED:GetPlayer(args[2])
					ZED:Broadcast(Color(0,200,0,255),"[ZED] " .. ply:GetName() .. " banned ".. target:GetName() .. ". Reason: " .. args[3], Color(0,200,0,255))
					target:Ban(args[3])
				else
					target = ZED:GetPlayer(args[2])
					ZED:Broadcast(Color(0,200,0,255),"[ZED] " .. ply:GetName() .. " banned ".. target:GetName() .. "." , Color(0,200,0,255))
					target:Ban("No reason specified.")
				end
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /banned <name> <reason>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("who", function(ply, args)
		local c = 0
		for player in Server:GetPlayers() do
			c = c +1 
		end
		ZED:SendChatMessage(ply, Color(0,200,150),"========== Online: " .. tostring(c) .. " ==========")
		local c = 0
		local str = ""
		for player in Server:GetPlayers() do
			c = c + 1
			str = str .. ", " .. player:GetName()
			if (c == 5)then
				c = 0
				ZED:SendChatMessage(ply, Color(0,200,150),string.sub(str, 3), Color(0,200,150))
				str = ""
			end
		end
		if(c > 0)then
			ZED:SendChatMessage(ply, Color(0,200,150),string.sub(str, 3), Color(0,200,150))
		end
	end)
	
	ZED:AddCommand("help", function(ply, args)
		ZED:SendChatMessage(ply, Color(0,150,200),"========== Commands =======")
		local c = 0
		local str = ""
		for k,v in pairs(ZED.Commands) do
			if(ZED:PlayerHasPermission(ply, k))then
				c = c + 1
				str = str .. ", " .. k
				if (c == 5)then
					c = 0
					ZED:SendChatMessage(ply, Color(0,150,200),string.sub(str, 3), Color(0,150,200))
					str = ""
				end
			end
		end
		if(c > 0)then
			ZED:SendChatMessage(ply, Color(0,150,200),string.sub(str, 3), Color(0,150,200))
		end
	end)
	
	ZED:AddCommand("version", function(ply, args)
		ZED:SendChatMessage(ply, Color(0,150,200),"This server is runnig ZED V1.0", Color(0,150,200))
	end)
	
	Console:Subscribe("s", function(args)
		ZED:Broadcast(Color(200,0,0), Color(200,0,0), "Console: ", Color(255,255,255), args.text)
	end)

end
MOD.InitPlayer = function(tbl, ply)
	if(ZED:GetPData(ply).modelId)then
		ply:SetModelId(ZED:GetPData(ply).modelId)
	end
end

table.insert(ZED.Plugins, MOD)