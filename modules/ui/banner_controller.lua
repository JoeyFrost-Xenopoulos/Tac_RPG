local Banner = require("modules.ui.banner")
local BigBar = require("modules.ui.bigbar")
local UnitManager = require("modules.units.manager")

local BannerController = {}

BannerController.activeUnit = nil

function BannerController.update(mx, my)
    local hoveredUnit = nil

    for _, unit in ipairs(UnitManager.units) do
        if unit:isHovered(mx, my) then
            hoveredUnit = unit
            break
        end
    end

    if hoveredUnit then
        if BannerController.activeUnit ~= hoveredUnit then
            Banner.reset()
            BannerController.activeUnit = hoveredUnit
        end

        Banner.activeVariant = hoveredUnit.uiVariant
        Banner.anchor = hoveredUnit.uiAnchor        
        Banner.x = (hoveredUnit.uiAnchor == "right") and WINDOW_WIDTH or 10
        Banner.y = (my < 384) and 620 or 20

        if not Banner.animating then
            Banner.start()
        end
    else
        BannerController.activeUnit = nil
        Banner.reset()
    end
end

function BannerController.draw()
    local unit = BannerController.activeUnit
    
    if unit and Banner.activeVariant and Banner.currentWidth > 0 then
        Banner.draw()
        if unit.avatar then
            local scale = 0.75
            local avatarHeight = unit.avatar:getHeight() * scale
            local bannerHeight = 128
            
            local avatarX
            if Banner.anchor == "left" then
                avatarX = Banner.x - 20
            elseif Banner.anchor == "right" then
                avatarX = Banner.x - 170
            else
                avatarX = Banner.x + 10
            end
            local avatarY = Banner.y + (bannerHeight / 2) - (avatarHeight / 2)
            love.graphics.draw(unit.avatar, avatarX, avatarY, 0, scale, scale)
        end

        BigBar.draw(Banner.x, Banner.y, Banner.currentWidth, Banner.anchor)
    end
end

return BannerController