-- modules/manager/update.lua
local function attach(UnitManager)
    local Cursor = require("modules.ui.cursor")
    local Pathfinding = require("modules.engine.pathfinding")
    local MovementRange = require("modules.engine.movement_range")
    local Map = require("modules.world.map")
    local Arrows = require("modules.ui.movement_arrows")
    local Menu = require("modules.ui.menu")
    local Grid = require("modules.ui.grid")
    local Effects = require("modules.audio.sound_effects")
    local TurnManager = require("modules.engine.turn")
    local Attack = require("modules.engine.attack")

    function UnitManager.update(dt)
        for _, unit in ipairs(UnitManager.units) do
            if not UnitManager._isDead(unit) then
                unit:update(dt)
            end
        end

        UnitManager.updateDamageDisplays(dt)

        local unit = UnitManager.selectedUnit
        if UnitManager.state == UnitManager.UnitState.MOVING then
            MovementRange.clear()
            if unit and not unit.isMoving then
                UnitManager.state = UnitManager.UnitState.MENU
                MovementRange.showAttackRange(unit)
                local screenW = love.graphics.getWidth()

                local unitPixelX = unit.tileX * Grid.tileSize

                local mx
                local my = 60

                if unitPixelX < screenW / 2 then
                    mx = screenW - Menu.width - 100
                else
                    mx = 60
                end

                local menuOptions = UnitManager.buildWaitMenuOptions(unit)

                Menu.show(mx, my, menuOptions, 40)
            end
            return
        elseif UnitManager.state == UnitManager.UnitState.MENU then
            return
        end

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

            local path = nil
            if tx ~= UnitManager._lastPathTileX or ty ~= UnitManager._lastPathTileY then
                UnitManager._lastPathTileX = tx
                UnitManager._lastPathTileY = ty

                local function canMoveWithUnits(fromX, fromY, toX, toY)
                    if not Map.canMove(fromX, fromY, toX, toY) then
                        return false
                    end
                    for _, otherUnit in ipairs(UnitManager.units) do
                        if otherUnit ~= unit and otherUnit.tileX == toX and otherUnit.tileY == toY then
                            if not otherUnit.isPlayer then
                                return false
                            end
                        end
                    end
                    return true
                end

                path = Pathfinding.findPath(
                    unit.tileX, unit.tileY, tx, ty, canMoveWithUnits
                )
                if path and unit.maxMoveRange and #path > unit.maxMoveRange + 1 then
                    local trimmed = {}
                    for i = 1, unit.maxMoveRange + 1 do
                        trimmed[i] = path[i]
                    end
                    path = trimmed
                end
                UnitManager._lastPath = path
            else
                path = UnitManager._lastPath
            end

            if path then
                Arrows.setPath(path)
            else
                Arrows.clear()
            end
        else
            Arrows.clear()
        end
    end
end

return attach
