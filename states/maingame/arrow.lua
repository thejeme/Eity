Arrow = {}
listOfArrows = {}

function createArrow(type, direction, speed)
  arrow = {}
  arrow.type = type -- 1 = normal, 2 = reverse, 3 = dodge --
  arrow.direction = direction -- 1 = left, 2 = down, 3 = right, 4 = up  --
  if (direction == 1) then
    arrow.tempPosition = gw / 2 + gh / 2
  elseif (direction == 2) then
    arrow.tempPosition = 0
  elseif (direction == 3) then
    arrow.tempPosition = gw / 2 - gh / 2
  elseif (direction == 4) then
    arrow.tempPosition = gh
  end
  arrow.speed = speed
  arrow.rotation = 0
  if modManager.isFlashlight then
    arrow.alpha = 0
  else
    arrow.alpha = 1
  end

  table.insert(listOfArrows, arrow)
end

local facing = {"right", "up", "left", "down"}
local opposite = {"left", "down", "right", "up"}

function Arrow:update(dt)
  for i = #listOfArrows, 1, -1 do
    local note = listOfArrows[i]
    local lane = note.direction
    local horizontal = lane % 2 == 1
    local sign = (lane == 1 or lane == 4) and -1 or 1
    local center = horizontal and gw / 2 or gh / 2
    local remaining = (center - note.tempPosition) * sign - (horizontal and gw * 0.075 or gh * 0.115)
    remaining = remaining - note.speed * dt
    note.tempPosition = note.tempPosition + sign * note.speed * dt
    if note.type == 2 and remaining < (horizontal and gw * 0.105 or gh * 0.205) then
      note.rotation = math.min(math.pi, note.rotation + note.speed * 0.05 * dt)
    end
    if remaining <= 0 then
      table.remove(listOfArrows, i)
      scoreManager.destroyednotes = scoreManager.destroyednotes + 1
      scoreManager.destroyedArrows = scoreManager.destroyedArrows + 1
      local target = note.type == 2 and opposite[lane] or facing[lane]
      local hit = player.direction == target
      if note.type == 3 then hit = not hit end
      if hit then
        if note.type == 1 then scoreManager.collectedBlueArrows = scoreManager.collectedBlueArrows + 1 end
        if note.type == 2 then scoreManager.collectedYellowArrows = scoreManager.collectedYellowArrows + 1 end
        player:blink(dt)
      end
      soundManager.playSoundEffect(hit and soundManager.hitsrc or soundManager.misssrc)
      scoreManager.AddScore(hit and "perfect" or "miss", note)
    end
  end
end

function Arrow:draw()

  for i, v in ipairs(listOfArrows) do
    if (v.type == 1) then
      love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)
    elseif (v.type == 2) then
        love.graphics.setColor(219 / 255, 130 / 255, 52 / 255, v.alpha)
    elseif (v.type == 3) then
        love.graphics.setColor(219 / 255, 52 / 255, 52 / 255, v.alpha)
    end

  if (v.direction == 4) then
    love.graphics.push()
    love.graphics.translate(gw / 2, gh / 2)
    love.graphics.rotate(v.rotation)
    love.graphics.translate(gw / 2 * -1, gh / 2 * -1)
    love.graphics.polygon('fill', gw / 2, -4 + v.tempPosition,
                          gw / 2 + 40, 35 + v.tempPosition,
                          gw / 2 + 20, 55 + v.tempPosition,
                          gw / 2, 35 + v.tempPosition,
                          gw / 2 - 20, 55 + v.tempPosition,
                          gw / 2 - 40, 35 + v.tempPosition)

    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, v.alpha)
    love.graphics.line(gw / 2, -4 + v.tempPosition,
                          gw / 2 + 40, 35 + v.tempPosition,
                          gw / 2 + 20, 55 + v.tempPosition,
                          gw / 2, 35 + v.tempPosition,
                          gw / 2 - 20, 55 + v.tempPosition,
                          gw / 2 - 40, 35 + v.tempPosition,
                          gw / 2, -4 + v.tempPosition)
    love.graphics.pop()

  elseif (v.direction == 2) then
    love.graphics.push()
    love.graphics.translate(gw / 2, gh / 2)
    love.graphics.rotate(v.rotation)
    love.graphics.translate(gw / 2 * -1, gh / 2 * -1)
    love.graphics.polygon('fill', gw / 2, 4 + v.tempPosition,
                          gw / 2 + 40, -35 + v.tempPosition,
                          gw / 2 + 20, -55 + v.tempPosition,
                          gw / 2, -35 + v.tempPosition,
                          gw / 2 - 20, -55 + v.tempPosition,
                          gw / 2 - 40, -35 + v.tempPosition)
    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, v.alpha)
    love.graphics.line(gw / 2, 4 + v.tempPosition,
                          gw / 2 + 40, -35 + v.tempPosition,
                          gw / 2 + 20, -55 + v.tempPosition,
                          gw / 2, -35 + v.tempPosition,
                          gw / 2 - 20, -55 + v.tempPosition,
                          gw / 2 - 40, -35 + v.tempPosition,
                          gw / 2, 4 + v.tempPosition)
    love.graphics.pop()

  elseif (v.direction == 1) then
    love.graphics.push()
    love.graphics.translate(gw / 2, gh / 2)
    love.graphics.rotate(v.rotation)
    love.graphics.translate(gw / 2 * -1, gh / 2 * -1)
    love.graphics.polygon('fill', -26 + v.tempPosition, gh / 2,
                          13 + v.tempPosition, gh / 2 + 40,
                          33 + v.tempPosition, gh / 2 + 20,
                          13 + v.tempPosition, gh / 2,
                          33 + v.tempPosition, gh / 2 - 20,
                          13 + v.tempPosition, gh / 2 - 40)
    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, v.alpha)
    love.graphics.line(-26 + v.tempPosition, gh / 2,
                          13 + v.tempPosition, gh / 2 + 40,
                          33 + v.tempPosition, gh / 2 + 20,
                          13 + v.tempPosition, gh / 2,
                          33 + v.tempPosition, gh / 2 - 20,
                          13 + v.tempPosition, gh / 2 - 40,
                          -26 + v.tempPosition, gh / 2)
    love.graphics.pop()

  elseif (v.direction == 3) then
    love.graphics.push()
    love.graphics.translate(gw / 2, gh / 2)
    love.graphics.rotate(v.rotation)
    love.graphics.translate(gw / 2 * -1, gh / 2 * -1)

    love.graphics.polygon('fill', 26 + v.tempPosition, gh / 2,
                          -13 + v.tempPosition, gh / 2 + 40,
                          -33 + v.tempPosition, gh / 2 + 20,
                          -13 + v.tempPosition, gh / 2,
                          -33 + v.tempPosition, gh / 2 - 20,
                          -13 + v.tempPosition, gh / 2 - 40)
    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, v.alpha)
    love.graphics.line(26 + v.tempPosition, gh / 2,
                          -13 + v.tempPosition, gh / 2 + 40,
                          -33 + v.tempPosition, gh / 2 + 20,
                          -13 + v.tempPosition, gh / 2,
                          -33 + v.tempPosition, gh / 2 - 20,
                          -13 + v.tempPosition, gh / 2 - 40,
                          26 + v.tempPosition, gh / 2)
      love.graphics.pop()
      end
    end
  end

return Arrow
