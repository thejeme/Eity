shelter = require "maps/Shelter/map"
freedomDive = require "maps/FREEDOM DiVE/map"
yumeiroParade = require "maps/Yumeiro Parade/map"
highscore = require "maps/Highscore/map"
prayerBlue = require "maps/Prayer Blue/map"
paradigmShift = require "maps/Paradigm Shift/map"
pressure = require "maps/The Pressure/map"
stellaRium = require "maps/Stella-rium/map"
virtualParadise = require "maps/Virtual Paradise/map"
coldGreenEyes = require "maps/Cold Green Eyes/map"

mapManager = { }
 
listOfMaps = {}
 
function mapManager.getListOfMaps()
 return listOfMaps
end

function mapManager.getLengthOfIndex(index)
  return listOfMaps[index].getLength()
end

function mapManager.getDifficultOfIndex(index)
  return listOfMaps[index].getDifficult()
end

function mapManager.getTitleOfIndex(index)
  return listOfMaps[index].getTitle()
end

function mapManager.getPorterOfIndex(index)
  return listOfMaps[index].getPorter()
end

function mapManager.getBackgroundOfIndex(index)
  return listOfMaps[index].getBackground()
end

function mapManager.getSongOfIndex(index)
  return listOfMaps[index].getSong()
end

function mapManager.getNotesOfIndex(index)
  return listOfMaps[index].getNotes()
end

 
function mapManager:load()
  table.insert(listOfMaps, shelter)
  table.insert(listOfMaps, prayerBlue)
  table.insert(listOfMaps, virtualParadise)
  table.insert(listOfMaps, coldGreenEyes)
  table.insert(listOfMaps, paradigmShift)  
  table.insert(listOfMaps, stellaRium)  
  table.insert(listOfMaps, pressure)
  table.insert(listOfMaps, freedomDive)
  table.insert(listOfMaps, highscore)
  table.insert(listOfMaps, yumeiroParade)

  -- Meteor Sightseeing set in difficulty order. Keep the original score indices.
  table.insert(listOfMaps, require("maps/Tears of Control/map"))
  table.insert(listOfMaps, require("maps/Supreme Sign/map"))
  table.insert(listOfMaps, require("maps/Blank Paper/map"))
  table.insert(listOfMaps, require("maps/Abstract World/map"))
end

return mapManager
