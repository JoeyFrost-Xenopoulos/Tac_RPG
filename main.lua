-- main.lua

require("config")

require("modules.engine.game")
require("modules.engine.grid")
require("modules.engine.movement")
require("modules.engine.turn")
require("modules.engine.combat")
require("modules.engine.input")
require("modules.engine.draw")
require("modules.engine.tiles")
require("modules.engine.foam")
require("modules.engine.map")
require("modules.engine.unitspawner")

require("modules.units.units")
require("modules.units.character")
require("modules.units.enemy")
require("modules.units.archer")
require("modules.units.mage")

require("modules.ui.effects")
require("modules.ui.weaponselector")
require("modules.ui.hoverinfo")

local Music = require("modules.audio.music")

function love.load()
    love.window.setTitle("Tactical RPG Prototype")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    WaterBackground = love.graphics.newImage("map/Water Background color.png")

    Tiles.load()
    Foam.load()
    Map.generate()
    Character.init()
    Enemy.init()
    Archer.init()
    Mage.init()

    local enemy1 = UnitSpawner.spawnNear({name = "Enemy1",class = "Soldier", team = "enemy",x = 7,y = 1})
    Enemy.assignToUnit(enemy1, "soldier")

    local enemy2 = UnitSpawner.spawnNear({ name="Enemy2", class="Soldier", team="enemy", x=8, y=2 })
    Enemy.assignToUnit(enemy2, "soldier")

    local hero = Units.create({ name="Hero", class="Soldier", team="player", x=3, y=4 }) 
    Character.assignToUnit(hero, "hero")

    local archer = UnitSpawner.spawnNear({name = "Archer1", class = "Archer", team = "player", x = 4, y = 4 })
    Archer.assignToUnit(archer, "archer")

    local mage1 = UnitSpawner.spawnNear({ name="Mage1", class="Mage", team="player", x=2, y=5 })
    Mage.assignToUnit(mage1, "mage")

    Turn.start()

    Music.load()
    --Music.play()
end

function love.update(dt)
    Input.update()
    Turn.updateEnemyTurn()
    Units.update(dt)
    Effects.update(dt)
    Foam.update(dt)

    for _, unit in ipairs(Units.list) do
        if unit.class == "Mage" then
            Mage.update(dt, unit)
        end
    end

    Mage.updateSpells(dt)

    for _, unit in ipairs(Units.list) do
        if unit.class == "Archer" then
            Archer.update(dt, unit)
        end
    end

    Archer.updateProjectiles(dt)
    Game.flashTimer = Game.flashTimer + dt

    for _, unit in ipairs(Units.list) do
        Character.update(dt, unit)
    end
end

function love.draw()
    local sx = WINDOW_WIDTH / WaterBackground:getWidth()
    local sy = WINDOW_HEIGHT / WaterBackground:getHeight()
    love.graphics.draw(WaterBackground, 0, 0, 0, sx, sy)

    Foam.draw()   
    Draw.grid()

    Draw.hover()
    Draw.selection()
    Draw.movementAndAttacks()
    Draw.units()
    Effects.draw()
    WeaponSelector.draw()
    Draw.heals()

    love.graphics.setColor(1, 1, 1)

    for _, unit in ipairs(Units.list) do
        if unit.animations then
            Character.draw(unit, 0.5, 0.5)
        end
    end

    HoverInfo.draw()
    Archer.drawProjectiles()
    Mage.drawSpells()
end

function love.mousepressed(x, y, button)
    Input.mousepressed(x, y, button)
end

function love.keypressed(key)
    Input.keypressed(key)
end
