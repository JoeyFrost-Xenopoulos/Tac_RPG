-- modules/ui/unit_stats.lua
local UnitStats = {}

UnitStats.visible = false
UnitStats.font = nil
UnitStats.background = nil
UnitStats.units = {}
UnitStats.index = 1
UnitStats.smallFont = nil
UnitStats.headerFont = nil
UnitStats.animTimer = 0
UnitStats.animFrame = 1

function UnitStats.load()
    UnitStats.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 46)
    UnitStats.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 38)
    UnitStats.headerFont = love.graphics.newFont("assets/ui/font/Star_Crush_Font.otf", 46)
    UnitStats.background = love.graphics.newImage("assets/ui/menu/stats_menu.png")
end

function UnitStats.show()
    local UnitManager = require("modules.units.manager")
    UnitStats.units = {}
    for _, unit in ipairs(UnitManager.units or {}) do
        if unit.isPlayer then
            table.insert(UnitStats.units, unit)
        end
    end
    UnitStats.index = 1
    UnitStats.visible = true
end

function UnitStats.hide()
    UnitStats.visible = false
end

function UnitStats.nextUnit()
    if #UnitStats.units == 0 then return end
    UnitStats.index = UnitStats.index + 1
    if UnitStats.index > #UnitStats.units then
        UnitStats.index = 1
    end
end

function UnitStats.update(dt)
    if not UnitStats.visible then return end
    
    local unit = UnitStats.units[UnitStats.index]
    if unit and unit.animations and unit.animations.idle then
        local anim = unit.animations.idle
        UnitStats.animTimer = UnitStats.animTimer + dt
        if UnitStats.animTimer >= (anim.speed or 0.1) then
            UnitStats.animTimer = UnitStats.animTimer - (anim.speed or 0.1)
            UnitStats.animFrame = UnitStats.animFrame + 1
            if UnitStats.animFrame > anim.frameCount then
                UnitStats.animFrame = 1
            end
        end
    end
end

function UnitStats.draw()
    if not UnitStats.visible then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if UnitStats.background then
        local imgW, imgH = UnitStats.background:getDimensions()
        local scaleX = screenW / imgW
        local scaleY = screenH / imgH
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(UnitStats.background, 0, 0, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.1, 0.2, 0.8, 1)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    end

    if UnitStats.font then
        love.graphics.setFont(UnitStats.font)
        love.graphics.setColor(1, 1, 1, 1)
        local text = "Backspace to go back"
        local textW = UnitStats.font:getWidth(text)
        local textH = UnitStats.font:getHeight()
        love.graphics.print(text, (screenW - textW) / 2, screenH - textH - 40)
    end

    -- Draw "Personal Data" header
    if UnitStats.headerFont then
        love.graphics.setFont(UnitStats.headerFont)
        love.graphics.setColor(1, 1, 1, 1)
        local headerText = "Personal Data"
        local headerW = UnitStats.headerFont:getWidth(headerText)
        love.graphics.print(headerText, (screenW - headerW) / 2 + 180, 30)
    end

    local unit = UnitStats.units[UnitStats.index]
    if unit then
        local panelW = math.min(420, math.floor(screenW * 0.35))
        local panelX = screenW - panelW - 60
        local panelY = 80
        local padding = 20

        if unit.avatar then
            local maxPortrait = 160
            local scale = math.min(maxPortrait / unit.avatar:getWidth(), maxPortrait / unit.avatar:getHeight())
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(unit.avatar, panelX + padding - 550, panelY + padding - 70, 0, scale * 2, scale * 2)
        end

        local nameY = panelY + padding + 170
        if UnitStats.font then
            love.graphics.setFont(UnitStats.font)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(unit.type or "Unknown", panelX + padding - 450, nameY + 100, 0)
            love.graphics.print(unit.name or "Unknown", panelX + padding - 450, nameY + 136, 0)
        end
        
        -- Draw HP and Level under name
        if UnitStats.smallFont then
            love.graphics.setFont(UnitStats.smallFont)
            love.graphics.setColor(1, 1, 1, 1)
            local hpText = string.format("HP: %d/%d", unit.health or 0, unit.maxHealth or 0)
            love.graphics.print(hpText, panelX + padding - 540, nameY + 270, 0)
            love.graphics.print("Lvl: --", panelX + padding - 540, nameY + 306, 0)
        end
        
        -- Draw mini idle animation to the right
        if unit.animations and unit.animations.idle then
            local anim = unit.animations.idle
            if anim.quads and anim.quads[UnitStats.animFrame] and anim.img then
                local quad = anim.quads[UnitStats.animFrame]
                local animScale = 1  -- Scale down the animation
                local animX = panelX + padding - 240
                local animY = nameY + 140
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(anim.img, quad, animX - 140, animY + 60, 0, animScale, animScale)
            end
        end

        local statsX = panelX + padding
        local statsY = nameY + 90
        if UnitStats.smallFont then
            love.graphics.setFont(UnitStats.smallFont)
            local leftColumn = {
                { label = "Str", value = unit.strength and tostring(unit.strength) or "--" },
                { label = "Mag", value = unit.magic and tostring(unit.magic) or "--" },
                { label = "Skill", value = unit.skill and tostring(unit.skill) or "--" },
                { label = "Spd", value = unit.speed and tostring(unit.speed) or "--" }
            }
            local rightColumn = {
                { label = "Luck", value = unit.luck and tostring(unit.luck) or "--" },
                { label = "Def", value = unit.defense and tostring(unit.defense) or "--" },
                { label = "Res", value = unit.resistance and tostring(unit.resistance) or "--" },
                { label = "Move", value = tostring(unit.maxMoveRange or 0) }
            }
            
            -- Draw left column
            for i, stat in ipairs(leftColumn) do
                local lineY = statsY + (i - 1) * 40
                love.graphics.print(stat.label .. ":", statsX - 100, lineY - 250)
                love.graphics.print(stat.value, statsX + 120- 100, lineY - 250)
            end
            
            -- Draw right column
            local rightX = statsX + 240
            for i, stat in ipairs(rightColumn) do
                local lineY = statsY + (i - 1) * 40
                love.graphics.print(stat.label .. ":", rightX- 100, lineY - 250)
                love.graphics.print(stat.value, rightX + 120- 100, lineY - 250)
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return UnitStats
