local UnitFactory = require("modules.units.unit_factory")
local Utils = require("modules.manager.utils")

local function loadAnimImage(imagePath, swapPath)
    if swapPath then
        return Utils.applyColourSwaps(imagePath, swapPath)
    end

    return love.graphics.newImage(imagePath)
end

local function createArcherConfig(isPlayer, colourSwapPath, animSwapPath, overrides)
    local config = {
        name = "Quickley",
        type = "Archer",
        avatar = colourSwapPath and Utils.applyColourSwaps("assets/units/archer/avatars/Avatars_03.png", colourSwapPath) or love.graphics.newImage("assets/units/archer/avatars/Avatars_03.png"),
        uiVariant = isPlayer and 1 or 2,
        isPlayer = isPlayer,
        maxMoveRange = 5,
        maxHealth = 20,
        health = 20,
        weapon = "bow",
        weapons = { "bow", "sword_test" },
        items = { "health_potion", "mana_potion" },
        -- Combat stats
        strength = 10,
        magic = 5,
        skill = 6,
        speed = 7,
        luck = 8,
        defense = 5,
        resistance = 3,
        constitution = 10,
        aid = 0,
        animations = {
            idle = {
                img = loadAnimImage("assets/units/archer/base/Archer_Idle.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                    {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                    {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
                },
                speed = 0.10
            },
            walk = {
                img = loadAnimImage("assets/units/archer/base/Archer_Run.png", animSwapPath),
                frames = {
                    {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                    {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192}
                },
                speed = 0.10
            },
            attack = {
                img = loadAnimImage("assets/units/archer/base/Archer_Shoot.png", animSwapPath),
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

    if overrides then
        for key, value in pairs(overrides) do
            config[key] = value
        end
    end

    return config
end

-- Factory function to create new archer instances
local function createArcherInstance(variant)
    variant = variant or "player"
    
    local config
    if variant == "player" then
        config = createArcherConfig(true, nil, nil, {
            name = "Quickley",
            maxHealth = 20,
            health = 20,
            strength = 10,
            magic = 5,
            skill = 6,
            speed = 7,
            luck = 8,
            defense = 5,
            resistance = 3,
            constitution = 10
        })
    else -- enemy
        config = createArcherConfig(
            false,
            "assets.units.archer.palettes.archer_avatar_swap",
            "assets.units.archer.palettes.archer_main_swap",
            {
                name = "Archer",
                maxHealth = 20,
                health = 20,
                strength = 8,
                magic = 4,
                skill = 4,
                speed = 5,
                luck = 6,
                defense = 6,
                resistance = 4,
                constitution = 11
            }
        )
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

-- Player variant (legacy singleton)
local ArcherPlayer = createArcherConfig(true, nil, nil, {
    name = "Quickley",
    maxHealth = 20,
    health = 20,
    strength = 10,
    magic = 5,
    skill = 6,
    speed = 7,
    luck = 8,
    defense = 5,
    resistance = 3,
    constitution = 10
})
ArcherPlayer.unit = UnitFactory.create(ArcherPlayer)

function ArcherPlayer.update(dt) ArcherPlayer.unit:update(dt) end
function ArcherPlayer.draw() ArcherPlayer.unit:draw() end
function ArcherPlayer.setPosition(x, y) ArcherPlayer.unit:setPosition(x, y) end
function ArcherPlayer.tryMove(x, y) return ArcherPlayer.unit:tryMove(x, y) end
function ArcherPlayer.setSelected(v) ArcherPlayer.unit:setSelected(v) end
function ArcherPlayer.isHovered(mx, my) return ArcherPlayer.unit:isHovered(mx, my) end
function ArcherPlayer.isClicked(mx, my) return ArcherPlayer.unit:isClicked(mx, my) end

-- Enemy variant (legacy singleton)
local ArcherEnemy = createArcherConfig(
    false,
    "assets.units.archer.palettes.archer_avatar_swap",
    "assets.units.archer.palettes.archer_main_swap",
    {
        name = "Kestrel",
        maxHealth = 20,
        health = 20,
        strength = 8,
        magic = 4,
        skill = 4,
        speed = 5,
        luck = 6,
        defense = 6,
        resistance = 4,
        constitution = 11
    }
)
ArcherEnemy.unit = UnitFactory.create(ArcherEnemy)

function ArcherEnemy.update(dt) ArcherEnemy.unit:update(dt) end
function ArcherEnemy.draw() ArcherEnemy.unit:draw() end
function ArcherEnemy.setPosition(x, y) ArcherEnemy.unit:setPosition(x, y) end
function ArcherEnemy.tryMove(x, y) return ArcherEnemy.unit:tryMove(x, y) end
function ArcherEnemy.setSelected(v) ArcherEnemy.unit:setSelected(v) end
function ArcherEnemy.isHovered(mx, my) return ArcherEnemy.unit:isHovered(mx, my) end
function ArcherEnemy.isClicked(mx, my) return ArcherEnemy.unit:isClicked(mx, my) end

return {
    player = ArcherPlayer,
    enemy = ArcherEnemy,
    createInstance = createArcherInstance
}
