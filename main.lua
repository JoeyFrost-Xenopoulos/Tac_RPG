-- main.lua

require("config")
require("modules.game")
require("modules.grid")
require("modules.units")
require("modules.movement")
require("modules.turn")
require("modules.combat")
require("modules.input")
require("modules.draw")
require("modules.effects")
require("modules.weaponselector")
require("modules.hoverinfo")

function love.load()
    love.window.setTitle("Tactical RPG Prototype")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    Grid.init()

    Units.create({ name = "Hero", class = "Soldier", team = "player", x = 3, y = 4 })
    Units.create({ name = "Archer1", class = "Archer", team = "player", x = 4, y = 6 })
    Units.create({ name = "Mage1", class = "Mage", team = "player", x = 2, y = 5 })

    Units.create({ name = "Enemy1", class = "Soldier", team = "enemy", x = 7, y = 4 })
    Units.create({ name = "Enemy2", class = "Archer", team = "enemy", x = 8, y = 4 })

    Turn.start()
end

function love.update(dt)
    Input.update()
    Turn.updateEnemyTurn()
    Units.update(dt)
    Effects.update(dt)
    Game.flashTimer = Game.flashTimer + dt
end

function love.draw()
    Draw.grid()
    Draw.hover()
    Draw.selection()
    Draw.movement()
    Draw.attacks()
    Draw.units()
    Effects.draw()
    HoverInfo.draw()
    WeaponSelector.draw()

    love.graphics.setColor(1, 1, 1)
end

function love.mousepressed(x, y, button)
    Input.mousepressed(x, y, button)
end

function love.keypressed(key)
    Input.keypressed(key)
end
