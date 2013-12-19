if( not ZED ) then ZED = {}	ZED.Plugins = {} end


MOD = {}
MOD.Initialize = function()
	ZED.Groups = {}
	ZED.CreateGroup = function(tbl, name, permission, inherits, color)
		grp = {}
		grp.name = name
		grp.permission = permission
		grp.inherits = inherits
		grp.color = color
		table.insert(ZED.Groups, grp)
	end
	
	ZED.ParseColor = function(tbl, t)
		if(t)then
			return Color(t[1],t[2],t[3])
		end
	end
	ZED.GetGroup = function(tbl, g)
		for _,grp in pairs(ZED.Groups) do
			if(grp.name == g)then
				return grp
			end
		end
	end
	ZED.GroupHasPermission = function(tbl, grp, str)
		if(ZED:GetGroup(grp))then
			if ZED:GetGroup(grp).inherits then
				if(ZED:GroupHasPermission(ZED:GetGroup(grp).inherits, str))then 
					return true 
				end
			end
			for k,v in pairs(ZED:GetGroup(grp).permission) do
				if(v == "*")then return true end
				if(string.lower(str) == string.lower(v))then
					return true
				end
			end
			return false
		else
			return false
		end
	end
	ZED.GetPlayerGroup = function(tbl, ply)
		for _,grp in pairs(ZED.Groups) do
			if(ZED:strEquals(grp.name, ZED:GetPData(ply).group))then
				return grp
			end
		end
	end
	ZED.GroupExists = function(tbl, str)
		for _,grp in pairs(ZED.Groups) do
			if(ZED:strEquals(grp.name, str))then
				return true
			end
		end
		return false
	end
	ZED.FindGroup = function(tbl, str)
		for _,grp in pairs(ZED.Groups) do
			if(ZED:strFind(grp.name, str))then
				return grp
			end
		end
		return false
	end

	ZED:AddCommand("setgroup", function(ply, args)
		if(args[2] and args[3])then
			if ZED:GetPlayer(args[2]) then
				target = ZED:GetPlayer(args[2])
				if(ZED:FindGroup(args[3]))then
					ZED:SetPData(target, {group = ZED:FindGroup(args[3]).name})
					ZED:SendChatMessage(ply, Color(0,200,0,255),"Set group from " .. target:GetName() .. " to " .. ZED:FindGroup(args[3]).name, Color(0,200,0,255))
					ZED:SendChatMessage(target, Color(0,200,0,255),"Your group has been set to " .. ZED:FindGroup(args[3]).name)
				else
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find group " .. args[3])
				end
			else
				ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[2], Color(200,0,0,255))
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /setgroup <player> <group>", Color(200,0,0,255))
		end
	end)
	
	Console:Subscribe("setgroup", function(args)
		if(args[1] and args[2])then
			if ZED:GetPlayer(args[1]) then
				target = ZED:GetPlayer(args[1])
				if(ZED:FindGroup(args[2]))then
					ZED:SetPData(target, {group = ZED:FindGroup(args[2]).name})
					print("Set group from " .. target:GetName() .. " to " .. ZED:FindGroup(args[2]).name)
					ZED:SendChatMessage(target, Color(0,200,0), "Your group has been set to " .. ZED:FindGroup(args[2]).name, Color(0,200,0,255))
				else
					print("Can't find group " .. args[2])
				end
			else
				print("Can't find " .. args[1])
			end
		else
			print("Syntax: /setgroup <player> <group>")
		end
	end)

	ZED:AddCommand("group", function(ply, args)
		if(args[2] and args[3])then
			if(ZED:strFind(args[2], "create"))then
				if(ZED:GroupExists(args[3]))then
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Group already exists: " .. args[3])
				else
					if(ZED:FindGroup(args[4]))then
						ZED:CreateGroup(args[3], {}, ZED:FindGroup(args[4]).name)
					else
						ZED:CreateGroup(args[3], {})
					end
					local str = ZED.Modules["json"]:encode(ZED:FindGroup(args[3]))
					local file = io.open("./data/groups/"..args[3]..".txt", "w")
					file:write(str)
					file:close()
					ZED:SendChatMessage(ply, Color(0,200,0,255),"Group created: " .. args[3], Color(0,200,0,255))
				end
			elseif(ZED:strFind(args[2], "delete"))then
				if(ZED:FindGroup(args[3]))then
					local name = ZED:FindGroup(args[3]).name
					for k,v in pairs(ZED.Groups) do
						if(ZED:strEquals(v.name, name))then
							local file = io.open("./data/groups/"..name..".txt", "w")
							file:write("Deleted by " .. ply:GetName())
							file:close()
							ZED.Groups[k] = nil
							ZED:SendChatMessage(ply, Color(0,200,0,255),"Group deleted: " .. name)
							break
						end
					end
				else
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[3], Color(200,0,0,255))
				end
			elseif(ZED:strFind(args[2], "addperm"))then
				if(ZED:FindGroup(args[3]))then
					if(not args[4])then
						ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /group addperm <group> <permission>", Color(200,0,0,255))
						return
					end
					for k,v in pairs(ZED.Groups) do
						if(v.name == ZED:FindGroup(args[3]).name)then
							for i,j in pairs(ZED.Groups[k].permission) do
								if(ZED:strEquals(j, args[4]))then
									ZED:SendChatMessage(ply, Color(200,0,0,255),"This group has already this permission: " .. args[4])
									return
								end
							end
							table.insert(ZED.Groups[k].permission, args[4])
						end
					end
					local str = ZED.Modules["json"]:encode(ZED:FindGroup(args[3]))
					local file = io.open("./data/groups/"..ZED:FindGroup(args[3]).name..".txt", "w")
					file:write(str)
					file:close()
					ZED:SendChatMessage(ply, Color(0,200,0,255),"Permission added: " .. args[4])
				else
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[3])
				end
			elseif(ZED:strFind(args[2], "delperm"))then
				if(ZED:FindGroup(args[3]))then
					if(not args[4])then
						ZED:SendChatMessage(ply, Color(200,0,0,255), "Syntax: /group delperm <group> <permission>")
						return
					end
					local found = -1
					local group = -1
					local perm = ""
					for k,v in pairs(ZED.Groups) do
						if(v.name == ZED:FindGroup(args[3]).name)then
							group = k
							for i,j in pairs(ZED.Groups[k].permission) do
								if(ZED:strFind(j, args[4]))then
									found = i
									perm = j
								end
							end
							break
						end
					end
					if(found > -1)then
						ZED.Groups[group].permission[found]=nil
						local str = ZED.Modules["json"]:encode(ZED:FindGroup(args[3]))
						local file = io.open("./data/groups/"..ZED:FindGroup(args[3]).name..".txt", "w")
						file:write(str)
						file:close()
						ZED:SendChatMessage(ply, Color(0,200,0,255),"Permission removed: " .. perm)
					else
						ZED:SendChatMessage(ply, Color(200,0,0,255),"Permission not found: " .. args[4])
					end
				else
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[3])
				end
			elseif(ZED:strFind(args[2], "setcolor"))then
				if(ZED:FindGroup(args[3]))then
					if (not args[4]) or (not args[5]) or (not args[6]) then
						ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: group setcolor <group> <r> <g> <b>")
						return
					end
					for k,v in pairs(ZED.Groups) do
						if(v.name == ZED:FindGroup(args[3]).name)then
							ZED.Groups[k].color = {tonumber(args[4]), tonumber(args[5]), tonumber(args[6])}
						end
					end
					local str = ZED.Modules["json"]:encode(ZED:FindGroup(args[3]))
					local file = io.open("./data/groups/"..ZED:FindGroup(args[3]).name..".txt", "w")
					file:write(str)
					file:close()
					ZED:SendChatMessage(ply, Color(tonumber(args[4]), tonumber(args[5]), tonumber(args[6])),"Color set.")
				else
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Can't find " .. args[3])
				end
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /group create <name> <inherits>")
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /group delete <name>")
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /group addperm <group> <permission>")
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /group delperm <group> <permission>")
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /group setcolor <group> <r> <g> <b>")
			if(ZED:CountWarps() > 0)then
				ZED:SendChatMessage(ply, Color(0,180,130),"Available Groups:")
				local c = 0
				local str = ""
				for k,v in pairs(ZED.Groups) do
					c = c + 1
					str = str .. ", " .. v.name
					if (c == 5)then
						c = 0
						ZED:SendChatMessage(ply, Color(0,200,150),string.sub(str, 3))
						str = ""
					end
				end
				if(c > 0)then
					ZED:SendChatMessage(ply, Color(0,200,150),string.sub(str, 3))
				end
			end
		end
	end)
	
	Console:Subscribe("group", function(args)
		if(args[1] and args[2])then
			if(ZED:strFind(args[1], "create"))then
				if(ZED:GroupExists(args[2]))then
					print("Group already exists: " .. args[2])
				else
					if(ZED:FindGroup(args[3]))then
						ZED:CreateGroup(args[2], {}, ZED:FindGroup(args[3]).name)
					else
						ZED:CreateGroup(args[2], {})
					end
					local str = ZED.Modules["json"]:encode(ZED:FindGroup(args[2]))
					local file = io.open("./data/groups/"..args[2]..".txt", "w")
					file:write(str)
					file:close()
					print("Group created: " .. args[2])
				end
			elseif(ZED:strFind(args[1], "delete"))then
				if(ZED:FindGroup(args[2]))then
					local name = ZED:FindGroup(args[2]).name
					for k,v in pairs(ZED.Groups) do
						if(ZED:strEquals(v.name, name))then
							local file = io.open("./data/groups/"..name..".txt", "w")
							file:write("Deleted by " .. ply:GetName())
							file:close()
							ZED.Groups[k] = nil
							print("Group deleted: " .. name)
							break
						end
					end
				else
					print("Can't find " .. args[2])
				end
			elseif(ZED:strFind(args[1], "addperm"))then
				if(ZED:FindGroup(args[2]))then
					if(not args[3])then
						print("Syntax: group addperm <group> <permission>")
						return
					end
					for k,v in pairs(ZED.Groups) do
						if(v.name == ZED:FindGroup(args[2]).name)then
							for i,j in pairs(ZED.Groups[k].permission) do
								if(ZED:strEquals(j, args[3]))then
									print("This group has already this permission: " .. args[3])
									return
								end
							end
							table.insert(ZED.Groups[k].permission, args[3])
						end
					end
					local str = ZED.Modules["json"]:encode(ZED:FindGroup(args[2]))
					local file = io.open("./data/groups/"..ZED:FindGroup(args[2]).name..".txt", "w")
					file:write(str)
					file:close()
					print("Permission added: " .. args[3])
				else
					print("Can't find " .. args[2])
				end
			elseif(ZED:strFind(args[1], "delperm"))then
				if(ZED:FindGroup(args[2]))then
					if(not args[3])then
						print("Syntax: group delperm <group> <permission>")
						return
					end
					local found = -1
					local group = -1
					local perm = ""
					for k,v in pairs(ZED.Groups) do
						if(v.name == ZED:FindGroup(args[2]).name)then
							group = k
							for i,j in pairs(ZED.Groups[k].permission) do
								if(ZED:strFind(j, args[3]))then
									found = i
									perm = j
								end
							end
							break
						end
					end
					if(found > -1)then
						ZED.Groups[group].permission[found]=nil
						local str = ZED.Modules["json"]:encode(ZED:FindGroup(args[2]))
						local file = io.open("./data/groups/"..ZED:FindGroup(args[2]).name..".txt", "w")
						file:write(str)
						file:close()
						print("Permission removed: " .. perm)
					else
						print("Permission not found: " .. args[3])
					end
				else
					print("Can't find " .. args[2])
				end
			elseif(ZED:strFind(args[1], "setcolor"))then
				if(ZED:FindGroup(args[2]))then
					if (not args[3]) or (not args[4]) or (not args[5]) then
						print("Syntax: group setcolor <group> <r> <g> <b>")
						return
					end
					for k,v in pairs(ZED.Groups) do
						if(v.name == ZED:FindGroup(args[2]).name)then
							ZED.Groups[k].color = {args[3], args[4], args[5]}
						end
					end
					local str = ZED.Modules["json"]:encode(ZED:FindGroup(args[2]))
					local file = io.open("./data/groups/"..ZED:FindGroup(args[2]).name..".txt", "w")
					file:write(str)
					file:close()
					print("Color set.")
				else
					print("Can't find " .. args[2])
				end
			end
		else
			print("Syntax: group create <name> <inherits>")
			print("Syntax: group delete <name>")
			print("Syntax: group addperm <group> <permission>")
			print("Syntax: group delperm <group> <permission>")
			print("Syntax: group setcolor <group> <r> <g> <b>")
			if(ZED:CountWarps() > 0)then
				print("Available Groups:")
				local c = 0
				local str = ""
				for k,v in pairs(ZED.Groups) do
					c = c + 1
					str = str .. ", " .. v.name
					if (c == 5)then
						c = 0
						print(string.sub(str, 3))
						str = ""
					end
				end
				if(c > 0)then
					print(string.sub(str, 3))
				end
			end
		end
	end)

end
MOD.InitPlayer = function(m, ply)
	if(not ZED:GetPData(ply).group)then
		ZED:SetPData(ply, {group = "User"})
	end
end
MOD.Chat = function(m, args)
		ZED:Broadcast(Color(160,160,160), "[", ZED:ParseColor(ZED:GetPlayerGroup(args.player).color), ZED:GetPlayerGroup(args.player).name, Color(160,160,160), "] ", Color(160,160,160), args.player:GetName(), Color(255,255,255), ": ", args.text)
	return true
end
MOD.PlayerHasPermission = function(m, player, permission)
	return ZED:GroupHasPermission(ZED:GetPlayerGroup(player).name, permission)
end
MOD.ModsReady = function()
	for k,v in pairs(io.files("./data/groups")) do
		local file = io.open("./data/groups/" .. v, "r")
		local ret = ZED.Modules["json"]:decode(file:read("*all"))
		if(ret)then
			ZED:CreateGroup(string.sub(v, 1, -5), ret.permission, ret.inherits, ret.color)
		end
	end
end

table.insert(ZED.Plugins, MOD)