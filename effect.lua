local flux = require ("flux/flux")
local GameObject = require("game_object")
local Effect = GameObject:extend()

local timeToLive = 0.3

-- Show a graphic briefly

function Effect:new(x, y, quadName, scale)
  Effect.super.new(self, x, y, quadName, scale)

  self.creationTime = 0
  self.a = 1.0
  flux.to(self, timeToLive, { a = 0.0 }):ease("linear")
end

function Effect:update(dt, game_x, game_y)
  Effect.super.update(self, dt)

  if self.time > (self.creationTime + timeToLive) then
    self.expired = true
  end

  return self.expired
end

return Effect
