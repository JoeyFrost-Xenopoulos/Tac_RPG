local UnitFactory = require("modules.units.unit_factory")
local Utils = require("modules.manager.utils")

local function loadAnimImage(imagePath, swapPath)
    if swapPath then
        return Utils.applyColourSwaps(imagePath, swapPath)
    end

    return love.graphics.newImage(imagePath)
end

local function createMonkConfig(isPlayer, colourSwapPath, animSwapPath, overrides)
    local config = {
        name = "Ari",
        type = "Monk",
        avatar = colourSwapPath and Utils.applyColourSwaps("assets/units/monk/avatars/Avatars_04.png", colourSwapPath) or love.graphics.newImage("assets/units/monk/avatars/Avatars_04.png"),
        uiVariant = isPlayer and 1 or 2,
        isPlayer = isPlayer,
        maxMoveRange = 5,
        maxHealth = 21,
        health = 21,
        weapon = "fire",
        weapons = { "fire", "ice" },
        items = { "mana_potion" },
        -- Combat stats
        strength = 7,
        magic = 12,
        skill = 7,
        speed = 7,
        luck = 5,
        defense = 4,
        resistance = 8,
        constitution = 8,
        aid = 0,
        animations = {
            idle = {
                img = loadAnimImage("assets/units/monk/base/Monk_Idle.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                    {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                    {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
                },
                speed = 0.10
            },
            walk = {
                img = loadAnimImage("assets/units/monk/base/Monk_Run.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                    {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
                },
                speed = 0.10
            },
            attack = {
                img = loadAnimImage("assets/units/monk/base/Monk_Heal.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                    {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                    {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                    {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192},
                    {x=1536,y=0,width=192,height=192},{x=1728,y=0,width=192,height=192},
                    {x=1920,y=0,width=192,height=192}
                },
                speed = 0.10
            },
            attack_fire = {
                img = loadAnimImage("assets/units/monk/base/Fire_attack.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=64,height=64},{x=64,y=0,width=64,height=64},
                    {x=128,y=0,width=64,height=64},{x=192,y=0,width=64,height=64},
                    {x=0,y=64,width=64,height=64},{x=64,y=64,width=64,height=64},
                    {x=128,y=64,width=64,height=64},{x=192,y=64,width=64,height=64},
                    {x=0,y=128,width=64,height=64},{x=64,y=128,width=64,height=64},
                    {x=128,y=128,width=64,height=64},{x=192,y=128,width=64,height=64},
                    {x=0,y=192,width=64,height=64},{x=64,y=192,width=64,height=64},
                    {x=128,y=192,width=64,height=64},{x=192,y=192,width=64,height=64}
                },
                speed = 0.10
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

local function createMonkInstance(variant)
    variant = variant or "player"

    local config
    if variant == "enemy" then
        config = createMonkConfig(
            false,
            "assets.units.monk.palettes.monk_avatar_swap",
            "assets.units.monk.palettes.monk_main_swap",
            {
                name = "Hex",
                maxHealth = 20,
                health = 20,
                strength = 6,
                magic = 10,
                skill = 6,
                speed = 6,
                luck = 3,
                defense = 3,
                resistance = 7,
                constitution = 8
            }
        )
    else
        config = createMonkConfig(true, nil, nil, {
            name = "Ari",
            maxHealth = 21,
            health = 21,
            strength = 7,
            magic = 12,
            skill = 7,
            speed = 7,
            luck = 5,
            defense = 4,
            resistance = 8,
            constitution = 8
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
local MonkEnemy = createMonkConfig(
    false,
    "assets.units.monk.palettes.monk_avatar_swap",
    "assets.units.monk.palettes.monk_main_swap",
    {
        name = "Hex",
        maxHealth = 20,
        health = 20,
        strength = 6,
        magic = 10,
        skill = 6,
        speed = 6,
        luck = 3,
        defense = 3,
        resistance = 7,
        constitution = 8
    }
)
MonkEnemy.unit = UnitFactory.create(MonkEnemy)

function MonkEnemy.update(dt) MonkEnemy.unit:update(dt) end
function MonkEnemy.draw() MonkEnemy.unit:draw() end
function MonkEnemy.setPosition(x, y) MonkEnemy.unit:setPosition(x, y) end
function MonkEnemy.tryMove(x, y) return MonkEnemy.unit:tryMove(x, y) end
function MonkEnemy.setSelected(v) MonkEnemy.unit:setSelected(v) end
function MonkEnemy.isHovered(mx, my) return MonkEnemy.unit:isHovered(mx, my) end
function MonkEnemy.isClicked(mx, my) return MonkEnemy.unit:isClicked(mx, my) end

-- Player variant (legacy singleton)
local MonkPlayer = createMonkConfig(true, nil, nil, {
    name = "Ari",
    maxHealth = 21,
    health = 21,
    strength = 7,
    magic = 12,
    skill = 7,
    speed = 7,
    luck = 5,
    defense = 4,
    resistance = 8,
    constitution = 8
})
MonkPlayer.unit = UnitFactory.create(MonkPlayer)

function MonkPlayer.update(dt) MonkPlayer.unit:update(dt) end
function MonkPlayer.draw() MonkPlayer.unit:draw() end
function MonkPlayer.setPosition(x, y) MonkPlayer.unit:setPosition(x, y) end
function MonkPlayer.tryMove(x, y) return MonkPlayer.unit:tryMove(x, y) end
function MonkPlayer.setSelected(v) MonkPlayer.unit:setSelected(v) end
function MonkPlayer.isHovered(mx, my) return MonkPlayer.unit:isHovered(mx, my) end
function MonkPlayer.isClicked(mx, my) return MonkPlayer.unit:isClicked(mx, my) end

return {
    enemy = MonkEnemy,
    player = MonkPlayer,
    createInstance = createMonkInstance
}
