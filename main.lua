require("config")
local Soldier = require("modules.units.soldier")
local Map = require("modules.world.map")
Grid = require("modules.ui.grid")
Cursor = require("modules.ui.cursor")
Enemy_Soldier = require("modules.units.enemy_soldier")

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    Map.load("map/map_1.lua")
    Cursor.load()
    Cursor.setGrid(Grid.tileSize, Grid.width, Grid.height)

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
end

function love.draw()
    Map.draw()
    Grid.draw()
    Enemy_Soldier.draw()
    Soldier.draw()
    Cursor.draw()
end

-- Create a custom module mousepressed at somepoint
function love.mousepressed(x, y, button)
    if button ~= 1 then return end

    local tx, ty = mouseToTile(x, y)

    -- Check if Soldier is clicked
    if Soldier.isClicked(x, y) then
        Soldier.setSelected(true)
        Enemy_Soldier.setSelected(false) -- deselect Enemy_Soldier
        return
    end

    -- Check if Enemy_Soldier is clicked
    if Enemy_Soldier.isClicked(x, y) then
        Enemy_Soldier.setSelected(true)
        Soldier.setSelected(false) -- deselect soldier
        return
    end

    -- If Soldier is selected, move it
    if Soldier.unit.selected then
        Soldier.tryMove(tx, ty)
        Soldier.setSelected(false)
    end

    -- If Enemy_Soldier is selected, move it
    if Enemy_Soldier.unit.selected then
        Enemy_Soldier.tryMove(tx, ty)
        Enemy_Soldier.setSelected(false)
    end
end
