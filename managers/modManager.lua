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
  modManager.isMirror = false
  modManager.isAuto = false

  modManager.speed = 1.00
end

function modManager.SetSpeed(speed)
  modManager.speed = speed
end

function modManager.getSpeed()
  return modManager.speed
end

local resultLabels = {
  {"isDodge", "Dodge"}, {"isMirror", "Mirror"}, {"isHidden", "Hidden"},
  {"isFlashlight", "Flashlight"}, {"isNoFail", "No Fail"}, {"isAuto", "Auto"},
}

function modManager.getResultLabel()
  local labels = {}
  for _, mod in ipairs(resultLabels) do
    if modManager[mod[1]] then labels[#labels + 1] = mod[2] end
  end
  if modManager.speed ~= 1 then
    labels[#labels + 1] = string.format("%.2f×", modManager.speed)
  end
  return table.concat(labels, " · ")
end

function modManager.prepareChart(notes)
  if not modManager.isDodge and not modManager.isMirror then return notes end
  local chart = {}
  for i, note in ipairs(notes) do
    local lane = math.ceil(note[2] / 128)
    if modManager.isMirror then lane = (lane + 1) % 4 + 1 end
    chart[i] = {modManager.isDodge and 3 or note[1], lane * 128 - 64,
      note[3], modManager.isDodge and 0 or note[4], note[5]}
  end
  return chart
end

return modManager
