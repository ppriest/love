--local resource_manager = require("resource_manager")
local GameObject = require("game_object")

local Powerup = GameObject:extend()

function Powerup:new(x, y, speed, powerup)
  Powerup.super.new(self, x, y, 'powerup' .. powerup, 2, 0.6)
  self.speed = speed or 150
  self.powerup = powerup or 1
end

function Powerup:getType()
  return self.powerup
end

-- returns true if should be removed
function Powerup:update(dt, groundHeight)
  Powerup.super.update(self, dt)
  
  -- movement
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
  Powerup.super.draw(self)
end

return Powerup
