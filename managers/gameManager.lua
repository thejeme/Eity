require 'managers/soundManager'
require 'managers/saveManager'
require 'managers/scoreManager'
require 'managers/modManager'
require 'managers/mapManager'
require 'states/maingame/player'

gameManager = {backgroundDim = 0.5}

function gameManager:getImageScaleForNewDimensions( image, newWidth, newHeight )
  local currentWidth, currentHeight = image:getDimensions()
  return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end

function gameManager:update(dt)
  scoreManager:update(dt)
  
  if gameManager.health <= 0 then
    gameManager.isFailed = true
  end
end

function gameManager:load()
  mapManager:load()
  saveManager:load()
  modManager:load()
  soundManager:load() 
  scoreManager.Restart()
  gameManager.pause = false
  gameManager.isFailed = false
  gameManager.gametime = 0
  gameManager.health = 50
  nextNote = 1
  endTime = 0
end

function gameManager.ReturnToMenu()
  mapSong:stop()
  stateManager.GameState = "Mainmenu"
end

function gameManager.Pause()
  gameManager.pause = not gameManager.pause
  if gameManager.pause then
    mapSong:pause()
  elseif not gameManager.audioEnded then
    mapSong:play()
  end
end

function gameManager:drawBackground()
  local width, height = img:getDimensions()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(img, 0, 0, 0, gw / width, gh / height)
end

function gameManager:setBackground()
  return love.graphics.newImage(mapManager.getBackgroundOfIndex(mapList.getSelectedMapIndex()))
end

function gameManager:setSong()
  return love.audio.newSource(mapManager.getSongOfIndex(mapList.getSelectedMapIndex()), "stream")
end


function gameManager.RestartNewMap()
  soundManager.stopPreview()
  soundManager.mainmenusrc:stop()
  if mapSong ~= nil then
    mapSong:stop()
  end
  mapSong = gameManager:setSong()
  mapSong:setVolume(saveManager.settings.musicVolume)  
  gameManager.Restart()
end

function gameManager.Restart()  
  mapSong:stop()
  mapSong:setPitch(modManager.getSpeed())
  mapSong:play()
  gameManager.audioEnded = false
  gameManager.tailTime = nil
  stateManager.GameState = "Maingame"
  scoreManager.Restart()
  mapNotes = modManager.prepareChart(mapManager.getNotesOfIndex(mapList.getSelectedMapIndex()))
  player:resetPosition()
  gameManager.pause = false
  gameManager.isFailed = false
  gameManager.gametime = 0
  gameManager.health = 50
  xbar = 20
  nextNote = 1
  endTime = 0
  listOfArrows = {}
  listOfSliders = {}
end

return gameManager
