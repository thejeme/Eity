local button = {}
button.__index = button

function newButton(x, y, width, height, corner, text, inlineColor, normalOutlineColor, highlightOutlineColor, textAlign, ox, oy, func, isToggle)
  local b = {}
  b.x = x
  b.y = y
  b.width = width
  b.height = height
  b.corner = corner
  b.text = text
  b.inlineColor = inlineColor
  b.normalOutlineColor = normalOutlineColor
  b.highlightOutlineColor = highlightOutlineColor
  b.textAlign = textAlign or "center"
  b.ox = ox or 0
  b.oy = oy or 0
  b.func = func
  b.isToggle = isToggle or false
  b.activeOutlineColor = normalOutlineColor
  
  return setmetatable(b, button)
end

function button:update(dt)
  local hovered = self.func and self:contains(mx, my)
  if hovered and not self.hovered then
    soundManager.playSoundEffect(soundManager.buttonOversrc)
  end
  self.hovered = hovered
end

function button:draw()
  love.graphics.setColor(self.inlineColor)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, self.corner)
  local outline = self.activeOutlineColor
  if self.func and self:contains(mx, my) then
    love.graphics.setColor(1, 1, 1, 0.22)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, self.corner)
    if not self.isToggle then outline = self.highlightOutlineColor end
  end
  love.graphics.setColor(outline)
  love.graphics.rectangle('line', self.x, self.y, self.width, self.height, self.corner)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(self.text, self.x + self.ox, self.y + self.oy, self.width, self.textAlign)
end

function button:contains(x, y)
  return x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height
end

function button:mousepressed(x, y, button)
  if self.func and button == 1 and self:contains(x, y) then
    self.func()
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
  end
end

function button:setHighlightOutlineColor()
  self.activeOutlineColor = self.highlightOutlineColor
end

function button:setNormalOutlineColor()
  self.activeOutlineColor = self.normalOutlineColor
end
