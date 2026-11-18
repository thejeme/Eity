mapList = {}

local bigFont
local rankingFont
local smallFont
local smallestFont
local maplist
local scrollY
local selectedMap
local selectionGlow = 0

function mapList:load(listOfMaps)
  bigFont = love.graphics.newFont("assets/roboto.ttf", 84)
  smallFont = love.graphics.newFont("assets/roboto.ttf", 24)
  smallestFont = love.graphics.newFont("assets/roboto.ttf", 18)
  rankingFont = love.graphics.newFont("assets/roboto.ttf", 58)
  maplist = listOfMaps
  scrollY = 0
  selectedMap = 1
end

function mapList.getSelectedMapIndex()
  return selectedMap
end

local function selectMap(index)
  if index ~= selectedMap then
    selectedMap = index
    selectionGlow = 1
    img = gameManager:setBackground()
  end
end

function mapList.scroll(delta)
  if delta ~= 0 then soundManager.stopPreview() end
  local minScroll = math.min(0, gh * 0.92 - (100 + 111 * (#maplist - 1) + 100))
  scrollY = math.max(minScroll, math.min(0, scrollY + delta))
end

local function revealSelected()
  local top = scrollY + 100 + 111 * (selectedMap - 1)
  local visibleTop, visibleBottom = gh * 0.08, gh * 0.92
  if top < visibleTop then
    mapList.scroll(visibleTop - top)
  elseif top + 100 > visibleBottom then
    mapList.scroll(visibleBottom - top - 100)
  end
end

function mapList.PickRandomMapIndex()
  if #maplist > 1 then
    local index = love.math.random(#maplist - 1)
    selectMap(index < selectedMap and index or index + 1)
    revealSelected()
  end
end

function mapList:update(dt)
  selectionGlow = math.max(0, selectionGlow - dt * 4)
end

local function rowBounds(index)
  local left = index == selectedMap and gw - 820 or gw - 780
  return left, scrollY + 100 + 111 * (index - 1), gw - 120 - left
end

local function rowAt(x, y)
  if y < gh * 0.08 or y >= gh * 0.92 then return end
  local index = math.floor((y - scrollY - 100) / 111) + 1
  if not maplist[index] then return end
  local left, top, width = rowBounds(index)
  if x >= left and x < left + width and y < top + 100 then return index end
end

function mapList:draw()
  local hovered = rowAt(mx, my)
  for i in ipairs(maplist) do
    local left, top, width = rowBounds(i)
    if i == hovered then
      love.graphics.setColor(0.24, 0.29, 0.32, 0.95)
    else
      love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    end
    love.graphics.rectangle('fill', left, top, width, 100, 10)
    love.graphics.setColor(White)
    love.graphics.rectangle('line', left, top, width, 100, 10)
    if i == selectedMap then
      love.graphics.setColor(0.25, 0.77, 1, 0.65 + 0.35 * selectionGlow)
      love.graphics.rectangle("fill", left, top + 10, 4 + 3 * selectionGlow, 80, 2)
    end
    love.graphics.setColor(White)
    love.graphics.setFont(smallFont)
    love.graphics.printf(mapManager.getTitleOfIndex(i), left + 20, top + 15, width, "left")
    love.graphics.setFont(smallestFont)
    love.graphics.printf(mapManager.getPorterOfIndex(i), left + 30, top + 45, 700, "left")
    love.graphics.setColor(Blue)
    love.graphics.printf(mapManager.getDifficultOfIndex(i), left + 30, top + 65, 700, "left")
    DrawGrade(i)
  end
end

function DrawGrade(i)
  love.graphics.setFont(rankingFont)
  love.graphics.setColor(White)
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61 - 2, scrollY + 116 + 111 * (i - 1) - 2, gw * 0.6, "center")
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61 + 2, scrollY + 116 + 111 * (i - 1) - 2, gw * 0.6, "center")
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61 - 2, scrollY + 116 + 111 * (i - 1) + 2, gw * 0.6, "center")
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61 + 2, scrollY + 116 + 111 * (i - 1) + 2, gw * 0.6, "center")
  love.graphics.setColor(scoreManager.getGradeColor(saveManager.highscores.mapGrade[i]))
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61, scrollY + 116 + 111 * (i - 1), gw * 0.6, "center") 
end

function mapList:mousepressed(x, y, button)
  if button ~= 1 then return end
  local index = rowAt(x, y)
  if index then selectMap(index) end
end

function mapList.mapListUp()
  selectMap(math.max(1, selectedMap - 1))
  revealSelected()
end

function mapList.mapListDown()
  selectMap(math.min(#maplist, selectedMap + 1))
  revealSelected()
end
