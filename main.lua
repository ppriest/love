Object = require ("classic")
local flux = require ("flux/flux")
local globals = require("globals")
--require ("sstrict/sstrict")

local game = require("game")

-- rendering state
local gameX = 800
local gameY = 600
local winWidth
local winHeight
local offsetX
local offsetY
local fullscreen = false
local mobile = false

-- call after toggling fullscreen/window
 local function initDisplay(full)
  fullscreen = full
  
  local targetWidth, targetHeight
  if(fullscreen) then
    targetWidth, targetHeight = love.window.getDesktopDimensions()
    love.window.setFullscreen( true )
  else
    targetWidth = gameX
    targetHeight = gameY
    love.window.setMode(targetWidth, targetHeight, {borderless=false, resizable=true})
    love.window.setFullscreen( false )
  end
  print("initDisplay()")
  print("  targetWidth: " .. targetWidth)
  print("  targetHeight: " .. targetHeight)
 
  love.resize(targetWidth, targetHeight)
end

-- called on window resize
function love.resize(w, h)
  local scaleX = w / winWidth
  local scaleY = h / winHeight
  print("love.resize()")
  print("  scaleX: " .. scaleX)
  print("  scaleY: " .. scaleY)
  
  scale = scaleX
  if(scaleX > scaleY) then
    scale = scaleY
  end
  print("  => scale: " .. scale)
  
  love.graphics.scale(scale, scale)
  offsetX = math.floor(w - (gameX*scale))/2
  offsetY = math.floor(h - (gameY*scale))/2

  print("  offsetX: " .. offsetX)
  print("  offsetY: " .. offsetY)
end

function love.load(arg)
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  io.stdout:setvbuf('no')
    
  if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    mobile = true
  end
  
  --love.window.setTitle("Matthew's Shooter")
  winWidth = love.graphics.getWidth()
  winHeight = love.graphics.getHeight()
  print("love.load()")
  print("  winWidth: " .. winWidth)
  print("  winHeight: " .. winHeight)
  initDisplay(fullscreen)
  
  love.graphics.setDefaultFilter("nearest", "nearest")

  game.load(gameX, gameY)
end

function love.keypressed(k)
  local digit = string.byte(k)-48
  
  if digit >= 0 and digit <= 9 then -- switch weapons
    game.chooseShotType(digit)
  elseif k == "space" then
    game.shoot()
  elseif k == 'escape' then -- fullscreen->window->quit
    --if fullscreen then
    --  initDisplay(false)
    --else
      love.event.quit()
    --end
  elseif k == 'f' or (k == 'return' and love.keyboard.isDown("ralt")) then -- toggle fullscreen
    initDisplay(not fullscreen)
  elseif k == 'r' then -- reset
    game.reload(gameX, gameY)
  elseif k == '=' then -- + level
    game.incLevel(gameX, gameY, 1)
  elseif k == '-' then -- - level
    game.incLevel(gameX, gameY, -1)
  elseif k == 'p' then -- pause
    game.togglePause()
  elseif k == 'g' then -- dump globals
    globals.dump(_G,"")
  end
end

function love.gamepadpressed(joystick, button)
  if (button == 'a') then
    game.shoot()    
  end
end

function love.gamepadreleased(joystick, button)
  if (button == 'back') then
      love.event.quit()
  end
end

function love.update(dt)
  flux.update(dt)
  game.update(dt, gameX, gameY)
end

function love.draw()
  -- scale proportionally, center, and clip
  love.graphics.translate(offsetX, offsetY)
  love.graphics.setScissor(offsetX, offsetY, (gameX*scale), (gameY*scale))
  love.graphics.scale(scale, scale)
  
  game.draw(gameX, gameY)

  if mobile then
    --touchoverlay.draw()
  end
end
 