local ShotObject = require("shot_object")
local ShotNormal = ShotObject:extend()

function ShotNormal:new(x, y, speed, disable)
  ShotNormal.super.new(self, x, y, nil, 1)
  self.speed = speed or 150
  self.disable = disable or false
  
  self.r = 0.5
  self.g = 0.5
  self.b = 0.5
end

function ShotNormal:update(dt, game_x, game_y)
  ShotNormal.super.update(self, dt)
  self.y = self.y - dt*self.speed
    
  if (self.y < 0 or self.y >= game_y or self.x < 0 or self.x > game_x) then
    return true
  end
  return false
end

return ShotNormal
