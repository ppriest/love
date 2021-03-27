local resource_manager = {}
 
local utilities = require("utilities")

-- resources
local image1
local image1Quads = {}
local gradient
local music = {}
local sound = {}

function resource_manager.load()
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
end


function resource_manager.getQuad(quadName)
  return image1, image1Quads[quadName]
end
  

-- start playing said music, only if it differs from what's playing already
local musicCurrent = ""
function resource_manager.playMusic(musicName)
  if(musicName ~= musicCurrent) then
    if(musicCurrent ~= "") then
      music[musicCurrent]:stop()
    end
    music[musicName]:play()
    musicCurrent = musicName
    return true
  end
  return false
end

-- create instance of sound using SLAM and return it for tweaking
function resource_manager.playSound(soundName)
  return sound[soundName]:play()
end

function resource_manager.getGradient()
  return gradient
end

return resource_manager
