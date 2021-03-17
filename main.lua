-- from [LÖVE tutorial, part 2](http://www.headchant.com/2010/12/31/love2d-%E2%80%93-tutorial-part-2-pew-pew/)
local cron = require 'cron'
require("paddy")

function chooseShotType(mode)
  mode = mode or love.math.random(1,6)
  shotType = mode
  -- shotType = 4

  if shotType == 1 then -- normal
   sp = 100
   nm = 5
  elseif shotType == 2 then -- triple shot
   sp = 130
   nm = 9
  elseif shotType == 3 then -- fast firing
   sp = 750
   nm = 3
   elseif shotType == 4 then -- homing bullets
   sp = 110
   nm = 5
   elseif shotType == 5 then -- drone
   sp = 100
   nm = 16
   elseif shotType == 6 then -- drone
   sp = 1500
   nm = 1
  end
end

function shotString()
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

local fullscreen = false

-- call after toggling fullscreen/window
function initDisplay(full)
  fullscreen = full
  
  local target_width, target_height
  if(fullscreen) then
    target_width, target_height = love.window.getDesktopDimensions()
    love.window.setFullscreen( true )
  else
    love.window.setMode(400, 400, {borderless=false, resizable=true})
    -- target_width, target_height = love.window.getMode()
    target_width = 400
    target_height = 400
    love.window.setFullscreen( false )
  end
  
  love.resize(target_width, target_height)
end

-- called on window resize
function love.resize(w, h)
  local scale_x = w / win_width
  local scale_y = h / win_height
  print("scale_x: " .. scale_x)
  print("scale_y: " .. scale_y)
  
  scale = scale_x
  if(scale_x > scale_y) then
    scale = scale_y
  end
  
  -- love.graphics.translate(offset_x, offset_y)
  love.graphics.scale(scale, scale)
end

function love.load(arg)
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  io.stdout:setvbuf('no')
    
  mobile = false
  if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    mobile = true
  end
  
  love.window.setTitle("Matthew's Shooter")
  win_width = love.graphics.getWidth()
  win_height = love.graphics.getHeight()
  print("screen_width: " .. win_width)
  print("screen_height: " .. win_height)
  initDisplay(false)
  
  chooseShotType(1)
  
  timeElapsed = 0
  lastTenSeconds = 0
  score = 0
  
  sophie = love.graphics.newImage("Sophie.png")
  
  hero = {} -- new table for the hero
  hero.x = 300 -- x,y coordinates of the hero
  hero.y = 450
  hero.width = 30
  hero.height = 15
  hero.speed = 150
  hero.shots = {} -- holds our fired shots
  
  drone = {} -- new table for the drone
  drone.x = 320 -- x,y coordinates of the drone
  drone.y = 450
  drone.width = 30
  drone.height = 15
  drone.speed = 150
  drone.shots = {} -- holds our fired shots

  enemies = {}
  for i=0,15 do
    local enemy = {}
    enemy.width = 40
    enemy.height = 20
    enemy.x = i * (enemy.width + 30) + 30
    enemy.y = enemy.height + 100
    table.insert(enemies, enemy)
  end
  hardenemies = {}
  for i=0,7 do
    local enemy = {}
    enemy.width = 40
    enemy.height = 20
    enemy.x = i * (enemy.width + 60) + 100
    enemy.y = enemy.height + 130
    table.insert(hardenemies, enemy)
  end
end

function love.keypressed(k)
   if k == 'escape' then
      love.event.quit()
   end
   if k == 'f' then
      initDisplay(true)
   end
   if k == 'w' then
      initDisplay(false)
   end
end

function love.keyreleased(key)
  -- in v0.9.2 and earlier space is represented by the actual space character ' ', so check for both
  if (key == " " or key == "space") then
    shoot()
  end
end

local timer = cron.every(10,  chooseShotType)

function love.update(dt)
  timer:update(dt)
  paddy.update(dt)

  -- keyboard actions for our hero
  if love.keyboard.isDown("left") or paddy.isDown("left") then
    hero.x = hero.x - hero.speed*dt
    drone.x = drone.x - drone.speed*dt*1.5
  elseif love.keyboard.isDown("right") or paddy.isDown("right") then
    hero.x = hero.x + hero.speed*dt
    drone.x = drone.x + drone.speed*dt*1.5
  end

  if paddy.isDown("a") then
    shoot()
  end

  local remEnemy = {}
  local remHardEnemy = {}
  local remShot = {}

  -- update the shots
  for i,v in ipairs(hero.shots) do
    -- move them up up up
    v.y = v.y - dt * sp

    if(shotType == 4) then 
      local enemyDist = 9999
      local enemyDir = 0
      local enemyX = v.x
      for ii,vv in ipairs(enemies) do
        -- find closest
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
      -- print(enemyDir .. " " .. enemyDist .. " " .. v.x .. " " .. enemyX)
      local factor = ((500 - v.y)/1000)
      print("factor: " .. factor)
      v.x = v.x + dt*sp*enemyDir*factor
    end

    -- mark shots that are not visible for removal
    if v.y < 0 then
      table.insert(remShot, i)
    end

    -- check for collision with enemies
    for ii,vv in ipairs(enemies) do
      if CheckCollision(v.x,v.y,2,5,vv.x,vv.y,vv.width,vv.height) then
        -- mark that enemy for removal
        table.insert(remEnemy, ii)
        -- mark the shot to be removed
        table.insert(remShot, i)
        score = score + 3
      end
    end
    for ii,vv in ipairs(hardenemies) do
      if CheckCollision(v.x,v.y,2,5,vv.x,vv.y,vv.width,vv.height) then
        -- mark that enemy for removal
        table.insert(remHardEnemy, ii)
        -- mark the shot to be removed
        table.insert(remShot, i)
        score = score + 10
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
    table.remove(hero.shots, v)
  end

  -- update those evil enemies
  for i,v in ipairs(enemies) do
    -- let them fall down slowly
    v.y = v.y + dt*3

    -- check for collision with ground
    if v.y > 465 then
      -- you lose!!!
    end
  end
  for i,v in ipairs(hardenemies) do
    -- let them fall down slowly
    v.y = v.y + 6*dt

    -- check for collision with ground
    if v.y > 465 then
      -- you lose!!!
    end
  end
end

function love.draw()
  love.graphics.scale(scale, scale)
  
  -- let's draw a background
  love.graphics.setColor(255,0,50,255)

  -- let's draw some ground
  love.graphics.setColor(0,255,0,255)
  love.graphics.rectangle("fill", 0, 465, 800, 150)

  -- draw overlay
  love.graphics.setColor(255,255,255,255)
  love.graphics.print( "Shot: " .. shotString(shotType), 10, 20, -0.1, 1.8, 1.6) 
  love.graphics.print( "Score: " .. score, 800, 20, 0.1, 1.8, 1.6, 100) 

  -- let's draw our hero
  love.graphics.setColor(255,255,0,255)
  love.graphics.rectangle("fill", hero.x, hero.y, hero.width, hero.height)
  
  if shotType == 5 then
    love.graphics.setColor(0,200,200,255)
    love.graphics.rectangle("fill", drone.x, drone.y, drone.width, drone.height)
  end

  -- let's draw our heros shots
  love.graphics.setColor(150,150,150,255)
  for i,v in ipairs(hero.shots) do
    love.graphics.rectangle("fill", v.x, v.y, 2, 5)
  end 

  -- let's draw our enemies
  love.graphics.setColor(255,200,200,255)
  for i,v in ipairs(enemies) do
    --love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
    love.graphics.draw(sophie, v.x, v.y, 0, 0.1, 0.1)
  end
   love.graphics.setColor(255,0,0,255)
 for i,v in ipairs(hardenemies) do
    love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
  end
  
  if mobile then
    paddy.draw()
  end
end

function shoot()
  if #hero.shots >= nm then return end
  
  local shot = {}
  shot.x = hero.x+hero.width/2
  shot.y = hero.y
  table.insert(hero.shots, shot)
  
  if shotType == 2 then
   local shot2 = {}
   shot2.x = hero.x+10+hero.width/2
   shot2.y = hero.y+10
   table.insert(hero.shots, shot2)
   local shot3 = {}
   shot3.x = hero.x-10+hero.width/2
   shot3.y = hero.y+10
   table.insert(hero.shots, shot3)
  end
  
  if shotType == 5 then
    local shotDrone = {}
    shotDrone.x = drone.x+drone.width/2
    shotDrone.y = drone.y
    table.insert(hero.shots, shotDrone)
  end
end

-- Collision detection function.
-- Checks if a an d b overlap.
-- w and h mean width and height.
function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end
   