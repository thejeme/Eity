mapList = {}

local bigFont
local rankingFont
local smallFont
local smallestFont
local maplist
local scrollY
local selectedMap

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
    img = gameManager:setBackground()
  end
end

function mapList.scroll(delta)
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

function mapList:draw()
  for i, v in ipairs(maplist) do
    if (i == selectedMap) then
      love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
      love.graphics.rectangle('fill', gw - 820, scrollY + 100 + 111 * (i - 1), 700, 100, 10)
      love.graphics.setColor(White)
      love.graphics.rectangle('line', gw - 820, scrollY + 100 + 111 * (i - 1), 700, 100, 10)
      love.graphics.setFont(smallFont)
      love.graphics.printf(mapManager.getTitleOfIndex(i), gw - 800, scrollY + 115 + 111 * (i - 1), 700, "left")
      love.graphics.setFont(smallestFont)
      love.graphics.setColor(White)
      love.graphics.printf(mapManager.getPorterOfIndex(i), gw - 790, scrollY + 145 + 111 * (i - 1), 700, "left")
      love.graphics.setColor(Blue)
      love.graphics.printf(mapManager.getDifficultOfIndex(i), gw - 790, scrollY + 165 + 111 * (i - 1), 700, "left")  
      DrawGrade(i)
    else
      love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
      love.graphics.rectangle('fill', gw - 780, scrollY + 100 + 111 * (i - 1), 660, 100, 10)
      love.graphics.setColor(White)
      love.graphics.rectangle('line', gw - 780, scrollY + 100 + 111 * (i - 1), 660, 100, 10)
      love.graphics.setFont(smallFont)
      love.graphics.printf(mapManager.getTitleOfIndex(i), gw - 760, scrollY + 115 + 111 * (i - 1), 660, "left")
      love.graphics.setFont(smallestFont)
      love.graphics.setColor(White)
      love.graphics.printf(mapManager.getPorterOfIndex(i), gw - 750, scrollY + 145 + 111 * (i - 1), 700, "left")
      love.graphics.setColor(Blue)
      love.graphics.printf(mapManager.getDifficultOfIndex(i), gw - 750, scrollY + 165 + 111 * (i - 1), 700, "left")
      
      DrawGrade(i)
    end
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
  if button ~= 1 or y < gh * 0.08 or y >= gh * 0.92 then return end
  for index in ipairs(maplist) do
    local left = index == selectedMap and gw - 820 or gw - 780
    local top = scrollY + 100 + 111 * (index - 1)
    if x >= left and x < gw - 120 and y >= top and y < top + 100 then
      selectMap(index)
      return
    end
  end
end

function mapList.mapListUp()
  selectMap(math.max(1, selectedMap - 1))
  revealSelected()
end

function mapList.mapListDown()
  selectMap(math.min(#maplist, selectedMap + 1))
  revealSelected()
end
