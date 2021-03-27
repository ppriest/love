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

-- game objects
local shots
local hero
local drone
local enemies = {}
local maxShotNumber
local shotSpeed
local shotType

-- game state
local level
local score
local flagStopped
local flagGameover
local flagWin
local groundHeight = 540
local winTime
local gameTime

local easyMode = false
local startLevel = 1


function game.shoot()
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
    shotDrone.sp = shotSpeed
    table.insert(shots, shotDrone)
  end
  
  local instance = resource_manager.playSound("shot")
  instance:setPitch(.5 + math.random() * .5)
end

function game.chooseShotType(mode)
  if flagStopped then
    return
  end
  
  mode = mode or love.math.random(1,6)
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
  else
    shotSpeed = 0
    maxShotNumber = 0
  end
end

function game.shotString(localShotType)
  local shotStrings = { "Normal", "Triple", "Fast", "Homing", "Drone", "Sniper" }
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

  shots = {} -- holds our fired shots
  game.chooseShotType(1)
  hero = Hero(400, groundHeight-15, 150, "hero") 
  drone = Hero(400, groundHeight-15, 450, "drone1") 
  
  level = startLevel
  enemies = {}
  game.spawnEnemies(gameX, gameY)
end

function game.spawnEnemies(gameX, gameY)
  --x, y, speed, health, score, image, quad, quad2
  
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
        
      -- blue
      for i=0,6 do
        local enemy = Enemy(i*90 + 100, 180, 10, 1, 3, "death", "blue")
        table.insert(enemies, enemy)
      end

      -- red
      for i=0,10 do
        local enemy = EnemyRed(i*70 + 30, 120)
        table.insert(enemies, enemy)
      end
      
      -- purple
      for i=0,2 do
       local enemy2 = EnemyPurple(i*250 + 100, 250)
       table.insert(enemies, enemy2)
      end
            
    elseif level == 2 then
      music = "bossfight"
      
      local enemy = EnemyBoss(gameX/2 - 32/2, 20)      
      table.insert(enemies, enemy) 
    
      -- black
      for i=0,2 do
        local enemy = EnemyBlack(i*110 + 100, 40)
        table.insert(enemies, enemy)
      end
    
    else
      if(winTime < 0) then
        winTime = gameTime
      end
      flagStopped = true
      flagWin = true
    end
  end
  
  resource_manager.playMusic(music)
end

local timer = cron.every(10, game.chooseShotType)

function game.update(dt, gameX, gameY)
  gameTime = gameTime + dt
  timer:update(dt)
  
  if flagStopped then
    return
  end

  -- keyboard actions for our hero
  local dir = 0
  if love.keyboard.isDown("left") then
    dir = -1
  elseif love.keyboard.isDown("right") then
    dir = 1
  end
  hero:update(dt, dir, gameX, gameY)
  if shotType == 5 then
    drone:update(dt, dir, gameX, gameY)
  end

  local remEnemy = {}
  local remShot = {}

  -- update the shots
  for i,shot in ipairs(shots) do
    -- move them up up up
    shot.y = shot.y - dt*shot.sp

    if(shotType == 4) then 
      local enemyDist = 9999
      local enemyDir = 0
      local enemyX = shot.x

      -- find closest
      --!strict
      for ii,enemy in ipairs(enemies) do
        if ((math.abs(shot.x - enemy.x) < enemyDist) or enemyDist == 9999) then
          enemyDist = math.abs(shot.x - enemy.x)
          enemyX = enemy:getX() + enemy:getWidth()/2
        end
      end
      
      if(shot.x > enemyX) then
        enemyDir = -1
      elseif (shot.x < enemyX) then
        enemyDir = 1
      end
	  
	    -- approach nearest in an arc
      local factor = ((500 - shot.y)/1000)
      shot.x = shot.x + dt*shot.sp*enemyDir*factor
    end

    -- mark shots that are not visible for removal
    if shot.y < 0 then
      table.insert(remShot, i)
    end

    -- check for collision with enemies
    for ii,enemy in ipairs(enemies) do
      if utilities.checkBoxCollision(shot.x,shot.y,2,5,enemy:getX(),enemy:getY(),enemy:getWidth(),enemy:getHeight()) then
        if(enemy:hit()) then
          -- mark that enemy for removal
          table.insert(remEnemy, ii)
          score = score + enemy:getScore()
        end
        -- mark the shot to be removed
        table.insert(remShot, i)
      end
    end
  end

  -- remove the marked enemies and shots
  for i,enemy in ipairs(remEnemy) do
    table.remove(enemies, enemy)
  end
  for i,shot in ipairs(remShot) do
    table.remove(shots, shot)
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
