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

-- Create a custom module mousepressed at somepoint
function love.mousepressed(x, y, button)
    if button ~= 1 then return end

    local tx, ty = mouseToTile(x, y)

    if Soldier.isClicked(x, y) then
        Soldier.setSelected(true)
        return
    end

    if Soldier.unit.selected then
        if Map.isWalkable(tx, ty) then
            Soldier.tryMove(tx, ty, Map.isWalkable)
            Soldier.setSelected(false)
        end
    end
end