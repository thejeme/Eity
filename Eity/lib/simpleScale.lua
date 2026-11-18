simpleScale = {}

local scale, offsetX, offsetY
local vsync

function simpleScale.resizeUpdate(width, height)
  scale = math.min(width / gw, height / gh)
  offsetX = (width - gw * scale) / 2
  offsetY = (height - gh * scale) / 2
end

function simpleScale.updateVSync()
  local requested = saveManager.settings.isEnabledVSync and 1 or 0
  if requested ~= vsync then
    if not isWeb then love.window.setVSync(requested) end
    vsync = requested
  end
end

function simpleScale.applyResolution()
  local resolution = resolutionList[saveManager.settings.resolutionIndex]
  local width, height = resolution[1], resolution[2]
  if not isWeb then
    local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
    local fit = math.min(1, desktopWidth / width, math.max(180, desktopHeight - 80) / height)
    width, height = math.floor(width * fit), math.floor(height * fit)
  end
  love.window.updateMode(width, height)
  simpleScale.resizeUpdate(love.graphics.getDimensions())
  vsync = nil
  simpleScale.updateVSync()
end

function simpleScale.toGame(x, y)
  return (x - offsetX) / scale, (y - offsetY) / scale
end

function simpleScale.contains(x, y)
  return x >= 0 and x < gw and y >= 0 and y < gh
end

function simpleScale.set()
  love.graphics.push()
  love.graphics.setScissor(offsetX, offsetY, gw * scale, gh * scale)
  love.graphics.translate(offsetX, offsetY)
  love.graphics.scale(scale, scale)
end

function simpleScale.unSet()
  love.graphics.pop()
  love.graphics.setScissor()
end
