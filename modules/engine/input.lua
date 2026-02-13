-- modules/engine/input.lua
-- Handles all LÖVE input callbacks (mouse, keyboard, etc.)

local Input = {}

local Mouse = require("modules.engine.mouse")
local CameraManager = require("modules.engine.camera_manager")
local TurnManager = require("modules.engine.turn")
local UnitStats = require("modules.ui.unit_stats")

function Input.mousepressed(x, y, button)
    CameraManager.mousepressed(x, y, button)
    
    if TurnManager.isOverlayActive() then
        return
    end
    Mouse.pressed(x, y, button)
end

function Input.mousereleased(x, y, button)
    CameraManager.mousereleased(x, y, button)
end

function Input.wheelmoved(x, y)
    CameraManager.wheelmoved(x, y)
end

function Input.keypressed(key)
    if UnitStats.visible and key == "backspace" then
        UnitStats.hide()
        return
    end
    if UnitStats.visible and key == "down" then
        UnitStats.nextUnit()
        return
    end
end

return Input
