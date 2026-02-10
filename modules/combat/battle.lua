-- modules/combat/battle.lua
local State = require("modules.combat.battle_state")
local Assets = require("modules.combat.battle_assets")
local Effects = require("modules.combat.battle_effects")
local Anim = require("modules.combat.battle_anim")
local Draw = require("modules.combat.battle_draw")
local Helpers = require("modules.combat.battle_helpers")
local CameraManager = require("modules.engine.camera_manager")

local Battle = State

-- ============================================================================
-- INITIALIZATION & LIFECYCLE
-- ============================================================================

function Battle.load()
    Assets.load(Battle)
end

function Battle.startBattle(attacker, defender)
    Battle.attacker = attacker
    Battle.defender = defender
    Battle.visible = true
    Battle.resetTimers()
    
    -- Start battle music transition
    local Audio = require("modules.audio.sound_effects")
    Audio.transitionToBattleTheme()
    
    local playerUnit = Helpers.getPlayerUnit(attacker, defender)
    local enemyUnit = Helpers.getEnemyUnit(attacker, defender)
    Battle.defenderHealthDisplay = enemyUnit and enemyUnit.health or 0
    Battle.playerHealthDisplay = playerUnit and playerUnit.health or 0
    Battle.defenderPreviousHealth = enemyUnit and enemyUnit.health or 0
    Battle.playerPreviousHealth = playerUnit and playerUnit.health or 0

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    local function getUnitScreenPosition(unit)
        if not unit then return screenW / 2, screenH / 2 end
        local tileSize = unit.tileSize or 64
        local worldX = (unit.tileX - 1) * tileSize + tileSize / 2
        local worldY = (unit.tileY - 1) * tileSize + tileSize
        return CameraManager.worldToScreen(worldX, worldY)
    end

    local attackerX, attackerY = getUnitScreenPosition(attacker)
    local defenderX, defenderY = getUnitScreenPosition(defender)

    Battle.transitionStartAttackerX = attackerX
    Battle.transitionStartAttackerY = attackerY
    Battle.transitionStartDefenderX = defenderX
    Battle.transitionStartDefenderY = defenderY

    Battle.transitionCenterX = (attackerX + defenderX) / 2
    Battle.transitionCenterY = (attackerY + defenderY) / 2

    Battle.transitionSquareSize = math.min(screenW, screenH) * 0.2
    Battle.transitionTargetW = Battle.transitionSquareSize
    Battle.transitionTargetH = Battle.transitionSquareSize
    Battle.transitionPhase = "platform_move"
    Battle.transitionTimer = 0
end

function Battle.endBattle()
    Battle.visible = false
    Battle.attacker = nil
    Battle.defender = nil
    Battle.resetTimers()
    
    -- Return to main theme
    local Audio = require("modules.audio.sound_effects")
    Audio.transitionToMainTheme()
end

-- ============================================================================
-- ATTACK SEQUENCE HELPERS
-- ============================================================================

local function playAttackSounds(attackFrameIndex)
    local Audio = require("modules.audio.sound_effects")
    if attackFrameIndex == 2 and not Battle.attackSwingPlayed then
        Audio.playAttackSwing()
        Battle.attackSwingPlayed = true
    end
    if attackFrameIndex == 3 and not Battle.attackHitPlayed then
        Audio.playAttackHit()
        Battle.attackHitPlayed = true
    end
end

local function calculateHealthAnimDuration(damage, targetUnit)
    if targetUnit and targetUnit.maxHealth and targetUnit.maxHealth > 0 then
        local healthLossPercent = damage / targetUnit.maxHealth
        return 0.3 + (healthLossPercent * 0.9)
    end
    return Battle.healthAnimDuration
end

local function applyDamageAndStartAnimation(attacker, defender, isCounterattack)
    local Attack = require("modules.engine.attack")
    local UnitManager = require("modules.units.manager")
    local playerUnit = Helpers.getPlayerUnit(Battle.attacker, Battle.defender)
    local enemyUnit = Helpers.getEnemyUnit(Battle.attacker, Battle.defender)

    -- Store previous health
    Battle.defenderPreviousHealth = enemyUnit and enemyUnit.health or 0
    Battle.playerPreviousHealth = playerUnit and playerUnit.health or 0

    -- Perform attack
    local damage = Attack.performAttack(attacker, defender)
    if isCounterattack then
        Battle.counterattackDamage = damage
    else
        Battle.damageAmount = damage
    end
    UnitManager.showDamage(defender, damage)

    -- Calculate animation duration
    Battle.healthAnimDurationActual = calculateHealthAnimDuration(damage, defender)

    -- Start health animation
    Battle.isHealthAnimating = true
    Battle.healthAnimStartTime = Battle.battleTimer
end

local function updateHealthAnimation()
    local elapsedTime = Battle.battleTimer - Battle.healthAnimStartTime
    local t = Helpers.clamp(elapsedTime / Battle.healthAnimDurationActual, 0, 1)
    local eased = Helpers.easeOutQuad(t)
    local playerUnit = Helpers.getPlayerUnit(Battle.attacker, Battle.defender)
    local enemyUnit = Helpers.getEnemyUnit(Battle.attacker, Battle.defender)

    Battle.defenderHealthDisplay = Battle.defenderPreviousHealth
        + ((enemyUnit and enemyUnit.health or 0) - Battle.defenderPreviousHealth) * eased
    Battle.playerHealthDisplay = Battle.playerPreviousHealth
        + ((playerUnit and playerUnit.health or 0) - Battle.playerPreviousHealth) * eased

    return t >= 1
end

local function resetPhaseFlags()
    Battle.attackSwingPlayed = false
    Battle.attackHitPlayed = false
    Battle.hitEffectActive = false
    Battle.hitFrameStartTime = 0
end

local function transitionToCounterattack()
    if Battle.counterattackEnabled and Battle.defender and Battle.defender.health > 0 then
        Battle.battlePhase = "counterattack"
        Battle.battleTimer = 0
        resetPhaseFlags()
        Battle.counterattackApplied = false
    else
        Battle.battlePhase = "done"
    end
end

local function finalizeDamageAnimation()
    Battle.isHealthAnimating = false
    local playerUnit = Helpers.getPlayerUnit(Battle.attacker, Battle.defender)
    local enemyUnit = Helpers.getEnemyUnit(Battle.attacker, Battle.defender)
    Battle.defenderHealthDisplay = enemyUnit and enemyUnit.health or 0
    Battle.playerHealthDisplay = playerUnit and playerUnit.health or 0
end

-- ============================================================================
-- PHASE HANDLERS
-- ============================================================================

local function updateInitialAttack()
    local attackFrameIndex = Anim.getAttackFrameIndex(Battle, Battle.attacker)
    Battle.attackFrameIndex = attackFrameIndex or 0

    playAttackSounds(attackFrameIndex)
    Effects.update(Battle, attackFrameIndex)

    -- Apply damage when animation completes
    local totalDuration = Battle.runDuration + Battle.attackDuration + (Battle.returnDuration or 0)
    if Battle.battleTimer >= totalDuration and not Battle.damageApplied then
        if Battle.attacker and Battle.defender then
            applyDamageAndStartAnimation(Battle.attacker, Battle.defender, false)
            Battle.damageApplied = true
        end
    end

    -- Update health animation and transition
    if Battle.damageApplied and Battle.isHealthAnimating then
        if updateHealthAnimation() then
            finalizeDamageAnimation()
            transitionToCounterattack()
        end
    end
end

local function updateCounterattack()
    local attackFrameIndex = Anim.getAttackFrameIndex(Battle, Battle.defender)
    Battle.attackFrameIndex = attackFrameIndex or 0

    playAttackSounds(attackFrameIndex)
    Effects.update(Battle, attackFrameIndex)

    -- Apply counterattack damage when animation completes
    local totalDuration = Battle.runDuration + Battle.attackDuration + (Battle.returnDuration or 0)
    if Battle.battleTimer >= totalDuration and not Battle.counterattackApplied then
        if Battle.attacker and Battle.defender then
            applyDamageAndStartAnimation(Battle.defender, Battle.attacker, true)
            Battle.counterattackApplied = true
        end
    end

    -- Update health animation and finish battle
    if Battle.counterattackApplied and Battle.isHealthAnimating then
        if updateHealthAnimation() then
            finalizeDamageAnimation()
            Battle.battlePhase = "done"
        end
    end
end

local function updateDone()
    local TurnManager = require("modules.engine.turn")
    TurnManager.markUnitAsMoved(Battle.attacker)
    if TurnManager.areAllUnitsMoved() then
        TurnManager.endTurn()
    end
    Battle.endBattle()
end

-- ============================================================================
-- MAIN UPDATE
-- ============================================================================

function Battle.update(dt)
    if not Battle.visible then return end

    if Battle.transitionPhase and Battle.transitionPhase ~= "done" then
        Battle.transitionTimer = Battle.transitionTimer + dt
        if Battle.transitionPhase == "platform_move" then
            if Battle.transitionTimer >= Battle.transitionMoveDuration then
                Battle.transitionPhase = "done"
                Battle.transitionTimer = 0
            end
        end
        return
    end

    Battle.battleTimer = Battle.battleTimer + dt

    if Battle.battlePhase == "initial_attack" then
        updateInitialAttack()
    elseif Battle.battlePhase == "counterattack" then
        updateCounterattack()
    elseif Battle.battlePhase == "done" then
        updateDone()
    end
end

-- ============================================================================
-- RENDERING & INPUT
-- ============================================================================

function Battle.draw()
    Draw.draw(Battle)
end

function Battle.clicked(mx, my)
    if not Battle.visible then return false end
    return true
end

return Battle
