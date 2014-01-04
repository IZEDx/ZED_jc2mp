--[[---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-----------------------------ZED MADE BY IZED ------ i-zed.net ----------------------------------
---------------------------------------------------------You are NOT allowed to change this file.
---------------------------------------------------------------------------------------------]]--

class 'ZEDChat'

function ZEDChat:__init()
	self.History = {
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}},
		{{text="", color=Color(0,0,0)}}
	}
	self.ChatEnabled = true
	
	--Events:Register("ZEDTunnel") -- Deprecated
	
    Network:Subscribe( "ZEDChat", self, self.Chat )
    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "KeyDown", self, self.KeyDown )
    Events:Subscribe( "ZEDTunnel", self, self.Chat )
end

function ZEDChat:ParseMessage(args)
	local t = {}
	local col = Color(255,255,255)
	for k,v in pairs(args) do
		if(type(v)=="string")then
			table.insert(t, {text = v, color = col})
		elseif(type(v)=="table")then
			for i,j in pairs(v) do
				if(type(j)=="string")then
					table.insert(t, {text = j, color = col})
				else
					col = j
				end
			end
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
	if(self.ChatEnabled)then
		local bigwidth = 0
		local ysize = 4
		if(Chat:GetActive())then
			ysize = 1.7
		end
		local y = Render.Height/3*1.835 + (Render.Height/4 - Render.Height/ysize)
		for i,j in ipairs(self.History) do
			if(i > #self.History - math.floor(Render.Height/ysize/(Render:GetTextHeight("T")+0.3)))then
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
			Render:FillArea(Vector2(25,y-2), Vector2( bigwidth + 15, Render.Height/ysize ), Color(0,0,0,100))
		end
		for i,j in ipairs(self.History) do
			if(i > #self.History - math.floor(Render.Height/ysize/(Render:GetTextHeight("T")+0.3)))then
				local x = 31
				for k,v in pairs(j) do
					Render:DrawText( Vector2(x,y+5) + Vector2( 1, 1 ), v.text, Color(0,0,0,150) )
					Render:DrawText( Vector2(x,y+5) + Vector2( 2, 2 ), v.text, Color(0,0,0,50) )
					Render:DrawText( Vector2(x,y+5), v.text, v.color )
					x = x + Render:GetTextWidth( v.text )
				end
				y = y + Render:GetTextHeight("T")
			end
		end
	end
end
function ZEDChat:KeyDown( args )
	if(args.key == 114)then
		if(self.ChatEnabled)then
			self.ChatEnabled = false
		else
			self.ChatEnabled = true
		end
	end
end

local zedchat = ZEDChat()