local Enemy = require("enemy")

local EnemyUrn = Enemy:extend()

function EnemyUrn:new(x, y, quadName)
  local quadName = quadName or "urn"
  EnemyUrn.super.new(self, x, y, 4, 1, 0, "smash", quadName)
end

return EnemyUrn
