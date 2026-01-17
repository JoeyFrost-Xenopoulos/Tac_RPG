require("config")
local Soldier = require("modules.units.soldier")
local Map = require("modules.world.map")
Grid = require("modules.ui.grid")
Cursor = require("modules.ui.cursor")
Enemy_Soldier = require("modules.units.enemy_soldier")
Banner = require("modules.ui.banner")
Mouse = require("modules.engine.mouse")

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    Map.load("map/map_1.lua")
    Cursor.load()
    Cursor.setGrid(Grid.tileSize, Grid.width, Grid.height)
    Banner.load()

    Soldier.load()
    Enemy_Soldier.load()
    Soldier.setPosition(3,3)
    Enemy_Soldier.setPosition(3,4)
end

function love.update(dt)
    Map.update(dt)
    Cursor.update()
    Enemy_Soldier.update(dt)
    Soldier.update(dt)
    Banner.update(dt)
end

function love.draw()
    local mx, my = love.mouse.getPosition()

    Map.draw()
    Grid.draw()
    Enemy_Soldier.draw()
    Soldier.draw()
    Cursor.draw()

    if Soldier.isHovered(mx, my) then
        if not Banner.animating then
        Banner.start()
        end
        if my < 384 then
            Banner.x = 0; Banner.y = 620
        else
            Banner.x = 0; Banner.y = 0
        end
        Banner.draw()
    else
        Banner.reset()
    end
end

function love.mousepressed(x, y, button)
    Mouse.pressed(x, y, button)
end
