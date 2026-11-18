local focus = require "objects/menuFocus"
require 'lib/simple-slider'
require 'objects/button'

Options = {}

local controls
local backButton, generalButton, volumeButton, mainButton, musicButton, effectButton, slidertickButton
local resolutionButton, vsyncButton, fpsButton
local mainVolumeSlider, musicVolumeSlider, effectsVolumeSlider

function Options:load()
  changedResolution = false
  backButton = newButton(gw * 0.54, gh / 2 + 375, gw * 0.1, 50, 15, "Back", Blue, White, White, "center", 0, 10, function() BackToStartScreen() end)
  generalButton = newButton(gw * 0.38, gh / 2 - 375, gw * 0.1, 50, 15, "General", Purple, White, White, "center", 0, 10)
  volumeButton = newButton(gw * 0.38, gh / 2, gw * 0.1, 50, 15, "Volume", Purple, White, White, "center", 0, 10)
  mainButton = newButton(gw * 0.35, gh / 2 + 75, gw * 0.3, 50, 15, "Main", GrayOpacity4, White, White, "left", 15, 10)
  musicButton = newButton(gw * 0.35, gh * 0.5 + 150, gw * 0.3, 50, 15, "Music", GrayOpacity4, White, White, "left", 15, 10)
  effectButton = newButton(gw * 0.35, gh / 2 + 225, gw * 0.3, 50, 15, "Effect", GrayOpacity4, White, White, "left", 15, 10)
  slidertickButton = newButton(gw * 0.35, gh / 2 + 300, gw * 0.3, 50, 15, "Enable slidertick sound", GrayOpacity4, White, White, "left", 15, 10)
  
  resolutionButton = newButton(gw * 0.35, gh / 2 - 300, gw * 0.3, 50, 15, "Resolution", GrayOpacity4, White, White, "left", 15, 10)
  vsyncButton = newButton(gw * 0.35, gh / 2 - 225, gw * 0.3, 50, 15, "Enable Vsync", GrayOpacity4, White, White, "left", 15, 10)
  fpsButton = newButton(gw * 0.35, gh / 2 - 150, gw * 0.3, 50, 15, "Show FPS", GrayOpacity4, White, White, "left", 15, 10)
  
  mainVolumeSlider = newSlider(gw * 0.56, gh / 2 + 100, gw * 0.15, saveManager.settings.mainVolume, 0, 2, function (v) soundManager:SetMainVolume(v) end)
  musicVolumeSlider = newSlider(gw * 0.56, gh / 2 + 175, gw * 0.15, saveManager.settings.musicVolume, 0, 0.1, function (v) soundManager:SetMusicVolume(v) end)
  effectsVolumeSlider = newSlider(gw * 0.56, gh / 2 + 250, gw * 0.15, saveManager.settings.effectVolume, 0, 0.1, function (v) soundManager:SetEffectsVolume(v) end)
  resolutionButton.onConfirm = function() self:mousepressed(gw * 0.51 + 100, gh / 2 - 275, 2) end
  resolutionButton.onDirection = function(button)
    if button ~= "dpleft" and button ~= "dpright" then return false end
    self:mousepressed(gw * 0.51 + 100, gh / 2 - 275, button == "dpleft" and 1 or 2)
    return true
  end
  vsyncButton.onConfirm = function() self:mousepressed(gw * 0.63, gh / 2 - 200, 1) end
  fpsButton.onConfirm = function() self:mousepressed(gw * 0.63, gh / 2 - 125, 1) end
  slidertickButton.onConfirm = function() self:mousepressed(gw * 0.63, gh / 2 + 325, 1) end
  for row, slider in pairs({[mainButton] = mainVolumeSlider, [musicButton] = musicVolumeSlider,
      [effectButton] = effectsVolumeSlider}) do
    row.onDirection = function(button)
      if button ~= "dpleft" and button ~= "dpright" then return false end
      slider.value = math.max(0, math.min(1, slider.value + (button == "dpleft" and -0.05 or 0.05)))
      slider.setter(slider:getValue())
      return true
    end
  end
  controls = {resolutionButton, vsyncButton, fpsButton, mainButton, musicButton,
    effectButton, slidertickButton, backButton}
end

function Options:gamepadpressed(button)
  if button == "b" then
    BackToStartScreen()
  else
    focus.press(controls, button)
  end
end

function Options:update(dt)
  backButton:update(dt)
  mainVolumeSlider:update()
  musicVolumeSlider:update()
  effectsVolumeSlider:update()
                
end

function Options:draw()
  focus.enter(controls)
  DrawButtons()
  DrawSliders()
  if focus.isSelected(resolutionButton) or focus.isSelected(mainButton)
      or focus.isSelected(musicButton) or focus.isSelected(effectButton) then
    love.graphics.setColor(White)
    love.graphics.printf("Left / Right to adjust", 0, gh - 70, gw, "center")
  end
end

local function onResolution(x, y)
  return x > gw * 0.51 and x < gw * 0.51 + 200 and y > gh / 2 - 290 and y < gh / 2 - 260
end

local function onToggle(x, y, centerY)
  return math.abs(x - gw * 0.63) < 16 and math.abs(y - centerY) < 16
end

function Options:mousepressed(x, y, button)
  backButton:mousepressed(x, y, button)
  if menustate ~= "Options" then return end

  if onToggle(x, y, gh / 2 - 125) and button == 1 then
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    if saveManager.settings.isEnabledFPS then
      saveManager.settings.isEnabledFPS = false
    else
      saveManager.settings.isEnabledFPS = true
    end
  elseif onToggle(x, y, gh / 2 - 200) and button == 1 then
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    if saveManager.settings.isEnabledVSync then
      saveManager.settings.isEnabledVSync = false
    else
      saveManager.settings.isEnabledVSync = true
    end
  elseif onToggle(x, y, gh / 2 + 325) and button == 1 then
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    if saveManager.settings.isEnabledTicksound then
      saveManager.settings.isEnabledTicksound = false
    else
      saveManager.settings.isEnabledTicksound = true
    end
  elseif onResolution(x, y) and button == 1 then
    changedResolution = true
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    saveManager.settings.resolutionIndex = saveManager.settings.resolutionIndex - 1
    if saveManager.settings.resolutionIndex <= 0 then
      saveManager.settings.resolutionIndex = #resolutionList
    end
  elseif onResolution(x, y) and button == 2 then
    changedResolution = true
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    saveManager.settings.resolutionIndex = saveManager.settings.resolutionIndex + 1
    if saveManager.settings.resolutionIndex > #resolutionList then
      saveManager.settings.resolutionIndex = 1
    end
  end
end

function BackToStartScreen()
  saveManager:saveSettings()
  menustate = "Startmenu"
  if (changedResolution) then
    changedResolution = false
    simpleScale.applyResolution()
  end
end

function DrawSliders()
  mainVolumeSlider:draw()
  musicVolumeSlider:draw()
  effectsVolumeSlider:draw()
end

local function drawToggle(y, enabled)
  local x = gw * 0.63
  if onToggle(mx, my, y) then
    love.graphics.setColor(1, 1, 1, 0.28)
    love.graphics.circle('fill', x, y, 20, 4)
  end
  love.graphics.setColor(White)
  love.graphics.circle('line', x, y, 16, 4)
  if enabled then
    love.graphics.setColor(Green)
    love.graphics.circle('fill', x, y, 8, 4)
  end
  love.graphics.setColor(White)
end

function DrawButtons()  
  love.graphics.setFont(buttonSmallFont)
  love.graphics.setLineWidth(6)   
  backButton:draw()
  generalButton:draw()  
  resolutionButton:draw()
  love.graphics.setColor(Green)
  love.graphics.rectangle("fill", gw * 0.51, gh / 2 - 290, 200, 30, 10)
  love.graphics.setColor(White)
  if onResolution(mx, my) then
    love.graphics.setColor(1, 1, 1, 0.22)
    love.graphics.rectangle("fill", gw * 0.51, gh / 2 - 290, 200, 30, 10)
    love.graphics.setColor(White)
  end
  love.graphics.setLineWidth(5)
  love.graphics.rectangle("line", gw * 0.51, gh / 2 - 290, 200, 30, 10)
  love.graphics.printf(resolutionList[saveManager.settings.resolutionIndex][1] .. " x " .. resolutionList[saveManager.settings.resolutionIndex][2], gw * 0.51, gh / 2 - 290, 200, "center")
  
  vsyncButton:draw()
  drawToggle(gh / 2 - 200, saveManager.settings.isEnabledVSync)
      
  fpsButton:draw()
  drawToggle(gh / 2 - 125, saveManager.settings.isEnabledFPS)
  
  volumeButton:draw()
  mainButton:draw()
  musicButton:draw()
  effectButton:draw()
  slidertickButton:draw()
  drawToggle(gh / 2 + 325, saveManager.settings.isEnabledTicksound)
  --[[
  love.graphics.setColor(Colors.getGreenColor())
  love.graphics.rectangle('fill', gw * 0.35, gh / 2 - 75, gw * 0.3, 50, 15)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', gw * 0.35, gh / 2 - 75, gw * 0.3, 50, 15)
  love.graphics.printf("Keyboard bindings", 0, gh / 2 - 63, gw, "center")
  ]]
end

return Options
