-- modules/engine/input.lua
-- Handles all LÖVE input callbacks (mouse, keyboard, etc.)

local Input = {}

local Mouse = require("modules.engine.mouse")
local CameraManager = require("modules.engine.camera_manager")
local TurnManager = require("modules.engine.turn")
local UnitStats = require("modules.ui.unit_stats")

function Input.mousepressed(x, y, button)
    -- Block mouse input if UnitStats is visible
    if UnitStats.isVisible() then
        return
    end
    
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
    -- Handle UnitStats input
    if UnitStats.isVisible() then
        if key == "backspace" then
            UnitStats.hide()
            return
        elseif key == "down" then
            UnitStats.nextUnit()
            return
        elseif key == "up" then
            UnitStats.previousUnit()
            return
        elseif key == "right" then
            UnitStats.switchToEnemyView()
            return
        elseif key == "left" then
            UnitStats.switchToPlayerView()
            return
        end
        -- Block all other input while UnitStats is visible
        return
    end

    -- Show unit stats page when 'E' is pressed and cursor is hovered over a unit
    if key == "e" then
        local Cursor = require("modules.ui.cursor")
        local UnitManager = require("modules.units.manager")
        -- Only allow stats if not moving or in battle phase
        if UnitManager.state ~= "idle" then return end
        local Battle = require("modules.combat.battle")
        if Battle.visible then return end
        local tx, ty = Cursor.getTile()
        for _, unit in ipairs(UnitManager.units or {}) do
            if unit.tileX == tx and unit.tileY == ty then
                UnitManager.selectedUnit = unit
                UnitStats.show(unit)
                return
            end
        end
    end
end

return Input
