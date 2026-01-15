require("config")
local Soldier = require("modules.units.soldier")
local Map = require("modules.world.map")
Grid = require("modules.ui.grid")
Cursor = require("modules.ui.cursor")

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    Map.load("map/map_1.lua")
    Cursor.setGrid(Grid.tileSize, Grid.width, Grid.height)

    Soldier.load()
    Soldier.setPosition(3,3)
end

function love.update(dt)
    Map.update(dt)
    Cursor.update()
    Soldier.update(dt)
end

function love.draw()
    Map.draw()
    Grid.draw()
    Soldier.draw()
    Cursor.draw()
end
