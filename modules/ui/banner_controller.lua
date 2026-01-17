local Banner = require("modules.ui.banner")
local Soldier = require("modules.units.soldier")
local Enemy_Soldier = require("modules.units.enemy_soldier")

local Avatar_01 = love.graphics.newImage("assets/ui/avatars/Avatars_01.png")
local Avatar_06 = love.graphics.newImage("assets/ui/avatars/Avatars_06.png")

local BannerController = {}

BannerController.targets = {
    {
        isHovered = function(mx, my)
            return Soldier.isHovered(mx, my)
        end,
        variant = 1,
        anchor = "left",
        getX = function()
            return 0
        end,
        avatar = Avatar_01,
    },
    {
        isHovered = function(mx, my)
            return Enemy_Soldier.isHovered(mx, my)
        end,
        variant = 2,
        anchor = "right",
        getX = function()
            return WINDOW_WIDTH
        end,
        avatar = Avatar_06,
    }
}

BannerController.activeVariant = nil
BannerController.activeAvatar = nil

function BannerController.update(mx, my)
    for _, target in ipairs(BannerController.targets) do
        if target.isHovered(mx, my) then

            if BannerController.activeVariant ~= target.variant then
                Banner.reset()
                BannerController.activeVariant = target.variant
                BannerController.activeAvatar = target.avatar
            end

            Banner.activeVariant = target.variant
            Banner.anchor = target.anchor
            Banner.x = target.getX()
            Banner.y = my < 384 and 620 or 0

            if not Banner.animating then
                Banner.start()
            end

            return
        end
    end

    BannerController.activeVariant = nil
    BannerController.activeAvatar = nil
    Banner.reset()
end

function BannerController.draw()
    if Banner.activeVariant then
        Banner.draw()

        if BannerController.activeAvatar then
            local avatar = BannerController.activeAvatar
            local scale = 0.75 -- half size
            local avatarWidth = avatar:getWidth() * scale
            local avatarHeight = avatar:getHeight() * scale

            local bannerHeight = 128

            local avatarX
            if Banner.anchor == "left" then
                avatarX = Banner.x - 20
            elseif Banner.anchor == "right" then
                avatarX = 800
            else
                avatarX = Banner.x + 10
            end

            local avatarY = Banner.y + (bannerHeight / 2) - (avatarHeight / 2)
            love.graphics.draw(avatar, avatarX, avatarY, 0, scale, scale)
        end
    end
end

return BannerController
