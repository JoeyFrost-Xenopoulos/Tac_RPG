-- modules/combat/battle_assets.lua
local Assets = {}

function Assets.load(state)
    state.platformImage = love.graphics.newImage("assets/combat/arena/battle_platform.png")
    state.platformImage:setFilter("nearest", "nearest")
    state.hitEffectImage = love.graphics.newImage("assets/combat/hit_effect/break01.png")
    state.hitEffectImage:setFilter("nearest", "nearest")
end

return Assets
