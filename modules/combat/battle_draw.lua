-- modules/combat/battle_draw.lua
local Anim = require("modules.combat.battle_anim")
local Effects = require("modules.combat.battle_effects")
local TransitionDraw = require("modules.combat.battle_transition_draw")
local UiDraw = require("modules.combat.battle_ui_draw")
local Helpers = require("modules.combat.battle_helpers")
local FrameDraw = require("modules.combat.battle_frame_draw")
local Projectile = require("modules.combat.battle_projectile")
local UnitAnimation = require("modules.units.base.animation")

local Draw = {}
local whiteSpriteShader

local function drawExpBar(state, screenW, screenH)
    if not state.expBarActive then return end
    if not state.expBarImage or not state.expBarBaseQuad or not state.expBarFullFillQuad then return end

    local function drawOutlinedText(text, x, y, width, align)
        align = align or "left"
        love.graphics.setColor(0, 0, 0, 1)
        if width then
            love.graphics.printf(text, x - 1, y, width, align)
            love.graphics.printf(text, x + 1, y, width, align)
            love.graphics.printf(text, x, y - 1, width, align)
            love.graphics.printf(text, x, y + 1, width, align)
            love.graphics.setColor(1, 0.8706, 0.2588, 1)
            love.graphics.printf(text, x, y, width, align)
        else
            love.graphics.print(text, x - 1, y)
            love.graphics.print(text, x + 1, y)
            love.graphics.print(text, x, y - 1)
            love.graphics.print(text, x, y + 1)
            love.graphics.setColor(1, 0.8706, 0.2588, 1)
            love.graphics.print(text, x, y)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end

    local barScaleX, barScaleY = 2, 1
    local barW, barH = 192 * barScaleX, 64 * barScaleY
    local numberGap = -4
    local numberAreaW = 86
    local numberRightPadding = 16
    local barY = screenH * 0.89 - (barH / 2)
    local panelPaddingX = 20
    local panelPaddingTop = 60
    local panelPaddingBottom = 16
    local barX = (screenW - barW) / 2
    local panelW = barW + panelPaddingX + numberGap + numberAreaW + numberRightPadding
    local panelX = barX - panelPaddingX
    local panelY = barY - panelPaddingTop
    local panelH = barH + panelPaddingTop + panelPaddingBottom
    local numberX = barX + barW + numberGap
    local animDelay = state.expBarAnimDelay or 0
    local animDuration = math.max(state.expBarAnimDuration or 1.0, 0.001)
    local animElapsed = math.max(0, (state.expBarTimer or 0) - animDelay)
    local animProgress = math.max(0, math.min(1, animElapsed / animDuration))
    
    -- Hide exp bar after animation completes during level up stats display
    if state.expLeveledUp and state.levelUpTableImage and animProgress >= 1 then return end
    local startFill = state.expBarStartFillPercent or 0
    local targetFillUnits = state.expBarTargetFillUnits
    if targetFillUnits == nil then
        targetFillUnits = state.expBarFillPercent or 0
    end

    local traveledFillUnits = startFill + (targetFillUnits - startFill) * animProgress
    local fillPercent
    if animProgress >= 1 then
        fillPercent = state.expBarFillPercent or 0
    elseif traveledFillUnits >= 1 then
        fillPercent = traveledFillUnits % 1
        if fillPercent == 0 then
            fillPercent = 1
        end
    else
        fillPercent = traveledFillUnits
    end

    fillPercent = math.max(0, math.min(1, fillPercent))
    local fillVisibleWidth = math.floor(192 * barScaleX * fillPercent)
    local maxExperience = math.max(state.expBarMaxValue or 100, 1)
    local displayedExpValue
    if animProgress >= 1 then
        displayedExpValue = state.expBarEndValue or 0
    else
        local startExpValue = state.expBarStartValue or 0
        local animatedGain = math.floor((state.expBarGainAmount or 0) * animProgress + 0.5)
        displayedExpValue = (startExpValue + animatedGain) % maxExperience
    end

    -- Draw the EXP bar background image
    if state.expBarBackgroundImage then
        local bgScaleX = panelW / 1000
        local bgScaleY = panelH / 400
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.expBarBackgroundImage, panelX - 30, panelY - 140, 0, bgScaleX, bgScaleY)
    end

    if state.expLeveledUp then
        local bannerW = 320
        local bannerH = 42
        local bannerX = panelX + (panelW - bannerW) / 2
        local bannerY = panelY - 24
        local bannerText = "LEVEL UP! " .. tostring(state.expLevelBefore or 1) .. " -> " .. tostring(state.expLevelAfter or 1)
        local textYOffset = 8

        if state.weaponFont then
            love.graphics.setFont(state.weaponFont)
            textYOffset = 6
        elseif state.previewFont then
            love.graphics.setFont(state.previewFont)
            textYOffset = 4
        end

        love.graphics.setColor(0.05, 0.1, 0.35, 0.95)
        love.graphics.rectangle("fill", bannerX, bannerY, bannerW, bannerH, 12, 12)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", bannerX, bannerY, bannerW, bannerH, 12, 12)
        love.graphics.setLineWidth(1)

        drawOutlinedText(bannerText, bannerX, bannerY + textYOffset, bannerW, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
    if fillVisibleWidth > 0 then
        local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()
        love.graphics.setScissor(barX, barY, fillVisibleWidth, barH)
        love.graphics.draw(state.expBarImage, state.expBarFullFillQuad, barX, barY, 0, barScaleX, barScaleY)
        if scissorX then
            love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
        else
            love.graphics.setScissor()
        end
    end
    love.graphics.draw(state.expBarImage, state.expBarBaseQuad, barX, barY, 0, barScaleX, barScaleY)

    local previousFont = love.graphics.getFont()
    local gainLabelText = "EXP"
    local gainNumberText = tostring(displayedExpValue)
    local textX = panelX + 46
    local textY = panelY + 16

    if state.pixelFont then
        love.graphics.setFont(state.pixelFont)
        drawOutlinedText(gainLabelText, textX, textY)
        drawOutlinedText(gainNumberText, numberX, barY + 2, numberAreaW, "right")
    elseif state.previewFont then
        love.graphics.setFont(state.previewFont)
        drawOutlinedText(gainLabelText, textX, textY)
        drawOutlinedText(gainNumberText, numberX, barY + 8, numberAreaW, "right")
    elseif state.weaponFont then
        love.graphics.setFont(state.weaponFont)
        drawOutlinedText(gainLabelText, textX, textY)
        drawOutlinedText(gainNumberText, numberX, barY + 10, numberAreaW, "right")
    else
        drawOutlinedText(gainLabelText, textX, textY)
        drawOutlinedText(gainNumberText, numberX, barY + 10, numberAreaW, "right")
    end

    if previousFont then
        love.graphics.setFont(previousFont)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

local function drawLevelUpStats(state, screenW, screenH)
    if not state.expLeveledUp then return end
    if not state.levelUpTableImage then return end
    if not state.levelUpStatsBefore or not state.levelUpStatsAfter then return end
    
    -- Only show after exp bar animation completes
    local animDelay = state.expBarAnimDelay or 0
    local animDuration = math.max(state.expBarAnimDuration or 1.0, 0.001)
    local animElapsed = math.max(0, (state.expBarTimer or 0) - animDelay)
    local animProgress = math.max(0, math.min(1, animElapsed / animDuration))
    if animProgress < 1 then return end

    local function drawOutlinedText(text, x, y, width, align)
        align = align or "left"
        love.graphics.setColor(0, 0, 0, 1)
        if width then
            love.graphics.printf(text, x - 1, y, width, align)
            love.graphics.printf(text, x + 1, y, width, align)
            love.graphics.printf(text, x, y - 1, width, align)
            love.graphics.printf(text, x, y + 1, width, align)
            love.graphics.setColor(1, 0.8706, 0.2588, 1)
            love.graphics.printf(text, x, y, width, align)
        else
            love.graphics.print(text, x - 1, y)
            love.graphics.print(text, x + 1, y)
            love.graphics.print(text, x, y - 1)
            love.graphics.print(text, x, y + 1)
            love.graphics.setColor(1, 0.8706, 0.2588, 1)
            love.graphics.print(text, x, y)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Table dimensions and scaling
    local tableW, tableH = state.levelUpTableImage:getDimensions()
    local maxTableW = 700
    local maxTableH = 700
    local scale = math.min(maxTableW / tableW, maxTableH / tableH)
    local scaledW = tableW * scale
    local scaledH = tableH * scale
    
    -- Center the table on screen
    local tableX = (screenW - scaledW) / 2
    local tableY = (screenH - scaledH) / 2 - 30

    -- Draw the table background
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(state.levelUpTableImage, tableX, tableY, 0, scale - 0.1, scale - 0.05)

    -- Stats data with proper names
    local statsList = {
        {name = "HP", key = "maxHealth"},
        {name = "STR", key = "strength"},
        {name = "MAG", key = "magic"},
        {name = "SKL", key = "skill"},
        {name = "SPD", key = "speed"},
        {name = "LCK", key = "luck"},
        {name = "DEF", key = "defense"},
        {name = "RES", key = "resistance"},
        {name = "CON", key = "constitution"},
        {name = "AID", key = "aid"},
    }

    -- Setup font with larger size
    local previousFont = love.graphics.getFont()
    local statFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 28)
    love.graphics.setFont(statFont)

    -- Display stats in 2 columns with adjusted sizing for scaled table
    local startX = tableX + scaledW * 0.12
    local startY = tableY + scaledH * 0.18
    local colWidth = scaledW * 0.20  -- Reduced from 0.38 to bring columns closer
    local rowHeight = scaledH * 0.065
    local col1X = startX
    local col2X = startX + colWidth
    
    -- Calculate animation timing for sequential stat updates
    local statAnimDelay = 0.1  -- Delay between each stat animation
    local statAnimDuration = 0.15  -- How long each stat takes to animate
    local totalStatsAnimDelay = 0.2  -- Delay before first stat starts animating (after exp bar finishes)
    
    -- Get current time relative to when we want stats to start animating
    local statStartTime = (state.expBarAnimDelay or 0) + math.max(state.expBarAnimDuration or 1.0, 0.001) + (state.expBarPostHoldDuration or 0.8) + totalStatsAnimDelay
    local elapsedSinceStatStart = math.max(0, (state.expBarTimer or 0) - statStartTime)
    
    for i, stat in ipairs(statsList) do
        local row = i % 5
        if row == 0 then row = 5 end
        local colX = (i > 5) and col2X or col1X
        local yPos = startY + (row - 1) * rowHeight

        local statNameColor = {1, 1, 1}
        local statBefore = state.levelUpStatsBefore[stat.key] or 0
        local statAfter = state.levelUpStatsAfter[stat.key] or 0
        local statGain = statAfter - statBefore

        -- Draw stat name
        love.graphics.setColor(statNameColor[1], statNameColor[2], statNameColor[3], 1)
        love.graphics.print(stat.name, colX, yPos)

        -- Draw before value
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.print(tostring(statBefore), colX + scaledW * 0.05, yPos)

        -- Calculate animation progress for this specific stat
        local statStartDelay = (i - 1) * statAnimDelay
        local statAnimStart = statStartDelay
        local statAnimEnd = statStartDelay + statAnimDuration
        
        local animatedGain = 0  -- Animate the gain amount
        
        if elapsedSinceStatStart >= statAnimStart then
            if elapsedSinceStatStart < statAnimEnd then
                -- Stat is currently animating
                animProgress = (elapsedSinceStatStart - statAnimStart) / statAnimDuration
                animatedGain = statGain * animProgress
            else
                -- Animation complete, show final gain
                animatedGain = statGain
            end
        end
        
        -- Draw arrow and animated gain value with color based on gain
        if statGain > 0 then
            love.graphics.setColor(0.3, 1, 0.3, 1)  -- Green for increase
            love.graphics.print("→", colX + scaledW * 0.095, yPos)
            love.graphics.print("+" .. tostring(math.floor(animatedGain + 0.5)), colX + scaledW * 0.115, yPos)
        elseif statGain < 0 then
            love.graphics.setColor(1, 0.3, 0.3, 1)  -- Red for decrease
            love.graphics.print("→", colX + scaledW * 0.095, yPos)
            love.graphics.print(tostring(math.floor(animatedGain + 0.5)), colX + scaledW * 0.115, yPos)
        else
            love.graphics.setColor(0.6, 0.6, 0.6, 1)  -- Gray for no change
            love.graphics.print("=", colX + scaledW * 0.095, yPos)
            love.graphics.print("0", colX + scaledW * 0.115, yPos)
        end
    end

    -- Draw LEVEL UP banner
    local bannerW = 400
    local bannerH = 50
    local bannerX = (screenW - bannerW) / 2
    local bannerY = tableY - 70

    love.graphics.setColor(0.05, 0.1, 0.35, 0.95)
    love.graphics.rectangle("fill", bannerX, bannerY, bannerW, bannerH, 12, 12)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", bannerX, bannerY, bannerW, bannerH, 12, 12)
    love.graphics.setLineWidth(1)

    local bannerText = "LEVEL UP! " .. tostring(state.expLevelBefore or 1) .. " → " .. tostring(state.expLevelAfter or 1)
    if state.weaponFont then
        love.graphics.setFont(state.weaponFont)
    elseif state.previewFont then
        love.graphics.setFont(state.previewFont)
    end
    drawOutlinedText(bannerText, bannerX, bannerY + 8, bannerW, "center")

    if previousFont then
        love.graphics.setFont(previousFont)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

local function getWhiteSpriteShader()
    if whiteSpriteShader then return whiteSpriteShader end

    whiteSpriteShader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 tex = Texel(texture, texture_coords);
            return vec4(1.0, 1.0, 1.0, tex.a * color.a);
        }
    ]])

    return whiteSpriteShader
end

local function getDeathAnimVisual(state, unit)
    if not state.deathAnimActive then return true, 1 end
    if not state.deathAnimUnit or unit ~= state.deathAnimUnit then return true, 1 end

    local elapsed = state.battleTimer - (state.deathAnimStartTime or 0)
    if elapsed < 0 then
        return true, 1
    end

    local blinkDuration = state.deathAnimBlinkDuration or 0.22
    local fadeDuration = state.deathAnimFadeDuration or 0.75
    local blinkCount = state.deathAnimBlinkCount or 2

    if elapsed < blinkDuration then
        local toggleCount = math.max(1, blinkCount * 2)
        local blinkProgress = elapsed / blinkDuration
        local blinkSlice = math.floor(blinkProgress * toggleCount)
        return blinkSlice % 2 == 0, 1
    end

    local fadeElapsed = elapsed - blinkDuration
    if fadeElapsed < fadeDuration then
        local alpha = 1 - (fadeElapsed / fadeDuration)
        return true, math.max(0, math.min(1, alpha))
    end

    return false, 0
end

function Draw.draw(state)
    if not state.visible then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if TransitionDraw.draw(state, screenW, screenH, Draw.drawUnit) then
        return
    end

    -- Draw semi-transparent dark overlay to darken the map
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    love.graphics.setColor(1, 1, 1, 1)

    if state.platformImage then
        local platformW, platformH = state.platformImage:getDimensions()
        local centerX = screenW / 2
        local platformY = screenH / 2 - platformH * 0.6 / 2 + 80

        local leftPlatformX = centerX - platformW * 0.6
        love.graphics.draw(state.platformImage, leftPlatformX + 360, platformY + 100, 0, -0.8, 0.8)

        local rightPlatformX = centerX
        love.graphics.draw(state.platformImage, rightPlatformX, platformY + 100, 0, 0.8, 0.8)

        state.platformX = leftPlatformX
        state.platformY = platformY

        local defenderStaticX, defenderFacingX
        if state.attacker.isPlayer then
            defenderStaticX = centerX - platformW * 0.3
            defenderFacingX = 1
        else
            defenderStaticX = centerX + platformW * 0.3
            defenderFacingX = -1
        end

        -- Determine which unit is animating and which is static
        local useCounterattackLayout = state.battlePhase == "counterattack"
            or (state.battlePhase == "death_anim" and state.deathAnimUnit and state.deathAnimUnit == state.attacker)

        if useCounterattackLayout then
            -- During counterattack: defender animates, attacker is static
            local attackerStaticX
            if state.attacker.isPlayer then
                attackerStaticX = centerX + platformW * 0.3
            else
                attackerStaticX = centerX - platformW * 0.3
            end
            local attackerFacingX = state.attacker.isPlayer and -1 or 1
            
            -- Apply slide-back offset if attacker is the target
            local slideOffset = 0
            local attackerAnim = "idle"
            if state.slideBackTarget == state.attacker then
                slideOffset = Effects.getSlideBackOffset(state)
                if Effects.isWalkingBack(state) then
                    attackerAnim = "walk"
                end
            end
            
            if state.attacker then
                Draw.drawUnit(state, state.attacker, attackerStaticX + slideOffset, platformY - 60, attackerFacingX, false, attackerAnim, true)
            end

            if state.defender then
                local defenderX = Anim.getAttackerDisplayPosition(state, screenW, platformW, state.defender)
                local defenderAnim = Helpers.getAttackAnimName(state, state.defender)
                Draw.drawUnit(state, state.defender, defenderX, platformY - 60, defenderFacingX, false, defenderAnim)
            end

            -- Hit effect should be on the attacker during counterattack
            if state.attacker and state.hitEffectActive then
                Effects.drawBreak(state, attackerStaticX + slideOffset, platformY + 160, state.defender)
            end
            if state.attacker and state.missEffectActive then
                Effects.drawMiss(state, attackerStaticX + slideOffset, platformY + 160, state.defender)
            end
            if state.attacker and state.critEffectActive then
                Effects.drawCrit(state, attackerStaticX + slideOffset, platformY + 160)
            end

            if state.attacker and state.fireEffectActive then
                Effects.drawFire(state, attackerStaticX + slideOffset, platformY + 160, state.defender)
            end
        else
            -- During initial attack: attacker animates, defender is static
            
            -- Apply slide-back offset if defender is the target
            local slideOffset = 0
            local defenderAnim = nil
            if state.slideBackTarget == state.defender then
                slideOffset = Effects.getSlideBackOffset(state)
                if Effects.isWalkingBack(state) then
                    defenderAnim = "walk"
                end
            end
            
            if state.defender then
                Draw.drawUnit(state, state.defender, defenderStaticX + slideOffset, platformY - 60, defenderFacingX, false, defenderAnim, true)
            end

            if state.defender and state.fireEffectActive then
                Effects.drawFire(state, defenderStaticX + slideOffset, platformY + 160, state.attacker)
            end

            if state.defender and state.hitEffectActive then
                Effects.drawBreak(state, defenderStaticX + slideOffset, platformY + 160, state.attacker)
            end
            if state.defender and state.missEffectActive then
                Effects.drawMiss(state, defenderStaticX + slideOffset, platformY + 160, state.attacker)
            end
            if state.defender and state.critEffectActive then
                Effects.drawCrit(state, defenderStaticX + slideOffset, platformY + 160)
            end

            if state.attacker then
                local attackerX = Anim.getAttackerDisplayPosition(state, screenW, platformW, state.attacker)
                local attackerFacingX = state.attacker.isPlayer and -1 or 1
                local attackAnim = Helpers.getAttackAnimName(state, state.attacker)
                Draw.drawUnit(state, state.attacker, attackerX, platformY - 60, attackerFacingX, false, attackAnim)
            end
        end
    end

    if state.battleFrameImage then
        local frameW, frameH = state.battleFrameImage:getDimensions()
        local frameX = (screenW - frameW) / 2
        local frameY = (screenH - frameH) / 2
        
        -- Apply overlay shake offset
        local shakeX, shakeY = Effects.getOverlayShake(state)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.battleFrameImage, frameX + shakeX, frameY + shakeY - 60)

        FrameDraw.drawAttackPreview(state, frameX + shakeX, frameY + shakeY, frameW)
        FrameDraw.drawWeaponInfo(state, frameX + shakeX, frameY + shakeY, frameW, state.weaponIcons, state.weaponFont)
    end

    -- Apply overlay shake offset to big bar
    local shakeX, shakeY = Effects.getOverlayShake(state)
    UiDraw.drawBigBar(state, screenW, screenH, nil, shakeX, shakeY)
    
    -- Draw projectile on top of units
    Projectile.draw(state)

    drawExpBar(state, screenW, screenH)
    drawLevelUpStats(state, screenW, screenH)

    Effects.drawFlash(state, screenW, screenH)

end

function Draw.drawUnit(state, unit, x, y, facingX, isAttacking, animNameOverride, applyHitEffect, scaleMultiplier)
    if not unit or not unit.animations then return end

    local isVisible, alpha = getDeathAnimVisual(state, unit)
    if not isVisible then return end

    local animName = animNameOverride or (isAttacking and "attack" or "idle")
    local drawAnimName = animName
    local quad
    if animName == "attack" then
        drawAnimName = Anim.getAttackAnimName(unit)
        quad = Anim.getAttackFrame(state, unit)
    else
        quad = Anim.getAnimationFrame(state, unit, animName)
    end
    if not quad then return end

    local _, _, qw, qh = quad:getViewport()
    local offsetX = qw / 2
    local offsetY = qh - 50

    scaleMultiplier = scaleMultiplier or 1
    local sX = unit.scaleX * facingX * scaleMultiplier
    local sY = unit.scaleY * scaleMultiplier

    local shouldWhiteFlash = false
    if applyHitEffect and state.hitEffectActive and state.hitEffectStartTime then
        local spriteFlashLeadTime = 0.025
        local timeSinceHit = state.battleTimer - (state.hitEffectStartTime - spriteFlashLeadTime)
        local spriteFlashDuration = (state.hitEffectDuration or 0.12) * 0.55
        shouldWhiteFlash = timeSinceHit >= 0 and timeSinceHit < spriteFlashDuration
    end

    if shouldWhiteFlash then
        love.graphics.setShader(getWhiteSpriteShader())
    end

    local animImage = UnitAnimation.getImage(unit, drawAnimName)
    if not animImage then return end

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(animImage, quad, x, y + 280, 0, sX * 2, sY * 2, offsetX, offsetY)
    if shouldWhiteFlash then
        love.graphics.setShader()
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")
end

return Draw
