auto = {}

local facing = {"right", "up", "left", "down"}
local dodgeFacing = {"left", "down", "right", "up"}

function auto.ApplyMod(mapNotes)
  local note = mapNotes[scoreManager.destroyedArrows + 1]
  if note then
    local directions = note[1] == 3 and dodgeFacing or facing
    player.direction = directions[math.ceil(note[2] / 128)]
  end
end

return auto
