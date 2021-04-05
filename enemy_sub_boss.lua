local Enemy = require("enemy")
local resource_manager = require("resource_manager")
local utilities = require("utilities")

local EnemySubBoss = Enemy:extend()

local showHitbox = false

function EnemySubBoss:new(x, y)
  self.speed = 4
  EnemySubBoss.super.new(self, x, y, self.speed, 50, 10, "death")
  self.scale = 4
  self.width = 40*self.scale
  self.height = 60*self.scale
  
  -- reuse sub-Enemies
  self.parts = {
    Enemy(self.x + -2*self.scale, self.y + (10*2)*self.scale, self.speed, 5, 0, "death", "sub_boss_lwing", self.scale, 1.0),
    Enemy(self.x + (10*3 + 5)*self.scale, self.y + (10*2)*self.scale, self.speed, 5, 0, "death", "sub_boss_rwing", self.scale, 1.0),
    Enemy(self.x + 5*self.scale, self.y + (10*5 - 4)*self.scale, self.speed, 1, 0, "smash", "sub_boss_cockpit", self.scale, 1.0),
    Enemy(self.x + 15*self.scale, self.y + 13*self.scale, self.speed, 10, 0, "smash", "sub_boss_window_dmg", self.scale, 1.0),
    Enemy(self.x + 15*self.scale, self.y + 24*self.scale, self.speed, 10, 0, "smash", "sub_boss_window_dmg", self.scale, 1.0),
    Enemy(self.x + 15*self.scale, self.y + 13*self.scale, self.speed, 1, 0, "smash", "sub_boss_window", self.scale, 1.0),
    Enemy(self.x + 15*self.scale, self.y + 24*self.scale, self.speed, 1, 0, "smash", "sub_boss_window", self.scale, 1.0),
    Enemy(self.x + 7*self.scale, self.y + 0*self.scale, self.speed, 3, 0, "death", "sub_boss_prop", self.scale, 1.0),
    Enemy(self.x + 28*self.scale, self.y + 0*self.scale, self.speed, 3, 0, "death", "sub_boss_prop", self.scale, 1.0)
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

function EnemySubBoss:checkCollision(shot, enemies)
  local hit = false
  local kill = false
  local remPart = {}

  for ii, part in pairs(self.parts) do
    if utilities.checkBoxCollision(shot, part) then
      hit = true
      if not shot:getInert() and part.hit(part, false) then
        table.insert(remPart, ii)
      end
    end
  end
  
  for ii,part in utilities.ripairs(remPart) do
    ii = ii
    table.remove(self.parts, part)
  end 
  
  if #self.parts == 0 then
    if utilities.checkBoxCollision(shot, self) then
      hit = true
      if not shot:getInert() and self.hit(self, false) then
        kill = true
      end
    end
  end
  
  return hit,kill
end

function EnemySubBoss:draw()
  local shader = resource_manager.getShader("white")
  
  -- hittable areas
  if self.flashing then
    love.graphics.setShader(shader)
  else
    love.graphics.setShader()
  end  
  
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
