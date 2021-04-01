local Enemy = require("enemy")

local EnemyUrn = Enemy:extend()

function EnemyUrn:new(x, y)
  EnemyUrn.super.new(self, x, y, 25, 1, 0, "smash", "urn")
end

return EnemyUrn
