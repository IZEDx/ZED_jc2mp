
ZED = {}
function ZED.Init(t)
	ZED.Commands = {}
	ZED.Players = {} 
	ZED.PData = {}
	ZED.CommandWhitelist = {derby=true, tp=true, boost=true,race=true,skydive=true}
	ZED.ScoreBoardTimer = 0
	ZED.ScoreBoardUpdateInterval = 200
	
	Events:Register( "ZEDPlayerHasPermission" )
	Events:Register( "ZEDPlayerInit" )
	Events:Register( "ZEDAddCommand" )
	Events:Register( "ZEDRemoveCommand" )
	Events:Register( "ZEDSendChatMessage" )
	Events:Register( "ZEDScoreboardUpdate" )
	Events:Register( "ZEDUpdateScoreboard" )
	Events:Register( "ZEDPlayerDeath" )
	Events:Register( "ZEDPlayerJoin" )
	Events:Register( "ZEDPlayerQuit" )
	Events:Register( "ZEDBroadcast" )
	Events:Register( "ZEDReady" )
	Events:Register( "GetPData" )
	
	Events:Subscribe( "GetPData", function(pdata)
		ZED.PData = pdata
	end)
	Events:Subscribe( "ZEDAddCommand", function(args)
		if(tostring(args.command))then
			ZED.Commands[string.lower(args.command)] = args.do
			return true
		else
			return false
		end
	end)
	Events:Subscribe( "ZEDRemoveCommand", function(args)
		ZED.Commands[string.lower(args.command)] = nil
	end)
	Events:Subscribe( "ZEDSendChatMessage", function(args)
		Network:Send( ply, "ZEDChat", args )
	end)
	Events:Subscribe( "ZEDBroadcast", function(args)
		Network:Broadcast( "ZEDChat", args )
	end)
	Events:Subscribe( "ZEDUpdateScoreboard", function(t)
		Network:Broadcast( "ZEDUpdateBoard", t )
	end)
	Events:Subscribe("PlayerDeath", function(args)
		if args.killer then		
			if(ZED.PData:Get(args.killer).kills)then
				ZED.PData:Set(args.killer, {kills=ZED.PData:Get(args.killer).kills+1})
			else
				ZED.PData:Set(args.killer, {kills=1})
			end
		end
		if(ZED.PData:Get(args.player).deaths)then
			ZED.PData:Set(args.player, {deaths=ZED.PData:Get(args.player).deaths+1})
		else
			ZED.PData:Set(args.player, {deaths=1})
		end
		Events:FireRegisteredEvent("ZEDPlayerDeath", {zed=ZED, args=args})
		ZED:UpdatePlayerList()
	end)
	Events:Subscribe("PlayerChat", function(args)
		if (args.text:sub(1, 1) ~= '/') then
			Console:Print(args.player:GetName() .. ": " .. args.text)
			if not Events:FireRegisteredEvent("ZEDPlayerChat", {zed=ZED, args=args}) then
				return false
			end
			ZED:Broadcast(Color(255,255,255), args.player:GetName(), Color(150,150,150), ": ", args.text)
			return false
		end
		local str = string.sub(args.text, 2)
		local cmd = str:split(' ')
		if( ZED.Commands[string.lower(cmd[1])] )then
			if( not ZED:PlayerHasPermission(args.player, string.lower(cmd[1])))then
				ZED:SendChatMessage(args.player, Color(200,0,0,255), "You have no access to this command: " .. string.lower(cmd[1]))
				print(args.player:GetName() .. " tried using command: " .. string.lower(args.text))
				return false
			end
			ZED.Commands[string.lower(cmd[1])](args.player, cmd)
			print(args.player:GetName() .. " used command: " .. string.lower(args.text))
		elseif( ZED.CommandWhitelist[string.lower(cmd[1])])then
			print(args.player:GetName() .. " used whitelisted external command: " .. string.lower(args.text))
		else
			ZED:SendChatMessage(args.player, Color(200,0,0,255), "Command not found: " .. string.lower(cmd[1]))
			print(args.player:GetName() .. " tried using command: " .. string.lower(args.text))
		end
		return false
	end)
	Events:Subscribe("PlayerJoin", function(args)
		if Events:FireRegisteredEvent("ZEDPlayerJoin", {zed=ZED, args=args}) then
			ZED:Broadcast(Color(0,200,200,255), args.player:GetName().." joined the server.")
		end
		ZED:InitPlayer(args.player)
		ZED:UpdatePlayerList()
	end)
	Events:Subscribe("PlayerQuit", function(args)
		if Events:FireRegisteredEvent("ZEDPlayerQuit", {zed=ZED, args=args}) then
			ZED:Broadcast(Color(0,200,200,255), args.player:GetName().." left the server.")
		end
		ZED:UpdatePlayerList()
	end)
	Events:Subscribe("PreTick", function()
		ZED.ScoreBoardTimer = ZED.ScoreBoardTimer + 1
		if(ZED.ScoreBoardTimer > ZED.ScoreBoardUpdateInterval)then
			ZED:UpdatePlayerList()
			ZED.ScoreBoardTimer = 0
		end
	end)
	
	for ply in Server:GetPlayers() do
		ZED:InitPlayer(ply)
	end
	
	Events:FireRegisteredEvent("ZEDReady")
	
	ZED:UpdatePlayerList()
end

ZED.file_exists =  function (t, name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
ZED.strEquals = function(t, v1, v2)
	if(string.lower(tostring(v1)) == string.lower(tostring(v2)))then
		return true
	else
		return false
	end
end
ZED.strFind = function(t, v1, v2)
	if(string.find(string.lower(tostring(v1)), string.lower(tostring(v2))))then
		return true
	else
		return false
	end
end
	
ZED.PlayerHasPermission = function(t, ply, str)
	for k,v in pairs(ZED.PData:Get(ply).permission) do
		if(v == "*")then return true end
		if(string.lower(str) == string.lower(v))then
			return true
		end
	end
	if Events:FireRegisteredEvent("PlayerHasPermission", {zed=self, player=ply, permission=str}) then
		return true
	end
	return false
end
ZED.InitPlayer = function(tbl, ply)
	ZED.PData:Load(ply, {permission={},kills=0,deaths=0})
	Events:FireRegisteredEvent("PlayerInit", {zed=self, player=ply})
end
ZED.UpdatePlayerList = function(tbl)
	if Events:FireRegisteredEvent("ZEDScoreboardUpdate", {zed=tbl}) then
		local t = {}
		t.players = {}
		t.name = Config:GetValue("Server", "Name")

		for v in Server:GetPlayers() do
				table.insert(t.players, {Name=v:GetName(),BGColor=v:GetColor(),FGColor=Color(0,0,0),Kills=ZED.PData:Get(v).kills,Deaths=ZED.PData:Get(v).deaths,Ping=v:GetPing()})
		end
		Network:Broadcast( "ZEDUpdateBoard", t )
	end
end
ZED.GetPlayer = function(tbl, str)
	for player in Server:GetPlayers() do
		if(string.find(string.lower(player:GetName()), string.lower(str)))then
			return player
		end
	end
end

ZED.SendChatMessage = function(tbl, ply, ...)
        Network:Send( ply, "ZEDChat", {...} )
end
ZED.Broadcast = function(tbl, ...)
        Network:Broadcast( "ZEDChat", {...} )
end

 
Events:Subscribe("ModulesLoad", function(args)
	ZED:Init()
end)
