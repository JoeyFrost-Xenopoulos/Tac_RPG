-- modules/units/manager.lua
local UnitManager = {}
local Cursor = require("modules.ui.cursor")
local Pathfinding = require("modules.engine.pathfinding")
local MovementRange = require("modules.engine.movement_range")
local Map = require("modules.world.map")
local Arrows = require("modules.ui.movement_arrows")
local Menu = require("modules.ui.menu")
local Grid = require("modules.ui.grid")
local Effects = require("modules.audio.sound_effects")
local TurnManager = require("modules.engine.turn")

UnitManager.units = {}
UnitManager.selectedUnit = nil
UnitManager.state = "idle"

function UnitManager.add(unit)
    table.insert(UnitManager.units, unit)
end

function UnitManager.update(dt)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    for _, unit in ipairs(UnitManager.units) do
        unit:update(dt)
    end

    local unit = UnitManager.selectedUnit    
    if UnitManager.state == "moving" then
        MovementRange.clear()
        if unit and not unit.isMoving then
            UnitManager.state = "menu"           
            local screenW = love.graphics.getWidth()

            local unitPixelX = unit.tileX * Grid.tileSize

            local mx
            local my = 60

            if unitPixelX < screenW / 2 then
                mx = screenW - Menu.width - 100
            else
                mx = 60
            end

            Menu.show(mx, my, {
                { text = "Wait", callback = UnitManager.confirmMove },
                { text = "Cancel", callback = UnitManager.cancelMove }
            })
        end
        return 
    elseif UnitManager.state == "menu" then
        return 
    end

    -- Don't allow player input during enemy turn
    if TurnManager.getCurrentTurn() ~= "player" then
        Arrows.clear()
        return
    end

    if not unit or not unit.isPlayer then
        Arrows.clear()
        return
    end
    
    local tx, ty = Cursor.getTile()

    if MovementRange.canReach(tx, ty)
       and not (tx == unit.tileX and ty == unit.tileY) then

        local path = Pathfinding.findPath(
            unit.tileX, unit.tileY, tx, ty, Map.canMove
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
        unit.tileX = unit.prevX
        unit.tileY = unit.prevY
        unit.isMoving = false
        UnitManager.state = "idle"
        MovementRange.show(unit) 
    end
    Menu.hide()
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
    UnitManager.state = "idle"
    MovementRange.show(unit)
    Effects.playConfirm()
end

return UnitManager