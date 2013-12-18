if( not ZED ) then ZED = {}	ZED.Plugins = {} end


MOD = {}
MOD.Initialize = function()
	ZED:AddCommand("veh", function(ply, args)
		if(args[2])then
			status, veh = pcall(Vehicle.Create, tonumber(args[2]), ply:GetPosition(), ply:GetAngle())
			if status then
				ply:EnterVehicle(veh, 0)
			else
				ply:SendChatMessage("Invalid ID.", Color(200,0,0,255))
			end
		else
			ply:SendChatMessage("Syntax: /veh <id>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("wep", function(ply, args)
		if(args[2] and args[3])then
			if pcall(ply.GiveWeapon, ply, tonumber(args[2]), Weapon(tonumber(args[3]), 999, 999)) then
			else
				ply:SendChatMessage("Invalid ID.", Color(200,0,0,255))
			end
		else
			ply:SendChatMessage("Syntax: /wep <slot> <id>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("model", function(ply, args)
		if(args[2])then
			if pcall(ply.SetModelId, ply, tonumber(args[2])) then
			else
				ply:SendChatMessage("Invalid ID.", Color(200,0,0,255))
			end
		else
			ply:SendChatMessage("Syntax: /model <id>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("slay", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				target:SetHealth(0)
				target:SendChatMessage("You have been slayed by " .. ply:GetName(), Color(200,0,0,255))
				ply:SendChatMessage("You have succesfully slayed " .. target:GetName(), Color(0,200,0,255))
			else
				ply:SendChatMessage("Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ply:SendChatMessage("Syntax: /slay <name>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("jump", function(ply, args)
		if(args[2])then
			ply:SetPosition(ply:GetPosition() + Vector3(0,tonumber(args[2]),0))
		else
			ply:SendChatMessage("Syntax: /jump <distance>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("removeveh", function(ply, args)
		for vehicle in Server:GetVehicles() do
			vehicle:Remove()
		end
	end)
	
	ZED:AddCommand("info", function(ply, args)
		ply:SendChatMessage("Info:", Color(200,200,0))
		local perm = ""
		for k,v in pairs(ZED:GetPData(ply).permission) do
			perm = perm .. v .. ","
		end
		ply:SendChatMessage("Permissions:" .. perm, Color(200,200,0))
		ply:SendChatMessage("Group:" .. ZED:GetPData(ply).group, Color(200,200,0))
		perm = ""
		for k,v in pairs(ZED:GetPlayerGroup(ply).permission) do
			perm = perm .. v .. ","
		end
		ply:SendChatMessage("Grouppermission:" .. perm, Color(200,200,0))
	end)
	
	ZED:AddCommand("getpos", function(ply, args)
		ply:SendChatMessage("Your Position: " .. tostring(ply:GetPosition()), Color(200,200,0))
	end)
	
	ZED:AddCommand("goto", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				ply:SetPosition(target:GetPosition())
				target:SendChatMessage(ply:GetName() .. " teleported to you.", Color(0,200,0,255))
				ply:SendChatMessage("You teleported to " .. target:GetName(), Color(0,200,0,255))
			else
				ply:SendChatMessage("Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ply:SendChatMessage("Syntax: /goto <name>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("bring", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				target:SetPosition(ply:GetPosition())
				target:SendChatMessage(ply:GetName() .. " teleported you to him.", Color(0,200,0,255))
				ply:SendChatMessage("You teleported " .. target:GetName() .. " to you.", Color(0,200,0,255))
			else
				ply:SendChatMessage("Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ply:SendChatMessage("Syntax: /bring <name>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("kick", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				if(args[3])then
					target = ZED:GetPlayer(args[2])
					ZED:Broadcast("[ZED] " .. ply:GetName() .. " kicked ".. target:GetName() .. ". Reason: " .. args[3], Color(0,200,0,255))
					target:Kick(args[3])
				else
					target = ZED:GetPlayer(args[2])
					ZED:Broadcast("[ZED] " .. ply:GetName() .. " kicked ".. target:GetName() .. ".", Color(0,200,0,255))
					target:Kick("No reason specified.")
				end
			else
				ply:SendChatMessage("Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ply:SendChatMessage("Syntax: /kick <name> <reason>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("ban", function(ply, args)
		if(args[2])then
			if ZED:GetPlayer(args[2]) then
				if(args[3])then
					target = ZED:GetPlayer(args[2])
					ZED:Broadcast("[ZED] " .. ply:GetName() .. " banned ".. target:GetName() .. ". Reason: " .. args[3], Color(0,200,0,255))
					target:Ban(args[3])
				else
					target = ZED:GetPlayer(args[2])
					ZED:Broadcast("[ZED] " .. ply:GetName() .. " banned ".. target:GetName() .. "." , Color(0,200,0,255))
					target:Ban("No reason specified.")
				end
			else
				ply:SendChatMessage("Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ply:SendChatMessage("Syntax: /banned <name> <reason>", Color(200,0,0,255))
		end
	end)
	
	ZED:AddCommand("who", function(ply, args)
		ply:SendChatMessage("========== Players ==========", Color(0,200,150))
		local c = 0
		local str = ""
		for player in Server:GetPlayers() do
			c = c + 1
			str = str .. ", " .. player:GetName()
			if (c == 5)then
				c = 0
				ply:SendChatMessage(string.sub(str, 3), Color(0,200,150))
				str = ""
			end
		end
		if(c > 0)then
			ply:SendChatMessage(string.sub(str, 3), Color(0,200,150))
		end
	end)
	
	ZED:AddCommand("help", function(ply, args)
		ply:SendChatMessage("========== Commands =======", Color(0,150,200))
		local c = 0
		local str = ""
		for k,v in pairs(ZED.Commands) do
			if(ZED:PlayerHasPermission(ply, k))then
				c = c + 1
				str = str .. ", " .. k
				if (c == 5)then
					c = 0
					ply:SendChatMessage(string.sub(str, 3), Color(0,150,200))
					str = ""
				end
			end
		end
		if(c > 0)then
			ply:SendChatMessage(string.sub(str, 3), Color(0,150,200))
		end
	end)
	
	ZED:AddCommand("version", function(ply, args)
		ply:SendChatMessage("This server is runnig ZED V0.8", Color(0,150,200))
	end)
end

table.insert(ZED.Plugins, MOD)