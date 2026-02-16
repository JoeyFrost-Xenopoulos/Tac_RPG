-- modules/world/cursor.lua
local Cursor = {}
local Map = require("modules.world.map")
local MovementRange = require("modules.engine.movement_range")
local Menu = require("modules.ui.menu")
local Effects = require("modules.audio.sound_effects")
local Options = require("modules.ui.options")
local CameraManager = require("modules.engine.camera_manager")
local Attack = require("modules.engine.attack")
local WeaponSelect = require("modules.ui.weapon_selector")

Cursor.color = {1, 1, 0, 0.5}
Cursor.tileX = 1
Cursor.tileY = 1

Cursor.tileSize = 64
Cursor.scaleX = 1
Cursor.scaleY = 1
Cursor.gridWidth = 15
Cursor.gridHeight = 12
Cursor.pulse = 0

Cursor.cursors = {}
Cursor.current = nil
Cursor.selectCooldown = 0.06
Cursor.selectTimer = 0
Cursor.lastSnappedEnemy = nil

function Cursor.load()
    -- Grid cursor
    Cursor.image = love.graphics.newImage("assets/ui/cursors/Cursor_04.png")
    Cursor.imageWidth = Cursor.image:getWidth()

    -- Default cursor
    local img1 = love.image.newImageData("assets/ui/cursors/Cursor_01.png")
    Cursor.cursors.default = love.mouse.newCursor(img1, 0, 0)

    -- Hover cursor
    local img2 = love.image.newImageData("assets/ui/cursors/Cursor_02.png")
    Cursor.cursors.hover = love.mouse.newCursor(img2, 0, 0)

    -- Blocked cursor
    local img3 = love.image.newImageData("assets/ui/cursors/Cursor_03.png")
    Cursor.cursors.blocked = love.mouse.newCursor(img3, 0, 0)
end

function Cursor.setMouse(name)
    if Cursor.current == name then return end
    Cursor.current = name
    love.mouse.setCursor(Cursor.cursors[name])
end

function Cursor.setGrid(tileSize, gridWidth, gridHeight, scaleX, scaleY)
    Cursor.tileSize = tileSize or Cursor.tileSize
    Cursor.gridWidth = gridWidth or Cursor.gridWidth
    Cursor.gridHeight = gridHeight or Cursor.gridHeight
    Cursor.scaleX = scaleX or 1
    Cursor.scaleY = scaleY or 1
end

function Cursor.getTile()
    return Cursor.tileX, Cursor.tileY
end

function Cursor.update()
    local Menu = require("modules.ui.menu")
    local WeaponSelect = require("modules.ui.weapon_selector")
    local UnitStats = require("modules.ui.unit_stats")
    local Options = require("modules.ui.options")
    
    local mx, my = love.mouse.getPosition()
    
    -- Reset cursor if any overlay menu is visible
    if Menu.isHovered(mx, my) or WeaponSelect.visible or UnitStats.visible or Options.visible then
        Cursor.setMouse("default")
        return
    end
    
    -- Convert screen coordinates to world coordinates using camera
    local worldX, worldY = CameraManager.screenToWorld(mx, my)
    
    local scaledX = worldX / Cursor.scaleX
    local scaledY = worldY / Cursor.scaleY

    local prevX, prevY = Cursor.tileX, Cursor.tileY

    Cursor.tileX = math.floor(scaledX / Cursor.tileSize) + 1
    Cursor.tileY = math.floor(scaledY / Cursor.tileSize) + 1

    Cursor.tileX = math.max(1, math.min(Cursor.tileX, 18))  -- Map width
    Cursor.tileY = math.max(1, math.min(Cursor.tileY, 15))  -- Map height

    local dt = love.timer.getDelta()
    Cursor.pulse = Cursor.pulse + dt

    local UnitManager = require("modules.units.manager")

    Cursor.selectTimer = math.max(0, Cursor.selectTimer - dt)
    if prevX ~= Cursor.tileX or prevY ~= Cursor.tileY then
        if Cursor.selectTimer <= 0
            and not Menu.visible
            and not Options.visible
            and UnitManager.state ~= "selectingAttack"
            and UnitManager.state ~= "combatSummary" then
            Effects.playSelect()
            Cursor.selectTimer = Cursor.selectCooldown
        end
    end
    local tx, ty = Cursor.tileX, Cursor.tileY
    local selectedUnit = UnitManager.selectedUnit

    if selectedUnit and (UnitManager.state == "selectingAttack" or UnitManager.state == "combatSummary") then
        local enemies = Attack.getEnemiesInRange(selectedUnit)
        
        -- Force cursor to snap to nearest enemy in range
        if #enemies > 0 then
            local nearestEnemy = enemies[1]
            local minDist = math.abs(tx - nearestEnemy.tileX) + math.abs(ty - nearestEnemy.tileY)
            
            for _, enemy in ipairs(enemies) do
                local dist = math.abs(tx - enemy.tileX) + math.abs(ty - enemy.tileY)
                if dist < minDist then
                    minDist = dist
                    nearestEnemy = enemy
                end
            end
            
            -- Keep cursor on the last selected enemy during combat summary
            if UnitManager.state == "combatSummary" then
                -- Keep cursor locked on the target enemy
                if UnitManager.battleTarget then
                    Cursor.tileX = UnitManager.battleTarget.tileX
                    Cursor.tileY = UnitManager.battleTarget.tileY
                    Cursor.lastSnappedEnemy = UnitManager.battleTarget
                end
            else
                -- Normal enemy snapping during attack selection
                if Cursor.lastSnappedEnemy ~= nearestEnemy then
                    Effects.playSelect()
                    Cursor.lastSnappedEnemy = nearestEnemy
                end

                -- Snap cursor to nearest enemy
                Cursor.tileX = nearestEnemy.tileX
                Cursor.tileY = nearestEnemy.tileY
            end
            Cursor.setMouse("hover")
        else
            Cursor.lastSnappedEnemy = nil
            Cursor.setMouse("blocked")
        end
        return
    end

    Cursor.lastSnappedEnemy = nil

    if selectedUnit then
        if (tx == selectedUnit.tileX and ty == selectedUnit.tileY)
        or MovementRange.canReach(tx, ty) then
            Cursor.setMouse("hover")
        else
            Cursor.setMouse("blocked")
        end
    else
        Cursor.setMouse("default")
    end
end

function Cursor.draw()
    if not Cursor.image then return end
    local mx, my = love.mouse.getPosition()
    if Menu.isHovered(mx, my) then return end

    love.graphics.push()
    love.graphics.scale(Cursor.scaleX, Cursor.scaleY)

    local tilePx = (Cursor.tileX - 1) * Cursor.tileSize
    local tilePy = (Cursor.tileY - 1) * Cursor.tileSize

    local imgW, imgH = Cursor.image:getDimensions()
    local scale = Cursor.tileSize / Cursor.imageWidth

    local pulse = 1 + math.sin(Cursor.pulse * 5) * 0.05
    scale = scale * pulse

    local drawX = tilePx + Cursor.tileSize / 2
    local drawY = tilePy + Cursor.tileSize / 2

    -- Check if we're in attack selection mode for red highlight
    local UnitManager = require("modules.units.manager")
    if UnitManager.state == "selectingAttack" or UnitManager.state == "combatSummary" then
        love.graphics.setColor(1, 0.2, 0.2, 1)  -- Red color for attack targeting
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    love.graphics.draw(Cursor.image, drawX, drawY, 0, scale, scale, imgW / 2, imgH / 2)
    
    -- Reset color to white after drawing
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.pop()
end

return Cursor
