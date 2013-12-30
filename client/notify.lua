--[[---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-----------------------------ZED MADE BY IZED ------ i-zed.net ----------------------------------
---------------------------------------------------------You are NOT allowed to change this file.
---------------------------------------------------------------------------------------------]]--

class 'Notify'
class 'SideNotify'

function Notify:__init()
	self.History = {}
	self.Alpha = 255
	self.Timer = Timer()
	self.DebugTimer = Timer()
    Network:Subscribe( "Notify", self, self.Input )
    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "ZEDNotify", self, self.Input )
end
function SideNotify:__init()
	self.History = {}
    Network:Subscribe( "SideNotify", self, self.Input )
    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "ZEDSideNotify", self, self.Input )
end

function Notify:Input( args )
	self.Alpha = 255
	self.Timer:Restart()
	table.insert(self.History, args)
end
function SideNotify:Input( args )
	args.timer = Timer()
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

function SideNotify:Render( args )
	local y = Render.Height/4*3
	for k,v in pairs(self.History) do
		if(v)then
			local width = Render:GetTextWidth(v.text, v.size ) + 5
			local timer = v.timer:GetSeconds()
			local fgAlpha = 255
			local bgAlpha = 150
			if timer > 2 then
				fgAlpha = 255 - 100 / 255 * (100 / 0.5 * (timer - 2))
				bgAlpha = 255 - 100 / 150 * (100 / 0.5 * (timer - 2))
				if fgAlpha < 0 then
					fgAlpha = 0
					self.History[k].timer = nil
					self.History[k] = nil
				end
				if bgAlpha < 0 then
					bgAlpha = 0
				end
			end
			if fgAlpha > 0 then
				if timer > 0.5 then
					timer = 0.5
				end
				local x = Render.Width - width / 0.5 * timer
				Render:FillArea( Vector2(x-5,y-10), Vector2(Render:GetTextWidth(v.text, v.size)+10, Render:GetTextHeight(v.text, v.size)+10), Color(0,0,0,bgAlpha))
				Render:DrawText( Vector2(x,y), v.text, Color(v.color.r, v.color.g, v.color.b, fgAlpha), v.size )
			end
		end
	end
end

local notify = Notify()
local sidenotify = SideNotify()