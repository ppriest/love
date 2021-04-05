local ShotObject = require("shot_object")
local ShotHoming = ShotObject:extend()

local utilities = require("utilities")

function ShotHoming:new(x, y, speed, disable)
  ShotHoming.super.new(self, x, y, nil, 1)
  self.speed = speed or 150
  self.disable = disable or false
  
  self.r = 0.5
  self.g = 0.5
  self.b = 0.5
end

function ShotHoming:update(dt, game_x, game_y, enemies)
  ShotHoming.super.update(self, dt)
  self.y = self.y - dt*self.speed

  -- approach nearest in an arc
  local enemyDir = utilities.findNearestEnemyX(self.x, enemies)
  local factor = ((500 - self.y)/1000)
  self.x = self.x + dt*self.speed*enemyDir*factor
    
  if (self.y < 0 or self.y >= game_y or self.x < 0 or self.x > game_x) then
    return true
  end
  return false
end

return ShotHoming
