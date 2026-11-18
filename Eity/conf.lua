function love.conf(t)
  t.version = "11.5"
  t.identity = "eity"
  t.window.title = "Eity"
  -- Use a small window icon for X11. The original artwork is kept at full size.
  t.window.icon = "assets/Eity_window.png"
  t.window.width = 1280
  t.window.height = 720
  t.window.resizable = true
  t.window.minwidth = 320
  t.window.minheight = 180
  t.window.vsync = 0
end
