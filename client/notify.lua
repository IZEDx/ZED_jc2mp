--[[---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-----------------------------ZED MADE BY IZED ------ i-zed.net ----------------------------------
---------------------------------------------------------You are NOT allowed to change this file.
---------------------------------------------------------------------------------------------]]--

class 'Notify'

function Notify:__init()
	self.History = {}
	self.TextSize = 50
	self.Alpha = 255
	self.Timer = Timer()
	self.DebugTimer = Timer()
    Network:Subscribe( "ZEDNotify", self, self.Input )
    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "ZEDNotify", self, self.Input )
end

function Notify:Input( args )
	self.Alpha = 255
	self.Timer:Restart()
	table.insert(self.History, args)
end

local c = 0
function Notify:Render( args )
	if(self.Timer:GetMilliseconds() <= 1000)then
		self.Alpha = 1/1000 * self.Timer:GetMilliseconds() * 255
	end
	local v = self.History[#self.History]
	if(self.History[#self.History])then
		if(self.Timer:GetSeconds() > v.time)then
			if((self.Timer:GetMilliseconds()-v.time*1000) <= 1000)then
				self.Alpha = 255 - (1/1000 * (self.Timer:GetMilliseconds()-v.time*1000) * 255)
			else
				self.Alpha = 0
			end
		end
		local y = Render.Height/7
		local x = Render.Width / 2 - Render:GetTextWidth(v.text, v.size )/2
		Render:DrawText( Vector2(x,y+5)+Vector2(2,2), v.text, Color(0,0,0, self.Alpha/3), v.size )
		Render:DrawText( Vector2(x,y+5)+Vector2(1,1), v.text, Color(0,0,0, self.Alpha/2), v.size )
		Render:DrawText( Vector2(x,y+5), v.text, Color(v.color.r, v.color.g, v.color.b, self.Alpha), v.size )
	end
end

local notify = Notify()