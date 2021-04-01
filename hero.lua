local Hero = Object:extend()
local resource_manager = require("resource_manager")

function Hero:new(x, y, speed, quadName)
  self.x = x or 0
  self.y = y or 0
  self.height = 15
  self.width = 30
  self.speed = speed or 150
  self.quadName = quadName or nil
  self.image, self.quad = resource_manager.getQuad(self.quadName)

  
  -- scale up the graphics
  -- hitbox is smaller than enemy, and centered
  self.scale = 3
  x, y, self.width, self.height = self.quad:getViewport()
  self.offsetX = -(self.scale*self.width*0.6)/2
  self.offsetY = -(self.scale*self.height*0.6)/2
  self.width = self.width*self.scale*0.4
  self.height= self.height*self.scale*0.4
  
  self.r = 1
  self.g = 1
  self.b = 1
  self.a = 1
end

function Hero:setColor(r, g, b, a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
end

function Hero:getHeight()
  return self.height
end

function Hero:getWidth()
  return self.width
end

function Hero:getX()
  return self.x
end

function Hero:getY()
  return self.y
end

-- dir is speed multiplier and direction - normally 1.0 / -1.0
function Hero:update(dt, dir, game_x, game_y)
  self.x = self.x + self.speed*dt*dir
  if self.x < 0 then
    self.x = 0
  end
  if self.x >= game_x-self.width then
    self.x = game_x-self.width-1
  end
end

function Hero:draw()
  love.graphics.setColor(self.r,self.g,self.b,self.a)
  love.graphics.draw(self.image, self.quad, self.x + self.offsetX, self.y + self.offsetY, 0, self.scale, self.scale)
  
  -- hitbox
  --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)    
end

return Hero
