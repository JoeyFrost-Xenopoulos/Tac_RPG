-- modules/manager/core.lua
-- Mixin module for UnitManager (returns attach function pattern).
-- Mixin modules export an `attach(UnitManager)` function that adds methods to the target table.
local function attach(UnitManager)
    local Menu = require("modules.ui.menu")
    local Arrows = require("modules.ui.movement_arrows")
    local MovementRange = require("modules.engine.movement_range")
    local Effects = require("modules.audio.sound_effects")
    local TurnManager = require("modules.engine.turn")

    function UnitManager.add(unit)
        table.insert(UnitManager.units, unit)
        UnitManager._addToGrid(unit)
        UnitManager.needsSort = true
    end

    local function getDrawY(unit)
        if unit.isMoving and unit.moveDuration and unit.moveDuration > 0 then
            local t = unit.moveTime / unit.moveDuration
            return unit.startY + (unit.targetY - unit.startY) * t
        end

        return unit.tileY
    end

    function UnitManager.draw()
        if UnitManager.needsSort then
            table.sort(UnitManager.units, function(a, b)
                local ay = getDrawY(a)
                local by = getDrawY(b)
                if ay ~= by then
                    return ay < by
                end

                if a.isMoving ~= b.isMoving then
                    return not a.isMoving
                end

                return (a.tileX or 0) < (b.tileX or 0)
            end)
            UnitManager.needsSort = false
        end
        for _, unit in ipairs(UnitManager.units) do
            if not UnitManager._isUnitDead(unit) then
                unit:draw()
            end
        end
    end

    function UnitManager.removeDeadUnits()
        if UnitManager.selectedUnit and UnitManager._isUnitDead(UnitManager.selectedUnit) then
            UnitManager.deselectAll()
        end

        local removed = false
        for i = #UnitManager.units, 1, -1 do
            local unit = UnitManager.units[i]
            if UnitManager._isUnitDead(unit) then
                UnitManager._removeFromGrid(unit)
                table.remove(UnitManager.units, i)
                removed = true
            end
        end
        if removed then
            UnitManager.needsSort = true
        end

        if UnitManager.battleAttacker and UnitManager._isUnitDead(UnitManager.battleAttacker) then
            UnitManager.battleAttacker = nil
        end
        if UnitManager.battleTarget and UnitManager._isUnitDead(UnitManager.battleTarget) then
            UnitManager.battleTarget = nil
        end
    end

    function UnitManager.getUnitAt(tileX, tileY)
        local k = UnitManager._gridKey(tileX, tileY)
        local list = UnitManager.unitGrid[k]
        if list then
            return list[1]
        end
        return nil
    end

    function UnitManager._gridKey(x, y)
        return x .. "," .. y
    end

    function UnitManager._addToGrid(unit)
        local k = UnitManager._gridKey(unit.tileX, unit.tileY)
        UnitManager.unitGrid[k] = UnitManager.unitGrid[k] or {}
        table.insert(UnitManager.unitGrid[k], unit)
    end

    function UnitManager._removeFromGrid(unit, x, y)
        x = x or unit.tileX
        y = y or unit.tileY
        local k = UnitManager._gridKey(x, y)
        local list = UnitManager.unitGrid[k]
        if list then
            for i = #list, 1, -1 do
                if list[i] == unit then
                    table.remove(list, i)
                    break
                end
            end
            if #list == 0 then
                UnitManager.unitGrid[k] = nil
            end
        end
    end

    function UnitManager._updateGridPosition(unit, oldX, oldY)
        UnitManager._removeFromGrid(unit, oldX, oldY)
        UnitManager._addToGrid(unit)
    end

    function UnitManager.clear()
        UnitManager.units = {}
        UnitManager.selectedUnit = nil
        UnitManager.unitGrid = {}
    end

    function UnitManager.getSelected()
        return UnitManager.selectedUnit
    end

    function UnitManager.deselectAll()
        for _, unit in ipairs(UnitManager.units) do
            unit:setSelected(false)
        end
        UnitManager.selectedUnit = nil
        UnitManager.state = UnitManager.UnitState.IDLE
        Menu.hide()
        Arrows.clear()
        MovementRange.clear()
    end

    function UnitManager.select(unit)
        if unit.hasActed then
            return
        end
        UnitManager.deselectAll()
        unit:setSelected(true)
        UnitManager.selectedUnit = unit
        unit.prevX = unit.tileX
        unit.prevY = unit.tileY
        UnitManager.state = UnitManager.UnitState.IDLE
        MovementRange.show(unit)
        Effects.playConfirm()
    end

    function UnitManager.endPlayerTurn()
        for _, unit in ipairs(UnitManager.units) do
            if unit.isPlayer and not unit.hasActed then
                unit.hasActed = true
            end
        end
        UnitManager.deselectAll()
        TurnManager.endTurn()
    end
end

return attach
