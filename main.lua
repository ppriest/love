-- from [LÖVE tutorial, part 2](http://www.headchant.com/2010/12/31/love2d-%E2%80%93-tutorial-part-2-pew-pew/)
Object = require "classic"
local cron = require "cron"
require("paddy")
require("globals")

local utilities = require("utilities")
require("hero")

local game_x = 800
local game_y = 600
local offset_x
local offset_y
local fullscreen

local sophie
local shots
local hero
local drone
local enemies = {}
local hardenemies = {}
local maxShotNumber
local shotSpeed
local shotType
local score

local ground_height = 465
local mobile = false
local rainbow_bg = false

  
local function shoot()
  if #shots >= maxShotNumber then return end
  
  local hx = hero:getX()+hero:getWidth()/2
  local hy = hero:getY()
  
  local shot = {}
  shot.x = hx
  shot.y = hy
  shot.sp = shotSpeed
  table.insert(shots, shot)
  
  if shotType == 2 then
   local shot2 = {}
   shot2.x = hx+10
   shot2.y = hy+10
   shot2.sp = shotSpeed
   table.insert(shots, shot2)
   
   local shot3 = {}
   shot3.x = hx-10
   shot3.y = hy+10
   shot3.sp = shotSpeed
   table.insert(shots, shot3)
  end
  
  if shotType == 5 then
    local dx = drone:getX()+drone:getWidth()/2
    local dy = drone:getY()
    
    local shotDrone = {}
    shotDrone.x = dx
    shotDrone.y = dy
    table.insert(shots, shotDrone)
  end
end

local function chooseShotType(mode)
  mode = mode or love.math.random(1,6)
  shotType = mode
  -- shotType = 5

  if shotType == 1 then -- normal
    shotSpeed = 100
    maxShotNumber = 5
  elseif shotType == 2 then -- triple shot
    shotSpeed = 130
    maxShotNumber = 9
  elseif shotType == 3 then -- fast firing
    shotSpeed = 750
    maxShotNumber = 3
  elseif shotType == 4 then -- homing bullets
    shotSpeed = 110
    maxShotNumber = 5
  elseif shotType == 5 then -- drone
    shotSpeed = 100
    maxShotNumber = 16
  elseif shotType == 6 then -- drone
    shotSpeed = 1500
    maxShotNumber = 1
  end
end

local function shotString()
   if shotType == 1 then -- normal
     return "Normal"
  elseif shotType == 2 then -- triple shot
     return "Triple"

  elseif shotType == 3 then -- fast firing
     return "Fast"

   elseif shotType == 4 then -- homing bullets
     return "Homing"

   elseif shotType == 5 then -- drone
     return "Drone"
     
   elseif shotType == 6 then -- sniper 
     return "Sniper"
     
   end
end 

-- call after toggling fullscreen/window
 local function initDisplay(full)
  fullscreen = full
  
  local target_width, target_height
  if(fullscreen) then
    target_width, target_height = love.window.getDesktopDimensions()
    love.window.setFullscreen( true )
  else
    target_width = game_x
    target_height = game_y
    love.window.setMode(target_width, target_height, {borderless=false, resizable=true})
    love.window.setFullscreen( false )
  end
  print("initDisplay()")
  print("  target_width: " .. target_width)
  print("  target_height: " .. target_height)
 
  love.resize(target_width, target_height)
end

-- called on window resize
function love.resize(w, h)
  local scale_x = w / win_width
  local scale_y = h / win_height
  print("love.resize()")
  print("  scale_x: " .. scale_x)
  print("  scale_y: " .. scale_y)
  
  scale = scale_x
  if(scale_x > scale_y) then
    scale = scale_y
  end
  print("  => scale: " .. scale)
  
  -- love.graphics.translate(offset_x, offset_y)
  love.graphics.scale(scale, scale)
  offset_x = math.floor(w - (game_x*scale))/2
  offset_y = math.floor(h - (game_y*scale))/2
  print("  offset_x: " .. offset_x)
  print("  offset_y: " .. offset_y)
end

local rainbow
function love.load(arg)
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  io.stdout:setvbuf('no')
    
  if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    mobile = true
  end
  
  love.window.setTitle("Matthew's Shooter")
  win_width = love.graphics.getWidth()
  win_height = love.graphics.getHeight()
  print("love.load()")
  print("  win_width: " .. win_width)
  print("  win_height: " .. win_height)
  initDisplay(false)
  
  rainbow = utilities.gradientMesh("horizontal",
        {1, 0, 0},
        {1, 1, 0},
        {0, 1, 0},
        {0, 1, 1},
        {0, 0, 1},
        {1, 0, 0}
  )  
  chooseShotType(1)
  
  sophie = love.graphics.newImage("Sophie.png")

  score = 0
  shots = {} -- holds our fired shots
 
  hero = Hero(300, ground_height-15) 
  drone = Hero(320, ground_height-15, 450) 
  drone:setColor(0,0.8,0.8,1)

  for i=0,10 do
    local enemy = {}
    enemy.width = 40
    enemy.height = 20
    enemy.x = i * (enemy.width + 30) + 30
    enemy.y = enemy.height + 100
    table.insert(enemies, enemy)
  end
  
  for i=0,6 do
    local enemy = {}
    enemy.width = 40
    enemy.height = 20
    enemy.x = i * (enemy.width + 60) + 100
    enemy.y = enemy.height + 130
    table.insert(hardenemies, enemy)
  end
end

function love.keypressed(k)
  local digit = string.byte(k)-48
  
  if digit >= 1 and digit <= 6 then -- switch weapons
    chooseShotType(digit)
  elseif k == 'escape' then -- fullscreen->window->quit
    if fullscreen then
      initDisplay(false)
    else
      love.event.quit()
    end
  elseif k == 'f' or (k == 'return' and love.keyboard.isDown("ralt")) then -- toggle fullscreen
    initDisplay(not fullscreen)
  elseif k == 'r' then -- toggle rainbow
    rainbow_bg = not rainbow_bg
  elseif k == 'g' then -- dump globals
    dump(_G,"")
  end
end

function love.keyreleased(key)
  if (key == "space") then
    shoot()
  end
end

local timer2 = cron.every(10, chooseShotType)
local timer = cron.every(30, function() rainbow_bg = not rainbow_bg end)

function love.update(dt)
  timer:update(dt)
  paddy.update(dt)

  -- keyboard actions for our hero
  local dir = 0
  if love.keyboard.isDown("left") or paddy.isDown("left") then
    dir = -1
  elseif love.keyboard.isDown("right") or paddy.isDown("right") then
    dir = 1
  end
  hero:update(dt, dir)
  drone:update(dt, dir)

  if paddy.isDown("a") then
    shoot()
  end

  local remEnemy = {}
  local remHardEnemy = {}
  local remShot = {}

  -- update the shots
  for i,v in ipairs(shots) do
    -- move them up up up
    v.y = v.y - dt * v.sp

    if(shotType == 4) then 
      local enemyDist = 9999
      local enemyDir = 0
      local enemyX = v.x

      -- find closest
      for ii,vv in ipairs(enemies) do
        if ((math.abs(v.x - vv.x) < enemyDist) or enemyDist == 9999) then
          enemyDist = math.abs(v.x - vv.x)
          enemyX = vv.x
        end
      end
      
      if(v.x > enemyX) then
        enemyDir = -1
      elseif (v.x < enemyX) then
        enemyDir = 1
      end
	  
	  -- approach nearest in an arc
      local factor = ((500 - v.y)/1000)
      v.x = v.x + dt*v.sp*enemyDir*factor
    end

    -- mark shots that are not visible for removal
    if v.y < 0 then
      table.insert(remShot, i)
    end

    -- check for collision with enemies
    for ii,vv in ipairs(enemies) do
      if utilities.checkBoxCollision(v.x,v.y,2,5,vv.x,vv.y,vv.width,vv.height) then
        -- mark that enemy for removal
        table.insert(remEnemy, ii)
        -- mark the shot to be removed
        table.insert(remShot, i)
        score = score + 1
      end
    end
    for ii,vv in ipairs(hardenemies) do
      if utilities.checkBoxCollision(v.x,v.y,2,5,vv.x,vv.y,vv.width,vv.height) then
        -- mark that enemy for removal
        table.insert(remHardEnemy, ii)
        -- mark the shot to be removed
        table.insert(remShot, i)
        score = score + 3
      end
    end
  end

  -- remove the marked enemies
  for i,v in ipairs(remEnemy) do
    table.remove(enemies, v)
  end
  -- remove the marked enemies
  for i,v in ipairs(remHardEnemy) do
    table.remove(hardenemies, v)
  end

  for i,v in ipairs(remShot) do
    table.remove(shots, v)
  end

  -- update those evil enemies
  for i,v in ipairs(enemies) do
    -- let them fall down slowly
    v.y = v.y + dt*3

    -- check for collision with ground
    if v.y > ground_height then
      -- you lose!!!
    end
  end
  for i,v in ipairs(hardenemies) do
    -- let them fall down slowly
    v.y = v.y + 6*dt

    -- check for collision with ground
    if v.y > ground_height then
      -- you lose!!!
    end
  end
end

function love.draw()
  -- scale proportionally, center, and clip
  love.graphics.translate(offset_x, offset_y)
  love.graphics.setScissor(offset_x, offset_y, (game_x*scale), (game_y*scale))
  love.graphics.scale(scale, scale)
  
  -- let's draw a background
  if(rainbow_bg) then
    love.graphics.setColor(1,1,1,1) 
    love.graphics.draw(rainbow, 0, 0, 0, game_x, game_y)
  else
    love.graphics.setColor(0,0,0.1,1.0)
    love.graphics.rectangle("fill", 0, 0, game_x, game_y)
  end

  -- let's draw some ground
  love.graphics.setColor(0,0.6,0,1.0)
  love.graphics.rectangle("fill", 0, ground_height, game_x, game_y-ground_height)

  -- draw overlay
  love.graphics.setColor(1,1,1,1)
  love.graphics.print( "Shot: " .. shotString(shotType), 10, 20, -0.1, 1.8, 1.6) 
  love.graphics.print( "Score: " .. score, game_x, 20, 0.1, 1.8, 1.6, 100) 

  -- let's draw our hero
  hero:draw()
  
  if shotType == 5 then
    drone:draw()
  end

  -- let's draw our shots
  love.graphics.setColor(0.5,0.5,0.5,1)
  for i,v in ipairs(shots) do
    love.graphics.rectangle("fill", v.x, v.y, 2, 5)
  end 

  -- let's draw our enemies
  love.graphics.setColor(1,0.7,0.7,1)
  for i,v in ipairs(enemies) do
    --love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
    love.graphics.draw(sophie, v.x, v.y, 0, 0.1, 0.1)
  end
  love.graphics.setColor(1,0,0,1)
  for i,v in ipairs(hardenemies) do
    love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
  end
  
  love.graphics.setColor(1,1,1,1)
  if mobile then
    paddy.draw()
  end
end
 