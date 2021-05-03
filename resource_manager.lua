local resource_manager = {}
 
local utilities = require("utilities")

-- resources
local images = {}
local quads = {}
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
  quads["blue"] =           {quad=love.graphics.newQuad(0*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  quads["red"] =            {quad=love.graphics.newQuad(1*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  quads["red_damage"] =     {quad=love.graphics.newQuad(1*tS,1*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  quads["black"] =          {quad=love.graphics.newQuad(2*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  quads["black_damage1"] =  {quad=love.graphics.newQuad(2*tS,1*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  quads["black_damage2"] =  {quad=love.graphics.newQuad(2*tS,2*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  quads["purple"] =         {quad=love.graphics.newQuad(0*tS,4*tS,3*tS,1*tS,image1:getDimensions()), image=image1}
  quads["purple_damage1"] = {quad=love.graphics.newQuad(0*tS,5*tS,3*tS,1*tS,image1:getDimensions()), image=image1}
  quads["boss"] =           {quad=love.graphics.newQuad(3*tS,0*tS,2*tS,2*tS,image1:getDimensions()), image=image1}
  quads["boss_damage"] =    {quad=love.graphics.newQuad(3*tS,2*tS,2*tS,2*tS,image1:getDimensions()), image=image1}
  quads["boss_damage2"] =   {quad=love.graphics.newQuad(3*tS,4*tS,2*tS,2*tS,image1:getDimensions()), image=image1}
  quads["urn"] =            {quad=love.graphics.newQuad(0*tS,3*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  quads["red_urn"] =        {quad=love.graphics.newQuad(1*tS,3*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  
  --hero
  for ii=1,7,1
  do
    quads["hero" .. ii] = {quad=love.graphics.newQuad(5*tS,(ii-1)*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  end
 
  --drone
  for ii=1,5,1
  do
    quads["drone" .. ii] = {quad=love.graphics.newQuad (6*tS,(ii-1)*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  end
  
  --weapons
  quads["glaive1"] = {quad=love.graphics.newQuad (7*tS,0*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  quads["glaive2"] = {quad=love.graphics.newQuad (7*tS,1*tS,1*tS,1*tS,image1:getDimensions()), image=image1}
  
  images["powerups"] = love.graphics.newImage("art/powerups.png")
  local image2 = images["powerups"]
  
  for ii=1,9,1
  do
    quads["powerup" .. ii] = {quad=love.graphics.newQuad ((ii-1)*tS10,0*tS10,1*tS10,1*tS10,image2:getDimensions()), image=image2}   
  end
  
  
  images["sub_boss"] = love.graphics.newImage("art/sub_boss.png")
  local image3 = images["sub_boss"]
  
  --enemies
  quads["sub_boss_main"] = {quad=love.graphics.newQuad(0*tS10,0*tS10,4*tS10,5*tS10 + 3,image3:getDimensions()), image=image3}
  quads["sub_boss_lwing"] = {quad=love.graphics.newQuad(4*tS10,0*tS10,0.6*tS10,2*tS10,image3:getDimensions()), image=image3}
  quads["sub_boss_rwing"] = {quad=love.graphics.newQuad(4*tS10,2*tS10,0.6*tS10,2*tS10,image3:getDimensions()), image=image3}
  quads["sub_boss_cockpit"] = {quad=love.graphics.newQuad(5*tS10,4*tS10,3*tS10,1*tS10,image3:getDimensions()), image=image3}
  quads["sub_boss_window"] = {quad=love.graphics.newQuad(5*tS10,3*tS10,1*tS10,1*tS10,image3:getDimensions()), image=image3}
  quads["sub_boss_window_dmg"] = {quad=love.graphics.newQuad(6*tS10,3*tS10,1*tS10,1*tS10,image3:getDimensions()), image=image3}
  quads["sub_boss_prop"] = {quad=love.graphics.newQuad(5*tS10,2*tS10,5,3,image3:getDimensions()), image=image3}
  quads["sub_boss_prop_dmg"] = {quad=love.graphics.newQuad(6*tS10,2*tS10,6,6,image3:getDimensions()), image=image3}

  images["caterpillar_boss"] = love.graphics.newImage("art/caterpillar_boss.png")
  local image4 = images["caterpillar_boss"]
  
  quads["caterpillar_boss_main"] = {quad=love.graphics.newQuad(0*tS10,0*tS10,3*tS10 - 2,5*tS10 - 3,image4:getDimensions()), image=image4}
  quads["caterpillar_boss_rfoot"] = {quad=love.graphics.newQuad(3*tS10,0*tS10,3,3,image4:getDimensions()), image=image4}
  quads["caterpillar_boss_lfoot"] = {quad=love.graphics.newQuad(4*tS10,0*tS10,3,3,image4:getDimensions()), image=image4}
  quads["caterpillar_boss_booster"] = {quad=love.graphics.newQuad(3*tS10,1*tS10,3,6,image4:getDimensions()), image=image4}
  quads["caterpillar_boss_nose1"] = {quad=love.graphics.newQuad(3*tS10,2*tS10,6,9,image4:getDimensions()), image=image4}
  quads["caterpillar_boss_nose2"] = {quad=love.graphics.newQuad(4*tS10,1*tS10,6,2,image4:getDimensions()), image=image4}
  quads["caterpillar_boss_back"] = {quad=love.graphics.newQuad(4*tS10,2*tS10,7,4,image4:getDimensions()), image=image4}
    
  images["effects"] = love.graphics.newImage("art/effects.png")
  local image5 = images["effects"]
   
  quads["effect_explosion"] = {quad=love.graphics.newQuad(0*tS10,0*tS10,3*tS10,3*tS10,image5:getDimensions()), image=image5}

  music["dramatic"] = love.audio.newSource("sounds/538828__puredesigngirl__dramatic-music.mp3", "stream")
  music["bossfight"] = love.audio.newSource("sounds/251415__tritus__fight-loop.ogg", "stream")
  --music[]:setVolume(0.9) -- 90% of ordinary volume
  --music[]:setPitch(0.5) -- one octave lower
  --music[]:setVolume(0.7)
  
  sound["shot"] = love.audio.newSource("sounds/344310__musiclegends__laser-shoot.wav", "static")
  sound["death"] = love.audio.newSource("sounds/448226__inspectorj__explosion-8-bit-01.wav", "static")
  sound["smash"] = love.audio.newSource("sounds/524999__geraldfiebig__ceramic-cup-shatters-on-tile-floor.wav", "static")
  
  shaders["white"] = love.graphics.newShader[[
vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(1);
    return outputcolor;
}
]]

  shaders["grey"] = love.graphics.newShader[[
vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb /= vec3(3);
    return outputcolor;
}
]]
end


function resource_manager.getQuad(quadName)
  local entry = quads[quadName]
  if entry == nil then
    print("resource_manager: requested non-existing: " .. quadName)
    return
  end
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
    music[musicName]:setLooping(true)
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
