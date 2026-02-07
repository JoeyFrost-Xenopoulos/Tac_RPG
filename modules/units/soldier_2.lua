local UnitFactory = require("modules.units.unit_factory")

local Soldier2Config = {
    name = "Helena",
    type = "Soldier",
    avatar = love.graphics.newImage("assets/ui/avatars/Avatars_01.png"),
    uiVariant = 1,
    isPlayer = true,
    maxMoveRange = 4,
    maxHealth = 120,
    health = 120,
    attackRange = 1,
    attackDamage = 20,
    animations = {
        idle = {
            img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Idle.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        walk = {
            img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Run.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
            },
            speed = 0.08
        },
        attack = {
            img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Attack1.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
            },
            speed = 0.15
        }
    }
}

local Soldier2 = {}
Soldier2.unit = UnitFactory.create(Soldier2Config)

function Soldier2.update(dt) Soldier2.unit:update(dt) end
function Soldier2.draw() Soldier2.unit:draw() end
function Soldier2.setPosition(x, y) Soldier2.unit:setPosition(x, y) end
function Soldier2.tryMove(x, y) return Soldier2.unit:tryMove(x, y) end
function Soldier2.setSelected(v) Soldier2.unit:setSelected(v) end
function Soldier2.isHovered(mx, my) return Soldier2.unit:isHovered(mx, my) end
function Soldier2.isClicked(mx, my) return Soldier2.unit:isClicked(mx, my) end

return Soldier2
