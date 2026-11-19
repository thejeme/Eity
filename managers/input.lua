local input = {}
local calibration = require "states/mainmenu/calibration"
local focus = require "objects/menuFocus"
local touchControls = require "objects/touchControls"
local touch
local stickDirections = {}

local function pressPointer(x, y, button)
  if simpleScale.contains(x, y) then
    mx, my = x, y
    stateManager:mousepressed(x, y, button)
  end
end

local function songListActive()
  return stateManager.GameState == "Mainmenu" and menustate == "Songselect" and not isMods
end

function input.updatePointer()
  if touch then
    mx, my = touch.x, touch.y
  else
    mx, my = simpleScale.toGame(love.mouse.getPosition())
  end
end

function love.mousepressed(x, y, button, isTouch)
  if not isTouch then
    focus.clear()
    touchControls.active = false
    x, y = simpleScale.toGame(x, y)
    pressPointer(x, y, button)
  end
end

function love.wheelmoved(_, y)
  if songListActive() then mapList.scroll(y * 30) end
end

function love.touchpressed(id, x, y)
  focus.clear()
  touchControls.active = true
  x, y = simpleScale.toGame(x, y)
  if not simpleScale.contains(x, y) then return end
  if stateManager.GameState == "Maingame" and not gameManager.pause and not gameManager.isFailed then
    touchControls.press(x, y)
    return
  end

  if touch then return end
  touch = {id = id, x = x, y = y, startY = y}
  touchPointerDown = true

  if songListActive() and x >= gw - 820 and x < gw - 120 and y >= gh * 0.08 and y < gh * 0.92 then
    touch.onList = true
  else
    pressPointer(x, y, 1)
  end
end

function love.touchmoved(id, x, y)
  if not touch or touch.id ~= id then return end
  x, y = simpleScale.toGame(x, y)
  if touch.onList and songListActive() then
    if touch.scrolling then
      mapList.scroll(y - touch.y)
    elseif math.abs(y - touch.startY) > 18 then
      touch.scrolling = true
      mapList.scroll(y - touch.startY)
    end
  end
  touch.x, touch.y = x, y
end

function love.touchreleased(id, x, y)
  if not touch or touch.id ~= id then return end
  if touch.onList and not touch.scrolling and songListActive() then
    x, y = simpleScale.toGame(x, y)
    pressPointer(x, y, 1)
  end
  touch = nil
  touchPointerDown = false
end

function love.focus(focused)
  if not focused then
    if calibration.active then calibration.close(false) end
    touch = nil
    touchPointerDown = false
    stickDirections = {}
    soundManager.stopPreview()
    if stateManager.GameState == "Maingame" and not gameManager.pause and not gameManager.isFailed then
      gameManager.Pause()
    end
  end
end

function love.visible(visible)
  if not visible then love.focus(false) end
end

function love.gamepadpressed(joystick, button)
  touchControls.active = false
  focus.active = true
  stateManager:gamepadpressed(joystick, button)
end

local stickAxes = {
  leftx = {"dpleft", "dpright"}, lefty = {"dpup", "dpdown"},
  rightx = {"dpleft", "dpright"}, righty = {"dpup", "dpdown"},
  [1] = {"dpleft", "dpright"}, [2] = {"dpup", "dpdown"},
}

local function handleAxis(joystick, axis, value)
  local directions = stickAxes[axis]
  if not directions then return end
  local active = stickDirections[joystick]
  if not active then
    active = {}
    stickDirections[joystick] = active
  end
  local direction = value <= -0.55 and directions[1] or value >= 0.55 and directions[2]
  if direction and direction ~= active[axis] then
    active[axis] = direction
    love.gamepadpressed(joystick, direction)
  elseif math.abs(value) < 0.35 then
    active[axis] = nil
  end
end

function love.gamepadaxis(joystick, axis, value)
  handleAxis(joystick, axis, value)
end

function love.joystickaxis(joystick, axis, value)
  if not joystick:isGamepad() then handleAxis(joystick, axis, value) end
end

local buttons = {"a", "b", "x", "y", [8] = "start", [10] = "start"}
local hats = {l = "dpleft", r = "dpright", u = "dpup", d = "dpdown"}

function love.joystickpressed(joystick, button)
  if not joystick:isGamepad() and buttons[button] then
    love.gamepadpressed(joystick, buttons[button])
  end
end

function love.joystickhat(joystick, _, direction)
  local button = hats[direction] or hats[direction:sub(1, 1)]
  if not joystick:isGamepad() and button then
    love.gamepadpressed(joystick, button)
  end
end

function love.joystickremoved(joystick)
  stickDirections[joystick] = nil
end

return input
