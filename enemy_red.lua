local Enemy = require("enemy")

local EnemyRed = Enemy:extend()

function EnemyRed:new(x, y)
  local image = love.graphics.newImage("art/gfx.png")
  local redQuad = love.graphics.newQuad(16,0,16,16,image:getDimensions())
  local redDamageQuad = love.graphics.newQuad(16,16,16,16,image:getDimensions())
  local sound = love.audio.newSource("sounds/448226__inspectorj__explosion-8-bit-01.wav", "static")

  print('before super: ')
  EnemyRed.super.new(self, x, y, 3, 3, 1, sound, image, redQuad, redDamageQuad)
  print('after super: ' .. self.health)
end

return EnemyRed
