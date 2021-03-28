local Enemy = require("enemy")

local EnemyBlack = Enemy:extend()

local alphaMin = 0.34

function EnemyBlack:new(x, y)
  EnemyBlack.super.new(self, x, y, 50, 3, 6, "death", "black")
end

function EnemyBlack:update(dt)
  self.time = self.time + dt
  self.y = self.y + dt*self.speed
  self.a = (math.sin(self.time)*alphaMin + (1-alphaMin))
end

function EnemyBlack:hit(disable)  
  EnemyBlack.super.hit(self, disable)
  
  if(self.health == 2) then
    self.quadName = "black_damage1"
    self.speed = 30
  elseif(self.health == 1) then
    self.quadName = "black_damage2"
    self.speed = 15
  end
 
  return (self.health <= 0)
end

return EnemyBlack