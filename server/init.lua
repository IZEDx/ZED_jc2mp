if not ZED then ZED = {} end
ZED.Commands = {}
if not ZED.Plugins then ZED.Plugins = {} end
ZED.Modules = {}
ZED.Player = {}

ZED.file_exists =  function (tbl, name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
ZED.strEquals = function(tbl, v1, v2)
	if(string.lower(tostring(v1)) == string.lower(tostring(v2)))then
		return true
	else
		return false
	end
end
ZED.strFind = function(tbl, v1, v2)
	if(string.find(string.lower(tostring(v1)), string.lower(tostring(v2))))then
		return true
	else
		return false
	end
end

ZED.PlayerHasPermission = function(tbl, ply, str)
	for k,v in pairs(ZED:GetPData(ply).permission) do
		if(v == "*")then return true end
		if(string.lower(str) == string.lower(v))then
			return true
		end
	end
	for _,MOD in pairs(ZED.Plugins) do
		if(MOD.PlayerHasPermission)then
			if(MOD:PlayerHasPermission(ply, str))then
				return true
			end
		end
	end
	return false
end

ZED.GetPData = function(t, ply)
	local file = io.open("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt", "r")
	local ret = ZED.Modules["json"]:decode(file:read("*all"))
	return ret
end
ZED.SetPData = function(t, ply, tbl)
	local str = ZED.Modules["json"]:encode(tbl)
	if(ZED:PDataExists(ply))then
		local p = ZED:GetPData(ply)
		for k,v in pairs(tbl) do
			p[k] = v
		end
		str = ZED.Modules["json"]:encode(p)
	end
	local file = io.open("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt", "w")
	file:write(str)
	file:close()
end
ZED.PDataExists = function(t, ply)
	if(ZED:file_exists("./data/player/" .. string.gsub(tostring(ply:GetSteamId()), ":", "-") .. ".txt"))then
		return true
	else
		return false
	end
end
ZED.InitPlayer = function(tbl, ply)
	if(not ZED:PDataExists(ply))then
		local tbl = {}
		tbl.permission = {}
		ZED:SetPData(ply, tbl)
	end
	for _,MOD in pairs(ZED.Plugins) do
		if(MOD.InitPlayer)then
			MOD:InitPlayer(ply)
		end
	end
end

ZED.AddCommand = function(tbl, str, cb)
	if(tostring(str))then
		ZED.Commands[string.lower(str)] = cb
		return true
	else
		return false
	end
end
ZED.RemoveCommand = function(tbl, str)
	ZED.Commands[string.lower(str)] = nil
end

ZED.Broadcast = function(tbl, str, clr)
	for ply in Server:GetPlayers() do
		ply:SendChatMessage(tostring(str), clr)
	end
end
ZED.GetPlayer = function(tbl, str)
	for player in Server:GetPlayers() do
		if(string.find(string.lower(player:GetName()), string.lower(str)))then
			return player
		end
	end
end

Events:Subscribe("PlayerChat", function(args)
	if (args.text:sub(1, 1) ~= '/') then
		return true
	end
	local str = string.sub(args.text, 2)
	local cmd = str:split(' ')
	if( ZED.Commands[string.lower(cmd[1])] )then
		if( not ZED:PlayerHasPermission(args.player, string.lower(cmd[1])))then
			args.player:SendChatMessage("You have no access to this command: " .. string.lower(cmd[1]), Color(200,0,0,255))
			print(args.player:GetName() .. " tried using command: " .. string.lower(args.text))
			return false
		end
		ZED.Commands[string.lower(cmd[1])](args.player, cmd)
		print(args.player:GetName() .. " used command: " .. string.lower(args.text))
	else
		args.player:SendChatMessage("Command not found: " .. string.lower(cmd[1]), Color(200,0,0,255))
		print(args.player:GetName() .. " tried using command: " .. string.lower(args.text))
	end
	return false
end)
Events:Subscribe("PlayerJoin", function(args)
	ZED:Broadcast(args.player:GetName().." joined the server.", Color(0,200,200,255))
	ZED:InitPlayer(args.player)
end)
Events:Subscribe("PlayerQuit", function(args)
	ZED:Broadcast(args.player:GetName().." left the server.", Color(0,200,200,255))
end)
Events:Subscribe("ModulesLoad", function(args)
	for _,MOD in pairs(ZED.Plugins) do
		if(MOD.name)then
			v = MOD:Initialize()
			ZED.Modules[MOD.name] = v
		else
			MOD:Initialize()
		end
	end
	for _,MOD in pairs(ZED.Plugins) do
		if(MOD.ModsReady)then
			MOD:ModsReady()
		end
	end
	for ply in Server:GetPlayers() do
		ZED:InitPlayer(ply)
	end
end)
