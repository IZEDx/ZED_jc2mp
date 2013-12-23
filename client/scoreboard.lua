class 'ZEDBoard'

function ZEDBoard:__init()
	self.Players = {}
	self.Header = {}
	self.ServerName = ""
	self.ScrollPosition = 0
	self.MaxPlayers = 0
	self.ViewPlayer = -1
	self.Buttons = {}
	self.PossibleItems = (Render.Height - 200)/(Render:GetTextHeight("T", 25)+2)
	self.blacklist = {Action.LookLeft, Action.LookRight, Action.LookUp, Action.LookDown, Action.PrevWeapon, Action.NextWeapon, Action.FireRight, Action.FireLeft, Action.VehicleFireLeft, Action.VehicleFireRight}
	
    Network:Subscribe( "ZEDUpdateBoard", self, self.UpdateBoard )
    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
    Events:Subscribe( "KeyDown", self, self.KeyDown )
    Events:Subscribe( "MouseDown", self, self.MouseDown )
    Events:Subscribe( "KeyUp", self, self.KeyUp )
    Events:Subscribe( "MouseScroll", self, self.MouseScroll )
    Events:Subscribe( "PreTick", self, self.PreTick )
end

function ZEDBoard:UpdateBoard( args )
	self.Players = args.players
	self.ServerName = args.name
	self.Header = args.header
	self.MaxPlayers = args.maxplayers
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function ZEDBoard:Render( args )
	if(Key:IsDown(9))then
		local mpos = Mouse:GetPosition()
		local modX = 0
		local y = 30
		if(self.ViewPlayer > -1)then
			modX = Render.Width / 5 * 0.5
			local x = Render.Width/5 * 0.5
			local width = Render.Width /5*1
			Render:FillArea(Vector2(x -40,y), Vector2(Render.Width /5*1 - 10, 100 + (Render.Height - 200)), Color(0,0,0,150))
			local y2 = y+20
			local y = y2
			for _,ply in pairs(self.Players) do
				if(ply[1] == self.ViewPlayer)then
					for k,v in pairs(self.Header) do
						Render:DrawText( Vector2(x-Render:GetTextWidth(v .. ": ") + width/10,y), tostring(v .. ": "), Color(255,255,255) )
						Render:DrawText( Vector2(x + width/8,y), tostring(ply[k]), Color(255,255,255) )
						y = y + 20
					end
					for k,v in pairs(ply.ExtraInfo) do
						Render:DrawText( Vector2(x-Render:GetTextWidth(k .. ": ") + width/10,y), tostring(k .. ": "), Color(255,255,255) )
						Render:DrawText( Vector2(x + width/8,y), tostring(v), Color(255,255,255) )
						y = y + 20
					end
					break
				end
			end
			for _,lply in pairs(self.Players) do
				if(lply[1] == LocalPlayer:GetId())then
					for k,v in pairs(lply.Buttons) do
						if mpos.x > x -20 and mpos.x < x-20 + Render.Width / 5 -50 and mpos.y >= y and mpos.y <= y + 20 then
							Render:FillArea(Vector2(x -20,y), Vector2(Render.Width /5*1 - 50, 20), Color(100,100,100,150))
						else
							Render:FillArea(Vector2(x -20,y), Vector2(Render.Width /5*1 - 50, 20), Color(200,200,200,150))
						end
						Render:DrawText( Vector2(x-Render:GetTextWidth(k)/2 + width/3,y+3), tostring(k), Color(255,255,255) )
						y = y + 25
					end
					break
				end
			end
		end
		Render:FillArea(Vector2(Render.Width/5-20 + modX,y), Vector2(Render.Width /5*3+40, 100 + (Render.Height - 200)), Color(0,0,0,150))
		Render:DrawText( Vector2(Render.Width/2 + modX - Render:GetTextWidth(self.ServerName, 20)/2,y+10), self.ServerName, Color(255,255,255), 20 )
		Render:DrawText( Vector2(Render.Width/2 + modX - Render:GetTextWidth("Players: " .. #self.Players .. "/" .. self.MaxPlayers .. " ("..round(100/self.MaxPlayers*#self.Players,2).."%)", 18)/2,y+30), "Players: " .. #self.Players .. "/" .. self.MaxPlayers .. " ("..round(100/self.MaxPlayers*#self.Players,2).."%)", Color(255,255,255), 18 )
		
		y = y + 50
		local x = Render.Width / 5 + 20 + modX
		
		local minpercentages = {}
		local totalpercentages = 100
		local maxWidth = ( Render.Width /5*3 )
		local xPositions = {}
		for k,v in pairs(self.Header) do
			local biggestWidth = Render:GetTextWidth(v)
			for i,j in pairs(self.Players) do
				local width = Render:GetTextWidth(tostring(j[tostring(v)]))
				if width > biggestWidth then
					biggestWidth = width
				end
			end
			minpercentages[k] = 100 / maxWidth * biggestWidth 
			totalpercentages = totalpercentages - minpercentages[k]
		end
		for k,v in pairs(self.Header) do
			--if(type(v) == "string" or type(v) == "number")then
			Render:DrawText( Vector2(x+10,y+2), v, Color(200,200,200),13 )
			xPositions[k] = x + 10
			x = x + (maxWidth / 100 * totalpercentages)/#self.Header + maxWidth / 100 * minpercentages[k]
			--end
		end
		
		y = y + 20
		local height = Render:GetTextHeight("T", 25) + 2
		for i = math.floor(self.ScrollPosition) + 1,math.floor(self.ScrollPosition) + 1+self.PossibleItems,1 do
			if(self.Players[i])then
				x = Render.Width / 5 + modX
				if mpos.x > x and mpos.x < x + Render.Width/5*3 and mpos.y >= y and mpos.y < y + Render:GetTextHeight("T", 25) + 2 then
					Render:FillArea(Vector2(x-10,y), Vector2(Render.Width /5*3+20, Render:GetTextHeight("T", 25) + 2), self.Players[i].BGColor)
				else
					Render:FillArea(Vector2(x,y), Vector2(Render.Width /5*3, Render:GetTextHeight("T", 25) + 2), self.Players[i].BGColor)
				end
				local c = 1
				for k,v in pairs(self.Players[i]) do
					if(type(v) == "string" or type(v) == "number")then
						x = xPositions[c]
						Render:DrawText( Vector2(x,y+5), tostring(v), self.Players[i].FGColor, 18 )
						c = c + 1
					end
				end
				y = y + height + 1
			end
		end	
		local credits = "ZED V2.0"
		Render:FillArea(Vector2(Render.Width/5-20 + modX,Render.Height - 30), Vector2(Render.Width /5*3+40, 30), Color(0,0,0,150))
		Render:DrawText( Vector2(Render.Width/2-20 + modX,Render.Height - 20), tostring(credits), Color(200,200,200), 15 )
	end
end

local lastScroll = 50
function ZEDBoard:MouseScroll( args )
	self.ScrollPosition = self.ScrollPosition - args.delta * lastScroll/10
	if(self.ScrollPosition < 0)then self.ScrollPosition = 0 end
	if(#self.Players > self.PossibleItems)then
		if(self.ScrollPosition > #self.Players - self.PossibleItems)then
			self.ScrollPosition = #self.Players - self.PossibleItems
		end
	else
		self.ScrollPosition = 0
	end
	lastScroll = 50
end
function ZEDBoard:PreTick( args )
	if lastScroll > 10 then
		lastScroll = lastScroll - 1
	end
end

local keyIsDown = false
function ZEDBoard:KeyDown( args )
	if(args.key == 9 and not keyIsDown)then
		keyIsDown = true
		Mouse:SetPosition(Vector2(Render.Width/2, Render.Height/2))
		Mouse:SetVisible(true)
	end
end
function ZEDBoard:MouseDown( args )
	if(args.button == 1)then
		local y = 100
		local height = Render:GetTextHeight("T", 25) + 2
		local width = Render.Width /5*3
		local x = Render.Width / 5 
		local mpos = Mouse:GetPosition()
		local found = false
		for i = math.floor(self.ScrollPosition) + 1,math.floor(self.ScrollPosition) + 1+self.PossibleItems,1 do
			if(self.Players[i])then
				if(mpos.x >= x and mpos.x <= x + width and mpos.y >= y and mpos.y <= y + height)then
					found = true
					self.ViewPlayer = self.Players[i][1]
				end
				y = y + height + 1
			end
		end	
		if(self.ViewPlayer > -1)then
			local x = Render.Width/5 * 0.5 - 40
			local width = Render.Width /5*1 - 10
			local y = 30
			local height = 100 + (Render.Height - 200)
			if mpos.x >= x and mpos.x <= x+width and mpos.y >= y and mpos.y <= y+height then
				found = true
				local x = Render.Width/5 * 0.5
				local width = Render.Width /5*1
				local y2 = y+20
				local y = y2
				for k,v in pairs(self.Header) do
					y = y + 20
				end
				for _,ply in pairs(self.Players) do
					if(ply[1] == self.ViewPlayer)then
						for k,v in pairs(ply.ExtraInfo) do
							y = y + 20
						end
						break
					end
				end
				for _,ply in pairs(self.Players) do
					if(ply[1] == LocalPlayer:GetId())then
						for k,v in pairs(ply.Buttons) do
							if mpos.x >= x-20 and mpos.x <= x-20+Render.Width /5*1 - 50 and mpos.y >=y and mpos.y <= y + 20 then
								Network:Send("ZEDButtonClick", {player=LocalPlayer, text=v .. " " .. tostring(self.ViewPlayer), v, self.ViewPlayer})
							end
							y = y + 25
						end
						break
					end
				end
			end
		end
		if not found then
			self.ViewPlayer = -1
		end
	end
end

function ZEDBoard:KeyUp( args )
	if(args.key == 9)then
		keyIsDown = false
		Mouse:SetVisible(false)
	end
end

function ZEDBoard:LocalPlayerInput( args )
	if(Key:IsDown(9))then
		for index, action in ipairs(self.blacklist) do
			if action == args.input then
				return false
			end
		end
	 
		return true
	end
end


local zedboard = ZEDBoard()