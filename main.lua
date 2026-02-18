-- main.lua
require("config")

-- Core systems
Input = require("modules.engine.input")
Mouse = require("modules.engine.mouse")
Map = require("modules.world.map")
Grid = require("modules.ui.grid")
Cursor = require("modules.ui.cursor")
Banner = require("modules.ui.banner")
BannerController = require("modules.ui.banner_controller")
Arrows = require("modules.ui.movement_arrows")
Menu = require("modules.ui.menu")
WeaponSelect = require("modules.ui.weapon_selector")
ItemSelector = require("modules.ui.item_selector")
TurnCounter = require("modules.ui.turn_counter")
Clouds = require("modules.world.clouds")
Leaf = require("modules.world.leaf")
TurnManager = require("modules.engine.turn")
TurnOverlay = require("modules.ui.turn_overlay")
Options = require("modules.ui.options")
UnitStats = require("modules.ui.unit_stats")
CombatSummary = require("modules.ui.combat_summary")
Battle = require("modules.combat.battle")
CameraManager = require("modules.engine.camera_manager")

-- Music
Effects = require("modules.audio.sound_effects")

-- Units
UnitManager = require("modules.units.manager")
Soldier = require("modules.units.soldier")
Enemy_Soldier = require("modules.units.enemy_soldier")
Harpoon_Fish = require("modules.units.harpoon_fish")

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
    WeaponSelect.load()
    ItemSelector.load()
    TurnCounter.load()
    Options.load()
    UnitStats.load()
    CombatSummary.load()
    Battle.load()
    Effects.load()
    Effects.playMainTheme()
    Clouds.load()
    Leaf.load()

    UnitManager.add(Soldier.unit)
    UnitManager.add(Soldier.unit2)
    UnitManager.add(Enemy_Soldier.unit)
    UnitManager.add(Enemy_Soldier.unit2)
    UnitManager.add(Harpoon_Fish.player.unit)
    UnitManager.add(Harpoon_Fish.enemy.unit)

    Soldier.setPosition(3, 3)
    Soldier.setPosition2(5, 2)
    Enemy_Soldier.setPosition(9, 2)
    Enemy_Soldier.setPosition2(8, 3)
    Harpoon_Fish.player.setPosition(5, 7)
    Harpoon_Fish.enemy.setPosition(6, 7)
    
    TurnManager.startTurn()
end

function love.update(dt)
    CameraManager.update(dt)
    Map.update(dt)
    Cursor.update()
    Options.update(dt)
    UnitStats.update(dt)
    Battle.update(dt)
    TurnOverlay.update(dt)
    UnitManager.update(dt)
    Banner.update(dt)
    Menu.update(dt)
    WeaponSelect.update(dt)
    ItemSelector.update(dt)
    Clouds.update(dt)
    Leaf.update(dt)
    TurnManager.updateEnemyTurn(dt)
    Effects.update(dt)

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
    UnitStats.draw()
    Menu.draw()
    WeaponSelect.draw()
    ItemSelector.draw()
    TurnCounter.draw()
    TurnOverlay.draw()
    CombatSummary.draw()
    Battle.draw()
end

function love.mousepressed(x, y, button)
    Input.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    Input.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
    Input.wheelmoved(x, y)
end

function love.keypressed(key)
    Input.keypressed(key)
end
