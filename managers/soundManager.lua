soundManager = {}



function soundManager:SetMainVolume(volume)
  saveManager.settings.mainVolume = volume
  love.audio.setVolume(volume)
end

function soundManager:SetMusicVolume(volume)  
  saveManager.settings.musicVolume = volume
  soundManager.mainmenusrc:setVolume(volume)
end

function soundManager:SetEffectsVolume(volume)
  saveManager.settings.effectVolume = volume
  effectsVolume = volume
  
  soundManager.buttonOversrc:setVolume(volume)
  soundManager.buttonHitsrc:setVolume(volume)

  soundManager.hitsrc:setVolume(volume)
  soundManager.hitSlidersrc:setVolume(volume)
  soundManager.misssrc:setVolume(volume)
end


function soundManager:load()
  soundManager.mainmenusrc = love.audio.newSource("assets/verse_one_bgmusic.mp3", "stream")
  
  soundManager.buttonOversrc = love.audio.newSource("assets/ButtonOver.wav", "static")
  soundManager.buttonHitsrc = love.audio.newSource("assets/ButtonHit.wav", "static")
  
  soundManager.hitsrc = love.audio.newSource("assets/hit.wav", "static")
  soundManager.hitSlidersrc = love.audio.newSource("assets/slider.wav", "static")
  soundManager.misssrc = love.audio.newSource("assets/miss.wav", "static")
  
  soundManager:SetMainVolume(saveManager.settings.mainVolume)
  soundManager:SetMusicVolume(saveManager.settings.musicVolume)  
  soundManager:SetEffectsVolume(saveManager.settings.effectVolume)
  
end

function soundManager.playSoundEffect(source)
	local clone = source:clone()
	clone:play()
end

-- Start each excerpt in a repeated musical phrase.
local previewStarts = {
  ["maps/Abstract World/song.mp3"] = 32,
  ["maps/Blank Paper/song.mp3"] = 53,
  ["maps/Cold Green Eyes/song.mp3"] = 46,
  ["maps/FREEDOM DiVE/song.mp3"] = 135,
  ["maps/Highscore/song.mp3"] = 115,
  ["maps/Paradigm Shift/song.mp3"] = 32,
  ["maps/Prayer Blue/song.mp3"] = 64,
  ["maps/Shelter/song.mp3"] = 24,
  ["maps/Stella-rium/song.mp3"] = 30,
  ["maps/Supreme Sign/song.mp3"] = 39,
  ["maps/Tears of Control/song.mp3"] = 128,
  ["maps/The Pressure/song.mp3"] = 41,
  ["maps/Virtual Paradise/song.mp3"] = 44,
  ["maps/Yumeiro Parade/song.mp3"] = 117,
}
local previewIndex, previewSource
local settled, elapsed = 0, 0

local outgoing, fadeTime, fadeVolume
local fadeDuration = 0.16

local function releaseOutgoing()
  if outgoing then
    outgoing:stop()
    outgoing:release()
    outgoing = nil
  end
end

function soundManager.fadePreview()
  if previewSource then
    releaseOutgoing()
    outgoing, previewSource = previewSource, nil
    fadeVolume, fadeTime = outgoing:getVolume(), fadeDuration
  end
  previewIndex = nil
  settled, elapsed = 0, 0
end

function soundManager.stopPreview()
  releaseOutgoing()
  if previewSource then
    previewSource:stop()
    previewSource:release()
    previewSource = nil
  end
  previewIndex = nil
  settled, elapsed = 0, 0
end

function soundManager.updatePreview(index, dt)
  if not index then
    soundManager.stopPreview()
    return
  end
  if outgoing then
    fadeTime = math.max(0, fadeTime - dt)
    outgoing:setVolume(fadeVolume * fadeTime / fadeDuration)
    if fadeTime == 0 then releaseOutgoing() end
  end
  if index ~= previewIndex then
    soundManager.fadePreview()
    previewIndex = index
    return
  end

  settled = settled + dt
  if settled < 0.45 then return end
  if not previewSource then
    local path = mapManager.getSongOfIndex(index)
    previewSource = love.audio.newSource(path, "stream")
    local duration = previewSource:getDuration("seconds")
    local start = math.min(previewStarts[path] or duration / 3, math.max(0, duration - 12))
    previewSource:seek(start, "seconds")
    previewSource:setVolume(0)
    previewSource:play()
    return
  end
  if elapsed >= 12 then return end
  elapsed = math.min(12, elapsed + dt)
  local gain = math.min(1, elapsed / 0.45, (12 - elapsed) / 0.6)
  previewSource:setVolume(gain * saveManager.settings.musicVolume)
  if elapsed == 12 then previewSource:stop() end
end

return soundManager
