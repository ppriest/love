local Enemy = Object:extend()

function Enemy:new(x, y, speed, score, image)
  self.x = x or 0
  self.y = y or 0
  self.height = 20
  self.width = 40
  self.speed = speed or 1
  self.score = score or 1
  self.image = image or nil
  
  self.r = 1
  self.g = 1
  self.b = 0
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


function Enemy:update(dt)
    self.y = self.y + dt*self.speed
end

function Enemy:draw()
  love.graphics.setColor(self.r,self.g,self.b,self.a)
  if(self.image ~= nil) then
    love.graphics.draw(self.image, self.x, self.y, 0, 0.1, 0.1)
  else
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)    
  end
end

return Enemy
