map = { }
 
function map:getBackground()
  return "maps/Template/bg.jpg"
end

function map:getTitle()
  return "Template"
end

function map:getDifficult()
  return "Template"
end
 
function map:getPorter()
  return "Template"
end

function map:getSong()
  return "maps/Yumeiro Parade/song.mp3"
end
 
function map:getLength()  
  return 100
end

function map:getNotes()        
  return {
    {1, 320, 400, 600, 2400},
  }
end

return map
