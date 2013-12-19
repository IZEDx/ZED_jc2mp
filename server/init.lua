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
	if(file)then
		local ret = ZED.Modules["json"]:decode(file:read("*all"))
		return ret
	end
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
	if(not ZED:GetPData(ply).deaths)then
		ZED:SetPData(ply, {deaths=0})
	end
	if(not ZED:GetPData(ply).kills)then
		ZED:SetPData(ply, {kills=0})
	end
	if(not ZED:PDataExists(ply))then
		local tbl = {}
		tbl.permission = {}
		tbl.kills = 0
		tbl.deaths = 0
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

ZED.SendChatMessage = function(tbl, ply, ...)
	Network:Send( ply, "ZEDChat", {...} )
end
ZED.Broadcast = function(tbl, ...)
	Network:Broadcast( "ZEDChat", {...} )
end

ZED.UpdatePlayerList = function(tbl)
	local t = {}
	t.players = {}
	t.name = Config:GetValue("Server", "Name")
	--print(t.name)
	--for i = 1, 100, 1 do
	for v in Server:GetPlayers() do
		table.insert(t.players, {name=v:GetName(),color=ZED:ParseColor(ZED:GetPlayerGroup(v).color),group=ZED:GetPlayerGroup(v).name,kills=ZED:GetPData(v).kills,deaths=ZED:GetPData(v).deaths,ping=v:GetPing()})
	end
	--end
	Network:Broadcast( "ZEDUpdateBoard", t )
end
ZED.GetPlayer = function(tbl, str)
	for player in Server:GetPlayers() do
		if(string.find(string.lower(player:GetName()), string.lower(str)))then
			return player
		end
	end
end


 
local timer = 0
Events:Subscribe("PlayerDeath", function(args)
	if args.killer then
		ZED:SetPData(args.killer, {kills=ZED:GetPData(args.killer).kills+1})
		ZED:SetPData(args.player, {deaths=ZED:GetPData(args.player).deaths+1})
	else
		ZED:SetPData(args.player, {deaths=ZED:GetPData(args.player).deaths+1})
	end
end)
Events:Subscribe("PlayerChat", function(args)
	if (args.text:sub(1, 1) ~= '/') then
		t = {}
		for _,MOD in pairs(ZED.Plugins) do
			if(MOD.ChatIII)then
				if MOD:ChatIII(args) then
					return false
				end
			end
		end
		for _,MOD in pairs(ZED.Plugins) do
			if(MOD.ChatII)then
				if MOD:ChatII(args) then
					return false
				end
			end
		end
		for _,MOD in pairs(ZED.Plugins) do
			if(MOD.ChatI)then
				if MOD:ChatI(args) then
					return false
				end
			end
		end
		for _,MOD in pairs(ZED.Plugins) do
			if(MOD.Chat)then
				if MOD:Chat(args) then
					return false
				end
			end
		end
		ZED:Broadcast(Color(255,255,255), args.player:GetName(), Color(150,150,150), ": ", args.text)
		return false
	end
	local str = string.sub(args.text, 2)
	local cmd = str:split(' ')
	if( ZED.Commands[string.lower(cmd[1])] )then
		if( not ZED:PlayerHasPermission(args.player, string.lower(cmd[1])))then
			ZED:SendChatMessage(args.player, Color(200,0,0,255), "You have no access to this command: " .. string.lower(cmd[1]), Color(200,0,0,255))
			print(args.player:GetName() .. " tried using command: " .. string.lower(args.text))
			return false
		end
		ZED.Commands[string.lower(cmd[1])](args.player, cmd)
		print(args.player:GetName() .. " used command: " .. string.lower(args.text))
	else
		ZED:SendChatMessage(args.player, Color(200,0,0,255), "Command not found: " .. string.lower(cmd[1]), Color(200,0,0,255))
		print(args.player:GetName() .. " tried using command: " .. string.lower(args.text))
	end
	return false
end)
Events:Subscribe("PlayerJoin", function(args)

	ZED:Broadcast(Color(0,200,200,255), args.player:GetName().." joined the server.")
	ZED:InitPlayer(args.player)
end)
Events:Subscribe("PlayerQuit", function(args)
	ZED:Broadcast(Color(0,200,200,255), args.player:GetName().." left the server.")
	ZED:UpdatePlayerList()
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
	Events:Subscribe("PostTick", function()
		timer = timer + 1
		if(timer > 200)then
			ZED:UpdatePlayerList()
			timer = 0
		end
	end)
	ZED:UpdatePlayerList()
end)
