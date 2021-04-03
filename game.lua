require ('slam')
local flux = require ("flux/flux")

-- TODO
-- Network play
-- Sword and boom power-ups
-- Certain enemies have certain drops
-- Enemies fight back
-- Save progress (high score, killed rare enemy etc.)
-- Weapon specific sprites

local game = {}

local cron = require "cron"

local utilities = require("utilities")
local resource_manager = require("resource_manager")

local Hero = require("hero")
local Enemy = require("enemy")
local EnemyBlue= require("enemy_blue")
local EnemyRed = require("enemy_red")
local EnemySubBoss = require("enemy_sub_boss")
local EnemyBoss = require("enemy_boss")
local EnemyBlack = require("enemy_black")
local EnemyPurple = require("enemy_purple")
local EnemyUrn = require("enemy_urn")
local EnemyRedUrn = require("enemy_redurn")
local ShotNormal = require("shot_normal")
local ShotHoming = require("shot_homing")
local ShotShuriken = require("shot_shuriken")
local Powerup = require("powerup")

-- game objects
local shotStrings = { "Normal", "Triple", "Fast", "Homing", "Drone", "Boom", "Disable", "Shuriken" }
local hero
local drone
local shotObjects
local enemies
local enemiesNextWave
local powerups
local maxShotNumber
local curShotSpeed
local weaponType

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
  if #shotObjects >= maxShotNumber then 
    return 
  end
  if weaponType == 5 then
    local dx = drone:getX()+drone:getWidth()/2
    local dy = drone:getY()
    table.insert(shotObjects, ShotNormal(dx, dy, curShotSpeed))
  end
end
local timer = cron.every(droneShootPeriod, game.droneShoot)

function game.shoot()
  if #shotObjects >= maxShotNumber then 
    return 
  end
  totalShotCount = totalShotCount + 1
  
  local hx = hero:getX()+hero:getWidth()/2
  local hy = hero:getY()

  if (weaponType <= 7) then
    local disable = false
    if weaponType == 7 then
      disable = true
    end
    
    if(weaponType == 4) then
      table.insert(shotObjects, ShotHoming(hx, hy, curShotSpeed, disable))
    else
      table.insert(shotObjects, ShotNormal(hx, hy, curShotSpeed, disable))
    end
    
    if weaponType == 2 then
      table.insert(shotObjects, ShotNormal(hx+10, hy+10, curShotSpeed))
      table.insert(shotObjects, ShotNormal(hx-10, hy+10, curShotSpeed))
    end
  elseif (weaponType == 8) then
      local dir = (((totalShotCount % 2) * 2) - 1) -- -1/1
      table.insert(shotObjects, ShotShuriken(hx, hy, dir))
  end
  
  local instance = resource_manager.playSound("shot")
  instance:setPitch(.5 + love.math.random() * .5)
end

function game.chooseWeaponType(mode)
  if flagStopped then
    return
  end
  
  lastPowerupTime = gameTime
  
  mode = mode or love.math.random(1,8)
  weaponType = mode

  if weaponType == 1 then -- normal
    curShotSpeed = 100
    maxShotNumber = 5
  elseif weaponType == 2 then -- triple shot
    curShotSpeed = 130
    maxShotNumber = 9
  elseif weaponType == 3 then -- fast firing
    curShotSpeed = 750
    maxShotNumber = 3
  elseif weaponType == 4 then -- homing bullets
    curShotSpeed = 110
    maxShotNumber = 5
  elseif weaponType == 5 then -- drone
    curShotSpeed = 100
    maxShotNumber = 16
  elseif weaponType == 6 then -- boom
    curShotSpeed = 100
    maxShotNumber = 5
  elseif weaponType == 7 then -- disable
    curShotSpeed = 120
    maxShotNumber = 5
  elseif weaponType == 8 then -- glaive
    curShotSpeed = 0
    maxShotNumber = 7
  else
    curShotSpeed = 0
    maxShotNumber = 0
  end
end

function game.shotString(localWeaponType)
  if localWeaponType >= 1 and localWeaponType <= #shotStrings then
    return shotStrings[localWeaponType]
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

  game.chooseWeaponType(1)
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
      --table.insert(enemies, EnemyUrn(90 + 100, 180))
      table.insert(enemies, EnemySubBoss(gameX/2 - 40, 50))
     
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
    elseif level == 7 then
      music = "dramatic"
      for i=0,4 do
        table.insert(enemies, EnemyUrn(spreadEnemy(i,400,3,gameX), 25))
      end
    elseif level == 8 then
      music = "dramatic"
      enemyKillTrigger = 3
      for i=0,2 do
        table.insert(enemies, EnemyPurple(spreadEnemy(i,400,3,gameX), 100))
      end
      for i=0,4 do
        table.insert(enemies, EnemyRed(spreadEnemy(i,150,5,gameX), 25))
      end
      for i=0,0 do
        table.insert(enemiesNextWave, EnemyBlack(spreadEnemy(i,200,1,gameX), 100))
      end
    elseif level == 9 then
      music = "dramatic"
      enemyKillTrigger = 2
      for i=0,2 do
        table.insert(enemies, EnemyPurple(spreadEnemy(i,400,3,gameX), 100))
      end
      for i=0,4 do
        table.insert(enemiesNextWave, EnemyUrn(spreadEnemy(i,400,3,gameX), 0))
      end
      for i=0,7 do
        table.insert(enemiesNextWave, EnemyRed(spreadEnemy(i,200,8,gameX), 0))
      end
     elseif level == 10 then
      music = "bossfight"
      enemyKillTrigger = 3
      table.insert(enemies, EnemyBoss(gameX/2 - 32/2, 20) ) 
      for i=0,1 do
        table.insert(enemies, EnemyUrn(spreadEnemy(i,500,2,gameX), -25))
        table.insert(enemies, EnemyUrn(spreadEnemy(i,450,2,gameX), -50))
        table.insert(enemies, EnemyUrn(spreadEnemy(i,400,2,gameX), -75))
        table.insert(enemies, EnemyUrn(spreadEnemy(i,350,2,gameX), -100))
      end
    elseif level == 11 then
      enemyKillTrigger = 6
      table.insert(enemies, EnemyRedUrn(gameX/2 - 32/2, 20))
      table.insert(enemiesNextWave, EnemyBlack(gameX/2 - 32/2, 20) ) 
      
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
  if numEnemies == 1 then
    return gameX/2
  end
  return i*((gameX - border)/(numEnemies-1)) + border/2
end

function game.update(dt, gameX, gameY)
  if flagStopped then
    return
  end
  
  gameTime = gameTime + dt
  timer:update(dt)
  
  hero:update(dt, game.getHeroDirection(), gameX, gameY)
  if weaponType == 5 then
    local dir = utilities.findNearestEnemyX(drone:getX() + drone:getWidth()/2, enemies)
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
    
    -- hero and powerup
    if utilities.checkBoxCollision(hero, powerup) then
      table.insert(remPowerup, ii)
      game.chooseWeaponType(powerup:getType())
    end
  end

  -- update the shots
  for i,shot in ipairs(shotObjects) do
    if shot:update(dt, gameX, gameY, enemies) then
      table.insert(remShotObject, i)
    end
    
    -- check for collision with enemies
    for ii,enemy in ipairs(enemies) do
      if utilities.checkBoxCollision(shot, enemy) then    
        if(not shot:getInert() and enemy:hit(shot:getDisable())) then
          -- mark that enemy for removal
          table.insert(remEnemy, ii)
          score = score + enemy:getScore()
          
          game.spawnPowerup(enemy, powerups)
          
          if enemy:is(EnemyUrn) then
            game.destroyUrn(enemy, enemies)
          end

        end
        shot:hit() -- ensure that it won't do damage for another short period
        
        -- mark the shot to be removed
        if shot:getRemoveOnImpact() then
          table.insert(remShotObject, i)
        end
      end
    end
  end

  -- remove the marked enemies and shots. work backwards to avoid removing the wrong ones on multiple removal
  -- there are more efficient algos for this that aren't O(n^2) from repeated calls to table.remove()
  for i,enemy in utilities.ripairs(remEnemy) do
    table.remove(enemies, enemy)
    totalEnemiesKilledThisLevel = totalEnemiesKilledThisLevel + 1
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
    if utilities.checkBoxCollision(hero,enemy) then
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
    end
    enemiesNextWave = {}
  end
  
  -- secret spawn
  local rare = love.math.random(1,500/dt)
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

function game.getHeroDirection()
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
  
  return dir
end

function game.destroyUrn(enemy, enemies)
  local swarmNum = 10 
  if enemy:is(EnemyRedUrn) then
    swarmNum = 7
  end
    
  for i=0,(swarmNum-1) do
    local enemy2
    if enemy:is(EnemyRedUrn) then
      enemy2 = EnemyRed(enemy:getX(), enemy:getY())
    else
      enemy2 = EnemyBlue(enemy:getX(), enemy:getY())
    end
    flux.to(enemy2, 2, { x = enemy:getX() + 120*math.cos(i * 2*math.pi / swarmNum), 
                         y = enemy:getY() + 80*math.sin(i * 2*math.pi / swarmNum) }):ease("backout")
    table.insert(enemies, enemy2)
  end
end

function game.spawnPowerup(enemy, powerups)
  local max = #shotStrings * math.ceil(1.0/powerupChance)
  local powerupType = love.math.random(1,max)
  if powerupType <= #shotStrings then
    local powerup = Powerup(enemy:getX() + enemy:getWidth()/2, enemy:getY(), 150, powerupType)
    table.insert(powerups, powerup)
  end
end
          
function game.draw(gameX, gameY)  -- let's draw a background

  local hour = tonumber(os.date("%H"))
   if hour <=10 and hour >= 7 then
        love.graphics.setColor(0.45,0.2,0.07,1)
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
  if weaponType == 5 then
    drone:draw()
  end
  hero:draw()
   
  -- draw powerups
  for i,powerup in ipairs(powerups) do
    powerup:draw()
  end
  
   -- draw shots
  for i,shot in ipairs(shotObjects) do
    shot:draw()
  end
  
  -- draw overlay
  if(not flagStopped) then
     
    love.graphics.setColor(1,1,1,1)
    local border = 10
    love.graphics.printf( "Level: " .. level, gameX-250-border, 10, 400/1.8, "right") 
    love.graphics.printf( "Shot: " .. game.shotString(weaponType), border, 50, 400/1.8, "left", -0.1, 1.8, 1.6) 
    love.graphics.printf( "Score: " .. score, gameX-400-border, 10, 400/1.8, "right", 0.1, 1.8, 1.6) 
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS( )), 10, 10)
       
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
  local fillLevel = (#shotObjects / maxShotNumber)
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