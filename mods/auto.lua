auto = {}

local facing = {"right", "up", "left", "down"}
local opposite = {"left", "down", "right", "up"}

function auto.ApplyMod(mapNotes)
  local note = mapNotes[scoreManager.destroyedArrows + 1]
  if note then
    local directions = note[1] == 1 and facing or opposite
    player.direction = directions[math.ceil(note[2] / 128)]
  end
end

return auto
