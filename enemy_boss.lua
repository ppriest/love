local Enemy = require("enemy")

local EnemyBoss = Enemy:extend()

local colourChange = 0.20

function EnemyBoss:new(x, y)
  EnemyBoss.super.new(self, x, y, 6, 50, 10, "death", "boss")
end

function EnemyBoss:update(dt)
  EnemyBoss.super.update(self, dt)
  
  --self.r = (math.sin(self.time)*colourChange + (1-colourChange))
  --self.g = (math.cos(self.time)*colourChange + (1-colourChange))
  self.scale = (math.cos(self.time)*0.16 + 2.9)
  EnemyBoss.super.recalcScale(self)
end

function EnemyBoss:hit(disable)  
  EnemyBoss.super.hit(self, disable)
  
  if(self.health == 35) then
    self.quadName = "boss_damage"
  self.speed = 10
  elseif(self.health == 18) then
    self.quadName = "boss_damage2"
    self.speed = 20
  end
 
  return (self.health <= 0)
end

return EnemyBoss
