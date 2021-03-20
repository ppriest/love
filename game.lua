local game = {}
local cron = require "cron"

local utilities = require("utilities")
local Hero = require("hero")

-- resources
local enemyImage
local rainbow

-- game objects
local shots
local hero
local drone
local enemies = {}
local hardEnemies = {}
local maxShotNumber
local shotSpeed
local shotType
local score
local flagStopped = false
local flagGameover = false
local flagWin = false
local ground_height = 465

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

function game.load()
  rainbow = utilities.gradientMesh("horizontal",
        {1, 0, 0},
        {1, 1, 0},
        {0, 1, 0},
        {0, 1, 1},
        {0, 0, 1},
        {1, 0, 0}
  )  
  game.chooseShotType(1)
  
  enemyImage = love.graphics.newImage("sophie.png")

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
    table.insert(hardEnemies, enemy)
  end
end

local timer = cron.every(10, game.chooseShotType)

function game.update(dt, gameX, gameY)
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
      --!strict
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
    for ii,vv in ipairs(hardEnemies) do
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
    table.remove(hardEnemies, v)
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
  for i,v in ipairs(hardEnemies) do
    -- let them fall down slowly
    v.y = v.y + 600*dt

    -- check for collision with ground
    if v.y > ground_height then
      -- you lose!!!
      flagStopped = true
      flagGameover = true
    end
  end
  
  -- check for win condition
  if #hardEnemies == 0 and #enemies == 0 then
      flagStopped = true
      flagWin = true
  end

end

function game.draw(gameX, gameY)  -- let's draw a background
  if(flagWin) then
    love.graphics.setColor(1,1,1,1) 
    love.graphics.draw(rainbow, 0, 0, 0, gameX, gameY)
  else
    love.graphics.setColor(0,0,0.1,1.0)
    love.graphics.rectangle("fill", 0, 0, gameX, gameY)
  end

  -- let's draw our hero
  hero:draw()
  if shotType == 5 then
    drone:draw()
  end

  -- let's draw our enemies
  love.graphics.setColor(1,0.7,0.7,1)
  for i,v in ipairs(enemies) do
    --love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
    love.graphics.draw(enemyImage, v.x, v.y, 0, 0.1, 0.1)
  end
  love.graphics.setColor(1,0,0,1)
  for i,v in ipairs(hardEnemies) do
    love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
  end
  
  -- let's draw some ground _over_ the enemies
  love.graphics.setColor(0,0.6,0,1.0)
  love.graphics.rectangle("fill", 0, ground_height, gameX, gameY-ground_height)
   
   -- shots on top of actors
  love.graphics.setColor(0.5,0.5,0.5,1)
  for i,v in ipairs(shots) do
    love.graphics.rectangle("fill", v.x, v.y, 2, 5)
  end 
 
  -- draw overlay
  if(not flagStopped) then
    love.graphics.setColor(1,1,1,1)
    love.graphics.print( "Shot: " .. game.shotString(shotType), 10, 20, -0.1, 1.8, 1.6) 
    love.graphics.print( "Score: " .. score, gameX, 20, 0.1, 1.8, 1.6, 100) 
  end
  
  if flagGameover then
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf( 'Game Over!', (gameX - 3*200)/2, gameY/3, 200, "center", 0, 3, 3)
  end
  if flagWin then
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf( 'You Win!\n'.. score, (gameX - 3*200)/2, gameY/3, 200, "center", 0, 3, 3)
  end

end

return game
