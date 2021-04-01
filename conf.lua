-- https://love2d.org/wiki/Config_Files

function love.conf(t)
    t.identity  = 'Matthews_Shooter'
    
    t.window.width = 800
    t.window.height = 600
    t.window.title = 'Matthew\'s Shooter'      -- The window title (string)
    t.window.resizable = true          -- Let the window be user-resizable (boolean)
    t.window.vsync = 1                  -- Vertical sync mode (number)
    
    t.modules.physics = false
end
