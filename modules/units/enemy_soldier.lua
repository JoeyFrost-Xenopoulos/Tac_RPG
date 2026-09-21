-- modules/units/enemy_soldier.lua
-- Unit definition module (factory pattern).
-- Returns a factory table with `createInstance(variant)` that produces BaseUnit instances.

local UnitFactory = require("modules.units.unit_factory")

local EnemyConfig = {
    name = "Soldier",
    type = "Enemy",
    avatar = love.graphics.newImage("assets/units/soldier/avatars/Avatars_06.png"),
    uiVariant = 2,
    isPlayer = false,
    maxMoveRange = 4,
    maxHealth = 24,
    health = 24,
    weapon = "sword",
    weapons = { "sword", "sword_test" },
    items = {},
    -- Combat stats
    strength = 10,
    magic = 2,
    skill = 3,
    speed = 3,
    luck = 2,
    defense = 5,
    resistance = 1,
    constitution = 9,
    aid = 0,
    animations = {
        idle = {
            img = love.graphics.newImage("assets/units/soldier/variants/enemy/Warrior_Idle.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        walk = {
            img = love.graphics.newImage("assets/units/soldier/variants/enemy/Warrior_Run.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
            },
            speed = 0.08
        },
        attack = {
            img = love.graphics.newImage("assets/units/soldier/variants/enemy/Warrior_Attack1.png"),
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
    avatar = love.graphics.newImage("assets/units/soldier/avatars/Avatars_06.png"),
    uiVariant = 2,
    isPlayer = false,
    maxMoveRange = 4,
    maxHealth = 26,
    health = 26,
    weapon = "sword",
    weapons = { "sword", "sword_test" },
    items = {},
    -- Combat stats
    strength = 11,
    magic = 2,
    skill = 4,
    speed = 3,
    luck = 1,
    defense = 6,
    resistance = 1,
    constitution = 10,
    aid = 0,
    animations = {
        idle = {
            img = love.graphics.newImage("assets/units/soldier/variants/enemy/Warrior_Idle.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        walk = {
            img = love.graphics.newImage("assets/units/soldier/variants/enemy/Warrior_Run.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
            },
            speed = 0.08
        },
        attack = {
            img = love.graphics.newImage("assets/units/soldier/variants/enemy/Warrior_Attack1.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
            },
            speed = 0.15
        }
    }
}

-- Factory function to create new enemy soldier instances
local function createEnemySoldier(variant)
    variant = variant or "unit"
    
    local config = (variant == "unit2") and EnemyConfig2 or EnemyConfig
    return UnitFactory.create(config)
end

-- Export factory
local Enemy = {}
Enemy.createInstance = createEnemySoldier
return Enemy
