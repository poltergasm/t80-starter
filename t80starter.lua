-- title:  TIC-80 framework skeleton
-- author: poltergasm
-- desc:   Includes a basic class and inheritance system, entity manager, scene manager, scene base, and example scenes to get you started
-- script: lua


local scr_w=240
local scr_h=136

-- class lib
local class={}
class.__index = class
function class:new() end
function class:extends()
	local cl={}
	cl["__call"]=class.__call
	cl.__index=cl
	cl.super=self
	setmetatable(cl, self)
	return cl
end

function class:__call(...)
	local inst=setmetatable({},self)
	inst:new(...)
	return inst
end

-- vector lib
local vec2 = class:extends()

function vec2:new(x, y)
	self.x=x or 0
	self.y=y or 0
end

-- entity manager
local em = class:extends()

function em:new()
	self.ents={}
end

function em:add(ent)
	self.entities[#self.ents+1]=ent
end

function em:update()
	local i=0
	for i=#self.ents, 1, -1 do
		if self.ents[i] ~= nil then
			if self.ents[i].remove then
				table.remove(self.ents, i)
			else
				self.ents[i]:update(i)
			end
		end
	end
end

function em:draw()
	local i=0
	for i=#self.ents, 1, -1 do
		self.ents[i]:draw()
	end
end

-- entity lib
local entity = class:extends()

function entity:new(name, x, y, w, h)
	self.pos=vec2(x or 0, y or 0)
	self.w=w or 0
	self.h=h or 0
	self.remove=false
	self.is_player=false
	self.name=name
	self.prop=false
	self.sprite=nil
	self.state=nil
end

function entity:draw()
	if self.state then
		-- do frame draw
	else
		spr(self.sprite,self.pos.x,self.pos.y)
	end
end

-- scene manager
local sm={
	current=nil,
	scenes={}
}

function sm:add(scenes)
	for k,v in pairs(scenes) do
		self.scenes[k]=v
	end
end

function sm:switch(scene)
	self.current=self.scenes[scene]
	if self.current.on_enter ~= nil then
		self.current:on_enter()
	end
end

function sm:update() self.current:update() end
function sm:draw() self.current:draw() end

-- scene lib
local scene = class:extends()

function scene:new() self.ent_mgr=em() end
function scene:on_enter() end
function scene:update() self.ent_mgr:update() end
function scene:draw() self.ent_mgr:draw() end

-- scene: title screen
local sc_title = scene:extends()

function sc_title:new() end

function sc_title:on_enter()
	cls()
	self.pressed=nil
	self.txt="Press x to play"
end

function sc_title:update()
	if self.pressed ~= nil then
		if time() > self.pressed+120 then
			self.pressed=nil
			sm:switch("game")
		end
	end
	
	if btnp(5, 60, 120) then
		self.txt="Let's a go!"
		self.pressed=time()
	end
end

function sc_title:draw()
	print(self.txt, 70, 50, 15)
end

-- scene: game
local sc_game=scene:extends()
function sc_game:new() end

function sc_game:on_enter()
	cls()
end

function sc_game:update()
end

function sc_game:draw()
	map()
end

-- setup
sm:add({title=sc_title, game=sc_game})
sm:switch("title")

-- tic functions
function TIC()
	sm:update()
end

function OVR()
	sm:draw() 
end
