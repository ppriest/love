local Enemy = require("enemy")
local resource_manager = require("resource_manager")

local alphaMin = 0.34

local EnemyBlack = Enemy:extend()

function EnemyBlack:new(x, y)
  EnemyBlack.super.new(self, x, y, 50, 3, 6, "death", "black")
end

function EnemyBlack:update(dt)
  self.time = self.time + dt
  self.y = self.y + dt*self.speed
  self.a = (math.sin(self.time)*alphaMin + (1-alphaMin))
end

function EnemyBlack:hit(disable)  
  if disable then
    self.speed = 0
  end
  
  self.health = self.health - 1
  if (self.health == 0) then
    resource_manager.playSound(self.soundName)
  end
  
  if(self.health == 2) then
    self.quadName = "black_damage1"
    self.speed = 35
  elseif(self.health == 1) then
    self.quadName = "black_damage2"
    self.speed = 0
  end
 
  return (self.health <= 0)
end

return EnemyBlack