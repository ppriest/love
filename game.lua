require 'slam'

-- TODO
-- Boss mode, play boss music when there is a boss onscreen
-- Enemy spawner
-- Item boxes
-- Network play
-- Mess with shaders for final effects, and also https://love2d.org/forums/viewtopic.php?t=79617
-- Joystick support


local game = {}

local cron = require "cron"

local utilities = require("utilities")
local resource_manager = require("resource_manager")
local Hero = require("hero")
local Enemy = require("enemy")
local EnemyRed = require("enemy_red")
local EnemyBoss = require("enemy_boss")
local EnemyBlack = require("enemy_black")
local EnemyPurple = require("enemy_purple")
local ShotObject = require("shot_object")

-- game objects
local hero
local drone
local shots
local shotObjects
local enemies
local enemiesNextWave
local maxShotNumber
local shotSpeed
local shotType

-- game state
local flagStopped
local flagGameover
local flagWin
local groundHeight = 540
local winTime
local gameTime
local score
local level
local totalShotCount
local totalEnemiesKilledThisLevel
local enemyKillTrigger

-- config
local joystickDeadzone = 0.20
local easyMode = false
local startLevel = 1

function game.droneShoot()
  if (#shots + #shotObjects) >= maxShotNumber then return end
     if shotType == 5 then
      local dx = drone:getX()+drone:getWidth()/2
      local dy = drone:getY()
      
      local shotDrone = {}
      shotDrone.x = dx
      shotDrone.y = dy
      shotDrone.sp = shotSpeed
      shotDrone.disable = false
      table.insert(shots, shotDrone)
    end
end

function game.shoot()
  if (#shots + #shotObjects) >= maxShotNumber then return end
  totalShotCount = totalShotCount + 1
  
  local hx = hero:getX()+hero:getWidth()/2
  local hy = hero:getY()

  if (shotType <= 7) then
    local shot = {}
    shot.x = hx
    shot.y = hy
    shot.sp = shotSpeed
    shot.disable = false
    if shotType == 7 then
      shot.disable = true
    end
    table.insert(shots, shot)
    
    if shotType == 2 then
     local shot2 = {}
     shot2.x = hx+10
     shot2.y = hy+10
     shot2.sp = shotSpeed
     shot2.disable = false
     table.insert(shots, shot2)
     
     local shot3 = {}
     shot3.x = hx-10
     shot3.y = hy+10
     shot3.sp = shotSpeed
     shot3.disable = false
     table.insert(shots, shot3)
    end
    
 
    
  elseif (shotType == 8) then
      local dir = (((totalShotCount % 2) * 2) - 1) -- -1/1
      local shotObject = ShotObject(hx, hy, dir)
      table.insert(shotObjects, shotObject)
  end
  
  local instance = resource_manager.playSound("shot")
  instance:setPitch(.5 + math.random() * .5)
end

function game.chooseShotType(mode)
  if flagStopped then
    return
  end
  
  mode = mode or love.math.random(1,8)
  shotType = mode

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
  elseif shotType == 7 then -- disable
    shotSpeed = 120
    maxShotNumber = 3
  elseif shotType == 8 then -- glaive
    shotSpeed = 0
    maxShotNumber = 3
  else
    shotSpeed = 0
    maxShotNumber = 0
  end
end

function game.shotString(localShotType)
  local shotStrings = { "Normal", "Triple", "Fast", "Homing", "Drone", "Sniper", "Disable", "Glaive" }
  if localShotType >= 1 and localShotType <= #shotStrings then
    return shotStrings[localShotType]
  end
  return "XXX"
end

function game.load(gameX, gameY)
  resource_manager.load()
  love.graphics.setNewFont("fonts/Deadly Advance.ttf", 20)
  game.reload(gameX, gameY)
end

function game.reload(gameX, gameY)
  flagStopped = false
  flagGameover = false
  flagWin = false
  score = 0
  winTime = -1
  gameTime = 0
  totalShotCount = 0

  shots = {} -- holds our fired shots
  game.chooseShotType(1)
  hero = Hero(400, groundHeight-15, 150, "hero") 
  drone = Hero(400, groundHeight-15, 450, "drone1") 
  
  level = startLevel
  enemies = {}
  enemiesNextWave = {}
  game.spawnEnemies(gameX, gameY)
  shotObjects = {}
end

function game.spawnEnemies(gameX, gameY)
  --x, y, speed, health, score, image, quad, quad2
  totalEnemiesKilledThisLevel = 0
  enemyKillTrigger = 0
  if easyMode then
    if level == 1 then
      music = "dramatic"
      local enemy = Enemy(90 + 100, 180, 10, 1, 3, "death", "blue")
      table.insert(enemies, enemy)
    elseif level == 2 then
      music = "bossfight"
      local enemy = EnemyBoss(gameX/2 - 32/2, 20)      
      table.insert(enemies, enemy)
    else
      if(winTime < 0) then
        winTime = gameTime
      end
      flagStopped = true
      flagWin = true
    end
  
  else
    if level == 1 then
      music = "dramatic"
        
      for i=0,6 do
        local enemy = Enemy(i*90 + 100, 180, 10, 1, 3, "death", "blue")
        table.insert(enemies, enemy)
      end

      for i=0,10 do
        local enemy = EnemyRed(i*70 + 30, 120)
        table.insert(enemies, enemy)
      end
      
      for i=0,2 do
       local enemy2 = EnemyPurple(i*250 + 100, 250)
       table.insert(enemies, enemy2)
      end
            
    elseif level == 2 then
      music = "bossfight"
      
      local enemy = EnemyBoss(gameX/2 - 32/2, 20)      
      table.insert(enemies, enemy) 
    
      for i=0,2 do
        local enemy = EnemyBlack(i*110 + 100, 40)
        table.insert(enemies, enemy)
      end
      
      for i=0,2 do
        local enemy = EnemyBlack(gameX - (i*110 + 100), 40)
        table.insert(enemiesNextWave, enemy)
      end
      enemyKillTrigger = 3
   
    else
      -- music = "win"
      if(winTime < 0) then
        winTime = gameTime
      end
      flagStopped = true
      flagWin = true
    end
  end
  
  resource_manager.playMusic(music)
end

-- for an object at X location objectX, find whether the nearest enemy (horizontally) is left/right
local function findNearestEnemyX(objectX)
  local enemyDist = 9999
  local enemyDir = 0
  local enemyX = objectX

  -- find closest

  for ii,enemy in ipairs(enemies) do
    if ((math.abs(objectX - enemy:getX()) < enemyDist) or enemyDist == 9999) then
      enemyDist = math.abs(objectX - enemy:getX())
      enemyX = enemy:getX() + enemy:getWidth()/2
    end
  end

  if(enemyDist < 10) then
    -- stop oscillation
    enemyDir = 0
  elseif(objectX > enemyX) then
    enemyDir = -1
  elseif (objectX < enemyX) then
    enemyDir = 1
  end
  
  return enemyDir
end


local timer = cron.every(0.6, game.droneShoot)
--local timer = cron.every(10, game.chooseShotType)

function game.update(dt, gameX, gameY)
  gameTime = gameTime + dt
  timer:update(dt)
  
  if flagStopped then
    return
  end
  
  local dir = 0
  
  -- sticks
  local joysticks = love.joystick.getJoysticks()
  for i,joystick in ipairs(joysticks) do
    if joystick:isGamepad() then
      local value = joystick:getGamepadAxis('leftx')
      if math.abs(value) > joystickDeadzone then
        --dir = math.ceil(value)
        dir = value
      end
    end
  end
  
  -- keyboard actions for our hero
  if love.keyboard.isDown("left") then
    dir = -1
  elseif love.keyboard.isDown("right") then
    dir = 1
  end
  
  hero:update(dt, dir, gameX, gameY)
  if shotType == 5 then
    local dir = findNearestEnemyX(drone:getX())
    drone:update(dt, dir, gameX, gameY)
  end

  local remEnemy = {}
  local remShot = {}
  local remShotObject = {}

  -- update the shots
  for i,shot in ipairs(shots) do
    -- move the bullets
    shot.y = shot.y - dt*shot.sp

    if(shotType == 4) then 
	    -- approach nearest in an arc
      local enemyDir = findNearestEnemyX(shot.x)
      local factor = ((500 - shot.y)/1000)
      shot.x = shot.x + dt*shot.sp*enemyDir*factor
    end

    -- mark shots that are not visible for removal
    if (shot.y < 0 or shot.y >= gameY or shot.x < 0 or shot.x > gameX) then
      table.insert(remShot, i)
    end

    -- check for collision with enemies
    for ii,enemy in ipairs(enemies) do
      if utilities.checkBoxCollision(shot.x,shot.y,2,5,enemy:getX(),enemy:getY(),enemy:getWidth(),enemy:getHeight()) then
        if(enemy:hit(shot.disable)) then
          -- mark that enemy for removal
          table.insert(remEnemy, ii)
          score = score + enemy:getScore()
        end
        -- mark the shot to be removed
        table.insert(remShot, i)
      end
    end
  end
  
  -- fancy shots
  for i,shot in ipairs(shotObjects) do
    if shot:update(dt, gameX, gameY) then
      table.insert(remShotObject, i)
    end
    
        -- check for collision with enemies
    for ii,enemy in ipairs(enemies) do
      if utilities.checkBoxCollisionC(shot, enemy) then
        if(enemy:hit(shot.disable)) then
          -- mark that enemy for removal
          table.insert(remEnemy, ii)
          score = score + enemy:getScore()
        end
      end
    end

  end

  -- remove the marked enemies and shots
  for i,enemy in ipairs(remEnemy) do
    table.remove(enemies, enemy)
    totalEnemiesKilledThisLevel = totalEnemiesKilledThisLevel + 1
  end
  for i,shot in ipairs(remShot) do
    table.remove(shots, shot)
  end    
  for i,shot in ipairs(remShotObject) do
    table.remove(shotObjects, shot)
  end    
  
  -- update the enemies' positions
  for i,enemy in ipairs(enemies) do
    enemy:update(dt)

    -- check for collision between enemy and hero
    if utilities.checkBoxCollisionC(hero,enemy) then
      flagStopped = true
      flagGameover = true
    end

    -- check for collision with ground
    if enemy:getY() > groundHeight then
      flagStopped = true
      flagGameover = true
    end
  end
  
  -- spawn more enemies
  if (totalEnemiesKilledThisLevel == enemyKillTrigger) then
    for i,enemy in ipairs(enemiesNextWave) do
      table.insert(enemies, enemy)
      enemiesNextWave[i] = nil
    end
  end
  
  -- check for win condition
  if #enemies == 0 then
    level = level + 1
    game.spawnEnemies(gameX, gameY)
  end

end

function game.draw(gameX, gameY)  -- let's draw a background

  love.graphics.setColor(0.08,0,0.08,1.0)
  love.graphics.rectangle("fill", 0, 0, gameX, gameY)
  if(flagWin) then
    local alpha = (gameTime-winTime)/5
    love.graphics.setColor(1,1,1,alpha) 
    love.graphics.draw(resource_manager.getGradient(), 0, 0, 0, gameX, gameY)
  end

  -- let's draw our enemies
  for i,enemy in ipairs(enemies) do
    enemy:draw()
  end
  
  -- let's draw some ground _over_ the enemies
  love.graphics.setColor(0,0.6,0,1.0)
  love.graphics.rectangle("fill", 0, groundHeight, gameX, gameY-groundHeight)
  
  -- let's draw our hero
  if shotType == 5 then
    drone:draw()
  end
  hero:draw()
   
   -- shots on top of actors
  love.graphics.setColor(0.5,0.5,0.5,1)
  for i,v in ipairs(shots) do
    love.graphics.rectangle("fill", v.x, v.y, 2, 5)
  end 
  
   -- draw fancy shots
  for i,shot in ipairs(shotObjects) do
    shot:draw()
  end
  
  -- draw overlay
  if(not flagStopped) then
    love.graphics.setColor(1,1,1,1)
    local border = 10
    love.graphics.printf( "Shot: " .. game.shotString(shotType), border, 50, 400/1.8, "left", -0.1, 1.8, 1.6) 
    love.graphics.printf( "Score: " .. score, gameX-400-border, 10, 400/1.8, "right", 0.1, 1.8, 1.6) 
  end
  
  if flagGameover then
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf( 'Game Over!', (gameX - 3*200)/2, gameY/3, 200, "center", 0, 3, 3)
    love.graphics.printf( 'Score: '.. score .. '\n\nPress \'R\' to Try Again', (gameX - 2*250)/2, gameY/3 + 90, 250, "center", 0, 2, 2)
  end
  if flagWin then
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf( 'You Win!', (gameX - 3*200)/2, gameY/3, 200, "center", 0, 3, 3)
    love.graphics.printf( 'Score: '.. score .. '\n\nPress \'R\' to Try Again', (gameX - 2*250)/2, gameY/3 + 90, 250, "center", 0, 2, 2)
  end

end

return game
