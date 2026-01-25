-- modules/engine/mouse.lua
local Mouse = {}
local Cursor = require("modules.ui.cursor")
local UnitManager = require("modules.units.manager")
local MovementRange = require("modules.engine.movement_range")
local Menu = require("modules.ui.menu")
local Effects = require("modules.audio.sound_effects")

function Mouse.pressed(x, y, button)
    if UnitManager.state == "menu" then
        if button == 1 then
            local hit = Menu.clicked(x, y)
        end
        if button == 2 then
            UnitManager.cancelMove()
        end
        return
    end

    local tx = Cursor.tileX
    local ty = Cursor.tileY
    
    if button == 1 then
        local clickedUnit = UnitManager.getUnitAt(tx, ty)
        local currentSelected = UnitManager.selectedUnit

        if clickedUnit then
            if UnitManager.state == "idle" then
                UnitManager.select(clickedUnit)
            end
        
        elseif currentSelected and UnitManager.state == "idle" then
            if MovementRange.canReach(tx, ty) then
                local success = currentSelected:tryMove(tx, ty)
                if success then
                    UnitManager.state = "moving"
                end
            else
                Effects.backPlay()
                UnitManager.deselectAll()
            end
        else
            UnitManager.deselectAll()
        end
    end
    if button == 2 and UnitManager.selectedUnit then
        Effects.backPlay()
        UnitManager.deselectAll()
    end
end

return Mouse