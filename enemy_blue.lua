local flux = require ("flux/flux")
local Enemy = require("enemy")

local EnemyBlue = Enemy:extend()

function EnemyBlue:new(x, y)
  EnemyBlue.super.new(self, x, y, 5, 1, 3, "death", "blue")
end

return EnemyBlue
