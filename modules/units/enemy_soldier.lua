local UnitFactory = require("modules.units.unit_factory")

local EnemyConfig = {
    name = "Barnes",
    type = "Enemy",
    avatar = love.graphics.newImage("assets/ui/avatars/Avatars_06.png"),
    uiVariant = 2,
    isPlayer = false,
    maxMoveRange = 4,
    maxHealth = 100,
    health = 100,
    attackRange = 1,
    attackDamage = 20,
    weapon = "sword",
    -- Combat stats
    strength = 12,
    magic = 2,
    skill = 9,
    speed = 9,
    luck = 2,
    defense = 6,
    resistance = 1,
    constitution = 10,
    aid = 0,
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
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
            },
            speed = 0.15
        }
    }
}

local EnemyConfig2 = {
    name = "Miller",
    type = "Enemy",
    avatar = love.graphics.newImage("assets/ui/avatars/Avatars_06.png"),
    uiVariant = 2,
    isPlayer = false,
    maxMoveRange = 4,
    maxHealth = 100,
    health = 100,
    attackRange = 1,
    attackDamage = 20,
    weapon = "sword",
    -- Combat stats
    strength = 13,
    magic = 2,
    skill = 10,
    speed = 8,
    luck = 1,
    defense = 7,
    resistance = 1,
    constitution = 11,
    aid = 0,
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
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
            },
            speed = 0.15
        }
    }
}

local Enemy = {}
Enemy.unit = UnitFactory.create(EnemyConfig)
Enemy.unit2 = UnitFactory.create(EnemyConfig2)

function Enemy.update(dt) Enemy.unit:update(dt) end
function Enemy.draw() Enemy.unit:draw() end
function Enemy.setPosition(x, y) Enemy.unit:setPosition(x, y) end
function Enemy.tryMove(x, y) return Enemy.unit:tryMove(x, y) end
function Enemy.setSelected(v) Enemy.unit:setSelected(v) end
function Enemy.isHovered(mx, my) return Enemy.unit:isHovered(mx, my) end
function Enemy.isClicked(mx, my) return Enemy.unit:isClicked(mx, my) end

function Enemy.update2(dt) Enemy.unit2:update(dt) end
function Enemy.draw2() Enemy.unit2:draw() end
function Enemy.setPosition2(x, y) Enemy.unit2:setPosition(x, y) end
function Enemy.tryMove2(x, y) return Enemy.unit2:tryMove(x, y) end
function Enemy.setSelected2(v) Enemy.unit2:setSelected(v) end
function Enemy.isHovered2(mx, my) return Enemy.unit2:isHovered(mx, my) end
function Enemy.isClicked2(mx, my) return Enemy.unit2:isClicked(mx, my) end

return Enemy
