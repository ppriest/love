local Enemy = require("enemy")

local EnemyRed = Enemy:extend()

function EnemyRed:new(x, y)
  EnemyRed.super.new(self, x, y, 3, 3, 1, "death", "red")
end

function EnemyRed:hit(disable)  
  EnemyRed.super.hit(self, disable)
  
  if(self.health == 2) then
    self.quadName = "red_damage"
  end
 
  return (self.health <= 0)
end

return EnemyRed
