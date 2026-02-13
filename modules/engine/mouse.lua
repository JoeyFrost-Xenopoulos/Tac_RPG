-- modules/engine/mouse.lua
local Mouse = {}
local Cursor = require("modules.ui.cursor")
local UnitManager = require("modules.units.manager")
local MovementRange = require("modules.engine.movement_range")
local Menu = require("modules.ui.menu")
local Effects = require("modules.audio.sound_effects")
local TurnManager = require("modules.engine.turn")
local Options = require("modules.ui.options")
local UnitStats = require("modules.ui.unit_stats")
local Attack = require("modules.engine.attack")
local WeaponSelect = require("modules.ui.weapon_selector")

function Mouse.pressed(x, y, button)
    if Options.visible then
        if button == 1 then
            Options.clicked(x, y)
        end
        return
    end

    if UnitStats.visible then
        return
    end

    if WeaponSelect.visible then
        if button == 1 then
            WeaponSelect.clicked(x, y)
        elseif button == 2 then
            WeaponSelect.cancel()
        end
        return
    end
    
    local Battle = require("modules.combat.battle")
    if Battle.visible then
        if button == 1 then
            Battle.clicked(x, y)
        end
        return
    end
    
    if TurnManager.getCurrentTurn() ~= "player" then
        return
    end
    
    if UnitManager.state == "selectingAttack" then
        if button == 1 then
            local clickedUnit = UnitManager.getUnitAt(Cursor.tileX, Cursor.tileY)
            if clickedUnit and not clickedUnit.isPlayer then
                -- Check if unit is in range
                local attacker = UnitManager.selectedUnit
                local enemies = Attack.getEnemiesInRange(attacker)
                for _, enemy in ipairs(enemies) do
                    if enemy == clickedUnit then
                        UnitManager.performAttack(attacker, clickedUnit)
                        return
                    end
                end
            end
        elseif button == 2 then
            -- Return to weapon selection
            UnitManager.showWeaponSelect(UnitManager.selectedUnit)
        end
        return
    end

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
                if not clickedUnit.isPlayer then
                    UnitManager.deselectAll()
                    MovementRange.show(clickedUnit)
                    return
                end

                if clickedUnit == currentSelected then
                    UnitManager.showWaitMenu()
                else
                    UnitManager.select(clickedUnit)
                end
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
            if not currentSelected and UnitManager.state == "idle" then
                UnitManager.showEndTurnMenu(tx, ty)
            else
                UnitManager.deselectAll()
            end
        end
    end
    if button == 2 and UnitManager.selectedUnit and UnitManager.state ~= "moving" then
        Effects.backPlay()
        UnitManager.deselectAll()
    end
end

return Mouse