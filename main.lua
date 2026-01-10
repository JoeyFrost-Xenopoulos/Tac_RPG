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

function love.load()
    love.window.setTitle("Tactical RPG Prototype")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    Grid.init()

    Units.create({ name = "Hero", team = "player", x = 3, y = 4, move = 4 })
    Units.create({ name = "Archer", team = "player", x = 4, y = 6, move = 3, attackRange = 2 })
    Units.create({ name = "Enemy", team = "enemy", x = 7, y = 4, move = 3 })
    Units.create({ name = "Enemy", team = "enemy", x = 8, y = 4, move = 3, attackRange = 2 })


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

    love.graphics.setColor(1, 1, 1)
end

function love.mousepressed(x, y, button)
    Input.mousepressed(x, y, button)
end

function love.keypressed(key)
    Input.keypressed(key)
end
