local UnitFactory = require("modules.units.unit_factory")
local Utils = require("modules.manager.utils")

local function loadAnimImage(imagePath, swapPath)
    if swapPath then
        return Utils.applyColourSwaps(imagePath, swapPath)
    end

    return love.graphics.newImage(imagePath)
end

local function createHarpoonFishConfig(isPlayer, colourSwapPath, animSwapPath, overrides)
    local config = {
        name = "James",
        type = "Soldier",
        avatar = Utils.applyColourSwaps("assets/units/harpoon_fish/avatars/Harpoon_Fish.png", colourSwapPath),
        uiVariant = isPlayer and 1 or 2,
        isPlayer = isPlayer,
        maxMoveRange = 4,
        maxHealth = 22,
        health = 22,
        weapon = "harpoon",
        weapons = { "harpoon", "sword_test" },
        items = { "health_potion" },
        -- Combat stats
        strength = 11,
        magic = 8,
        skill = 6,
        speed = 6,
        luck = 3,
        defense = 4,
        resistance = 6,
        constitution = 9,
        aid = 0,
        animations = {
            idle = {
                img = loadAnimImage("assets/units/harpoon_fish/base/HarpoonFish_Idle.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                    {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                    {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                    {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192},
                },
                speed = 0.10
            },
            walk = {
                img = loadAnimImage("assets/units/harpoon_fish/base/HarpoonFish_Run.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                    {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                    {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
                },
                speed = 0.08
            },
            attack = {
                img = loadAnimImage("assets/units/harpoon_fish/base/HarpoonFish_Throw.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                    {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                    {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                    {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192},
                },
                speed = 0.15
            }
        }
    }

    if overrides then
        for key, value in pairs(overrides) do
            config[key] = value
        end
    end

    return config
end

-- Factory function to create new harpoon fish instances
local function createHarpoonFishInstance(variant)
    variant = variant or "player"
    
    local config
    if variant == "enemy" then
        config = createHarpoonFishConfig(
            false,
            {
                "assets.units.harpoon_fish.palettes.enemy_pack_to_enemy",
                "assets.units.harpoon_fish.palettes.harpoon_fish_main_swap"
            },
            "assets.units.harpoon_fish.palettes.harpoon_fish_main_swap",
            {
                name = "Barb",
                maxHealth = 22,
                health = 22,
                strength = 6,
                magic = 6,
                skill = 4,
                speed = 4,
                luck = 2,
                defense = 5,
                resistance = 4,
                constitution = 10
            }
        )
    else -- player
        config = createHarpoonFishConfig(true, "assets.units.harpoon_fish.palettes.enemy_pack_to_player", nil, {
            name = "James",
            maxHealth = 22,
            health = 22,
            strength = 9,
            magic = 8,
            skill = 6,
            speed = 6,
            luck = 3,
            defense = 4,
            resistance = 6,
            constitution = 9
        })
    end
    
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

-- Enemy variant (legacy singleton)
local HarpoonFishEnemy = createHarpoonFishConfig(
    false,
    {
        "assets.units.harpoon_fish.palettes.enemy_pack_to_enemy",
        "assets.units.harpoon_fish.palettes.harpoon_fish_main_swap"
    },
    "assets.units.harpoon_fish.palettes.harpoon_fish_main_swap",
    {
        name = "Barb",
        maxHealth = 22,
        health = 22,
        strength = 6,
        magic = 6,
        skill = 4,
        speed = 4,
        luck = 2,
        defense = 5,
        resistance = 4,
        constitution = 10
    }
)
HarpoonFishEnemy.unit = UnitFactory.create(HarpoonFishEnemy)

function HarpoonFishEnemy.update(dt) HarpoonFishEnemy.unit:update(dt) end
function HarpoonFishEnemy.draw() HarpoonFishEnemy.unit:draw() end
function HarpoonFishEnemy.setPosition(x, y) HarpoonFishEnemy.unit:setPosition(x, y) end
function HarpoonFishEnemy.tryMove(x, y) return HarpoonFishEnemy.unit:tryMove(x, y) end
function HarpoonFishEnemy.setSelected(v) HarpoonFishEnemy.unit:setSelected(v) end
function HarpoonFishEnemy.isHovered(mx, my) return HarpoonFishEnemy.unit:isHovered(mx, my) end
function HarpoonFishEnemy.isClicked(mx, my) return HarpoonFishEnemy.unit:isClicked(mx, my) end

-- Player variant (legacy singleton)
local HarpoonFishPlayer = createHarpoonFishConfig(true, "assets.units.harpoon_fish.palettes.enemy_pack_to_player", nil, {
    name = "James",
    maxHealth = 22,
    health = 22,
    strength = 9,
    magic = 8,
    skill = 6,
    speed = 6,
    luck = 3,
    defense = 4,
    resistance = 6,
    constitution = 9
})
HarpoonFishPlayer.unit = UnitFactory.create(HarpoonFishPlayer)

function HarpoonFishPlayer.update(dt) HarpoonFishPlayer.unit:update(dt) end
function HarpoonFishPlayer.draw() HarpoonFishPlayer.unit:draw() end
function HarpoonFishPlayer.setPosition(x, y) HarpoonFishPlayer.unit:setPosition(x, y) end
function HarpoonFishPlayer.tryMove(x, y) return HarpoonFishPlayer.unit:tryMove(x, y) end
function HarpoonFishPlayer.setSelected(v) HarpoonFishPlayer.unit:setSelected(v) end
function HarpoonFishPlayer.isHovered(mx, my) return HarpoonFishPlayer.unit:isHovered(mx, my) end
function HarpoonFishPlayer.isClicked(mx, my) return HarpoonFishPlayer.unit:isClicked(mx, my) end

return {
    enemy = HarpoonFishEnemy,
    player = HarpoonFishPlayer,
    createInstance = createHarpoonFishInstance
}