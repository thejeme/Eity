local feedback = {}
local impacts = {}
local milestone = 0
local blue = {0.25, 0.77, 1}
local amber = {1, 0.70, 0.29}
local coral = {1, 0.39, 0.45}
local mint = {0.40, 1, 0.82}
-- Angles point from the center toward the incoming note.
local angles = {0, -math.pi / 2, math.pi, math.pi / 2}

function feedback.reset()
  impacts = {}
  milestone = 0
end

function feedback.hit(result, note, combo)
  -- Hold coverage and release are scored together. Draw one burst per note.
  if result == "sliderStart" then return end
  local last = impacts[#impacts]
  if last and last.note == note then return end
  local miss = result == "miss"
  local angle = angles[note.direction]
  if note.type == 2 then angle = angle + math.pi end
  local release = result == "sliderEnd"
  local color = miss and coral or (release and mint or (note.type == 2 and amber or blue))
  if #impacts >= 12 then table.remove(impacts, 1) end
  impacts[#impacts + 1] = {
    note = note, angle = angle, age = 0, duration = release and 0.38 or 0.28,
    color = color, miss = miss, release = release,
  }
  if not miss and combo > 0 and combo % 25 == 0 then milestone = 0.52 end
end

function feedback.update(dt)
  milestone = math.max(0, milestone - dt)
  for i = #impacts, 1, -1 do
    local hit = impacts[i]
    hit.age = hit.age + dt
    if hit.age >= hit.duration then table.remove(impacts, i) end
  end
end

function feedback.draw()
  local g = love.graphics
  g.push("all")
  g.translate(gw / 2, gh / 2)
  local rim = gh * 0.1
  if milestone > 0 then
    local fade = milestone / 0.52
    g.setColor(mint[1], mint[2], mint[3], fade * 0.76)
    g.setLineWidth(2 + fade * 3)
    g.circle("line", 0, 0, rim + 12 + (1 - fade) * 65, 4)
  end
  for _, slider in ipairs(listOfSliders) do
    if slider.holding then
      g.push()
      g.rotate(angles[slider.direction] + (slider.type == 2 and math.pi or 0))
      local filled = 1 - math.max(0, slider.length) / slider.maxlength
      local color = mint
      g.setColor(color[1], color[2], color[3], 0.85)
      g.setLineWidth(5)
      local span = 10 + 38 * filled
      g.line(rim-span, -span, rim, 0, rim-span, span)
      g.pop()
    end
  end
  for _, hit in ipairs(impacts) do
    local t = hit.age / hit.duration
    local fade = 1 - t
    local color = hit.color
    g.push()
    g.rotate(hit.angle)
    g.translate(rim, 0)
    g.setColor(color[1], color[2], color[3], fade * 0.95)
    g.setLineWidth(2 + 4 * fade)
    if hit.miss then
      local gap = 6 + t * 14
      g.line(-8, -gap-8, 0, -gap, 8, -gap-8)
      g.line(-8, gap+8, 0, gap, 8, gap+8)
    else
      local rays = hit.release and 7 or 5
      for ray = 1, rays do
        local angle = (ray - (rays + 1) / 2) * 0.37
        local distance = 7 + (1 - fade * fade) * (38 + 10 * (ray % 2))
        local dx, dy = math.cos(angle), math.sin(angle)
        g.line(dx * distance, dy * distance, dx * (distance + 12 * fade), dy * (distance + 12 * fade))
      end
      g.circle("line", 0, 0, 5 + t * (hit.release and 35 or 19), 4)
    end
    g.pop()
  end
  g.pop()
end

return feedback
