local Enemy = require("enemy")
local resource_manager = require("resource_manager")

local EnemyBoss = Enemy:extend()

function EnemyBoss:new(x, y)
  EnemyBoss.super.new(self, x, y, 4, 50, 10, "death", "boss")
end

function EnemyBoss:hit()  

  self.health = self.health - 1
  if (self.health == 0) then
    resource_manager.playSound(self.soundName)
  end
  
  if(self.health == 35) then
    self.quadName = "boss_damage"
  elseif(self.health == 18) then
    self.quadName = "boss_damage2"
  end
 
  return (self.health <= 0)
end

return EnemyBoss
