local flux = require ("flux/flux")
local resource_manager = require("resource_manager")
local GameObject = require("game_object")
local Effect = GameObject:extend()

-- Show a graphic briefly

function Effect:new(x, y, rotation, quadName, scale, timeToLive, timeToStart)
  Effect.super.new(self, x, y, quadName, scale)

  local image, quad = resource_manager.getQuad(self.quadName)
  local x2, y2, width, height = quad:getViewport()
  self.rotation = rotation or 0
  self.originX = width/2
  self.originY = height/2
  self.creationTime = 0
  self.a = 0.0
  self.timeToLive = timeToLive or 0.3
  self.timeToStart = timeToStart or 0.0
  flux.to(self, self.timeToStart, { a = 1.0 }):ease("expoin"):after(self, self.timeToLive, { a = 0.0 }):ease("linear")
end

function Effect:update(dt, game_x, game_y)
  Effect.super.update(self, dt)

  if self.time > (self.creationTime + self.timeToLive) then
    self.expired = true
  end

  return self.expired
end

return Effect
