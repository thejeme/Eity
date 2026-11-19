require 'mods/halfSpeed'
require 'mods/doubleSpeed'
require 'mods/hidden'
require 'mods/flashlight'
require 'mods/auto'

modManager = {}

function modManager:load()
  modManager.isHalfSpeed = false
  modManager.isDoubleSpeed = false
  modManager.isHidden = false
  modManager.isFlashlight = false
  modManager.isNoFail = false
  modManager.isDodge = false
  modManager.isOrbit = false
  modManager.isAuto = false

  modManager.speed = 1.00
end

function modManager.SetSpeed(speed)
  modManager.speed = speed
end

function modManager.getSpeed()
  return modManager.speed
end

function modManager.prepareChart(notes)
  if not modManager.isDodge and not modManager.isOrbit then return notes end
  local chart = {}
  for i, note in ipairs(notes) do
    local lane = math.ceil(note[2] / 128)
    local turns = modManager.isOrbit and math.floor((i - 1) / 8) or 0
    local rotated = (lane - 1 - turns) % 4 + 1
    -- Vertical lanes are longer. Preserve both arrival time and hold duration.
    local scale = (rotated % 2 == 0 and 415.8 or 396) / (lane % 2 == 0 and 415.8 or 396)
    chart[i] = {modManager.isDodge and 3 or note[1], rotated * 128 - 64,
      note[3] * scale, modManager.isDodge and 0 or note[4] * scale, note[5]}
  end
  return chart
end

return modManager
