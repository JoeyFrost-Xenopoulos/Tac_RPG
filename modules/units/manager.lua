-- modules/units/manager.lua
local UnitManager = {}

UnitManager.units = {}
UnitManager.selectedUnit = nil

function UnitManager.add(unit)
    table.insert(UnitManager.units, unit)
end

function UnitManager.update(dt)
    for _, unit in ipairs(UnitManager.units) do
        unit:update(dt)
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
end

return UnitManager