local Powerup = Object:extend()
local resource_manager = require("resource_manager")

function Powerup:new(x, y, speed, powerup)
  self.x = x or 0
  self.y = y or 0
  self.height = 15
  self.width = 15
  self.speed = speed or 150
  self.powerup = powerup or 1
  self.image, self.quad = resource_manager.getQuad('powerup' .. self.powerup)

  -- scale up the graphics
  -- hitbox is smaller than enemy, and centered
  self.scale = 2
  self.time = 0
end

function Powerup:getHeight()
  return self.height
end

function Powerup:getWidth()
  return self.width
end

function Powerup:getX()
  return self.x
end

function Powerup:getY()
  return self.y
end

function Powerup:getType()
  return self.powerup
end

-- returns true if should be removed
function Powerup:update(dt, groundHeight)
  self.time = self.time + dt
  local grounded = false
  
  if self.y < groundHeight then
    self.y = self.y + self.speed*dt
  else
    self.y = groundHeight
    grounded = true
  end
  
  return grounded and self.time > 5
end

function Powerup:draw()
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.image, self.quad, self.x, self.y, 0, self.scale, self.scale)
  
  -- hitbox
  --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)    
end

return Powerup
