local GameObject = require("game_object")
local ShotObject = GameObject:extend()

local inertTime = 0.1 -- won't damage again for this long

function ShotObject:new(x, y, quadName, scale)
  ShotObject.super.new(self, x, y, quadName, scale)

  self.initX = x or 0
  self.initY = y or 0
  self.height = 5
  self.width = 2

  self.timeLastDamage = 0
  self.inert = false
  self.disable = false
end

function ShotObject:getInert()
  return self.inert
end

function ShotObject:getDisable()
  return self.disable
end

function ShotObject:getRemoveOnImpact()
  return true
end

function ShotObject:hit()
  self.inert = true
  self.timeLastDamage = self.time
end

function ShotObject:update(dt, game_x, game_y)
  ShotObject.super.update(self, dt)

  if self.time > (self.timeLastDamage + inertTime) then
    self.inert = false
  end

  return
end

return ShotObject
