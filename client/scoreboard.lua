class 'ZEDBoard'

function ZEDBoard:__init()
	self.Players = {}
	self.Header = {}
	self.ServerName = ""
	self.ScrollPosition = 0
	self.MaxPlayers = 0
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
		local y = 30
		Render:FillArea(Vector2(Render.Width/5-20,y), Vector2(Render.Width /5*3+40, 100 + (Render.Height - 200)), Color(0,0,0,150))
		Render:DrawText( Vector2(Render.Width/2 - Render:GetTextWidth(self.ServerName, 20)/2,y+10), self.ServerName, Color(255,255,255), 20 )
		Render:DrawText( Vector2(Render.Width/2 - Render:GetTextWidth("Players: " .. #self.Players .. "/" .. self.MaxPlayers .. " ("..round(100/self.MaxPlayers*#self.Players,2).."%)", 18)/2,y+30), "Players: " .. #self.Players .. "/" .. self.MaxPlayers .. " ("..round(100/self.MaxPlayers*#self.Players,2).."%)", Color(255,255,255), 18 )
		
		y = y + 50
		local x = Render.Width / 5 + 20
		
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
			print(#self.Header)
			x = x + (maxWidth / 100 * totalpercentages)/#self.Header + maxWidth / 100 * minpercentages[k]
			--end
		end
		
		y = y + 20
		local height = Render:GetTextHeight("T", 25) + 2
		for i = math.floor(self.ScrollPosition) + 1,math.floor(self.ScrollPosition) + 1+self.PossibleItems,1 do
			if(self.Players[i])then
				x = Render.Width / 5
				Render:FillArea(Vector2(x,y), Vector2(Render.Width /5*3, Render:GetTextHeight("T", 25) + 2), self.Players[i].BGColor)
				local c = 1
				for k,v in pairs(self.Players[i]) do
					if(type(v) == "string" or type(v) == "number")then
						x = xPositions[c]
						Render:DrawText( Vector2(x,y+5), tostring(v), self.Players[i].FGColor, 18 )
						c = c + 1
					end
				end
				y = y + height
			end
		end	
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
		for i = math.floor(self.ScrollPosition) + 1,math.floor(self.ScrollPosition) + 1+self.PossibleItems,1 do
			if(self.Players[i])then
				if(mpos.x >= x and mpos.x <= x + width and mpos.y >= y and mpos.y <= y + height)then
					print(self.Players[i][1])
				end
				y = y + height
			end
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