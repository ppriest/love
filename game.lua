require ('slam')
local flux = require ("flux/flux")

-- TODO
-- Network play
-- Sword and boom power-ups
-- Certain enemies have certain drops
-- Enemies fight back
--save progress (high score, killed rare enemy ecs.)

local game = {}

local cron = require "cron"

local utilities = require("utilities")
local resource_manager = require("resource_manager")

local Hero = require("hero")
local Enemy = require("enemy")
local EnemyBlue= require("enemy_blue")
local EnemyRed = require("enemy_red")
local EnemyBoss = require("enemy_boss")
local EnemyBlack = require("enemy_black")
local EnemyPurple = require("enemy_purple")
local EnemyUrn = require("enemy_urn")
local ShotObject = require("shot_object")
local Powerup = require("powerup")

-- game objects
local shotStrings = { "Normal", "Triple", "Fast", "Homing", "Drone", "Boom", "Disable", "Shuriken" }
local hero
local drone
local shots
local shotObjects
local enemies
local enemiesNextWave
local powerups
local maxShotNumber
local shotSpeed
local shotType

-- game state
local flagStopped
local flagGameover
local flagWin
local flagPaused
local groundHeight = 540
local winTime
local gameTime
local powerupTime
local score
local level
local music
local totalShotCount
local totalEnemiesKilledThisLevel
local enemyKillTrigger

-- config
local joystickDeadzone = 0.20
local easyMode = false
local startLevel = 1
local powerupChance = 0.15
local droneShootPeriod = 0.6 -- seconds
local powerupDuration = 10

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
local timer = cron.every(droneShootPeriod, game.droneShoot)

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
  
  lastPowerupTime = gameTime
  
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
  elseif shotType == 6 then -- boom
    shotSpeed = 100
    maxShotNumber = 5
  elseif shotType == 7 then -- disable
    shotSpeed = 120
    maxShotNumber = 5
  elseif shotType == 8 then -- glaive
    shotSpeed = 0
    maxShotNumber = 7
  else
    shotSpeed = 0
    maxShotNumber = 0
  end
end

function game.shotString(localShotType)
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

function game.incLevel(gameX, gameY, incLevel)
  local newLevel = level + incLevel
  game.reload(gameX, gameY, newLevel)
end

function game.reload(gameX, gameY, newLevel)
  level = newLevel or startLevel
  flagStopped = false
  flagGameover = false
  flagWin = false
  flagPaused = false
  score = 0
  winTime = -1
  gameTime = 0
  lastPowerupTime = 0
  totalShotCount = 0

  shots = {} -- holds our fired shots
  game.chooseShotType(1)
  hero = Hero(400, groundHeight-15, 150, "hero") 
  drone = Hero(400, groundHeight-15, 450, "drone1") 
  
  enemies = {}
  enemiesNextWave = {}
  powerups = {}
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
      table.insert(enemies, EnemyUrn(90 + 100, 180))
      
    elseif level == 2 then
      music = "bossfight"
      table.insert(enemies, EnemyBoss(gameX/2 - 32/2, 20))
      
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
        table.insert(enemies, EnemyBlue(i*90 + 100, 180))
      end
            
    elseif level == 2 then
      music = "dramatic"
      for i=0,10 do
        table.insert(enemies, EnemyRed(i*70 + 30, 120))
      end
      for i=0,12 do
        table.insert(enemies, EnemyBlue(i*45 + 100, 180))
      end
      
    elseif level == 3 then
      music = "dramatic"
      for i=0,1 do
        table.insert(enemies, EnemyBlack(i*250 + 250, 25))
      end
      
    elseif level == 4 then
      music = "dramatic"
      enemyKillTrigger = 15
      for i=0,11 do
        table.insert(enemies, EnemyBlue(i*((gameX - 100.0)/12) + 50, 25))
      end
      for i=0,9 do
        table.insert(enemies, EnemyBlue(i*((gameX - 100.0)/10) + 50, 50))
      end
      for i=0,2 do
        table.insert(enemiesNextWave, EnemyBlack(gameX - (i*110 + 100), 40))
      end
      
    elseif level == 5 then
      music = "bossfight"
      table.insert(enemies, EnemyBoss(gameX/2 - 32/2, 20) ) 
      for i=0,6 do
        table.insert(enemies, EnemyBlue(i*90 + 100, 100))
      end
    elseif level == 6 then
      music = "dramatic"
      for i=0,2 do
        table.insert(enemies, EnemyUrn(spreadEnemy(i,400,3,gameX), 100))
      end
      
    elseif level == 15 then
      music = "bossfight"
      enemyKillTrigger = 3
      table.insert(enemies, EnemyBoss(gameX/2 - 32/2, 20) ) 
      for i=0,2 do
        table.insert(enemies, EnemyBlack(i*110 + 100, 40))
      end
      for i=0,2 do
        table.insert(enemiesNextWave, EnemyBlack(gameX - (i*110 + 100), 40))
      end
   
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

function spreadEnemy(i,border,numEnemies,gameX)
  return i*((gameX - border)/(numEnemies-1)) + border/2
end

-- for an object at X location objectX, find whether the nearest enemy (horizontally) is left/right
local function findNearestEnemyX(objectX)
  local enemyDist = 9999
  local enemyDir = 0
  local enemyX = objectX

  -- find closest

  for ii,enemy in ipairs(enemies) do
    local thisEnemyX = enemy:getX() + enemy:getWidth()/2
    if ((math.abs(objectX - thisEnemyX) < enemyDist) or enemyDist == 9999) then
      enemyDist = math.abs(objectX - thisEnemyX)
      enemyX = thisEnemyX
    end
  end

  if(enemyDist < 3) then
    -- stop oscillation
    enemyDir = 0
  elseif(objectX > enemyX) then
    enemyDir = -1
  elseif (objectX < enemyX) then
    enemyDir = 1
  end
  
  return enemyDir
end

function game.update(dt, gameX, gameY)
  if flagPaused then
    return
  end
  
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
    local dir = findNearestEnemyX(drone:getX() + drone:getWidth()/2)
    drone:update(dt, dir, gameX, gameY)
  end

  local remPowerup = {}
  local remEnemy = {}
  local remShot = {}
  local remShotObject = {}
  
  -- powerups
  for ii,powerup in ipairs(powerups) do
    if powerup:update(dt, groundHeight) then
      table.insert(remPowerup, ii)
    end
    
    if utilities.checkBoxCollisionC(hero, powerup) then
      table.insert(remPowerup, ii)
      game.chooseShotType(powerup:getType())
    end
  end

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
          
          game.spawnPowerup(enemy, powerups)
          
          if enemy:is(EnemyUrn) then
            game.destroyUrn(enemy, enemies)
          end
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
        if(not shot:getInert() and enemy:hit(shot.disable)) then
          -- mark that enemy for removal
          table.insert(remEnemy, ii)
          score = score + enemy:getScore()
          
          game.spawnPowerup(enemy, powerups)
          
          if enemy:is(EnemyUrn) then
            game.destroyUrn(enemy, enemies)
          end

        end
        shot:hit() -- ensure that it won't do damage for another short period
      end
    end
  end

  -- remove the marked enemies and shots. work backwards to avoid removing the wrong ones on multiple removal
  -- there are more efficient algos for this that aren't O(n^2) from repeated calls to table.remove()
  for i,enemy in utilities.ripairs(remEnemy) do
    table.remove(enemies, enemy)
    totalEnemiesKilledThisLevel = totalEnemiesKilledThisLevel + 1
  end
  for i,shot in utilities.ripairs(remShot) do
    table.remove(shots, shot)
  end    
  for i,shot in utilities.ripairs(remShotObject) do
    table.remove(shotObjects, shot)
  end    
  for i,powerup in utilities.ripairs(remPowerup) do
    table.remove(powerups, powerup)
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
  if (totalEnemiesKilledThisLevel >= enemyKillTrigger) then
    for i,enemy in ipairs(enemiesNextWave) do
      table.insert(enemies, enemy)
      enemiesNextWave[i] = nil
    end
  end
  
  -- secret spawn
  local rare = math.random(1,100/dt)
  if rare == 1 then
    for i=0,6 do
        local enemy = EnemyBlue(i*90 + 100, 180)
        table.insert(enemies, enemy)
    end
  end
  
  -- check for win condition
  if #enemies == 0 then
    level = level + 1
    game.spawnEnemies(gameX, gameY)
  end

end

function game.destroyUrn(enemy, enemies)
  local swarmNum = 10
  for i=0,(swarmNum-1) do
    local enemy2 = EnemyBlue(enemy:getX(), enemy:getY()-20)
    flux.to(enemy2, 2, { x = enemy:getX() + 120*math.cos(i * 2*math.pi / swarmNum), 
                         y = enemy:getY() + 80*math.sin(i * 2*math.pi / swarmNum) }):ease("backout")
    table.insert(enemies, enemy2)
  end
end

function game.spawnPowerup(enemy, powerups)
  local max = #shotStrings * math.ceil(1.0/powerupChance)
  local powerupType = math.random(1,max)
  if powerupType <= #shotStrings then
    local powerup = Powerup(enemy:getX() + enemy:getWidth()/2, enemy:getY(), 150, powerupType)
    table.insert(powerups, powerup)
  end
end
          
function game.draw(gameX, gameY)  -- let's draw a background

  local hour = tonumber(os.date("%H"))
   if hour <=10 and hour >= 7 then
        love.graphics.setColor(0.18,0,0.03,1)
  elseif hour <=6 or hour >= 21 then
        love.graphics.setColor(0,0,0,1)
  elseif hour <=20 and hour >= 18 then
        love.graphics.setColor(0.1,0,0.1,1)
  elseif hour <=17 and hour >= 11 then
        love.graphics.setColor(0.1,0.05,0.05,1)
  end
  love.graphics.rectangle("fill", 0, 0, gameX, gameY)
  
  if(flagWin) then
    local alpha = (gameTime-winTime)/5
    love.graphics.setColor(1,1,1,alpha) 
    love.graphics.draw(resource_manager.getGradient(), 0, 0, 0, gameX, gameY)
  end

  -- draw enemies
  for i,enemy in ipairs(enemies) do
    enemy:draw()
  end
  
  -- draw some ground _over_ the enemies
  love.graphics.setColor(0,0.6,0,1.0)
  love.graphics.rectangle("fill", 0, groundHeight, gameX, gameY-groundHeight)
  
  -- draw hero
  if shotType == 5 then
    drone:draw()
  end
  hero:draw()
   
  -- draw powerups
  for i,powerup in ipairs(powerups) do
    powerup:draw()
  end
   
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
    love.graphics.printf( "Level: " .. level, gameX-250-border, 10, 400/1.8, "right") 
    love.graphics.printf( "Shot: " .. game.shotString(shotType), border, 50, 400/1.8, "left", -0.1, 1.8, 1.6) 
    love.graphics.printf( "Score: " .. score, gameX-400-border, 10, 400/1.8, "right", 0.1, 1.8, 1.6) 
       
    game.drawGauge(gameX, gameY)
    
  end
  
  if flagPaused then
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf( 'Paused!', (gameX - 3*200)/2, gameY/3, 200, "center", 0, 3, 3)
    love.graphics.printf( 'Score: '.. score .. '\n\nPress \'P\' to Resume', (gameX - 2*250)/2, gameY/3 + 90, 250, "center", 0, 2, 2)
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

function game.drawGauge(gameX, gameY)
  local fillLevel = ((#shots + #shotObjects) / maxShotNumber)
  if(fillLevel > 1.0) then
    fillLevel = 1.0
  end
    
  if(fillLevel > 0.7) then
    love.graphics.setColor(0.6,0,0,1)
  else
    love.graphics.setColor(0,1,0,1)
  end
  love.graphics.rectangle("fill", 10, (gameY-70) - (50 * fillLevel), 25, 50 * fillLevel) 
  if(fillLevel > 0.95) then
    love.graphics.setColor(1.0,0,0,0.15)
    love.graphics.printf( 'Overheat!', (gameX - 3*200)/2, gameY/3, 200, "center", 0, 3, 3)
    love.graphics.setColor(1.0,0,0,1)
  else
    love.graphics.setColor(0.7,0.7,0.7,1)
  end
  love.graphics.rectangle("line", 10, gameY-120, 25, 50)
end

function game.togglePause()
  if not flagGameover and not flagWin then
    flagStopped = not flagPaused
    flagPaused = not flagPaused
  end
end

return game