-- modules/units/manager.lua
local UnitManager = {}
local Cursor = require("modules.ui.cursor")
local Pathfinding = require("modules.engine.pathfinding")
local MovementRange = require("modules.engine.movement_range")
local Map = require("modules.world.map")
local Arrows = require("modules.ui.movement_arrows")

UnitManager.units = {}
UnitManager.selectedUnit = nil

function UnitManager.add(unit)
    table.insert(UnitManager.units, unit)
end

function UnitManager.update(dt)
    for _, unit in ipairs(UnitManager.units) do
        unit:update(dt)
    end

    local unit = UnitManager.selectedUnit
    if not unit or unit.isMoving or not unit.isPlayer then
        Arrows.clear()
        return
    end
    local tx, ty = Cursor.getTile()

    if MovementRange.canReach(tx, ty)
       and not (tx == unit.tileX and ty == unit.tileY) then

        local path = Pathfinding.findPath(
            unit.tileX,
            unit.tileY,
            tx, ty,
            Map.canMove
        )
        if path and unit.maxMoveRange and #path > unit.maxMoveRange + 1 then
            local trimmed = {}
            for i = 1, unit.maxMoveRange + 1 do
                trimmed[i] = path[i]
            end
            path = trimmed
        end

        Arrows.setPath(path)
    else
        Arrows.clear()
    end
end

function UnitManager.draw()
    table.sort(UnitManager.units, function(a, b) return a.tileY < b.tileY end)    
    for _, unit in ipairs(UnitManager.units) do
        unit:draw()
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

function UnitManager.deselectAll()
    for _, unit in ipairs(UnitManager.units) do
        unit:setSelected(false)
    end
    UnitManager.selectedUnit = nil
end

function UnitManager.select(unit)
    UnitManager.deselectAll()
    unit:setSelected(true)
    UnitManager.selectedUnit = unit
    Arrows.clear()
end

return UnitManager