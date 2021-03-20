local Enemy = Object:extend()

function Enemy:new(x, y, speed, health, score, image, quad, quad2)
  self.x = x or 0
  self.y = y or 0
  self.height = 20
  self.width = 40
  self.speed = speed or 1
  self.health = health or 1
  self.score = score or 1
  self.image = image or nil
  self.quad = quad or nil
  self.quad2 = quad2 or nil
  
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
  return (self.health <= 0)
end

function Enemy:draw()
  love.graphics.setColor(self.r,self.g,self.b,self.a)
  if(self.image ~= nil) then
    if(self.quad ~= nil) then
      love.graphics.draw(self.image, self.quad, self.x, self.y, 0, 3, 3)
    else
      love.graphics.draw(self.image, self.x, self.y, 0, 0.1, 0.1)
    end
  else
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)    
  end
end

return Enemy
