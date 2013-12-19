class 'ZEDChat'

function ZEDChat:__init()
	self.History = {}
    Network:Subscribe( "ZEDChat", self, self.Chat )
    Events:Subscribe( "Render", self, self.Render )
end

function ZEDChat:ParseMessage(args)
	local t = {}
	local col = Color(255,255,255)
	for k,v in pairs(args) do
		if(type(v)=="string")then
			table.insert(t, {text = v, color = col})
		else
			col = v
		end
	end
	table.insert(self.History, t)
end

function ZEDChat:Chat( args )
	for i = 0, 14, 1 do
		Chat:Print("", Color(0,0,0))
	end
	text = self:ParseMessage(args)
end

function ZEDChat:Render( args )
	if(Chat:GetEnabled())then
		local y = Render.Height - 350
		local bigwidth = 0
		for i,j in ipairs(self.History) do
			if(i > #self.History - 14)then
				local width = 0
				for k,v in pairs(j) do
					width = width + Render:GetTextWidth( v.text )
				end
				if width > bigwidth then
					bigwidth = width
				end
			end
		end
		if(Chat:GetActive() and bigwidth > 0)then
			Render:FillArea(Vector2(25,y-2), Vector2( bigwidth + 10, 225 ), Color(0,0,0,100))
		end
		for i,j in ipairs(self.History) do
			if(i > #self.History - 14)then
				local x = 31
				for k,v in pairs(j) do
					Render:DrawText( Vector2(x,y) + Vector2( 1, 1 ), v.text, Color(0,0,0,150) )
					Render:DrawText( Vector2(x,y) + Vector2( 2, 2 ), v.text, Color(0,0,0,50) )
					Render:DrawText( Vector2(x,y), v.text, v.color )
					x = x + Render:GetTextWidth( v.text )
				end
				y = y + Render:GetTextHeight("T")
			end
		end
	end
end

local zedchat = ZEDChat()