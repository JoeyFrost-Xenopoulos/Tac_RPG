-- modules/world/cursor.lua
local Cursor = {}
local Map = require("modules.world.map")
local MovementRange = require("modules.engine.movement_range")
local Menu = require("modules.ui.menu")
local Effects = require("modules.audio.sound_effects")
local Options = require("modules.ui.options")
local CameraManager = require("modules.engine.camera_manager")
local Attack = require("modules.engine.attack")

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
    local mx, my = love.mouse.getPosition()
    if Menu.isHovered(mx, my) then
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

    Cursor.selectTimer = math.max(0, Cursor.selectTimer - dt)
    if prevX ~= Cursor.tileX or prevY ~= Cursor.tileY then
        if Cursor.selectTimer <= 0 and not Menu.visible and not Options.visible then
            Effects.playSelect()
            Cursor.selectTimer = Cursor.selectCooldown
        end
    end

    local UnitManager = require("modules.units.manager")
    local tx, ty = Cursor.tileX, Cursor.tileY
    local selectedUnit = UnitManager.selectedUnit

    if selectedUnit and UnitManager.state == "selectingAttack" then
        local hoveredUnit = UnitManager.getUnitAt(tx, ty)
        if hoveredUnit and not hoveredUnit.isPlayer then
            local enemies = Attack.getEnemiesInRange(selectedUnit)
            local inRange = false
            for _, enemy in ipairs(enemies) do
                if enemy == hoveredUnit then
                    inRange = true
                    break
                end
            end
            Cursor.setMouse(inRange and "hover" or "blocked")
        else
            Cursor.setMouse("blocked")
        end
        return
    end

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

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Cursor.image, drawX, drawY, 0, scale, scale, imgW / 2, imgH / 2)

    love.graphics.pop()
end

return Cursor
