--local resource_manager = require("resource_manager")
local GameObject = require("game_object")

local Hero = GameObject:extend()

function Hero:new(x, y, speed, quadName)
  Hero.super.new(self, x, y, quadName, 3)
  self.speed = speed or 150
end

-- dir is speed multiplier and direction - normally 1.0 / -1.0
function Hero:update(dt, dir, game_x, game_y)
  Hero.super.update(self, dt)
  
  -- movement
  self.x = self.x + self.speed*dt*dir
  if self.x < 0 then
    self.x = 0
  end
  if self.x >= game_x-self.width then
    self.x = game_x-self.width-1
  end
end

function Hero:draw()
  Hero.super.draw(self)
end

return Hero
