local Enemy = require("enemy")
local resource_manager = require("resource_manager")
local utilities = require("utilities")

local EnemySubBoss = Enemy:extend()

local showHitbox = false

function EnemySubBoss:new(x, y)
  self.speed = 4
  EnemySubBoss.super.new(self, x, y, self.speed, 50, 10, "death")
  self.scale = 4
  self.width = 2*self.scale
  self.height = 2*self.scale
  
  -- reuse sub-Enemies
  self.parts = {
    Enemy(self.x + -2*self.scale, self.y + (10*2)*self.scale, self.speed, 5, 0, "death", "sub_boss_lwing", self.scale, 1.0),
    Enemy(self.x + (10*3 + 5)*self.scale, self.y + (10*2)*self.scale, self.speed, 5, 0, "death", "sub_boss_rwing", self.scale, 1.0),
    Enemy(self.x + 5*self.scale, self.y + (10*5 - 4)*self.scale, self.speed, 1, 0, "smash", "sub_boss_cockpit", self.scale, 1.0)
  }

end

function EnemySubBoss:update(dt)
  EnemySubBoss.super.update(self, dt)
  
  for ii, part in pairs(self.parts) do
    ii = ii
    part:update(dt)
  end
end

function EnemySubBoss:hit(disable)  
  -- can't disable
  EnemySubBoss.super.hit(self, false)
  
  for ii, part in pairs(self.parts) do
    ii = ii
    part:hit(false)
  end
  
  return (self.health <= 0)
end

function EnemySubBoss:checkCollision(shot)
  --if(not shot:getInert() and self.hit(self, shot:getDisable())) then  
  
  
  local hit = false
  for ii, part in pairs(self.parts) do
    ii = ii
    if utilities.checkBoxCollision(shot, part) then
      hit = true
    end
  end
  
  if utilities.checkBoxCollision(shot, self) then
    hit = true
  end
  
  return hit
end

function EnemySubBoss:draw()
  --local shader = resource_manager.getShader("white")
  
  -- hittable areas
  --if self.flashing then
    --love.graphics.setShader(shader)
  --else
    love.graphics.setShader()
  --end  
  
  love.graphics.setColor(self.r,self.g,self.b,self.a)
 
  local image, quad = resource_manager.getQuad("sub_boss_main")
  love.graphics.draw(image, quad, self.x, self.y, 0, self.scale, self.scale)
  
  local image2, quad2 = resource_manager.getQuad("sub_boss_cockpit_dmg")
  love.graphics.draw(image2, quad2, self.x + 5*self.scale, self.y + (10*5 - 4)*self.scale, 0, self.scale, self.scale)

  for ii, part in pairs(self.parts) do
    ii = ii
    part:draw()
  end

  if showHitbox then
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height) 
  end
  
  love.graphics.setShader()
end


return EnemySubBoss
