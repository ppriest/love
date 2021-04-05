local flux = require ("flux/flux")
local Enemy = require("enemy")
local EnemyBlue= require("enemy_blue")
local EnemyRed = require("enemy_red")

local EnemyUrn = Enemy:extend()

function EnemyUrn:new(x, y, quadName, spawnType)
  EnemyUrn.super.new(self, x, y, 4, 1, 0, "smash", quadName or "urn")
  self.spawnType = spawnType or "blue"
end

function EnemyUrn:checkCollision(shot, enemies)
  local hit,kill = EnemyUrn.super.checkCollision(self, shot)
  if kill then
    self.smash(self, enemies)
  end
  
  return hit,kill
end

function EnemyUrn:smash(enemies)
  local swarmNum = 10 
  if self.spawnType == "red" then
    swarmNum = 6
  end
    
  for i=0,(swarmNum-1) do
    local enemy
    if self.spawnType == "red" then
      enemy = EnemyRed(self.x, self.y)
    elseif self.spawnType == "blue" then
      enemy = EnemyBlue(self.x, self.y)
    end
    flux.to(enemy, 2, { x = self.x + 120*math.cos(i * 2*math.pi / swarmNum), 
                        y = self.y +  80*math.sin(i * 2*math.pi / swarmNum) }):ease("backout")
    table.insert(enemies, enemy)
  end
end

return EnemyUrn
