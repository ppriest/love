local Enemy = require("enemy")
--local EnemyBlack = require("enemy_black")
--local resource_manager = require("resource_manager")
--local utilities = require("utilities")

local EnemyCaterpillarBoss = Enemy:extend()

function EnemyCaterpillarBoss:new(x, y)
  self.speed = 3
  EnemyCaterpillarBoss.super.new(self, x, y, self.speed, 50, 10, "death", "caterpillar_boss_main")
  self.scale = 4
  self.width = 28*self.scale
  self.height = 47*self.scale
  self.offsetX = 0
  self.offsetY = 0
  
  -- reuse sub-Enemies
  self.parts = {
    Enemy(self.x + 11*self.scale, self.y + 46*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_nose2", self.scale, 1.0),
    Enemy(self.x + 11*self.scale, self.y + 46*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_nose1", self.scale, 1.0),
    Enemy(self.x + 9*self.scale, self.y + -5*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_booster", self.scale, 1.0),
    Enemy(self.x + 16*self.scale, self.y + -5*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_booster", self.scale, 1.0),
    Enemy(self.x + -2*self.scale, self.y + 8*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_lfoot", self.scale, 1.0),
    Enemy(self.x + -2*self.scale, self.y + 21*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_lfoot", self.scale, 1.0),
    Enemy(self.x + -2*self.scale, self.y + 36*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_lfoot", self.scale, 1.0),
    Enemy(self.x + 27*self.scale, self.y + 8*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_rfoot", self.scale, 1.0),
    Enemy(self.x + 27*self.scale, self.y + 21*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_rfoot", self.scale, 1.0),
    Enemy(self.x + 27*self.scale, self.y + 36*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_rfoot", self.scale, 1.0),
    Enemy(self.x + 11*self.scale, self.y + 6*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_back", self.scale, 1.0),
    Enemy(self.x + 11*self.scale, self.y + 20*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_back", self.scale, 1.0),
    Enemy(self.x + 11*self.scale, self.y + 34*self.scale, self.speed, 8, 0, "death", "caterpillar_boss_back", self.scale, 1.0)
  }

end

function EnemyCaterpillarBoss:hit(disable)  
  -- can't disable
  EnemyCaterpillarBoss.super.hit(self, false) -- no disable
  return (self.health <= 0)
end

return EnemyCaterpillarBoss
