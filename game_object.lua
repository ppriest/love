local GameObject = Object:extend()
local resource_manager = require("resource_manager")
local utilities = require("utilities")

local flashTime = 0.1

function GameObject:new(x, y, quadName, scale, hitboxProportion)
  self.x = x or 0
  self.y = y or 0
  self.quadName = quadName or nil
  self.scale = scale or 1
  self.hitBoxProportion = hitboxProportion or 1.0

  self.offsetX = 0
  self.offsetY = 0
  self.height = 15
  self.width = 30
  GameObject.recalcScale(self)
  
  self.r = 1
  self.g = 1
  self.b = 1
  self.a = 1
  
  self.time = 0
  self.flashStartTime = 0
  self.flashing = false
end

function GameObject:recalcScale()
  if not self.quadName then
    return
  end

  local image, quad = resource_manager.getQuad(self.quadName)
  local x, y, width, height = quad:getViewport()
  self.offsetX = -(self.scale*width*(1.0 - self.hitBoxProportion))/2
  self.offsetY = -(self.scale*height*(1.0 - self.hitBoxProportion))/2
  self.width = width*self.scale*self.hitBoxProportion
  self.height= height*self.scale*self.hitBoxProportion
end  

function GameObject:setColor(r, g, b, a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
end

function GameObject:getHeight()
  return self.height
end

function GameObject:getWidth()
  return self.width
end

function GameObject:getX()
  return self.x
end

function GameObject:getY()
  return self.y
end

function GameObject:startFlash()
  self.flashing = true
  self.flashStartTime = self.time
end

function GameObject:update(dt)
  self.time = self.time + dt
  if self.time > (self.flashStartTime + flashTime) then
    self.flashing = false
  end
end

function GameObject:draw()
  local shader = resource_manager.getShader("white")
  if self.flashing then
    love.graphics.setShader(shader)
  else
    love.graphics.setShader()
  end
  
  love.graphics.setColor(self.r,self.g,self.b,self.a)
  
  if self.quadName then
    local image, quad = resource_manager.getQuad(self.quadName)
    love.graphics.draw(image, quad, self.x + self.offsetX, self.y + self.offsetY, 0, self.scale, self.scale)
  else
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height) 
  end
  
  if utilities.getShowHitbox() then
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height) 
  end
  
  love.graphics.setShader()
end

return GameObject
