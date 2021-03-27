local ShotObject = Object:extend()
local resource_manager = require("resource_manager")

local radiusX = 0.18
local radiusY = 0.3
local speed = 2.0

function ShotObject:new(x, y, dir)
  self.x = x or 0
  self.y = y or 0
  self.dir = dir or 1
  
  self.initX = x or 0
  self.initY = y or 0
  self.height = 20
  self.width = 20
  self.image, self.quad = resource_manager.getQuad("glaive1")

  -- scale up the graphics
  self.scale = 2
  x, y, self.width, self.height = self.quad:getViewport()
  self.width = self.width*self.scale
  self.height= self.height*self.scale
  
  self.time = 0
end

function ShotObject:getHeight()
  return self.height
end

function ShotObject:getWidth()
  return self.width
end

function ShotObject:getX()
  return self.x
end

function ShotObject:getY()
  return self.y
end

function ShotObject:update(dt, game_x, game_y)
  self.time = self.time + dt
  
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
  
  local animFrame = (math.floor(self.time*10) % 2) + 1
  self.image, self.quad = resource_manager.getQuad("glaive" .. animFrame)
  
  -- don't allow removal until completed arc
  if loopComplete and (self.y < 0 or self.y >= game_y or self.x < 0 or self.x > game_x) then
    return true 
  end
  return false
end

function ShotObject:draw()
  -- love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.image, self.quad, self.x, self.y, 0, self.scale, self.scale)
end

return ShotObject
