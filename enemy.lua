local flux = require ("flux/flux")
local resource_manager = require("resource_manager")
local utilities = require("utilities")

local GameObject = require("game_object")

local Enemy = GameObject:extend()

local invulnerableDuration = 0.5

function Enemy:new(x, y, speed, health, score, soundName, quadName, scale, hitboxProportion)
  Enemy.super.new(self, x, y, quadName, scale or 3, hitboxProportion or 0.6)
  self.speed = speed or 1
  self.health = health or 1
  self.score = score or 1
  self.soundName = soundName

  self.timeLastDamaged = 0
  
  self.parts = {}
      
  self.a = 0
  flux.to(self, invulnerableDuration, { a = 1 }):ease("linear")
end

function Enemy:getScore()
  return self.score
end

function Enemy:getHealth()
  return self.health
end

function Enemy:update(dt)
  Enemy.super.update(self, dt)
  
  -- movement
  self.y = self.y + dt*self.speed
  
  for ii, part in pairs(self.parts) do
    ii = ii
    part:update(dt)
  end
end

function Enemy:hit(disable)
  Enemy.super.startFlash(self)
  
  if disable then
    self.speed = 0
  end
  
  if self.time > invulnerableDuration then
    self.health = self.health - 1
  end
    
  if (self.health == 0) then
    resource_manager.playSound(self.soundName)
  end
  
  for ii, part in pairs(self.parts) do
    ii = ii
    part:hit(disable)
  end
  
  return (self.health <= 0)
end

function Enemy:draw()
  Enemy.super.draw(self)

  for ii, part in pairs(self.parts) do
    ii = ii
    part:draw()
  end

end

-- first return is whether shot hit, second is if enemy is destroyed and should be removed
function Enemy:checkCollision(shot, enemies)
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

return Enemy
