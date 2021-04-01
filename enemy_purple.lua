local Enemy = require("enemy")
--local resource_manager = require("resource_manager")

local EnemyPurple = Enemy:extend()

function EnemyPurple:new(x, y)
  -- custom hitbox
  EnemyPurple.super.new(self, x, y, 8, 12, 10, "death", "purple")
  self.offsetX = -(self.scale*self.width*0.1)/2
  self.width = self.width*self.scale*0.75
end

function EnemyPurple:hit(disable)  
  EnemyPurple.super.hit(self, disable)
  
  if(self.health == 6) then
    self.quadName = "purple_damage1"
  end
 
  return (self.health <= 0)
end

return EnemyPurple
