-- modules/units/monk.lua
-- Unit definition module (factory pattern).
-- Returns a factory table with `createInstance(variant)` that produces BaseUnit instances.

local UnitFactory = require("modules.units.unit_factory")
local Utils = require("modules.manager.utils")

local function loadAnimImage(imagePath, swapPath)
    if swapPath then
        return Utils.applyColourSwaps(imagePath, swapPath)
    end

    return love.graphics.newImage(imagePath)
end

local function loadWeaponAnimImages(imagePath, baseSwapPath, weaponSwapPaths)
    if type(weaponSwapPaths) ~= "table" then
        return nil
    end

    local weaponImages = {}
    for weapon, swapPath in pairs(weaponSwapPaths) do
        local combinedSwapPath = swapPath
        if baseSwapPath then
            combinedSwapPath = { baseSwapPath, swapPath }
        end

        weaponImages[weapon] = loadAnimImage(imagePath, combinedSwapPath)
    end

    return next(weaponImages) and weaponImages or nil
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
        items = {},
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
                weaponImgs = loadWeaponAnimImages("assets/units/monk/base/Monk_Heal.png", animSwapPath, {
                    fire = "assets.units.monk.palettes.fire_preset",
                    ice = "assets.units.monk.palettes.ice_preset"
                }),
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
                weaponImgs = loadWeaponAnimImages("assets/units/monk/base/Fire_attack.png", animSwapPath, {
                    fire = "assets.units.monk.palettes.fire_preset",
                    ice = "assets.units.monk.palettes.ice_preset"
                }),
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

    return UnitFactory.create(config)
end

return {
    createInstance = createMonkInstance
}
