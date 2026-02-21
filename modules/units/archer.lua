local UnitFactory = require("modules.units.unit_factory")
local Utils = require("modules.manager.utils")

local function loadAnimImage(imagePath, swapPath)
    if swapPath then
        return Utils.applyColourSwaps(imagePath, swapPath)
    end

    return love.graphics.newImage(imagePath)
end

local function createArcherConfig(isPlayer, colourSwapPath, animSwapPath)
    return {
        name = "Quickley",
        type = "Archer",
        avatar = colourSwapPath and Utils.applyColourSwaps("assets/units/archer/avatars/Avatars_03.png", colourSwapPath) or love.graphics.newImage("assets/units/archer/avatars/Avatars_03.png"),
        uiVariant = isPlayer and 1 or 2,
        isPlayer = isPlayer,
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
        speed = 18,
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
end

-- Player variant
local ArcherPlayer = createArcherConfig(true)
ArcherPlayer.unit = UnitFactory.create(ArcherPlayer)

function ArcherPlayer.update(dt) ArcherPlayer.unit:update(dt) end
function ArcherPlayer.draw() ArcherPlayer.unit:draw() end
function ArcherPlayer.setPosition(x, y) ArcherPlayer.unit:setPosition(x, y) end
function ArcherPlayer.tryMove(x, y) return ArcherPlayer.unit:tryMove(x, y) end
function ArcherPlayer.setSelected(v) ArcherPlayer.unit:setSelected(v) end
function ArcherPlayer.isHovered(mx, my) return ArcherPlayer.unit:isHovered(mx, my) end
function ArcherPlayer.isClicked(mx, my) return ArcherPlayer.unit:isClicked(mx, my) end

-- Enemy variant
local ArcherEnemy = createArcherConfig(
    false,
    "assets.units.archer.palettes.archer_avatar_swap",
    "assets.units.archer.palettes.archer_main_swap"
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
    enemy = ArcherEnemy
}
