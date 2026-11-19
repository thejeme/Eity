local controls = {active = false}
local buttons = {
  {key = "left",  x = 0.065, y = 0.875, angle = math.pi},
  {key = "down",  x = 0.16,  y = 0.875, angle = math.pi / 2},
  {key = "up",    x = 0.84,  y = 0.875, angle = -math.pi / 2},
  {key = "right", x = 0.935, y = 0.875, angle = 0},
  {key = "pause", x = 0.95,  y = 0.17},
}

function controls.press(x, y)
  for _, button in ipairs(buttons) do
    local radius = gh * (button.angle and 0.078 or 0.058)
    local dx, dy = x - gw * button.x, y - gh * button.y
    if dx * dx + dy * dy <= radius * radius then
      if button.key == "pause" then
        gameManager.Pause()
      else
        player:keypressed(button.key)
      end
      return
    end
  end
end

function controls.draw()
  if not controls.active then return end
  local g = love.graphics
  g.push("all")
  for _, button in ipairs(buttons) do
    local radius = gh * (button.angle and 0.078 or 0.058)
    g.push()
    g.translate(gw * button.x, gh * button.y)
    if button.key == player.direction then
      g.setColor(0.13, 0.38, 0.47, 0.92)
    else
      g.setColor(0.07, 0.09, 0.12, 0.82)
    end
    g.circle("fill", 0, 0, radius)
    g.setColor(0.74, 0.90, 0.95, 0.95)
    g.setLineWidth(4)
    g.circle("line", 0, 0, radius)
    if button.angle then
      g.rotate(button.angle)
      g.setLineWidth(10)
      g.line(-25, -27, 3, 0, -25, 27)
      g.line(2, -27, 30, 0, 2, 27)
    else
      g.rectangle("fill", -17, -20, 11, 40, 3)
      g.rectangle("fill", 6, -20, 11, 40, 3)
    end
    g.pop()
  end
  g.pop()
end

return controls
