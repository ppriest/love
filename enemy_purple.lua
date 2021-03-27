local Enemy = require("enemy")
--local resource_manager = require("resource_manager")

local EnemyPurple = Enemy:extend()

function EnemyPurple:new(x, y)
  EnemyPurple.super.new(self, x, y, 8, 12, 10, "death", "purple", 6, "purple_damage1")
  self.offsetX = -(self.scale*self.width*0.1)/2
  self.width = self.width*self.scale*0.75
end

return EnemyPurple
