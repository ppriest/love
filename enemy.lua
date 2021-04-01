local resource_manager = require("resource_manager")
local GameObject = require("game_object")

local Enemy = GameObject:extend()

function Enemy:new(x, y, speed, health, score, soundName, quadName, healthDamage, quadName2)
  print("quadname: " .. quadName)
  Enemy.super.new(self, x, y, quadName, 3)
  self.speed = speed or 1
  self.health = health or 1
  self.score = score or 1
  self.soundName = soundName
  self.healthDamage = healthDamage or -1
  self.quadName2 = quadName2 or nil

  self.timeLastDamaged = 0
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
  
  if disable then
    self.speed = 0
  end
  
  if(self.quadName2 ~= nil and self.healthDamage == self.health) then
    self.quadName = self.quadName2
  end
  
  self.health = self.health - 1
  if (self.health == 0) then
    resource_manager.playSound(self.soundName)
  end
  return (self.health <= 0)
end

function Enemy:draw()
  Enemy.super.draw(self)
end

return Enemy
