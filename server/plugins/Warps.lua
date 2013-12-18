if( not ZED ) then ZED = {}	ZED.Plugins = {} end


MOD = {}
MOD.Initialize = function()
	ZED.Warps = {}
	ZED.CountWarps = function()
		local c = 0
		for k,v in pairs(ZED.Warps) do
			c = c + 1
		end
		return c
	end
	
	ZED:AddCommand("warp", function(ply, args)
		if(args[2])then
			for k,v in pairs(ZED.Warps) do
				if(string.find(string.lower(k), string.lower(args[2])))then
					ply:SetPosition(v)
					return 
				end
			end
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Warp not found.")
			if(ZED:CountWarps() > 0)then
				ZED:SendChatMessage(ply, Color(0,180,130),"Available Warps:")
				local c = 0
				local str = ""
				for k,v in pairs(ZED.Warps) do
					c = c + 1
					str = str .. ", " .. k
					if (c == 5)then
						c = 0
						ZED:SendChatMessage(ply, Color(0,200,150),string.sub(str, 3))
						str = ""
					end
				end
				if(c > 0)then
					ZED:SendChatMessage(ply, Color(0,200,150),string.sub(str, 3), Color(0,200,150))
				end
			end
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /warp <name>")
			if(ZED:CountWarps() > 0)then
				ZED:SendChatMessage(ply, Color(0,180,130),"Available Warps:")
				local c = 0
				local str = ""
				for k,v in pairs(ZED.Warps) do
					c = c + 1
					str = str .. ", " .. k
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
	
	ZED:AddCommand("setwarp", function(ply, args)
		if(args[2])then
			for k,v in pairs(ZED.Warps) do
				if(string.lower(k) == string.lower(args[2]))then
					ZED:SendChatMessage(ply, Color(200,0,0,255),"Warp does already exist.")
					return
				end
			end
			ZED.Warps[string.lower(args[2])] = ply:GetPosition()
			ZED:SendChatMessage(ply, Color(0,200,0,255),"Warp set.")
			local tbl = {}
			for k,v in pairs(ZED.Warps) do
				tbl[k] = {x=v.x, y=v.y, z=v.z}
			end
			local str = ZED.Modules["json"]:encode(tbl)
			local file = io.open("./data/warps.txt", "w")
			file:write(str)
			file:close()
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255,"Syntax: /warp <name>"))
			if(ZED:CountWarps() > 0)then
				ZED:SendChatMessage(ply, Color(0,180,130),"Available Warps:")
				local c = 0
				local str = ""
				for k,v in pairs(ZED.Warps) do
					c = c + 1
					str = str .. ", " .. k
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
	
	ZED:AddCommand("delwarp", function(ply, args)
		if(args[2])then
			for k,v in pairs(ZED.Warps) do
				if(string.find(string.lower(k), string.lower(args[2])))then
					ZED.Warps[k] = nil
					ZED:SendChatMessage(ply, Color(0,200,0,255),"Warp deleted.")
					local tbl = {}
					for k,v in pairs(ZED.Warps) do
						tbl[k] = {x=v.x, y=v.y, z=v.z}
					end
					local str = ZED.Modules["json"]:encode(tbl)
					local file = io.open("./data/warps.txt", "w")
					file:write(str)
					file:close()
					return
				end
			end
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Warp not found.")
			if(ZED:CountWarps() > 0)then
				ZED:SendChatMessage(ply, Color(0,180,130),"Available Warps:")
				local c = 0
				local str = ""
				for k,v in pairs(ZED.Warps) do
					c = c + 1
					str = str .. ", " .. k
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
		else
			ZED:SendChatMessage(ply, Color(200,0,0,255),"Syntax: /warp <name>")
			if(ZED:CountWarps() > 0)then
				ZED:SendChatMessage(ply, Color(0,180,130),"Available Warps:")
				local c = 0
				local str = ""
				for k,v in pairs(ZED.Warps) do
					c = c + 1
					str = str .. ", " .. k
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
		
end
MOD.ModsReady = function()
	if not ZED:file_exists("./data/warps.txt") then
		local tbl = {}
		for k,v in pairs(ZED.Warps) do
			tbl[k] = {x=v.x, y=v.y, z=v.z}
		end
		local str = ZED.Modules["json"]:encode(tbl)
		local file = io.open("./data/warps.txt", "w")
		file:write(str)
		file:close()
	else
		local file = io.open("./data/warps.txt", "r")
		local tbl = ZED.Modules["json"]:decode(file:read("*all"))
		for k,v in pairs(tbl) do
			ZED.Warps[k] = Vector3(v.x, v.y, v.z)
		end
	end
end

table.insert(ZED.Plugins, MOD)