local UnitFactory = require("modules.units.unit_factory")

local SoldierConfig = {
    name = "Ingram",
    type = "Soldier",
    avatar = love.graphics.newImage("assets/units/soldier/avatars/Avatars_01.png"),
    uiVariant = 1,
    isPlayer = true,
    maxMoveRange = 4,
    maxHealth = 30,
    health = 30,
    weapon = "sword",
    weapons = { "sword", "sword_test" },
    items = { "health_potion", "mana_potion" },
    -- Combat stats
    strength = 15,
    magic = 3,
    skill = 5,
    speed = 5,
    luck = 5,
    defense = 8,
    resistance = 2,
    constitution = 12,
    aid = 0,
    animations = {
        idle = {
            img = love.graphics.newImage("assets/units/soldier/base/Warrior_Idle.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        walk = {
            img = love.graphics.newImage("assets/units/soldier/base/Warrior_Run.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        attack = {
            img = love.graphics.newImage("assets/units/soldier/base/Warrior_Attack1.png"),
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
    avatar = love.graphics.newImage("assets/units/soldier/avatars/Avatars_01.png"),
    uiVariant = 1,
    isPlayer = true,
    maxMoveRange = 4,
    maxHealth = 28,
    health = 28,
    weapon = "sword",
    weapons = { "sword", "sword_test" },
    items = { "health_potion" },
    -- Combat stats
    strength = 14,
    magic = 5,
    skill = 4,
    speed = 4,
    luck = 7,
    defense = 7,
    resistance = 4,
    constitution = 11,
    aid = 0,
    animations = {
        idle = {
            img = love.graphics.newImage("assets/units/soldier/base/Warrior_Idle.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192}
            },
            speed = 0.10
        },
        walk = {
            img = love.graphics.newImage("assets/units/soldier/base/Warrior_Run.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
            },
            speed = 0.08
        },
        attack = {
            img = love.graphics.newImage("assets/units/soldier/base/Warrior_Attack1.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
            },
            speed = 0.15
        }
    }
}

-- Factory function to create new soldier instances
local function createSoldierInstance(variant)
    variant = variant or "unit"
    
    local config = (variant == "unit2") and Soldier2Config or SoldierConfig
    local unit = UnitFactory.create(config)
    
    return {
        unit = unit,
        update = function(dt) unit:update(dt) end,
        draw = function() unit:draw() end,
        setPosition = function(x, y) unit:setPosition(x, y) end,
        tryMove = function(x, y) return unit:tryMove(x, y) end,
        setSelected = function(v) unit:setSelected(v) end,
        isHovered = function(mx, my) return unit:isHovered(mx, my) end,
        isClicked = function(mx, my) return unit:isClicked(mx, my) end
    }
end

local Soldier = {}

-- Export factory
Soldier.createInstance = createSoldierInstance

return Soldier
