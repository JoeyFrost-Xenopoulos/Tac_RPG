-- modules/manager/core.lua
local function attach(UnitManager)
    local Menu = require("modules.ui.menu")
    local Arrows = require("modules.ui.movement_arrows")
    local MovementRange = require("modules.engine.movement_range")
    local Effects = require("modules.audio.sound_effects")
    local TurnManager = require("modules.engine.turn")

    function UnitManager.add(unit)
        table.insert(UnitManager.units, unit)
    end

    local function getDrawY(unit)
        if unit.isMoving and unit.moveDuration and unit.moveDuration > 0 then
            local t = unit.moveTime / unit.moveDuration
            return unit.startY + (unit.targetY - unit.startY) * t
        end

        return unit.tileY
    end

    function UnitManager.draw()
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

        for i = #UnitManager.units, 1, -1 do
            local unit = UnitManager.units[i]
            if UnitManager._isUnitDead(unit) then
                table.remove(UnitManager.units, i)
            end
        end

        if UnitManager.battleAttacker and UnitManager._isUnitDead(UnitManager.battleAttacker) then
            UnitManager.battleAttacker = nil
        end
        if UnitManager.battleTarget and UnitManager._isUnitDead(UnitManager.battleTarget) then
            UnitManager.battleTarget = nil
        end
    end

    function UnitManager.getUnitAt(tileX, tileY)
        for _, unit in ipairs(UnitManager.units) do
            if unit.tileX == tileX and unit.tileY == tileY then
                return unit
            end
        end
        return nil
    end

    function UnitManager.getSelected()
        return UnitManager.selectedUnit
    end

    function UnitManager.deselectAll()
        for _, unit in ipairs(UnitManager.units) do
            unit:setSelected(false)
        end
        UnitManager.selectedUnit = nil
        UnitManager.state = "idle"
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
        UnitManager.state = "idle"
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
