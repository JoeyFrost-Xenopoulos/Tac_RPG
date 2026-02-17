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
            local hasMoved = (unit.tileX ~= unit.prevX) or (unit.tileY ~= unit.prevY)

            if hasMoved then
                unit.tileX = unit.prevX
                unit.tileY = unit.prevY
                unit.isMoving = false
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
