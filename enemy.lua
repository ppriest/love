local Enemy = Object:extend()

function Enemy:new(x, y, speed, health, score, sound, image, quad, quad2)
  self.x = x or 0
  self.y = y or 0
  self.speed = speed or 1
  self.health = health or 1
  self.score = score or 1
  self.sound = sound
  self.image = image or nil
  self.quad = quad or nil
  self.quad2 = quad2 or nil
  
  -- scale up the graphics
  -- hitbox is smaller than enemy, and centered
  self.scale = 3
  x, y, self.width, self.height = quad:getViewport()
  self.offsetX = -(self.scale*self.width*0.6)/2
  self.offsetY = -(self.scale*self.height*0.6)/2
  self.width = self.width*self.scale*0.4
  self.height= self.height*self.scale*0.4
  
  self.r = 1
  self.g = 1
  self.b = 1
  self.a = 1
end

function Enemy:setColor(r, g, b, a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
end

function Enemy:getHeight()
  return self.height
end

function Enemy:getWidth()
  return self.width
end

function Enemy:getX()
  return self.x
end

function Enemy:getY()
  return self.y
end

function Enemy:getScore()
  return self.score
end

function Enemy:getHealth()
  return self.health
end

function Enemy:update(dt)
  self.y = self.y + dt*self.speed
end

function Enemy:hit()
  self.health = self.health - 1
  if(self.quad2 ~= nil) then
    self.quad = self.quad2
  end
  if (self.health == 0) then
    self.sound:play()
  end
  return (self.health <= 0)
end

function Enemy:draw()
  love.graphics.setColor(self.r,self.g,self.b,self.a)
  love.graphics.draw(self.image, self.quad, self.x + self.offsetX, self.y + self.offsetY, 0, self.scale, self.cale)
  
  -- hitbox
  -- love.graphics.rectangle("line", self.x, self.y, self.width, self.height)    
end

return Enemy
