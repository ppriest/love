local flux = require ("flux/flux")
local resource_manager = require("resource_manager")
local GameObject = require("game_object")

local Enemy = GameObject:extend()

local invulnerableDuration = 0.5

function Enemy:new(x, y, speed, health, score, soundName, quadName)
  Enemy.super.new(self, x, y, quadName, 3)
  self.speed = speed or 1
  self.health = health or 1
  self.score = score or 1
  self.soundName = soundName

  self.timeLastDamaged = 0
  
  self.a = 0
  flux.to(self, invulnerableDuration, { a = 1 }):ease("linear")
end

function Enemy:getScore()
  return self.score
end

function Enemy:getHealth()
  return self.health
end

function Enemy:update(dt)
  Enemy.super.update(self, dt)
  
  -- movement
  self.y = self.y + dt*self.speed
end

function Enemy:hit(disable)
  Enemy.super.startFlash(self)
  
  --print('disable: ' .. tonumber(disable))
  
  if disable then
    self.speed = 0
  end
  
  if self.time > invulnerableDuration then
    self.health = self.health - 1
  end
    
  if (self.health == 0) then
    resource_manager.playSound(self.soundName)
  end
  return (self.health <= 0)
end

function Enemy:draw()
  Enemy.super.draw(self)
end

return Enemy
