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

-- Music
Effects = require("modules.audio.sound_effects")

-- Units
UnitManager = require("modules.units.manager")
Soldier = require("modules.units.soldier")
Enemy_Soldier = require("modules.units.enemy_soldier")

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    Map.load("map/map_1.lua")

    Cursor.load()
    Cursor.setGrid(Grid.tileSize, Grid.width, Grid.height)
    Banner.load()
    Arrows.load()
    Menu.load()
    Effects.load()
    Effects.playMainTheme()
    Clouds.load()

    UnitManager.add(Soldier.unit)
    UnitManager.add(Enemy_Soldier.unit)

    Soldier.setPosition(3, 3)
    Enemy_Soldier.setPosition(3, 4)
end

function love.update(dt)
    Map.update(dt)
    Cursor.update()
    UnitManager.update(dt)
    Banner.update(dt)
    Menu.update(dt)
    Clouds.update(dt)

    local mx, my = love.mouse.getPosition()
    BannerController.update(mx, my)
end

function love.draw()
    Map.drawLayersBelowSoldier()
    Grid.draw()
    -- Grid.drawLines()

    Arrows.draw()
    UnitManager.draw()
    Map.drawTrees()
    Map.drawLayersAboveSoldier()
    Clouds.draw()
    
    Cursor.draw()
    BannerController.draw()
    Menu.draw()
end

function love.mousepressed(x, y, button)
    Mouse.pressed(x, y, button)
end
