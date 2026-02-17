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
    attackRange = 1,
    attackDamage = 20,
    weapon = "sword",
    weapons = { "sword", "sword_test" },
    items = { "health_potion", "mana_potion" },
    -- Combat stats
    strength = 15,
    magic = 3,
    skill = 12,
    speed = 11,
    luck = 5,
    defense = 8,
    resistance = 2,
    constitution = 12,
    aid = 0,
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
            speed = 0.10
        },
        attack = {
            img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Attack1.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
            },
            speed = 0.08
        }
    }
}

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
    weapon = "sword",
    weapons = { "sword", "sword_test" },
    items = { "health_potion" },
    -- Combat stats
    strength = 14,
    magic = 5,
    skill = 13,
    speed = 12,
    luck = 7,
    defense = 7,
    resistance = 4,
    constitution = 11,
    aid = 0,
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

local Soldier = {}
Soldier.unit = UnitFactory.create(SoldierConfig)
Soldier.unit2 = UnitFactory.create(Soldier2Config)

function Soldier.update(dt) Soldier.unit:update(dt) end
function Soldier.draw() Soldier.unit:draw() end
function Soldier.setPosition(x, y) Soldier.unit:setPosition(x, y) end
function Soldier.tryMove(x, y) return Soldier.unit:tryMove(x, y) end
function Soldier.setSelected(v) Soldier.unit:setSelected(v) end
function Soldier.isHovered(mx, my) return Soldier.unit:isHovered(mx, my) end
function Soldier.isClicked(mx, my) return Soldier.unit:isClicked(mx, my) end

function Soldier.update2(dt) Soldier.unit2:update(dt) end
function Soldier.draw2() Soldier.unit2:draw() end
function Soldier.setPosition2(x, y) Soldier.unit2:setPosition(x, y) end
function Soldier.tryMove2(x, y) return Soldier.unit2:tryMove(x, y) end
function Soldier.setSelected2(v) Soldier.unit2:setSelected(v) end
function Soldier.isHovered2(mx, my) return Soldier.unit2:isHovered(mx, my) end
function Soldier.isClicked2(mx, my) return Soldier.unit2:isClicked(mx, my) end

return Soldier
