local focus = require "objects/menuFocus"
local calibration = {active = false}
local period = 0.6
local click, controls, tapButton
local samples, offset, lastBeat, preview, resumeMusic

local function makeClickTrack()
  local rate = 22050
  local beatSamples = math.floor(rate * period + 0.5)
  local data = love.sound.newSoundData(8 * beatSamples, rate, 16, 1)
  for beat = 0, 7 do
    for i = 0, math.floor(rate * 0.035) do
      local t = i / rate
      data:setSample(beat * beatSamples + i, 0.6 * math.sin(2 * math.pi * 1350 * t) * math.exp(-155 * t))
    end
  end
  local source = love.audio.newSource(data)
  source:setLooping(true)
  return source
end

local function adjust(value)
  offset = math.max(-250, math.min(250, value))
  preview = true
  tapButton.text = "Test again"
end

local function tap()
  if preview then
    samples, lastBeat, preview = {}, nil, false
    tapButton.text = "Tap to the click"
    return
  end
  local time = click:tell("seconds")
  local beat = math.floor(time / period + 0.5)
  local errorMs = 1000 * (time - beat * period)
  if beat % 8 == lastBeat or math.abs(errorMs) > 250 or not click:isPlaying() then return end
  lastBeat = beat % 8
  samples[#samples + 1] = errorMs
  if #samples == 8 then
    table.sort(samples)
    adjust(math.floor((samples[4] + samples[5]) / 2 + 0.5))
  end
end

function calibration.close(save)
  if save then
    saveManager.settings.audioOffsetMs = offset
    saveManager:saveSettings()
  end
  click:stop()
  calibration.active = false
  if resumeMusic then soundManager.mainmenusrc:play() end
end

function calibration.open()
  if not click then click = makeClickTrack() end
  local function button(x, y, width, label, action)
    local b = newButton(gw / 2 + x, gh / 2 + y, width, 60, 12, label, GrayOpacity6,
      White, Blue, "center", 0, 15, action)
    b.onConfirm = action
    return b
  end
  tapButton = button(-170, -42, 340, "Tap to the click", tap)
  controls = {
    tapButton,
    button(-290, 58, 170, "-5 ms", function() adjust(offset - 5) end),
    button(-85, 58, 170, "Reset", function() adjust(0) end),
    button(120, 58, 170, "+5 ms", function() adjust(offset + 5) end),
    button(-190, 170, 170, "Cancel", function() calibration.close(false) end),
    button(20, 170, 170, "Save", function() calibration.close(true) end),
  }
  offset, samples, lastBeat, preview = saveManager.settings.audioOffsetMs, {}, nil, false
  resumeMusic = soundManager.mainmenusrc:isPlaying()
  soundManager.mainmenusrc:pause()
  calibration.active = true
  click:play()
end

function calibration.draw()
  focus.enter(controls)
  love.graphics.setColor(0.05, 0.06, 0.09, 0.96)
  love.graphics.rectangle("fill", gw / 2 - 420, gh / 2 - 270, 840, 545, 18)
  love.graphics.setColor(White)
  love.graphics.setFont(squareButtonsmallFont)
  love.graphics.printf(string.format("Audio offset   %+d ms", offset), 0, gh / 2 - 240, gw, "center")
  love.graphics.setFont(buttonSmallFont)
  local message = string.format("Tap or press Space with eight clicks   %d / 8", #samples)
  if preview then
    message = "Check the flash against the click, then adjust or save."
    local phase = (click:tell("seconds") - offset / 1000) % period
    love.graphics.setColor(0.48, 1, 0.82, math.max(0, 1 - phase / 0.14))
    love.graphics.circle("fill", gw / 2, gh / 2 - 80, 14, 4)
    love.graphics.setColor(White)
  end
  love.graphics.printf(message, 0, gh / 2 - 145, gw, "center")
  love.graphics.setLineWidth(3)
  for _, b in ipairs(controls) do b:draw() end
end

function calibration.mousepressed(x, y, button)
  if button ~= 1 then return end
  for _, b in ipairs(controls) do
    if b:contains(x, y) then b.func() return end
  end
end

function calibration.keypressed(key)
  if key == "space" then tap()
  elseif key == "left" then adjust(offset - 5)
  elseif key == "right" then adjust(offset + 5)
  elseif key == "return" then calibration.close(true)
  elseif key == "escape" then calibration.close(false) end
end

function calibration.gamepadpressed(button)
  if button == "b" then calibration.close(false) else focus.press(controls, button) end
end

return calibration
