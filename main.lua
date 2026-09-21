-- main.lua
require("config")

-- Core systems
local Input = require("modules.engine.input")
local Mouse = require("modules.engine.mouse")
local Map = require("modules.world.map")
local Grid = require("modules.ui.grid")
local Cursor = require("modules.ui.cursor")
local Banner = require("modules.ui.banner")
local BannerController = require("modules.ui.banner_controller")
local Arrows = require("modules.ui.movement_arrows")
local Menu = require("modules.ui.menu")
local WeaponSelect = require("modules.ui.weapon_selector")
local ItemSelector = require("modules.ui.item_selector")
local TurnCounter = require("modules.ui.turn_counter")
local Clouds = require("modules.world.clouds")
local Leaf = require("modules.world.leaf")
local TurnManager = require("modules.engine.turn")
local TurnOverlay = require("modules.ui.turn_overlay")
local Options = require("modules.ui.options")
local UnitStats = require("modules.ui.unit_stats")
local CombatSummary = require("modules.ui.combat_summary")
local Battle = require("modules.combat.battle")
local CameraManager = require("modules.engine.camera_manager")
local AttackIndicator = require("modules.ui.attack_indicator")

-- Music
local Effects = require("modules.audio.sound_effects")

-- Units
local UnitManager = require("modules.units.manager")
local UnitSpawner = require("modules.units.unit_spawner")


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

    -- Load units from map configuration
    local mapUnitConfig = require("map.config.map_1_units")
    UnitSpawner.spawnUnits(mapUnitConfig, UnitManager)
    
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
    AttackIndicator.draw()
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
