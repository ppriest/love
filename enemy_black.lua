local Enemy = require("enemy")
local resource_manager = require("resource_manager")

local EnemyBlack = Enemy:extend()

function EnemyBlack:new(x, y)
  EnemyBlack.super.new(self, x, y, 50, 3, 6, "death", "black")
end

function EnemyBlack:hit()  

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