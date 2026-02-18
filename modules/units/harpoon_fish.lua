local UnitFactory = require("modules.units.unit_factory")
local Utils = require("modules.manager.utils")

local function loadAnimImage(imagePath, swapPath)
    if swapPath then
        return Utils.applyColourSwaps(imagePath, swapPath)
    end

    return love.graphics.newImage(imagePath)
end

local function createHarpoonFishConfig(isPlayer, colourSwapPath, animSwapPath)
    return {
        name = "James",
        type = "Soldier",
        avatar = Utils.applyColourSwaps("assets/units/harpoon_fish/avatars/Harpoon_Fish.png", colourSwapPath),
        uiVariant = isPlayer and 1 or 2,
        isPlayer = isPlayer,
        maxMoveRange = 4,
        maxHealth = 120,
        health = 120,
        attackDamage = 5,
        weapon = "harpoon",
        weapons = { "harpoon", "sword_test" },
        items = { "health_potion" },
        -- Combat stats
        strength = 11,
        magic = 8,
        skill = 14,
        speed = 13,
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
end

-- Enemy variant
local HarpoonFishEnemy = createHarpoonFishConfig(
    false,
    {
        "assets.units.harpoon_fish.palettes.enemy_pack_to_enemy",
        "assets.units.harpoon_fish.palettes.harpoon_fish_main_swap"
    },
    "assets.units.harpoon_fish.palettes.harpoon_fish_main_swap"
)
HarpoonFishEnemy.unit = UnitFactory.create(HarpoonFishEnemy)

function HarpoonFishEnemy.update(dt) HarpoonFishEnemy.unit:update(dt) end
function HarpoonFishEnemy.draw() HarpoonFishEnemy.unit:draw() end
function HarpoonFishEnemy.setPosition(x, y) HarpoonFishEnemy.unit:setPosition(x, y) end
function HarpoonFishEnemy.tryMove(x, y) return HarpoonFishEnemy.unit:tryMove(x, y) end
function HarpoonFishEnemy.setSelected(v) HarpoonFishEnemy.unit:setSelected(v) end
function HarpoonFishEnemy.isHovered(mx, my) return HarpoonFishEnemy.unit:isHovered(mx, my) end
function HarpoonFishEnemy.isClicked(mx, my) return HarpoonFishEnemy.unit:isClicked(mx, my) end

-- Player variant
local HarpoonFishPlayer = createHarpoonFishConfig(true, "assets.units.harpoon_fish.palettes.enemy_pack_to_player")
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
    player = HarpoonFishPlayer
}