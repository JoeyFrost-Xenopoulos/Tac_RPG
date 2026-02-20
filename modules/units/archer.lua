local UnitFactory = require("modules.units.unit_factory")

local ArcherConfig = {
    name = "Quickley",
    type = "Archer",
    avatar = love.graphics.newImage("assets/units/archer/avatars/Avatars_03.png"),
    uiVariant = 1,
    isPlayer = true,
    maxMoveRange = 5,
    maxHealth = 90,
    health = 90,
    attackDamage = 18,
    weapon = "bow",
    weapons = { "bow", "sword_test" },
    items = { "health_potion", "mana_potion" },
    -- Combat stats
    strength = 10,
    magic = 5,
    skill = 16,
    speed = 13,
    luck = 8,
    defense = 5,
    resistance = 3,
    constitution = 10,
    aid = 0,
    animations = {
        idle = {
            img = love.graphics.newImage("assets/units/archer/base/Archer_Idle.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        walk = {
            img = love.graphics.newImage("assets/units/archer/base/Archer_Run.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        attack = {
            img = love.graphics.newImage("assets/units/archer/base/Archer_Shoot.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192}
            },
            speed = 0.10
        }
    }
}

local Archer = {}
Archer.unit = UnitFactory.create(ArcherConfig)

function Archer.update(dt) Archer.unit:update(dt) end
function Archer.draw() Archer.unit:draw() end
function Archer.setPosition(x, y) Archer.unit:setPosition(x, y) end
function Archer.tryMove(x, y) return Archer.unit:tryMove(x, y) end
function Archer.setSelected(v) Archer.unit:setSelected(v) end
function Archer.isHovered(mx, my) return Archer.unit:isHovered(mx, my) end
function Archer.isClicked(mx, my) return Archer.unit:isClicked(mx, my) end

return Archer
