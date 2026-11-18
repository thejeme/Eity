local focus = {active = false}
local selected
local group
local directions = {
  dpup = {0, -1}, dpdown = {0, 1}, dpleft = {-1, 0}, dpright = {1, 0},
}

function focus.clear()
  focus.active = false
  selected, group = nil, nil
end

function focus.isSelected(item)
  return selected ~= nil and item == selected
end

function focus.select(item)
  selected = item
end

local function center(item)
  return item.x + (item.width or 0) / 2, item.y + (item.height or 0) / 2
end

function focus.enter(items)
  if focus.active and group ~= items then
    group, selected = items, items[1]
  end
end

function focus.press(items, button)
  local direction = directions[button]
  if button ~= "a" and not direction then return false end
  focus.active = true
  focus.enter(items)
  if selected.onDirection and selected.onDirection(button) then return true end
  if button == "a" then
    if selected.onConfirm then
      selected.onConfirm()
    elseif selected.func then
      selected.func()
      soundManager.playSoundEffect(soundManager.buttonHitsrc)
    end
    return true
  end

  local x, y = center(selected)
  local nearest, best = selected, math.huge
  for _, item in ipairs(items) do
    local ix, iy = center(item)
    local dx, dy = ix - x, iy - y
    local forward = dx * direction[1] + dy * direction[2]
    if forward > 0 then
      local sideways = dx * direction[2] + dy * direction[1]
      local distance = forward + 3 * math.abs(sideways)
      if distance < best then nearest, best = item, distance end
    end
  end
  selected = nearest
  return true
end

function focus.draw(item)
  if focus.isSelected(item) then focus.drawOutline(item) end
end

function focus.drawOutline(item)
  love.graphics.push("all")
  local function outline(offset)
    if item.radius then
      love.graphics.circle("line", item.x, item.y, item.radius + item.scale + offset, 4)
    else
      love.graphics.rectangle("line", item.x - offset, item.y - offset,
        item.width + offset * 2, item.height + offset * 2, item.corner or 10)
    end
  end
  local offset = item.radius and 24 or 0
  love.graphics.setColor(0.04, 0.06, 0.08, 1)
  love.graphics.setLineWidth(12)
  outline(offset)
  love.graphics.setColor(0.56, 0.93, 1, 1)
  love.graphics.setLineWidth(6)
  outline(offset)
  love.graphics.pop()
end

return focus
