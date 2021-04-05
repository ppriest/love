local EnemyUrn = require("enemy_urn")

local EnemyRedUrn = EnemyUrn:extend()

function EnemyRedUrn:new(x, y)
  EnemyRedUrn.super.new(self, x, y, "red_urn", "red")
end

return EnemyRedUrn
