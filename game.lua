require 'slam'

-- TODO
-- Boss mode, play boss music when there is a boss onscreen
-- Enemy spawner
-- Item boxes
-- Network play


local game = {}

local cron = require "cron"

local utilities = require("utilities")
local Hero = require("hero")
local Enemy = require("enemy")
local EnemyRed = require("enemy_red")

-- resources
local image1
local image1Quads = {}
local gradient
local music = {}
local sound = {}

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
  
  local instance = sound["shot"]:play()
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
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  gradient = utilities.gradientMesh("vertical",
        {1, 0, 0},
        {1, 1, 0},
        {1, 0, 0},
        {1, 1, 0},
        {1, 0, 0} 
  )
  
  image1 = love.graphics.newImage("art/gfx.png")
  
  -- blue
  image1Quads["blue"] = love.graphics.newQuad(0,0,16,16,image1:getDimensions())
  
  -- red
  image1Quads["red"] = love.graphics.newQuad(16,0,16,16,image1:getDimensions())
  image1Quads["red_damage"] = love.graphics.newQuad(16,16,16,16,image1:getDimensions())
  
  -- black
  image1Quads["black"] = love.graphics.newQuad(32,0,16,16,image1:getDimensions())
  image1Quads["black_damage1"] = love.graphics.newQuad(32,16,16,16,image1:getDimensions())
  image1Quads["black_damage2"] = love.graphics.newQuad(32,32,16,16,image1:getDimensions())
  
  -- purple
  image1Quads["purple"] = love.graphics.newQuad(0,64,48,16,image1:getDimensions())
  image1Quads["purple_damage1"] = love.graphics.newQuad(0,80,48,16,image1:getDimensions())
  
  -- boss
  image1Quads["boss"] = love.graphics.newQuad(48,0,32,32,image1:getDimensions())
  image1Quads["boss_damage"] = love.graphics.newQuad(48,32,32,32,image1:getDimensions())
  image1Quads["boss_damage2"] = love.graphics.newQuad(48,64,32,32,image1:getDimensions())
  
  --urn rocket
  image1Quads["urn"] = love.graphics.newQuad(0,64,16,16,image1:getDimensions())
  
  --red urn rocket
  image1Quads["urn_red"] = love.graphics.newQuad(16,64,16,16,image1:getDimensions())
  
  --shooter
  image1Quads["hero"] = love.graphics.newQuad(80,0,16,16,image1:getDimensions())
  
  --drone
  image1Quads["drone1"] = love.graphics.newQuad (96,0,16,16,image1:getDimensions())
  image1Quads["drone2"] = love.graphics.newQuad (96,16,16,16,image1:getDimensions())
  image1Quads["drone3"] = love.graphics.newQuad (96,32,16,16,image1:getDimensions())
  image1Quads["drone4"] = love.graphics.newQuad (96,48,16,16,image1:getDimensions())
  image1Quads["drone5"] = love.graphics.newQuad (96,64,16,16,image1:getDimensions())
  music["dramatic"] = love.audio.newSource("sounds/538828__puredesigngirl__dramatic-music.mp3", "stream")
  music["bossfight"] = love.audio.newSource("sounds/251415__tritus__fight-loop.ogg", "stream")
  --music[]:setVolume(0.9) -- 90% of ordinary volume
  --music[]:setPitch(0.5) -- one octave lower
  --music[]:setVolume(0.7)
  
  sound["shot"] = love.audio.newSource("sounds/344310__musiclegends__laser-shoot.wav", "static")
  sound["death"] = love.audio.newSource("sounds/448226__inspectorj__explosion-8-bit-01.wav", "static")
  
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
  hero = Hero(400, groundHeight-15, 150, image1, image1Quads["hero"]) 
  drone = Hero(400, groundHeight-15, 450, image1, image1Quads["drone1"]) 
  
  level = 1
  enemies = {}
  game.spawnEnemies(gameX, gameY)
end

local musicCurrent = ""
function game.spawnEnemies(gameX, gameY)
  --x, y, speed, health, score, image, quad, quad2
  
  if level == 1 then
    musicNew = "dramatic"
      
    -- blue
    for i=0,6 do
      local enemy = Enemy(i*90 + 100, 180, 10, 1, 3, sound["death"], image1, image1Quads["blue"])
      table.insert(enemies, enemy)
    end

    -- red
    for i=0,10 do
      local enemy = Enemy(i*70 + 30, 120, 3, 3, 1, sound["death"], image1, image1Quads["red"], image1Quads["red_damage"])
      --local enemy = EnemyRed(i*70 + 30, 120)
      table.insert(enemies, enemy)
    end
    
    -- purple
    for i=0,2 do
     local enemy2 = Enemy(i*250 + 100, 250, 8, 12, 10, sound["death"], image1, image1Quads["purple"], image1Quads["purple_damage1"])
     table.insert(enemies, enemy2)
    end
          
  elseif level == 2 then
    musicNew = "bossfight"
    
    -- boss
    local enemy = Enemy(gameX/2 - 32/2, 20, 4, 50, 10, sound["death"], image1, image1Quads["boss"], image1Quads["boss_damage"])
    table.insert(enemies, enemy) 
  
    -- black
    for i=0,2 do
      local enemy = Enemy(i*110 + 100, 40, 50, 3, 6, sound["death"], image1, image1Quads["black"], image1Quads["black_damage1"])
      table.insert(enemies, enemy)
    end
  
  else
    if(winTime < 0) then
      winTime = gameTime
    end
    flagStopped = true
    flagWin = true
  end
  
  if(musicNew ~= musicCurrent) then
    if(musicCurrent ~= "") then
      music[musicCurrent]:stop()
    end
    music[musicNew]:play()
    musicCurrent = musicNew
  end
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
    love.graphics.draw(gradient, 0, 0, 0, gameX, gameY)
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
