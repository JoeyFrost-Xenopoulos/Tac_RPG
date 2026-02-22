-- modules/combat/battle_frame_draw.lua
-- Handles drawing UI elements on the battle frame

local FrameDraw = {}

local WEAPON_NAMES = {
    sword = "Heavy Sword",
    sword_test = "Practice Blade",
    bow = "Bow",
    harpoon = "Harpoon",
}

local PREVIEW_CONFIG = {
    enemyX = 80,
    playerX = -300,
    topY = 60,
    offsetY = 620,
    width = 220,
}

local WEAPON_CONFIG = {
    attackerX = 290,
    defenderX = -500,
    iconY = 735,
    iconScale = 0.80,
    textOffset = 10,
}

function FrameDraw.drawAttackPreview(state, frameX, frameY, frameW)
    if not state.previewFont then return end

    local enemyPreview = state.enemyAttackPreview or {}
    local playerPreview = state.playerAttackPreview or {}
    
    local leftPreviewX = frameX + PREVIEW_CONFIG.enemyX
    local rightPreviewX = frameX + frameW + PREVIEW_CONFIG.playerX
    local previewTopY = frameY + PREVIEW_CONFIG.topY
    local lineHeight = state.previewFont:getHeight() + 2

    love.graphics.setFont(state.previewFont)
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Enemy preview (left)
    love.graphics.print(string.format("Hit: %d%%", enemyPreview.hit or 0), 
        leftPreviewX + 50, previewTopY + PREVIEW_CONFIG.offsetY)
    love.graphics.print(string.format("Dmg: %d", enemyPreview.damage or 0), 
        leftPreviewX + 50, previewTopY + PREVIEW_CONFIG.offsetY + lineHeight)
    love.graphics.print(string.format("Crit: %d%%", enemyPreview.crit or 0), 
        leftPreviewX + 50, previewTopY + PREVIEW_CONFIG.offsetY + lineHeight * 2)

    -- Player preview (right)
    love.graphics.printf(string.format("Hit: %d%%", playerPreview.hit or 0), 
        rightPreviewX - 100, previewTopY + PREVIEW_CONFIG.offsetY, PREVIEW_CONFIG.width, "right")
    love.graphics.printf(string.format("Dmg: %d", playerPreview.damage or 0), 
        rightPreviewX - 110, previewTopY + PREVIEW_CONFIG.offsetY + lineHeight, PREVIEW_CONFIG.width, "right")
    love.graphics.printf(string.format("Crit: %d%%", playerPreview.crit or 0), 
        rightPreviewX - 100, previewTopY + PREVIEW_CONFIG.offsetY + lineHeight * 2, PREVIEW_CONFIG.width, "right")
end

function FrameDraw.drawWeaponInfo(state, frameX, frameY, frameW, weaponIcons, weaponFont)
    if not weaponIcons or not weaponFont then return end

    love.graphics.setFont(weaponFont)
    love.graphics.setColor(1, 1, 1, 1)

    local leftUnit
    local rightUnit
    if state.attacker and state.defender then
        if state.attacker.isPlayer then
            leftUnit = state.defender
            rightUnit = state.attacker
        else
            leftUnit = state.attacker
            rightUnit = state.defender
        end
    else
        leftUnit = state.defender or state.attacker
        rightUnit = (leftUnit == state.defender) and state.attacker or state.defender
    end

    -- Left side weapon
    if leftUnit then
        local weaponType = leftUnit.weapon or "sword"
        local weaponIcon = weaponIcons[weaponType] or weaponIcons.sword
        local iconW, iconH = weaponIcon:getDimensions()
        
        local defenderSwordX = frameX + WEAPON_CONFIG.attackerX
        local defenderSwordY = frameY + WEAPON_CONFIG.iconY
        love.graphics.draw(weaponIcon, defenderSwordX, defenderSwordY, 0, 
            WEAPON_CONFIG.iconScale, WEAPON_CONFIG.iconScale)
        
        local weaponName = WEAPON_NAMES[weaponType] or "Unknown"
        love.graphics.print(weaponName, defenderSwordX + iconW * WEAPON_CONFIG.iconScale + WEAPON_CONFIG.textOffset, 
            defenderSwordY + 10
        )
    end

    -- Right side weapon
    if rightUnit then
        local weaponType = rightUnit.weapon or "sword"
        local weaponIcon = weaponIcons[weaponType] or weaponIcons.sword
        local iconW, iconH = weaponIcon:getDimensions()
        
        local attackerSwordX = frameX + frameW + WEAPON_CONFIG.defenderX
        local attackerSwordY = frameY + WEAPON_CONFIG.iconY
        love.graphics.draw(weaponIcon, attackerSwordX - 60, attackerSwordY, 0, 
            WEAPON_CONFIG.iconScale, WEAPON_CONFIG.iconScale)
        
        local weaponName = WEAPON_NAMES[weaponType] or "Unknown"
        love.graphics.print(weaponName, attackerSwordX + iconW * WEAPON_CONFIG.iconScale + WEAPON_CONFIG.textOffset - 60, 
            attackerSwordY + 10)
    end
end

return FrameDraw
