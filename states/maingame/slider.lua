Slider = {}

listOfSliders = {}

function createSlider(direction, speed, length)
  slider = {}
  slider.direction = direction -- 1 = left, 2 = down, 3 = right, 4 = up  --
  if (direction == 1) then
    slider.tempPosition = gw / 2 + gh / 2
  elseif (direction == 2) then
    slider.tempPosition = 0
  elseif (direction == 3) then
    slider.tempPosition = gw / 2 - gh / 2
  elseif (direction == 4) then
    slider.tempPosition = gh
  end
  slider.shouldPlayhitSound = true
  slider.speed = speed
  slider.maxlength = length
  slider.length = length
  slider.scoreLength = length
  if modManager.isFlashlight then
    slider.alpha = 0
  else
    slider.alpha = 1
  end

  table.insert(listOfSliders, slider)
end

local facing = {"right", "up", "left", "down"}

function Slider:update(dt)
  for i = #listOfSliders, 1, -1 do
    local slider = listOfSliders[i]
    local lane = slider.direction
    local sign = (lane == 1 or lane == 4) and -1 or 1
    local edge = lane % 2 == 1 and gw * (0.5 - sign * 0.075) or gh * (0.5 - sign * 0.115)
    local travel = slider.speed * dt
    slider.holding = false
    slider.tempPosition = slider.tempPosition + sign * travel
    if (slider.tempPosition - edge) * sign > 0 then
      slider.tempPosition = edge
      local aligned = player.direction == facing[lane]
      if slider.length > 0 then
        slider.length = slider.length - travel
        slider.holding = aligned
        if aligned then
          slider.scoreLength = slider.scoreLength - travel
          player:blink(dt)
          if saveManager.settings.isEnabledTicksound then
            soundManager.hitSlidersrc:play()
          elseif slider.shouldPlayhitSound then
            soundManager.playSoundEffect(soundManager.hitsrc)
            slider.shouldPlayhitSound = false
          end
        end
      else
        table.remove(listOfSliders, i)
        scoreManager.destroyednotes = scoreManager.destroyednotes + 2
        scoreManager.destroyedArrows = scoreManager.destroyedArrows + 1
        scoreManager.AddScore(slider.scoreLength <= 0 and "sliderStart" or "miss", slider)
        if aligned then scoreManager.collectedBlueSliders = scoreManager.collectedBlueSliders + 1 end
        soundManager.playSoundEffect(aligned and soundManager.hitsrc or soundManager.misssrc)
        scoreManager.AddScore(aligned and "sliderEnd" or "miss", slider)
      end
    end
  end
end

function Slider:draw()
  for i, v in ipairs(listOfSliders) do
  if (v.direction == 4) then
    love.graphics.push()

    love.graphics.setColor(0.25, 0.25, 0.25, v.alpha)
    love.graphics.rectangle('fill', gw / 2 - 40, 35 + v.tempPosition, 80, v.length)

    love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)
    love.graphics.polygon('fill', gw / 2, -4 + v.tempPosition,
                          gw / 2 + 40, 35 + v.tempPosition,
                          gw / 2 + 20, 55 + v.tempPosition,
                          gw / 2, 35 + v.tempPosition,
                          gw / 2 - 20, 55 + v.tempPosition,
                          gw / 2 - 40, 35 + v.tempPosition)

    love.graphics.polygon('fill', gw / 2, -4 + v.tempPosition + v.length,
                          gw / 2 + 40, 35 + v.tempPosition + v.length,
                          gw / 2 + 20, 55 + v.tempPosition + v.length,
                          gw / 2, 35 + v.tempPosition + v.length,
                          gw / 2 - 20, 55 + v.tempPosition + v.length,
                          gw / 2 - 40, 35 + v.tempPosition + v.length)


    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, v.alpha)

    love.graphics.line(gw / 2, -4 + v.tempPosition,
                          gw / 2 + 40, 35 + v.tempPosition,
                          gw / 2 + 40, 35 + v.tempPosition + v.length,
                          gw / 2 + 20, 55 + v.tempPosition + v.length,
                          gw / 2, 35 + v.tempPosition + v.length,
                          gw / 2 - 20, 55 + v.tempPosition + v.length,
                          gw / 2 - 40, 35 + v.tempPosition + v.length,
                          gw / 2 - 40, 35 + v.tempPosition,
                          gw / 2, -4 + v.tempPosition)
      love.graphics.pop()
      
      elseif (v.direction == 2) then
        love.graphics.push()

        love.graphics.setColor(0.25, 0.25, 0.25, v.alpha)
        love.graphics.rectangle('fill', gw / 2 - 40, -35 + v.tempPosition - v.length, 80, v.length)

        love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)
        love.graphics.polygon('fill', gw / 2, 4 + v.tempPosition,
                              gw / 2 + 40, -35 + v.tempPosition,
                              gw / 2 + 20, -55 + v.tempPosition,
                              gw / 2, -35 + v.tempPosition,
                              gw / 2 - 20, -55 + v.tempPosition,
                              gw / 2 - 40, -35 + v.tempPosition)

        love.graphics.polygon('fill', gw / 2, 4 + v.tempPosition - v.length,
                              gw / 2 + 40, -35 + v.tempPosition - v.length,
                              gw / 2 + 20, -55 + v.tempPosition - v.length,
                              gw / 2, -35 + v.tempPosition - v.length,
                              gw / 2 - 20, -55 + v.tempPosition - v.length,
                              gw / 2 - 40, -35 + v.tempPosition - v.length)


      love.graphics.setLineWidth(5)
      love.graphics.setColor(1, 1, 1, v.alpha)

      love.graphics.line(gw / 2, 4 + v.tempPosition,
                            gw / 2 + 40, -35 + v.tempPosition,
                            gw / 2 + 40, -35 + v.tempPosition - v.length,
                            gw / 2 + 20, -55 + v.tempPosition - v.length,
                            gw / 2, -35 + v.tempPosition - v.length,
                            gw / 2 - 20, -55 + v.tempPosition - v.length,
                            gw / 2 - 40, -35 + v.tempPosition - v.length,
                            gw / 2 - 40, -35 + v.tempPosition,
                            gw / 2, 4 + v.tempPosition)

      love.graphics.pop()
      elseif (v.direction == 1) then
        love.graphics.push()

        love.graphics.setColor(0.25, 0.25, 0.25, v.alpha)
        love.graphics.rectangle('fill', 13 + v.tempPosition, gh / 2 - 40, v.length, 80)

        love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)

        love.graphics.polygon('fill', -26 + v.tempPosition , gh / 2,
                              13 + v.tempPosition, gh / 2 + 40,
                              33 + v.tempPosition, gh / 2 + 20,
                              13 + v.tempPosition, gh / 2,
                              33 + v.tempPosition, gh / 2 - 20,
                              13 + v.tempPosition, gh / 2 - 40)

        love.graphics.polygon('fill', -26 + v.tempPosition + v.length, gh / 2,
                              13 + v.tempPosition + v.length, gh / 2 + 40,
                              33 + v.tempPosition + v.length, gh / 2 + 20,
                              13 + v.tempPosition + v.length, gh / 2,
                              33 + v.tempPosition + v.length, gh / 2 - 20,
                              13 + v.tempPosition + v.length, gh / 2 - 40)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(1, 1, 1, v.alpha)

        love.graphics.line(-26 + v.tempPosition , gh / 2,
                              13 + v.tempPosition, gh / 2 + 40,
                              13 + v.tempPosition + v.length, gh / 2 + 40,
                              33 + v.tempPosition + v.length, gh / 2 + 20,
                              13 + v.tempPosition + v.length, gh / 2,
                              33 + v.tempPosition + v.length, gh / 2 - 20,
                              13 + v.tempPosition + v.length, gh / 2 - 40,
                              13 + v.tempPosition, gh / 2 - 40,
                              -26 + v.tempPosition, gh / 2)
        love.graphics.pop()

        elseif (v.direction == 3) then
        love.graphics.push()

        love.graphics.setColor(0.25, 0.25, 0.25, v.alpha)
        love.graphics.rectangle('fill', (13 - v.tempPosition + v.length) * -1, gh / 2 - 40, v.length, 80)

        love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, v.alpha)


        love.graphics.polygon('fill', 26 + v.tempPosition, gh / 2,
                              -13 + v.tempPosition, gh / 2 + 40,
                              -33 + v.tempPosition, gh / 2 + 20,
                              -13 + v.tempPosition, gh / 2,
                              -33 + v.tempPosition, gh / 2 - 20,
                              -13 + v.tempPosition, gh / 2 - 40)

        love.graphics.polygon('fill', 26 + v.tempPosition - v.length, gh / 2,
                              -13 + v.tempPosition - v.length, gh / 2 + 40,
                              -33 + v.tempPosition - v.length, gh / 2 + 20,
                              -13 + v.tempPosition - v.length, gh / 2,
                              -33 + v.tempPosition - v.length, gh / 2 - 20,
                              -13 + v.tempPosition - v.length, gh / 2 - 40)

      love.graphics.setLineWidth(5)
      love.graphics.setColor(1, 1, 1, v.alpha)

      love.graphics.line(26 + v.tempPosition, gh / 2,
                            -13 + v.tempPosition, gh / 2 + 40,
                            -13 + v.tempPosition - v.length, gh / 2 + 40,
                            -33 + v.tempPosition - v.length, gh / 2 + 20,
                            -13 + v.tempPosition - v.length, gh / 2,
                            -33 + v.tempPosition - v.length, gh / 2 - 20,
                            -13 + v.tempPosition - v.length, gh / 2 - 40,
                            -13 + v.tempPosition, gh / 2 - 40,
                            26 + v.tempPosition, gh / 2)
        love.graphics.pop()
      end
    end
  end

return Slider
