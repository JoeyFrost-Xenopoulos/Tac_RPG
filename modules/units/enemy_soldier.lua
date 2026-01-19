-- modules/units/enemy_soldier.lua
local BaseUnit = require("modules.units.base")

local Enemy = {}
local instance = nil

function Enemy.load()
    local config = {
        type = "Enemy",
        avatar = love.graphics.newImage("assets/ui/avatars/Avatars_06.png"),
        uiVariant = 2,
        uiAnchor = "right",
        isPlayer = false, -- Red selection, no grid
        maxMoveRange = 4,
        animations = {
            idle = {
                img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Idle.png"),
                frames = {
                    {x=0,    y=0, width=192, height=192},
                    {x=192,  y=0, width=192, height=192},
                    {x=384,  y=0, width=192, height=192},
                    {x=576,  y=0, width=192, height=192},
                    {x=768,  y=0, width=192, height=192},
                    {x=960,  y=0, width=192, height=192},
                    {x=1152, y=0, width=192, height=192},
                    {x=1344, y=0, width=192, height=192}
                },
                speed = 0.10
            },
            walk = {
                img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Run.png"),
                frames = {
                    {x=0,    y=0, width=192, height=192},
                    {x=192,  y=0, width=192, height=192},
                    {x=384,  y=0, width=192, height=192},
                    {x=576,  y=0, width=192, height=192},
                    {x=768,  y=0, width=192, height=192},
                    {x=960,  y=0, width=192, height=192}
                },
                speed = 0.08
            },
            attack = {
                img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Attack1.png"),
                frames = {
                    {x=0,    y=0, width=68, height=126},
                    {x=188,  y=0, width=70, height=126},
                },
                speed = 0.15
            }
        }
    }

    instance = BaseUnit.new(config)
    Enemy.unit = instance
end

-- Proxy functions
function Enemy.update(dt) instance:update(dt) end
function Enemy.draw() instance:draw() end
function Enemy.setPosition(x, y) instance:setPosition(x, y) end
function Enemy.tryMove(x, y) instance:tryMove(x, y) end
function Enemy.setSelected(v) instance:setSelected(v) end
function Enemy.isHovered(mx, my) return instance:isHovered(mx, my) end
function Enemy.isClicked(mx, my) return instance:isClicked(mx, my) end

return Enemy