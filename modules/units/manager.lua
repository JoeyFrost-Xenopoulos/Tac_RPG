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
local Options = require("modules.ui.options")
local Attack = require("modules.engine.attack")

UnitManager.units = {}
UnitManager.selectedUnit = nil
UnitManager.state = "idle"
UnitManager.damageDisplays = {}

function UnitManager.add(unit)
    table.insert(UnitManager.units, unit)
end

function UnitManager.update(dt)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    for _, unit in ipairs(UnitManager.units) do
        unit:update(dt)
    end
    
    UnitManager.updateDamageDisplays(dt)

    local unit = UnitManager.selectedUnit    
    if UnitManager.state == "moving" then
        MovementRange.clear()
        if unit and not unit.isMoving then
            UnitManager.state = "menu"
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

            local menuOptions = {}
            
            -- Check if unit can attack
            if unit.isPlayer and Attack.canAttack(unit) then
                table.insert(menuOptions, { text = "Attack", callback = UnitManager.performAttackPrompt })
            end
            
            table.insert(menuOptions, { text = "Wait", callback = UnitManager.confirmMove })
            table.insert(menuOptions, { text = "Cancel", callback = UnitManager.cancelMove })

            Menu.show(mx, my, menuOptions)
        end
        return 
    elseif UnitManager.state == "menu" then
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

        local path = Pathfinding.findPath(
            unit.tileX, unit.tileY, tx, ty, canMoveWithUnits
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
        -- Check if a move actually happened
        local hasMoved = (unit.tileX ~= unit.prevX) or (unit.tileY ~= unit.prevY)
        
        -- Revert position back to where we started
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

function UnitManager.showWaitMenu()
    local unit = UnitManager.selectedUnit
    if not unit then return end
    
    -- Update prevX/prevY to current position so cancel won't revert to old positions from previous turns
    unit.prevX = unit.tileX
    unit.prevY = unit.tileY
    
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
    
    local menuOptions = {}
    
    -- Check if unit can attack
    if unit.isPlayer and Attack.canAttack(unit) then
        table.insert(menuOptions, { text = "Attack", callback = UnitManager.performAttackPrompt })
    end
    
    table.insert(menuOptions, { text = "Wait", callback = UnitManager.confirmMove })
    table.insert(menuOptions, { text = "Cancel", callback = function() UnitManager.state = "idle"; Menu.hide() end })
    
    Menu.show(mx, my, menuOptions)
end

function UnitManager.showEndTurnMenu(tx, ty)
    -- position End menu using the same left/right logic as Wait menu
    UnitManager.state = "menu"
    local screenW = love.graphics.getWidth()

    local clickPixelX = tx * Grid.tileSize

    local mx
    local my = 60

    if clickPixelX < screenW / 2 then
        mx = screenW - Menu.width - 100
    else
        mx = 60
    end

    Menu.show(mx, my, {
        { text = "End All", callback = UnitManager.endPlayerTurn },
        { text = "Options", callback = function() UnitManager.state = "idle"; Menu.hide(); Options.show() end },
        { text = "Suspend", callback = function() Menu.hide(); love.event.quit() end },
        { text = "Cancel", callback = function() UnitManager.state = "idle"; Menu.hide() end }
    })
end

function UnitManager.endPlayerTurn()
    -- Mark all remaining player units as acted
    for _, unit in ipairs(UnitManager.units) do
        if unit.isPlayer and not unit.hasActed then
            unit.hasActed = true
        end
    end
    UnitManager.deselectAll()
    TurnManager.endTurn()
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
    UnitManager.state = "idle"
    MovementRange.show(unit)
    Effects.playConfirm()
end

function UnitManager.performAttackPrompt()
    local unit = UnitManager.selectedUnit
    if not unit then return end
    
    local enemies = Attack.getEnemiesInRange(unit)
    if #enemies == 0 then 
        Menu.hide()
        UnitManager.state = "idle"
        return 
    end
    
    -- Show available targets for attack
    UnitManager.state = "selectingAttack"
    Menu.hide()
    MovementRange.clear()
    Grid.clearHighlights()
    
    -- Highlight enemies in range with a different color
    for _, enemy in ipairs(enemies) do
        Grid.highlightTile(enemy.tileX, enemy.tileY, {1.0, 0.0, 0.0, 0.6})
    end
end

function UnitManager.performAttack(attacker, target)
    if not attacker or not target then return end
    
    -- Make attacker face the target
    if target.tileX > attacker.tileX then
        attacker.facingX = 1
    elseif target.tileX < attacker.tileX then
        attacker.facingX = -1
    end

    -- Make defender face the attacker
    if attacker.tileX > target.tileX then
        target.facingX = 1
    elseif attacker.tileX < target.tileX then
        target.facingX = -1
    end
    
    -- Play attack sound
    Effects.playSelect()
    
    -- Show battle screen
    local Battle = require("modules.combat.battle")
    Battle.startBattle(attacker, target)
    
    -- Store the attacker and target for the battle to process
    UnitManager.battleAttacker = attacker
    UnitManager.battleTarget = target
    
    -- Deselect unit (will end turn once battle completes)
    UnitManager.deselectAll()
end

function UnitManager.showDamage(target, damage)
    -- Create a damage display at the target's position
    table.insert(UnitManager.damageDisplays, {
        x = target.tileX * Grid.tileSize + 32,
        y = target.tileY * Grid.tileSize,
        damage = damage,
        time = 0,
        duration = 1.0
    })
end

function UnitManager.updateDamageDisplays(dt)
    for i = #UnitManager.damageDisplays, 1, -1 do
        local display = UnitManager.damageDisplays[i]
        display.time = display.time + dt
        
        if display.time >= display.duration then
            table.remove(UnitManager.damageDisplays, i)
        end
    end
end

function UnitManager.drawDamageDisplays()
    if #UnitManager.damageDisplays == 0 then return end
    
    love.graphics.setFont(love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 48))
    love.graphics.setColor(1, 0, 0, 1) -- Red color for damage
    
    for _, display in ipairs(UnitManager.damageDisplays) do
        local alpha = 1 - (display.time / display.duration)
        local offsetY = display.time * 30  -- Move up over time
        
        love.graphics.setColor(1, 0, 0, alpha)
        love.graphics.printf(tostring(display.damage), display.x - 20, display.y - offsetY, 40, "center")
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

return UnitManager