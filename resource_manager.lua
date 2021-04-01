local resource_manager = {}
 
local utilities = require("utilities")

-- resources
local images = {}
local image1Quads = {}
local gradient
local music = {}
local sound = {}
local shaders = {}

local tS = 16
local tS10 = 10

function resource_manager.load()
  gradient = utilities.gradientMesh("vertical",
    {1, 0, 0},
    {1, 1, 0},
    {1, 0, 0},
    {1, 1, 0},
    {1, 0, 0} 
  )
  
  images["characters"] = love.graphics.newImage("art/gfx.png")
  local image1 = images["characters"]
  
  --enemies
  image1Quads["blue"] =           {quad=love.graphics.newQuad(0*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["red"] =            {quad=love.graphics.newQuad(1*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["red_damage"] =     {quad=love.graphics.newQuad(1*tS,1*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["black"] =          {quad=love.graphics.newQuad(2*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["black_damage1"] =  {quad=love.graphics.newQuad(2*tS,1*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["black_damage2"] =  {quad=love.graphics.newQuad(2*tS,2*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["purple"] =         {quad=love.graphics.newQuad(0*tS,4*tS,3*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["purple_damage1"] = {quad=love.graphics.newQuad(0*tS,5*tS,3*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["boss"] =           {quad=love.graphics.newQuad(3*tS,0*tS,2*tS,2*tS,image1:getDimensions()), image=image1}
  image1Quads["boss_damage"] =    {quad=love.graphics.newQuad(3*tS,2*tS,2*tS,2*tS,image1:getDimensions()), image=image1}
  image1Quads["boss_damage2"] =   {quad=love.graphics.newQuad(3*tS,4*tS,2*tS,2*tS,image1:getDimensions()), image=image1}
  image1Quads["urn"] =            {quad=love.graphics.newQuad(0*tS,4*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["urn_red"] =        {quad=love.graphics.newQuad(1*tS,4*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  
  --hero
  image1Quads["hero"] = {quad=love.graphics.newQuad(5*tS,5*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  
  --drone
  image1Quads["drone1"] = {quad=love.graphics.newQuad (6*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["drone2"] = {quad=love.graphics.newQuad (6*tS,1*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["drone3"] = {quad=love.graphics.newQuad (6*tS,2*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["drone4"] = {quad=love.graphics.newQuad (6*tS,3*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["drone5"] = {quad=love.graphics.newQuad (6*tS,4*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  
  --weapons
  image1Quads["glaive1"] = {quad=love.graphics.newQuad (7*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  image1Quads["glaive2"] = {quad=love.graphics.newQuad (7*tS,1*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  
  images["powerups"] = love.graphics.newImage("art/powerups.png")
  local image2 = images["powerups"]
  
  for ii=1,8,1
  do
    image1Quads["powerup" .. ii] = {quad=love.graphics.newQuad ((ii-1)*tS10,0*tS10,1*tS10,1*tS10,image2:getDimensions()), image=image2}   
  end
   
  music["dramatic"] = love.audio.newSource("sounds/538828__puredesigngirl__dramatic-music.mp3", "stream")
  music["bossfight"] = love.audio.newSource("sounds/251415__tritus__fight-loop.ogg", "stream")
  --music[]:setVolume(0.9) -- 90% of ordinary volume
  --music[]:setPitch(0.5) -- one octave lower
  --music[]:setVolume(0.7)
  
  sound["shot"] = love.audio.newSource("sounds/344310__musiclegends__laser-shoot.wav", "static")
  sound["death"] = love.audio.newSource("sounds/448226__inspectorj__explosion-8-bit-01.wav", "static")
  
  shaders["white"] = love.graphics.newShader[[
vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(1);
    return outputcolor;
}
]]

end


function resource_manager.getQuad(quadName)
  local entry = image1Quads[quadName]
  return entry.image, entry.quad
end

function resource_manager.getShader(shaderName)
  return shaders[shaderName]
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
