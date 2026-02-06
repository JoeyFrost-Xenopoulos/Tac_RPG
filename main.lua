-- main.lua
require("config")

-- Core systems
Mouse = require("modules.engine.mouse")
Map = require("modules.world.map")
Grid = require("modules.ui.grid")
Cursor = require("modules.ui.cursor")
Banner = require("modules.ui.banner")
BannerController = require("modules.ui.banner_controller")
Arrows = require("modules.ui.movement_arrows")
Menu = require("modules.ui.menu")
Clouds = require("modules.world.clouds")
Leaf = require("modules.world.leaf")
TurnManager = require("modules.engine.turn")
TurnOverlay = require("modules.ui.turn_overlay")
Options = require("modules.ui.options")
Battle = require("modules.combat.battle")
CameraManager = require("modules.engine.camera_manager")

-- Music
Effects = require("modules.audio.sound_effects")

-- Units
UnitManager = require("modules.units.manager")
Soldier = require("modules.units.soldier")
Soldier2 = require("modules.units.soldier_2")
Enemy_Soldier = require("modules.units.enemy_soldier")

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    Map.load("map/map_1.lua")

    -- Initialize camera: 18x15 tiles map, 15x12 viewport, 64px tiles
    CameraManager.init(19, 15, TILE_SIZE, GRID_WIDTH, GRID_HEIGHT)

    Cursor.load()
    Cursor.setGrid(Grid.tileSize, Grid.width, Grid.height)
    Banner.load()
    Arrows.load()
    Menu.load()
    Options.load()
    Battle.load()
    Effects.load()
    Effects.playMainTheme()
    Clouds.load()
    Leaf.load()

    UnitManager.add(Soldier.unit)
    UnitManager.add(Soldier2.unit)
    UnitManager.add(Enemy_Soldier.unit)

    Soldier.setPosition(3, 3)
    Soldier2.setPosition(5, 2)
    Enemy_Soldier.setPosition(8, 2)
    
    TurnManager.startTurn()
end

function love.update(dt)
    CameraManager.update(dt)
    Map.update(dt)
    Cursor.update()
    Options.update(dt)
    Battle.update(dt)
    TurnOverlay.update(dt)
    UnitManager.update(dt)
    Banner.update(dt)
    Menu.update(dt)
    Clouds.update(dt)
    Leaf.update(dt)
    TurnManager.updateEnemyTurn(dt)

    local mx, my = love.mouse.getPosition()
    local worldMx, worldMy = CameraManager.screenToWorld(mx, my)
    BannerController.update(worldMx, worldMy)
end

function love.draw()
    CameraManager.attach()
    
    Map.drawLayersBelowSoldier()
    Grid.draw()

    Arrows.draw()
    UnitManager.draw()
    UnitManager.drawDamageDisplays()
    Map.drawTrees()
    Map.drawLayersAboveSoldier()
    Cursor.draw()
    Clouds.draw()
    Leaf.draw()
    
    CameraManager.detach()
    
    BannerController.draw()
    Options.draw()
    Menu.draw()
    TurnOverlay.draw()
    Battle.draw()
end

function love.mousepressed(x, y, button)
    CameraManager.mousepressed(x, y, button)
    
    if TurnManager.isOverlayActive() then
        return
    end
    Mouse.pressed(x, y, button)
end

function love.mousereleased(x, y, button)
    CameraManager.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
    CameraManager.wheelmoved(x, y)
end
