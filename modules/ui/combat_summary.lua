-- modules/ui/combat_summary.lua
-- Displays a combat preview menu before battle starts

local CombatSummary = {}
local CombatSystem = require("modules.combat.combat_system")

-- State
CombatSummary.visible = false
CombatSummary.attacker = nil
CombatSummary.defender = nil
CombatSummary.menuImage = nil
CombatSummary.scale = 0.4
CombatSummary.nameFont = nil
CombatSummary.font = nil
CombatSummary.hpFont = nil
CombatSummary.critFont = nil
CombatSummary.smallFont = nil
CombatSummary.weaponIcons = {}
CombatSummary.weaponIconScale = 0.8

function CombatSummary.load()
    CombatSummary.menuImage = love.graphics.newImage("assets/ui/menu/combat_summary_menu.png")
    CombatSummary.nameFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 42)
    CombatSummary.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 42)
    CombatSummary.hpLabelFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 42)
    CombatSummary.hpFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 42)
    CombatSummary.mtFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 42)
    CombatSummary.critFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 42)
    CombatSummary.critLabelFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 40)
    CombatSummary.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 18)
    CombatSummary.instructionFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 24)
    CombatSummary.weaponIcons.sword = love.graphics.newImage("assets/ui/icons/sword.png")
    CombatSummary.weaponIcons.sword:setFilter("nearest", "nearest")
end

function CombatSummary.show(attacker, defender)
    CombatSummary.visible = true
    CombatSummary.attacker = attacker
    CombatSummary.defender = defender
end

function CombatSummary.hide()
    CombatSummary.visible = false
    CombatSummary.attacker = nil
    CombatSummary.defender = nil
end

function CombatSummary.isVisible()
    return CombatSummary.visible
end

function CombatSummary.draw()
    if not CombatSummary.visible or not CombatSummary.attacker or not CombatSummary.defender then
        return
    end
    
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- Calculate menu position (left side of screen, centered vertically)
    local menuW = CombatSummary.menuImage:getWidth() * CombatSummary.scale
    local menuH = CombatSummary.menuImage:getHeight() * CombatSummary.scale
    local menuX = -50
    local menuY = (screenH - menuH) / 2 - 100
    
    -- Draw menu background
    love.graphics.draw(CombatSummary.menuImage, menuX, menuY, 0, CombatSummary.scale, CombatSummary.scale)
    
    -- Calculate combat stats
    local attacker = CombatSummary.attacker
    local defender = CombatSummary.defender
    
    local attackerDamage = CombatSystem.calculateTotalDamage(attacker, defender, false)
    local defenderDamage = CombatSystem.calculateTotalDamage(defender, attacker, false)
    local attackerHit = CombatSystem.calculateHitChance(attacker, defender)
    local defenderHit = CombatSystem.calculateHitChance(defender, attacker)
    local attackerCrit = CombatSystem.calculateCritChance(attacker)
    local defenderCrit = CombatSystem.calculateCritChance(defender)
    
    -- Draw text information
    local centerX = menuX + menuW / 2
    local textY = menuY + 60
    local lineHeight = 45
    local sectionGap = 20
    
    -- Unit names positioning
    local attackerNameOffsetX = 110
    local attackerNameOffsetY = -5
    local defenderNameOffsetX = -100
    local defenderNameOffsetY = 320
    
    -- Unit names at the top
    love.graphics.setFont(CombatSummary.nameFont)
    
    -- Attacker name (left side, blue)
    love.graphics.setColor(1, 1, 1, 1)
    local attackerName = attacker.name or "Player"
    local attackerNameWidth = CombatSummary.nameFont:getWidth(attackerName)
    local attackerNameX = centerX - attackerNameWidth + attackerNameOffsetX
    local attackerNameY = textY + attackerNameOffsetY
    love.graphics.print(attackerName, attackerNameX, attackerNameY)
    
    -- Defender name (right side, red)
    love.graphics.setColor(1, 1, 1, 1)
    local defenderName = defender.name or "Enemy"
    local defenderNameX = centerX + defenderNameOffsetX
    local defenderNameY = textY + defenderNameOffsetY
    love.graphics.print(defenderName, defenderNameX, defenderNameY)

    local attackerIcon = CombatSummary.weaponIcons[attacker.weapon] or CombatSummary.weaponIcons.sword
    local defenderIcon = CombatSummary.weaponIcons[defender.weapon] or CombatSummary.weaponIcons.sword
    if attackerIcon or defenderIcon then
        local iconScale = CombatSummary.weaponIconScale
        local defenderNameWidth = CombatSummary.nameFont:getWidth(defenderName)

        love.graphics.setColor(1, 1, 1, 1)
        if attackerIcon then
            local iconW = attackerIcon:getWidth()
            local attackerIconX = attackerNameX - 30 - iconW * iconScale
            love.graphics.draw(attackerIcon, attackerIconX, attackerNameY - 10, 0, iconScale, iconScale)
        end
        if defenderIcon then
            local defenderIconX = defenderNameX + defenderNameWidth + 30
            love.graphics.draw(defenderIcon, defenderIconX, defenderNameY - 10, 0, iconScale, iconScale)
        end
    end
    
    textY = textY + lineHeight + sectionGap
    
    -- Helper function to draw text
    local function drawTextWithBorder(text, x, y, font, isValue)
        if isValue then
            -- Draw light blue text
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(text, x, y)
        else
            -- Draw normal text
            love.graphics.print(text, x, y)
        end
    end
    
    -- Helper function to draw comparison stats
    local function drawStat(label, attackerValue, defenderValue, customFont, valueFont, attackerOffset, defenderOffset, labelFont, attackerX, attackerY, defenderX, defenderY)
        local font = labelFont or customFont or CombatSummary.font
        local vFont = valueFont or customFont or CombatSummary.font
        love.graphics.setFont(font)
        
        -- Calculate positions
        local labelWidth = font:getWidth(label)
        local attackerStr = tostring(attackerValue)
        local defenderStr = tostring(defenderValue)
        love.graphics.setFont(vFont)
        local attackerValWidth = vFont:getWidth(attackerStr)
        love.graphics.setFont(font)
        
        -- Default offsets if not provided
        attackerOffset = attackerOffset or 40
        defenderOffset = defenderOffset or -25
        
        -- Calculate default positions
        local defaultAttackerX = centerX + labelWidth / 2 + attackerOffset
        local defaultDefenderX = centerX - labelWidth / 2 - attackerValWidth + defenderOffset
        local defaultY = textY + 5
        
        -- Use manual positions if provided, otherwise use calculated defaults
        attackerX = attackerX or defaultAttackerX
        attackerY = attackerY or defaultY
        defenderX = defenderX or defaultDefenderX
        defenderY = defenderY or defaultY
        
        -- Label positioning offsets
        local labelOffsetX = 10
        local labelOffsetY = 10
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(label, centerX - labelWidth / 2 + labelOffsetX, textY + labelOffsetY - 5)
        
        -- Draw values with borders
        love.graphics.setFont(vFont)
        drawTextWithBorder(attackerStr, attackerX, attackerY, vFont, true)
        drawTextWithBorder(defenderStr, defenderX, defenderY, vFont, true)
        
        textY = textY + lineHeight
    end
    
    -- Draw all stats in comparison format
    love.graphics.setColor(1, 1, 1, 1)
    drawStat("HP", attacker.health, defender.health, CombatSummary.font, CombatSummary.hpFont, 40, -25, CombatSummary.hpLabelFont)
    drawStat("Mt", attackerDamage, defenderDamage, CombatSummary.font, CombatSummary.mtFont)
    drawStat("Hit", attackerHit .. "%", defenderHit .. "%", CombatSummary.font, nil, 30, -12)
    drawStat("Crt", attackerCrit .. "%", defenderCrit .. "%", CombatSummary.font, CombatSummary.critFont, 40, -25, CombatSummary.critLabelFont, nil, nil, nil, nil)
    
    textY = textY + sectionGap
    
    -- Instructions (centered under the menu)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(CombatSummary.instructionFont)
    
    local instructY = menuY + menuH - 10
    local instruction1 = "Left Click: Attack"
    local instruction2 = "Right Click: Cancel"
    local inst1Width = CombatSummary.instructionFont:getWidth(instruction1)
    local inst2Width = CombatSummary.instructionFont:getWidth(instruction2)
    
    love.graphics.print(instruction1, menuX + (menuW - inst1Width) / 2, instructY)
    love.graphics.print(instruction2, menuX + (menuW - inst2Width) / 2, instructY + 25)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function CombatSummary.clicked(button)
    if not CombatSummary.visible then
        return
    end
    
    if button == 1 then
        -- Left click: proceed with attack
        local attacker = CombatSummary.attacker
        local defender = CombatSummary.defender
        CombatSummary.hide()
        
        -- Deselect all units before starting battle
        local UnitManager = require("modules.units.manager")
        UnitManager.deselectAll()
        
        -- Start the battle
        local Battle = require("modules.combat.battle")
        Battle.startBattle(attacker, defender)
        
        return true
    elseif button == 2 then
        -- Right click: cancel and return to target selection
        CombatSummary.hide()
        
        -- Return to attack selection state
        local UnitManager = require("modules.units.manager")
        UnitManager.returnToAttackSelection()
        
        return true
    end
    
    return false
end

return CombatSummary
