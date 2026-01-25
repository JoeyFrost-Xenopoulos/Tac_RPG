local UnitFactory = require("modules.units.unit_factory")

local EnemyConfig = {
    name = "Barnes",
    type = "Enemy",
    avatar = love.graphics.newImage("assets/ui/avatars/Avatars_06.png"),
    uiVariant = 2,
    uiAnchor = "right",
    isPlayer = false,
    maxMoveRange = 4,
    animations = {
        idle = {
            img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Idle.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        walk = {
            img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Run.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
            },
            speed = 0.08
        },
        attack = {
            img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Attack1.png"),
            frames = {
                {x=0,y=0,width=68,height=126},{x=188,y=0,width=70,height=126}
            },
            speed = 0.15
        }
    }
}

local Enemy = {}
Enemy.unit = UnitFactory.create(EnemyConfig)

function Enemy.update(dt) Enemy.unit:update(dt) end
function Enemy.draw() Enemy.unit:draw() end
function Enemy.setPosition(x, y) Enemy.unit:setPosition(x, y) end
function Enemy.tryMove(x, y) return Enemy.unit:tryMove(x, y) end
function Enemy.setSelected(v) Enemy.unit:setSelected(v) end
function Enemy.isHovered(mx, my) return Enemy.unit:isHovered(mx, my) end
function Enemy.isClicked(mx, my) return Enemy.unit:isClicked(mx, my) end

return Enemy
