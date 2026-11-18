require 'states/maingame/maingame_UI'
require 'states/maingame/arrow'
require 'states/maingame/slider'
require 'states/maingame/player'

local feedback = require "states/maingame/feedback"

Maingame = {}

function Maingame:load()
  maingame_UI:load()
  nextNote = 1
  endTime = 0
  mapNotes = {}
end

function Maingame:update(dt)
  maingame_UI:update(dt)
  
  if modManager.isAuto then
    auto.ApplyMod(mapNotes)
  end
  
  if gameManager.pause or gameManager.isFailed then
     mapSong:pause() 
     love.mouse.setVisible(true) 
   end
  
  if not gameManager.pause and not gameManager.isFailed then
    love.mouse.setVisible(false)
    feedback.update(dt)
    player:update(dt)
    mapSong:setPitch(modManager.getSpeed())
    mapSong:play()
    gameManager.gametime = gameManager.gametime + dt * modManager.getSpeed()
    
    while mapNotes[nextNote] and (mapNotes[nextNote][5] - 400) * 0.001 < gameManager.gametime do
      local note = mapNotes[nextNote]
      local lane = math.ceil(note[2] * 4 / 512)
      local speed = note[3] * modManager.getSpeed()
      if note[4] == 0 then
        createArrow(note[1], lane, speed)
      else
        createSlider(note[1], lane, speed, note[4])
      end
      nextNote = nextNote + 1
    end

    Arrow:update(dt)
    Slider:update(dt)
    
  if #mapNotes < scoreManager.destroyedArrows + 1 then
    if endTime < 2 then          
      endTime = endTime + dt * modManager.getSpeed()
    else
      if scoreManager.combo > scoreManager.maxCombo then scoreManager.maxCombo = scoreManager.combo end
      scoreManager.CalculateTotalNotes()
      mapSong:stop()
      endTime = 0
      love.mouse.setVisible(true)
      stateManager.GameState = "Rankingscreen"
      if (saveManager.highscores.mapScore[mapList.getSelectedMapIndex()] < scoreManager.score) then
        scoreManager.setHighScore()
      end
    end
  end
    
    
    if modManager.isNoFail or modManager.isAuto then
      gameManager.health = 100
      xbar = gw * 0.35
    end
    if modManager.isHidden then
    hidden.ApplyMod(dt)
    elseif modManager.isFlashlight then
      flashlight.ApplyMod(dt)
    end
  end
end

local directions = {
  dpleft = "left", x = "left", dpright = "right", b = "right",
  dpup = "up", y = "up", dpdown = "down", a = "down",
}

function Maingame:gamepadpressed(joystick, button)
  if gameManager.pause or gameManager.isFailed then
    if (button == "y" or button == "start") and not gameManager.isFailed then
      gameManager.Pause()
    elseif button == "b" then
      gameManager.Restart()
    elseif button == "a" then
      gameManager.ReturnToMenu()
    end
  elseif button == "start" then
    gameManager.Pause()
  elseif directions[button] then
    player:keypressed(directions[button])
  end
end

function Maingame:draw()
  gameManager:drawBackground()
  love.graphics.setColor(0.3, 0.3, 0.3, gameManager.backgroundDim)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  Arrow:draw()
  Slider:draw()
  maingame_UI:draw()
  
  love.graphics.setFont(defaultFont)
  --love.graphics.print(gameManager.gametime, 0, 60)
end

function Maingame:mousepressed(x, y,button)
  maingame_UI:mousepressed(x, y,button)
end

function Maingame:keypressed(key)
  
  if key == "escape" and not gameManager.isFailed then
    gameManager.Pause()
  end
  
  if key == "r" then
    gameManager.Restart()
  end
  
  if key == "tab" then
    isEnabledUI = not isEnabledUI
  end
  
  
  
  player:keypressed(key)
end 

return Maingame
