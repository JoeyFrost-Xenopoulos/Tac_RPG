-- modules/combat/battle_assets.lua
local Assets = {}

function Assets.load(state)
    state.platformImage = love.graphics.newImage("assets/combat/arena/battle_platform.png")
    state.platformImage:setFilter("nearest", "nearest")
    state.hitEffectImage = love.graphics.newImage("assets/combat/hit_effect/break01.png")
    state.hitEffectImage:setFilter("nearest", "nearest")
    state.battleFrameImage = love.graphics.newImage("assets/combat/battle_frame_attp.png")
    state.battleFrameImage:setFilter("nearest", "nearest")
    state.bigBarBaseImage = love.graphics.newImage("assets/ui/bars/BigBar_Base.png")
    state.bigBarBaseImage:setFilter("nearest", "nearest")
    state.bigBarFillImage = love.graphics.newImage("assets/ui/bars/BigBar_Fill.png")
    state.bigBarFillImage:setFilter("nearest", "nearest")
    state.pixelFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 48)
    state.weaponFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 32)
    state.previewFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 30)
    state.swordIconImage = love.graphics.newImage("assets/ui/icons/sword.png")
    state.swordIconImage:setFilter("nearest", "nearest")
end

return Assets
