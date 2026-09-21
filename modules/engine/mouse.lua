-- modules/engine/mouse.lua
-- Standalone mouse handler module (returns table pattern).
-- Top-level engine modules return a table of functions/state.
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
local ItemSelector = require("modules.ui.item_selector")
local CombatSummary = require("modules.ui.combat_summary")
local Battle = require("modules.combat.battle")

local function handleIdle(x, y, button)
    local tx = Cursor.tileX
    local ty = Cursor.tileY

    if button == 1 then
        local clickedUnit = UnitManager.getUnitAt(tx, ty)
        local currentSelected = UnitManager.selectedUnit

        if clickedUnit then
            if not clickedUnit.isPlayer then
                Effects.playClick()
                UnitManager.select(clickedUnit)
                return
            end

            if clickedUnit == currentSelected then
                UnitManager.showWaitMenu()
            else
                UnitManager.select(clickedUnit)
            end

        elseif currentSelected then
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
            UnitManager.showEndTurnMenu(tx, ty)
        end
    end

    if button == 2 and UnitManager.selectedUnit then
        Effects.backPlay()
        UnitManager.deselectAll()
    elseif button == 2 then
        Effects.backPlay()
        MovementRange.clear()
    end
end

local function handleSelectingAttack(x, y, button)
    if button == 1 then
        local clickedUnit = UnitManager.getUnitAt(Cursor.tileX, Cursor.tileY)
        if clickedUnit and not clickedUnit.isPlayer then
            local attacker = UnitManager.selectedUnit
            local enemies = Attack.getEnemiesInRange(attacker)
            for _, enemy in ipairs(enemies) do
                if enemy == clickedUnit then
                    Effects.playConfirm()
                    UnitManager.performAttack(attacker, clickedUnit)
                    return
                end
            end
        end
    elseif button == 2 then
        UnitManager.showWeaponSelect(UnitManager.selectedUnit)
    end
end

local function handleMenu(x, y, button)
    if button == 1 then
        Menu.clicked(x, y)
    elseif button == 2 then
        UnitManager.cancelMove()
    end
end

local stateHandlers = {
    idle = handleIdle,
    selectingAttack = handleSelectingAttack,
    menu = handleMenu,
}

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

    if ItemSelector.visible then
        if button == 1 then
            ItemSelector.clicked(x, y)
        elseif button == 2 then
            ItemSelector.cancel()
        end
        return
    end

    if CombatSummary.isVisible() then
        CombatSummary.clicked(button)
        return
    end

    if Battle.visible then
        if button == 1 then
            Battle.clicked(x, y)
        end
        return
    end

    if TurnManager.getCurrentTurn() ~= "player" then
        return
    end

    if UnitManager.state == "moving" then
        return
    end

    local handler = stateHandlers[UnitManager.state] or stateHandlers.idle
    handler(x, y, button)
end

return Mouse
