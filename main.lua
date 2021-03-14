-- from [LÖVE tutorial, part 2](http://www.headchant.com/2010/12/31/love2d-%E2%80%93-tutorial-part-2-pew-pew/)

function chooseShotType()
  shotType = love.math.random(1,5)
  print("Shoot mode: " .. shotType)

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
   elseif shotType == 5 then -- backup
   sp = 100
   nm = 16
  end
end


function love.load(arg)
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  io.stdout:setvbuf('no')
    
  chooseShotType()
  
  timeElapsed = 0
  
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

function love.keyreleased(key)
  -- in v0.9.2 and earlier space is represented by the actual space character ' ', so check for both
  if (key == " " or key == "space") then
    shoot()
  end
end

function love.update(dt)
  timeElapsed = timeElapsed + dt
  
  -- print((math.floor(timeElapsed) % 10))
  
  if((math.floor(timeElapsed) % 10) == 0) then
    chooseShotType()
  end

  -- keyboard actions for our hero
  if love.keyboard.isDown("left") then
    hero.x = hero.x - hero.speed*dt
  elseif love.keyboard.isDown("right") then
    hero.x = hero.x + hero.speed*dt
  end

  local remEnemy = {}
  local remShot = {}

  -- update the shots
  for i,v in ipairs(hero.shots) do
    -- move them up up up
    v.y = v.y - dt * sp

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
      end
    end
    for ii,vv in ipairs(hardenemies) do
      if CheckCollision(v.x,v.y,2,5,vv.x,vv.y,vv.width,vv.height) then
        -- mark that enemy for removal
        table.insert(remEnemy, ii)
        -- mark the shot to be removed
        table.insert(remShot, i)
      end
    end
  end

  -- remove the marked enemies
  for i,v in ipairs(remEnemy) do
    table.remove(enemies, v)
    table.remove(hardenemies, v)
  end

  for i,v in ipairs(remShot) do
    table.remove(hero.shots, v)
  end

  -- update those evil enemies
  for i,v in ipairs(enemies) do
    -- let them fall down slowly
    v.y = v.y + dt

    -- check for collision with ground
    if v.y > 465 then
      -- you loose!!!
    end
  end
  for i,v in ipairs(hardenemies) do
    -- let them fall down slowly
    v.y = v.y + 2*dt

    -- check for collision with ground
    if v.y > 465 then
      -- you lose!!!
    end
  end
end

function love.draw()
  -- let's draw a background
  love.graphics.setColor(255,0,50,255)

  -- let's draw some ground
  love.graphics.setColor(0,255,0,255)
  love.graphics.rectangle("fill", 0, 465, 800, 150)

  -- let's draw our hero
  love.graphics.setColor(255,255,0,255)
  love.graphics.rectangle("fill", hero.x, hero.y, hero.width, hero.height)
  
    love.graphics.setColor(0,200,200 ,  255)
  love.graphics.rectangle("fill", drone.x, drone.y, drone.width, drone.height)

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
end

-- Collision detection function.
-- Checks if a and b overlap.
-- w and h mean width and height.
function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end
