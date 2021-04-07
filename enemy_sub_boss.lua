local Enemy = require("enemy")
local EnemyBlack = require("enemy_black")
--local resource_manager = require("resource_manager")
--local utilities = require("utilities")

local EnemySubBoss = Enemy:extend()

function EnemySubBoss:new(x, y)
  self.speed = 2
  EnemySubBoss.super.new(self, x, y, self.speed, 50, 10, "death", "sub_boss_main")
  self.scale = 4
  self.width = 40*self.scale
  self.height = 50*self.scale
  self.offsetX = 0
  self.offsetY = 0
  
  -- reuse sub-Enemies
  self.parts = {
    Enemy(self.x + -2*self.scale, self.y + (10*2)*self.scale, self.speed, 8, 0, "death", "sub_boss_lwing", self.scale, 1.0),
    Enemy(self.x + (10*3 + 5)*self.scale, self.y + (10*2)*self.scale, self.speed, 8, 0, "death", "sub_boss_rwing", self.scale, 1.0),
    Enemy(self.x + 5*self.scale, self.y + (10*5 - 3)*self.scale, self.speed, 3, 0, "smash", "sub_boss_cockpit", self.scale, 1.0),
    Enemy(self.x + 15*self.scale, self.y + 13*self.scale, self.speed, 10, 0, "death", "sub_boss_window_dmg", self.scale, 1.0),
    Enemy(self.x + 15*self.scale, self.y + 24*self.scale, self.speed, 10, 0, "death", "sub_boss_window_dmg", self.scale, 1.0),
    Enemy(self.x + 15*self.scale, self.y + 13*self.scale, self.speed, 1, 0, "smash", "sub_boss_window", self.scale, 1.0),
    Enemy(self.x + 15*self.scale, self.y + 24*self.scale, self.speed, 1, 0, "smash", "sub_boss_window", self.scale, 1.0),
    Enemy(self.x + 7*self.scale, self.y + 0*self.scale, self.speed, 5, 0, "death", "sub_boss_prop", self.scale, 1.0),
    Enemy(self.x + 28*self.scale, self.y + 0*self.scale, self.speed, 5, 0, "death", "sub_boss_prop", self.scale, 1.0)
  }

end

function EnemySubBoss:hit(disable)  
  -- can't disable
  EnemySubBoss.super.hit(self, false) -- no disable
  return (self.health <= 0)
end

function EnemySubBoss:checkCollision(shot, enemies)
  local hit,kill = EnemySubBoss.super.checkCollision(self, shot, enemies)
  
  -- randomly spawn black
  if hit then
    local rare = love.math.random(1,30)
    if rare == 1 then
      for i=0,6 do
          local enemy = EnemyBlack(self.x + self.width/2 - 8, self.y + 20)
          table.insert(enemies, enemy)
      end
    end
  end
  
  return hit,kill
end

return EnemySubBoss
