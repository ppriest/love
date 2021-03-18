Object = require "classic"

Hero = Object:extend()

function Hero:new(x, y, speed)
  self.x = x or 0
  self.y = y or 0
  self.height = 15
  self.width = 30
  self.speed = speed or 150
  
  self.r = 1
  self.g = 1
  self.b = 0
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

function Hero:update(dt, dir)
  self.x = self.x + self.speed*dt*dir
end

function Hero:draw()
  love.graphics.setColor(self.r,self.g,self.b,self.a)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
