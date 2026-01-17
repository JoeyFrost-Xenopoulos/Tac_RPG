local Banner = require("modules.ui.banner")
local Soldier = require("modules.units.soldier")
local Enemy_Soldier = require("modules.units.enemy_soldier")

local BannerController = {}

-- Configure hover targets here
BannerController.targets = {
    {
        isHovered = function(mx, my)
            return Soldier.isHovered(mx, my)
        end,
        variant = 1,
        anchor = "left",
        getX = function()
            return 0
        end
    },
    {
        isHovered = function(mx, my)
            return Enemy_Soldier.isHovered(mx, my)
        end,
        variant = 2,
        anchor = "right",
        getX = function()
            return WINDOW_WIDTH
        end
    }
}

BannerController.activeVariant = nil

function BannerController.update(mx, my)
    for _, target in ipairs(BannerController.targets) do
        if target.isHovered(mx, my) then

            -- Reset animation only if banner type changes
        if BannerController.activeVariant ~= target.variant then
            Banner.reset()            -- reset all animation state
            BannerController.activeVariant = target.variant
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

    -- Nothing hovered
    BannerController.activeVariant = nil
    Banner.reset()
end

function BannerController.draw()
    if Banner.activeVariant then
        Banner.draw()
    end
end

return BannerController
