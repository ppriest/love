local ShotObject = require("shot_object")
local ShotShuriken = ShotObject:extend()

local resource_manager = require("resource_manager")

local radiusX = 0.18
local radiusY = 0.3
local speed = 2.0

function ShotShuriken:new(x, y, dir)
  ShotShuriken.super.new(self, x, y, "glaive1", 2)
  self.dir = dir or 1
end

function ShotShuriken:update(dt, game_x, game_y)
  ShotShuriken.super.update(self, dt)
  
  local animFrame = (math.floor(self.time*10) % 2) + 1
  self.quadName = ("glaive" .. animFrame)
 
  local loopComplete = false
  if (self.time*speed < math.pi*2) then
    -- ellipse
    self.x = self.initX - self.dir*game_x*radiusX*math.sin(self.time*speed)
    self.y = self.initY + (game_y*radiusY*(math.cos(self.time*speed) - 1))
  else
    -- 360 degrees complete
    self.x = self.initX - self.dir*(self.time*speed - math.pi*2)*100
    self.y = self.initY
    loopComplete = true
  end
   
  -- don't allow removal until completed arc
  if loopComplete and (self.y < 0 or self.y >= game_y or self.x < 0 or self.x > game_x) then
    return true 
  end
  return false
end

function ShotShuriken:getRemoveOnImpact()
  return false
end

return ShotShuriken
