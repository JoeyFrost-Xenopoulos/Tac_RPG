-- modules/manager/movement.lua
local function attach(UnitManager)
    local MovementRange = require("modules.engine.movement_range")
    local Menu = require("modules.ui.menu")
    local TurnManager = require("modules.engine.turn")

    function UnitManager.confirmMove()
        local unit = UnitManager.selectedUnit
        if unit then
            TurnManager.markUnitAsMoved(unit)
            UnitManager.deselectAll()

            if TurnManager.areAllUnitsMoved() then
                TurnManager.endTurn()
            end
        end
    end

    function UnitManager.cancelMove()
        local unit = UnitManager.selectedUnit

        if unit then
            local hasMoved = UnitManager.hasUnitMoved(unit)

            if hasMoved then
                local oldX, oldY = unit.tileX, unit.tileY
                unit.tileX = unit.prevX
                unit.tileY = unit.prevY
                unit.isMoving = false
                UnitManager.needsSort = true
                UnitManager._updateGridPosition(unit, oldX, oldY)
            end
        end

        UnitManager.state = "idle"
        if unit then
            MovementRange.show(unit)
        end
        Menu.hide()
    end
end

return attach
