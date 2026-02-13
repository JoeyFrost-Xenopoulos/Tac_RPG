-- modules/engine/camera_manager.lua
-- Responsible for: camera positioning, zooming, viewport management, and coordinate conversion
local CameraManager = {}

local Camera = require("libs.camera")

-- Camera instance
CameraManager.camera = Camera()

-- Configuration
CameraManager.mapWidthTiles = 18
CameraManager.mapHeightTiles = 15
CameraManager.tileSize = 64
CameraManager.viewportWidthTiles = 15
CameraManager.viewportHeightTiles = 12

-- Zoom settings
CameraManager.zoom = 1.0
CameraManager.minZoom = 0.8  -- Prevent zooming out too far (shows entire map width/height without black)
CameraManager.maxZoom = 2.0
CameraManager.zoomSpeed = 0.1

-- Drag settings
CameraManager.isDragging = false
CameraManager.dragStartX = 0
CameraManager.dragStartY = 0
CameraManager.dragStartCameraX = 0
CameraManager.dragStartCameraY = 0

function CameraManager.init(mapWidthTiles, mapHeightTiles, tileSize, viewportWidthTiles, viewportHeightTiles)
    CameraManager.mapWidthTiles = mapWidthTiles
    CameraManager.mapHeightTiles = mapHeightTiles
    CameraManager.tileSize = tileSize
    CameraManager.viewportWidthTiles = viewportWidthTiles
    CameraManager.viewportHeightTiles = viewportHeightTiles
    
    -- Start camera at top-left (show first viewport-sized chunk)
    local startX = (viewportWidthTiles * tileSize) / 2
    local startY = (viewportHeightTiles * tileSize) / 2
    CameraManager.camera:lookAt(startX, startY)
end

function CameraManager.update(dt)
    -- Apply current zoom to camera
    CameraManager.camera:zoomTo(CameraManager.zoom)
    
    -- Handle WASD keyboard panning
    local panSpeed = 400  -- pixels per second
    local dx = 0
    local dy = 0
    
    if love.keyboard.isDown("w") then
        dy = -panSpeed * dt
    end
    if love.keyboard.isDown("s") then
        dy = panSpeed * dt
    end
    if love.keyboard.isDown("a") then
        dx = -panSpeed * dt
    end
    if love.keyboard.isDown("d") then
        dx = panSpeed * dt
    end
    
    if dx ~= 0 or dy ~= 0 then
        local cx, cy = CameraManager.camera:position()
        local newX = cx + (dx / CameraManager.zoom)
        local newY = cy + (dy / CameraManager.zoom)
        CameraManager._clampCamera(newX, newY)
    end
    
    if CameraManager.isDragging then
        local mx, my = love.mouse.getPosition()
        -- Calculate how far mouse has moved from drag start
        local dragDeltaX = mx - CameraManager.dragStartX
        local dragDeltaY = my - CameraManager.dragStartY
        
        -- When mouse moves right, camera should move left (inverse control)
        -- So we subtract the delta
        local newX = CameraManager.dragStartCameraX - (dragDeltaX / CameraManager.zoom)
        local newY = CameraManager.dragStartCameraY - (dragDeltaY / CameraManager.zoom)
        
        -- Clamp to map boundaries
        CameraManager._clampCamera(newX, newY)
    end
end

function CameraManager._clampCamera(x, y)
    local viewportPixelWidth = CameraManager.viewportWidthTiles * CameraManager.tileSize
    local viewportPixelHeight = CameraManager.viewportHeightTiles * CameraManager.tileSize
    local mapPixelWidth = CameraManager.mapWidthTiles * CameraManager.tileSize
    local mapPixelHeight = CameraManager.mapHeightTiles * CameraManager.tileSize
    
    -- Account for zoom when calculating bounds
    local zoomedViewportWidth = viewportPixelWidth / CameraManager.zoom
    local zoomedViewportHeight = viewportPixelHeight / CameraManager.zoom
    
    -- Prevent camera from showing outside map
    local minX = zoomedViewportWidth / 2
    local minY = zoomedViewportHeight / 2
    local maxX = mapPixelWidth - (zoomedViewportWidth / 2)
    local maxY = mapPixelHeight - (zoomedViewportHeight / 2)
    
    x = math.max(minX, math.min(maxX, x))
    y = math.max(minY, math.min(maxY, y))
    
    CameraManager.camera:lookAt(x, y)
end

function CameraManager.mousepressed(x, y, button)
    -- Currently not using mouse for camera control
    -- Using WASD instead
end

function CameraManager.mousereleased(x, y, button)
    -- Currently not using mouse for camera control
end

function CameraManager.wheelmoved(x, y)
    local Menu = require("modules.ui.menu")
    local Options = require("modules.ui.options")
    local UnitStats = require("modules.ui.unit_stats")
    
    -- Don't allow zoom if menus are open
    if Menu.visible or Options.visible or UnitStats.visible then
        return
    end
    
    -- Get mouse position for zoom center
    local mx, my = love.mouse.getPosition()
    
    -- Convert screen position to world position (before zoom)
    local cx, cy = CameraManager.camera:position()
    local wx_before = mx / CameraManager.zoom + cx - (love.graphics.getWidth() / 2 / CameraManager.zoom)
    local wy_before = my / CameraManager.zoom + cy - (love.graphics.getHeight() / 2 / CameraManager.zoom)
    
    -- Update zoom
    CameraManager.zoom = CameraManager.zoom + (y * CameraManager.zoomSpeed)
    CameraManager.zoom = math.max(CameraManager.minZoom, math.min(CameraManager.maxZoom, CameraManager.zoom))
    
    -- Convert screen position to world position (after zoom)
    local wx_after = mx / CameraManager.zoom + cx - (love.graphics.getWidth() / 2 / CameraManager.zoom)
    local wy_after = my / CameraManager.zoom + cy - (love.graphics.getHeight() / 2 / CameraManager.zoom)
    
    -- Adjust camera to keep mouse at same world location
    local newCx = cx + (wx_before - wx_after)
    local newCy = cy + (wy_before - wy_after)
    
    CameraManager._clampCamera(newCx, newCy)
end

function CameraManager.attach()
    CameraManager.camera:attach()
end

function CameraManager.detach()
    CameraManager.camera:detach()
end

function CameraManager.screenToWorld(screenX, screenY)
    -- Get camera position and apply camera transform to convert screen to world coords
    local cx, cy = CameraManager.camera:position()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- When camera is at (cx, cy) with zoom, screen point (screenX, screenY) maps to world as:
    local worldX = (screenX - screenW/2) / CameraManager.zoom + cx
    local worldY = (screenY - screenH/2) / CameraManager.zoom + cy
    return worldX, worldY
end

function CameraManager.worldToScreen(worldX, worldY)
    local cx, cy = CameraManager.camera:position()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    local screenX = (worldX - cx) * CameraManager.zoom + screenW / 2
    local screenY = (worldY - cy) * CameraManager.zoom + screenH / 2
    return screenX, screenY
end

function CameraManager.getZoom()
    return CameraManager.zoom
end

function CameraManager.setZoom(zoom)
    CameraManager.zoom = math.max(CameraManager.minZoom, math.min(CameraManager.maxZoom, zoom))
    local cx, cy = CameraManager.camera:position()
    CameraManager._clampCamera(cx, cy)
end

return CameraManager
