local Enemy = require("enemy")

local EnemyRed = Enemy:extend()

function EnemyRed:new(x, y)
  EnemyRed.super.new(self, x, y, 3, 3, 1, "death", "red", "red_damage")
end

return EnemyRed
