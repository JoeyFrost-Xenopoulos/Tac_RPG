-- modules/combat/battle_assets.lua
local Assets = {}

function Assets.load(state)
    state.platformImage = love.graphics.newImage("assets/combat/arena/battle_platform.png")
    state.platformImage:setFilter("nearest", "nearest")
    state.hitEffectImage = love.graphics.newImage("assets/combat/hit_effect/symett_hit_1.png")
    state.hitEffectImage:setFilter("nearest", "nearest")
    state.harpoonHitEffectImage = love.graphics.newImage("assets/combat/hit_effect/harpoon_hit_3.png")
    state.harpoonHitEffectImage:setFilter("nearest", "nearest")
    state.meleeHitEffectImage = love.graphics.newImage("assets/combat/hit_effect/melee_hit_1.png")
    state.meleeHitEffectImage:setFilter("nearest", "nearest")
    state.missEffectPlayerImage = love.graphics.newImage("assets/combat/miss_player.png")
    state.missEffectPlayerImage:setFilter("nearest", "nearest")
    state.missEffectEnemyImage = love.graphics.newImage("assets/combat/miss_enemy.png")
    state.missEffectEnemyImage:setFilter("nearest", "nearest")
    state.critEffectImage = love.graphics.newImage("assets/combat/crit.png")
    state.critEffectImage:setFilter("nearest", "nearest")
    state.battleFrameImage = love.graphics.newImage("assets/combat/battle_frame_attp.png")
    state.battleFrameImage:setFilter("nearest", "nearest")
    state.bigBarBaseImage = love.graphics.newImage("assets/ui/bars/BigBar_Base.png")
    state.bigBarBaseImage:setFilter("nearest", "nearest")
    state.bigBarFillImage = love.graphics.newImage("assets/ui/bars/BigBar_Fill.png")
    state.bigBarFillImage:setFilter("nearest", "nearest")
    state.expBarImage = love.graphics.newImage("assets/ui/bars/exp_bar.png")
    state.expBarImage:setFilter("nearest", "nearest")
        state.expBarBackgroundImage = love.graphics.newImage("assets/ui/bars/exp_background_myself.png")
        state.expBarBackgroundImage:setFilter("nearest", "nearest")
    state.levelUpTableImage = love.graphics.newImage("assets/ui/menu/menu.png")
    state.levelUpTableImage:setFilter("nearest", "nearest")
    state.levelUpHeaderRibbonImage = love.graphics.newImage("assets/ui/ribbons/BigRibbons.png")
    state.levelUpHeaderRibbonImage:setFilter("nearest", "nearest")
        state.levelUpArrowImage = love.graphics.newImage("assets/ui/bars/level_up_arrow.png")
        state.levelUpArrowImage:setFilter("nearest", "nearest")
    state.levelUpStarAnimImage = love.graphics.newImage("assets/ui/bars/star_anim.png")
    state.levelUpStarAnimImage:setFilter("nearest", "nearest")

    do
        local frameW, frameH = 192, 64
        local imageW, imageH = state.expBarImage:getDimensions()
        state.expBarBaseQuad = love.graphics.newQuad(0, 0, frameW, frameH, imageW, imageH)
        state.expBarFullFillQuad = love.graphics.newQuad(frameW, 0, frameW, frameH, imageW, imageH)
    end
    state.pixelFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 48)
    state.weaponFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 32)
    state.previewFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 30)
    state.levelUpHeaderFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 42)
    state.levelUpStatsFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 36)
    
    -- Load weapon icons
    state.weaponIcons = {}
    state.weaponIcons.sword = love.graphics.newImage("assets/ui/icons/sword.png")
    state.weaponIcons.sword:setFilter("nearest", "nearest")
    state.weaponIcons.harpoon = love.graphics.newImage("assets/ui/icons/harpoon.png")
    state.weaponIcons.harpoon:setFilter("nearest", "nearest")
    state.weaponIcons.bow = love.graphics.newImage("assets/ui/icons/bow.png")
    state.weaponIcons.bow:setFilter("nearest", "nearest")
    state.weaponIcons.fire = love.graphics.newImage("assets/ui/icons/fire_book.png")
    state.weaponIcons.fire:setFilter("nearest", "nearest")
    state.weaponIcons.ice = love.graphics.newImage("assets/ui/icons/ice_book.png")
    state.weaponIcons.ice:setFilter("nearest", "nearest")
    -- Keep thunder mapped for compatibility with older spell ids.
    state.weaponIcons.thunder = love.graphics.newImage("assets/ui/icons/ice_book.png")
    state.weaponIcons.thunder:setFilter("nearest", "nearest")
    
    -- Load projectile images
    state.projectileImages = {}
    state.projectileImages.harpoon = love.graphics.newImage("assets/units/harpoon_fish/base/Harpoon.png")
    state.projectileImages.harpoon:setFilter("nearest", "nearest")
    state.projectileImages.bow = love.graphics.newImage("assets/units/archer/base/Arrow.png")
    state.projectileImages.bow:setFilter("nearest", "nearest")
    state.projectileImages.ice = love.graphics.newImage("assets/units/monk/base/ice_shard_attack.png")
    state.projectileImages.ice:setFilter("nearest", "nearest")
end

return Assets
