local UnitFactory = require("modules.units.unit_factory")

local SoldierConfig = {
    name = "Ingram",
    type = "Soldier",
    avatar = love.graphics.newImage("assets/ui/avatars/Avatars_01.png"),
    uiVariant = 1,
    isPlayer = true,
    maxMoveRange = 4,
    maxHealth = 120,
    health = 120,
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
                {x=0,y=0,width=68,height=126},{x=188,y=0,width=70,height=126}
            },
            speed = 0.15
        }
    }
}

local Soldier = {}
Soldier.unit = UnitFactory.create(SoldierConfig)

function Soldier.update(dt) Soldier.unit:update(dt) end
function Soldier.draw() Soldier.unit:draw() end
function Soldier.setPosition(x, y) Soldier.unit:setPosition(x, y) end
function Soldier.tryMove(x, y) return Soldier.unit:tryMove(x, y) end
function Soldier.setSelected(v) Soldier.unit:setSelected(v) end
function Soldier.isHovered(mx, my) return Soldier.unit:isHovered(mx, my) end
function Soldier.isClicked(mx, my) return Soldier.unit:isClicked(mx, my) end

return Soldier
