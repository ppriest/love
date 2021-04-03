local Enemy = require("enemy")
local resource_manager = require("resource_manager")

local EnemySubBoss = Enemy:extend()

local showHitbox = false

function EnemySubBoss:new(x, y)
  EnemySubBoss.super.new(self, x, y, 4, 50, 10, "death")
  self.scale = 4
  self.width = 40*self.scale
  self.height = 50*self.scale
  
  self.damaged = false
end

function EnemySubBoss:update(dt)
  EnemySubBoss.super.update(self, dt)
end

function EnemySubBoss:hit(disable)  
  EnemySubBoss.super.hit(self, disable)
  
  self.damaged = true
  return (self.health <= 0)
end

function EnemySubBoss:draw()
  local shader = resource_manager.getShader("white")
  love.graphics.setShader()
  
  love.graphics.setColor(self.r,self.g,self.b,self.a)
 
  local image, quad = resource_manager.getQuad("sub_boss_main")
  love.graphics.draw(image, quad, self.x, self.y, 0, self.scale, self.scale)
  
  -- hittable areas
  if self.flashing then
    love.graphics.setShader(shader)
  else
    love.graphics.setShader()
  end  
  
  local cockpit_name = "sub_boss_cockpit"
  if self.damaged then
    cockpit_name = "sub_boss_cockpit_dmg"
  end
  local image2, quad2 = resource_manager.getQuad(cockpit_name)
  love.graphics.draw(image2, quad2, self.x + 5*self.scale, self.y + (10*5 - 4)*self.scale, 0, self.scale, self.scale)
  
  local image3, quad3 = resource_manager.getQuad("sub_boss_lwing")  
  love.graphics.draw(image3, quad3, self.x + -2*self.scale, self.y + (10*2)*self.scale, 0, self.scale, self.scale)
  
  local image4, quad4 = resource_manager.getQuad("sub_boss_rwing")    
  love.graphics.draw(image4, quad4, self.x + (10*3 + 5)*self.scale, self.y + (10*2)*self.scale, 0, self.scale, self.scale)
  
  if showHitbox then
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height) 
  end
  
  love.graphics.setShader()
end


return EnemySubBoss
