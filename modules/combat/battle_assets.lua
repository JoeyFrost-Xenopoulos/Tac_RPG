-- modules/combat/battle_assets.lua
local Assets = {}

function Assets.load(state)
    state.platformImage = love.graphics.newImage("assets/combat/arena/battle_platform.png")
    state.platformImage:setFilter("nearest", "nearest")
    state.hitEffectImage = love.graphics.newImage("assets/combat/hit_effect/break01.png")
    state.hitEffectImage:setFilter("nearest", "nearest")
    state.harpoonHitEffectImage = love.graphics.newImage("assets/combat/hit_effect/harpoon_hit_3.png")
    state.harpoonHitEffectImage:setFilter("nearest", "nearest")
    state.meleeHitEffectImage = love.graphics.newImage("assets/combat/hit_effect/melee_hit_1.png")
    state.meleeHitEffectImage:setFilter("nearest", "nearest")
    state.missEffectPlayerImage = love.graphics.newImage("assets/combat/miss_player.png")
    state.missEffectPlayerImage:setFilter("nearest", "nearest")
    state.missEffectEnemyImage = love.graphics.newImage("assets/combat/miss_enemy.png")
    state.missEffectEnemyImage:setFilter("nearest", "nearest")
    state.battleFrameImage = love.graphics.newImage("assets/combat/battle_frame_attp.png")
    state.battleFrameImage:setFilter("nearest", "nearest")
    state.bigBarBaseImage = love.graphics.newImage("assets/ui/bars/BigBar_Base.png")
    state.bigBarBaseImage:setFilter("nearest", "nearest")
    state.bigBarFillImage = love.graphics.newImage("assets/ui/bars/BigBar_Fill.png")
    state.bigBarFillImage:setFilter("nearest", "nearest")
    state.pixelFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 48)
    state.weaponFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 32)
    state.previewFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 30)
    
    -- Load weapon icons
    state.weaponIcons = {}
    state.weaponIcons.sword = love.graphics.newImage("assets/ui/icons/sword.png")
    state.weaponIcons.sword:setFilter("nearest", "nearest")
    state.weaponIcons.harpoon = love.graphics.newImage("assets/ui/icons/harpoon.png")
    state.weaponIcons.harpoon:setFilter("nearest", "nearest")
    state.weaponIcons.bow = love.graphics.newImage("assets/ui/icons/bow.png")
    state.weaponIcons.bow:setFilter("nearest", "nearest")
    
    -- Load projectile images
    state.projectileImages = {}
    state.projectileImages.harpoon = love.graphics.newImage("assets/units/harpoon_fish/base/Harpoon.png")
    state.projectileImages.harpoon:setFilter("nearest", "nearest")
end

return Assets
