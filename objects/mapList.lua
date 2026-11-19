local focus = require "objects/menuFocus"
mapList = {}

local bigFont
local rankingFont
local smallFont
local smallestFont
local songOrder
local difficultyRank = {Easy = 1, Normal = 2, Hard = 3, Insane = 4}
local scrollY
local selectedRow
local selectionGlow = 0

function mapList:load(listOfMaps)
  bigFont = love.graphics.newFont("assets/roboto.ttf", 84)
  smallFont = love.graphics.newFont("assets/roboto.ttf", 24)
  smallestFont = love.graphics.newFont("assets/roboto.ttf", 18)
  rankingFont = love.graphics.newFont("assets/roboto.ttf", 58)
  songOrder = {}
  for index in ipairs(listOfMaps) do
    songOrder[index] = index
  end
  table.sort(songOrder, function(a, b)
    local first, second = listOfMaps[a], listOfMaps[b]
    local difficultyA, difficultyB = first.getDifficult(), second.getDifficult()
    local rankA, rankB = difficultyRank[difficultyA] or math.huge, difficultyRank[difficultyB] or math.huge
    if rankA ~= rankB then return rankA < rankB end
    if difficultyA ~= difficultyB then return difficultyA < difficultyB end
    local titleA, titleB = first.getTitle():lower(), second.getTitle():lower()
    if titleA ~= titleB then return titleA < titleB end
    return a < b
  end)
  scrollY = 0
  selectedRow = 1
end

function mapList.getSelectedMapIndex()
  return songOrder[selectedRow]
end

function mapList.getSelectedSongLabel()
  local index = mapList.getSelectedMapIndex()
  local difficulty = mapManager.getDifficultOfIndex(index)
  return {
    White, mapManager.getTitleOfIndex(index) .. " - " .. mapManager.getPorterOfIndex(index) .. " ",
    DifficultyColors[difficulty] or White, "[" .. difficulty .. "]",
  }
end

local function selectMap(index)
  if index ~= selectedRow then
    selectedRow = index
    selectionGlow = 1
    img = gameManager:setBackground()
  end
end

function mapList.scroll(delta)
  if delta ~= 0 then soundManager.stopPreview() end
  local minScroll = math.min(0, gh * 0.92 - (100 + 111 * (#songOrder - 1) + 100))
  scrollY = math.max(minScroll, math.min(0, scrollY + delta))
end

local function revealSelected()
  local top = scrollY + 100 + 111 * (selectedRow - 1)
  local visibleTop, visibleBottom = gh * 0.08, gh * 0.92
  if top < visibleTop then
    mapList.scroll(visibleTop - top)
  elseif top + 100 > visibleBottom then
    mapList.scroll(visibleBottom - top - 100)
  end
end

function mapList.PickRandomMapIndex()
  if #songOrder > 1 then
    local index = love.math.random(#songOrder - 1)
    selectMap(index < selectedRow and index or index + 1)
    revealSelected()
  end
end

function mapList:update(dt)
  selectionGlow = math.max(0, selectionGlow - dt * 4)
end

local function rowBounds(index)
  local left = index == selectedRow and gw - 820 or gw - 780
  return left, scrollY + 100 + 111 * (index - 1), gw - 120 - left
end

local function rowAt(x, y)
  if y < gh * 0.08 or y >= gh * 0.92 then return end
  local index = math.floor((y - scrollY - 100) / 111) + 1
  if not songOrder[index] then return end
  local left, top, width = rowBounds(index)
  if x >= left and x < left + width and y < top + 100 then return index end
end

function mapList:draw(songFocused)
  local hovered = rowAt(mx, my)
  for row, mapIndex in ipairs(songOrder) do
    local left, top, width = rowBounds(row)
    if row == hovered then
      love.graphics.setColor(0.24, 0.29, 0.32, 0.95)
    else
      love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    end
    love.graphics.rectangle('fill', left, top, width, 100, 10)
    love.graphics.setColor(White)
    love.graphics.rectangle('line', left, top, width, 100, 10)
    if row == selectedRow then
      love.graphics.setColor(0.25, 0.77, 1, 0.65 + 0.35 * selectionGlow)
      love.graphics.rectangle("fill", left, top + 10, 4 + 3 * selectionGlow, 80, 2)
    end
    love.graphics.setColor(White)
    love.graphics.setFont(smallFont)
    love.graphics.printf(mapManager.getTitleOfIndex(mapIndex), left + 20, top + 15, width, "left")
    love.graphics.setFont(smallestFont)
    love.graphics.printf(mapManager.getPorterOfIndex(mapIndex), left + 30, top + 45, 700, "left")
    local difficulty = mapManager.getDifficultOfIndex(mapIndex)
    love.graphics.setColor(DifficultyColors[difficulty] or White)
    love.graphics.printf(difficulty, left + 30, top + 65, 700, "left")
    DrawGrade(mapIndex, top + 16)
    if row == selectedRow and songFocused then
      focus.drawOutline({x = left, y = top, width = width, height = 100})
    end
  end
end

function DrawGrade(mapIndex, y)
  local grade = saveManager.highscores.mapGrade[mapIndex]
  love.graphics.setFont(rankingFont)
  love.graphics.setColor(White)
  love.graphics.printf(grade, gw * 0.61 - 2, y - 2, gw * 0.6, "center")
  love.graphics.printf(grade, gw * 0.61 + 2, y - 2, gw * 0.6, "center")
  love.graphics.printf(grade, gw * 0.61 - 2, y + 2, gw * 0.6, "center")
  love.graphics.printf(grade, gw * 0.61 + 2, y + 2, gw * 0.6, "center")
  love.graphics.setColor(scoreManager.getGradeColor(grade))
  love.graphics.printf(grade, gw * 0.61, y, gw * 0.6, "center")
end

function mapList:mousepressed(x, y, button)
  if button ~= 1 then return end
  local index = rowAt(x, y)
  if index then selectMap(index) end
end

function mapList.mapListUp()
  selectMap(math.max(1, selectedRow - 1))
  revealSelected()
end

function mapList.mapListDown()
  selectMap(math.min(#songOrder, selectedRow + 1))
  revealSelected()
end
