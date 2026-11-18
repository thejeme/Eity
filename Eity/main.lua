require 'managers/stateManager'
require 'managers/gameManager'
require 'globals'
require 'colors'
require 'lib/simpleScale'

local osName = love.system.getOS()
isWeb = osName == "Web" or osName == "Emscripten"
local input = require 'managers/input'
local discordRPC
local startTime
local nextPresenceUpdate = 0

function love.load()
  gameManager:load()
  if not resolutionList[saveManager.settings.resolutionIndex] then
    saveManager.settings.resolutionIndex = 5
  end
  simpleScale.applyResolution()
  stateManager:load()
  love.graphics.setBackgroundColor(0, 0, 0, 1)
  if osName == "Windows" then
    local ok, rpc = pcall(require, 'lib/discordRPC')
    if ok then
      discordRPC = rpc
      discordRPC.initialize(require('applicationId'), true)
      startTime = os.time()
    end
  end
end

function love.resize(width, height)
  simpleScale.resizeUpdate(width, height)
end

function love.update(dt)
  input.updatePointer()
  gameManager:update(dt)
  stateManager:update(dt)
  local browsing = stateManager.GameState == "Mainmenu" and menustate == "Songselect" and not isMods
  local previewIndex = browsing and love.window.hasFocus() and mapList.getSelectedMapIndex() or nil
  soundManager.updatePreview(previewIndex, dt)
  simpleScale.updateVSync()

  if discordRPC then
    if nextPresenceUpdate < love.timer.getTime() then
      local details, state = "In Mainmenu", ""
      if stateManager.GameState == "Maingame" then
        local index = mapList.getSelectedMapIndex()
        details = mapManager.getTitleOfIndex(index)
        state = "By " .. mapManager.getPorterOfIndex(index)
      end
      discordRPC.updatePresence({
        largeImageKey = "eity_icon",
        largeImageText = "Eity",
        details = details,
        state = state,
        startTimestamp = startTime,
      })
      nextPresenceUpdate = love.timer.getTime() + 2
    end
    discordRPC.runCallbacks()
  end
end

function love.draw()
  simpleScale.set()
  stateManager:draw()
  if saveManager.settings.isEnabledFPS then
    love.graphics.setFont(defaultFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("FPS " .. love.timer.getFPS(), 0, gh - 12, gw, "right")
  end
  simpleScale.unSet()
end

function love.quit()
  if discordRPC then discordRPC.shutdown() end
end

function love.keypressed(key)
  stateManager:keypressed(key)
end
