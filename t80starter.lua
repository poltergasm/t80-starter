-- title:  TIC-80 game boilerplate
-- author: poltergasm
-- desc:   Includes a basic class and inheritance system, entity manager, scene manager, scene base, and example scenes to get you started
-- script: lua

-- globals
local scr_w=240
local scr_h=136
local up=0
local down=1
local left=2
local right=3

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
	self.ents[#self.ents+1]=ent
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

function entity:new(x, y, w, h)
	self.pos=vec2(x or 0, y or 0)
	self.w=w or 0
	self.h=h or 0
	self.remove=false
	self.is_player=false
	self.prop=false
	self.sprite=nil
	self.state=nil
	self.tick=0
	self.step=5
	self.frame=0
	self.dir=0
	self.col=-1
	self.scale=1
	self.flipped=0
end

function entity:update()
	self.tick=(self.tick+1) % self.step
	if self.tick == 0 then
		self.frame=self.frame%#self.anim[self.state]+1
	end
end

function entity:draw()
	if self.anim ~= nil then
		spr(self.frame,self.pos.x,self.pos.y,
			self.col, self.scale, self.flipped)
	else
		spr(self.sprite,self.pos.x,self.pos.y,
			self.col, self.scale, self.flipped)
	end
end

-- entities
-- player
local ent_plyr=entity:extends()

function ent_plyr:new(...)
	ent_plyr.super.new(self,...)
	
	self.is_player=true
	self.sprite=1
	self.state="idle"
	self.dir=right
	self.anim={
		idle={1},
		walk={2,3,4},
		jump={5}
	}
end

function ent_plyr:update()
	ent_plyr.super.update(self)

	-- movement
	if btn(left) then
		self.state="walk"
		self.pos.x=self.pos.x-1
		self.dir=left
	elseif btn(3) then
		self.state="walk"
		self.pos.x=self.pos.x+1
		self.dir=right
	else
		self.state="idle"
	end

	self.flipped=self.dir==right and 0 or 1
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
	self.current:on_enter()
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
function sc_game:new() self.ent_mgr=em() end

function sc_game:on_enter()
	cls()
	self.player=ent_plyr(50, 88)
	self.ent_mgr:add(self.player)
end

function sc_game:update()
	sc_game.super.update(self)
end

function sc_game:draw()
	map()
	sc_game.super.draw(self)
end

-- setup
local title=sc_title()
local game=sc_game()
sm:add({title=title, game=game})
sm:switch("title")

-- tic functions
function TIC()
	sm:update()
end

function OVR()
	sm:draw() 
end
