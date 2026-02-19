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
    
    -- Calculate distance between attacker and defender
    local CombatSystem = require("modules.combat.combat_system")
    local distance = math.abs(attacker.tileX - defender.tileX) + math.abs(attacker.tileY - defender.tileY)
    local defenderRange = CombatSystem.getAttackRange(defender)
    local attackerRange = CombatSystem.getAttackRange(attacker)
    
    -- Disable counterattack if attacker is outside defender's range
    if distance > defenderRange then
        Battle.counterattackEnabled = false
    end
    
    -- Skip walk animation for ranged attacks (range > 1)
    if attackerRange > 1 then
        Battle.runDuration = 0
        Battle.returnDuration = 0
        Battle.attackDuration = 1.6  -- Extended duration to accommodate projectile flight
    else
        -- Reset to default values for melee attacks
        Battle.runDuration = 0.8
        Battle.returnDuration = 0.8
        Battle.attackDuration = 0.7
    end
    
    -- Start battle music transition
    local Audio = require("modules.audio.sound_effects")
    Audio.transitionToBattleTheme()
    
    local playerUnit = Helpers.getPlayerUnit(attacker, defender)
    local enemyUnit = Helpers.getEnemyUnit(attacker, defender)
    Battle.defenderHealthDisplay = enemyUnit and enemyUnit.health or 0
    Battle.playerHealthDisplay = playerUnit and playerUnit.health or 0
    Battle.defenderPreviousHealth = enemyUnit and enemyUnit.health or 0
    Battle.playerPreviousHealth = playerUnit and playerUnit.health or 0

    -- Calculate and set battle preview stats
    local CombatSystem = require("modules.combat.combat_system")
    
    -- Player stats
    if playerUnit and enemyUnit then
        Battle.playerAttackPreview = {
            hit = CombatSystem.calculateHitChance(playerUnit, enemyUnit),
            damage = CombatSystem.calculateTotalDamage(playerUnit, enemyUnit, false),
            crit = CombatSystem.calculateCritChance(playerUnit)
        }
    end
    
    -- Enemy stats
    if enemyUnit and playerUnit then
        Battle.enemyAttackPreview = {
            hit = CombatSystem.calculateHitChance(enemyUnit, playerUnit),
            damage = CombatSystem.calculateTotalDamage(enemyUnit, playerUnit, false),
            crit = CombatSystem.calculateCritChance(enemyUnit)
        }
    end

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

    local UnitManager = require("modules.units.manager")
    UnitManager.removeDeadUnits()
    
    -- Return to main theme
    local Audio = require("modules.audio.sound_effects")
    Audio.transitionToMainTheme()
end

-- ============================================================================
-- ATTACK SEQUENCE HELPERS
-- ============================================================================

local function playAttackSounds(attackFrameIndex, attacker, projectileHit)
    local Audio = require("modules.audio.sound_effects")
    local Projectile = require("modules.combat.battle_projectile")
    
    -- For ranged attacks, play sounds based on projectile hit
    if attacker and Projectile.needsProjectile(attacker) then
        if projectileHit then
            if Battle.currentAttackHit then
                if Battle.currentAttackIsCritical then
                    Audio.playAttackCritical()
                else
                    Audio.playAttackHit()
                end
            else
                Audio.playAttackMiss()
            end
            Battle.attackHitPlayed = true
        end
    else
        -- For melee attacks, use frame-based timing
        if attackFrameIndex == 2 and not Battle.attackSwingPlayed then
            Audio.playAttackSwing()
            Battle.attackSwingPlayed = true
        end
        if attackFrameIndex == 3 and not Battle.attackHitPlayed then
            if Battle.currentAttackHit then
                if Battle.currentAttackIsCritical then
                    Audio.playAttackCritical()
                else
                    Audio.playAttackHit()
                end
            else
                Audio.playAttackMiss()
            end
            Battle.attackHitPlayed = true
        end
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
    local UnitManager = require("modules.units.manager")
    local Audio = require("modules.audio.sound_effects")
    local playerUnit = Helpers.getPlayerUnit(Battle.attacker, Battle.defender)
    local enemyUnit = Helpers.getEnemyUnit(Battle.attacker, Battle.defender)

    -- Store previous health
    Battle.defenderPreviousHealth = enemyUnit and enemyUnit.health or 0
    Battle.playerPreviousHealth = playerUnit and playerUnit.health or 0

    -- Use pre-calculated damage (calculated in updateInitialAttack or updateCounterattack)
    local damage = Battle.calculatedAttackDamage
    
    -- Apply damage to defender
    local previousHealth = defender.health
    if damage > 0 then
        defender.health = math.max(0, defender.health - damage)
    end

    if previousHealth > 0 and defender.health == 0 then
        defender.isDead = true
        Audio.playDeathBell()
    end
    
    if isCounterattack then
        Battle.counterattackDamage = damage
    else
        Battle.damageAmount = damage
    end
    
    Battle.isLastAttackHit = damage > 0
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
    Battle.isLastAttackHit = true
    Battle.calculatedAttackDamage = 0
    Battle.currentAttackHit = false
    Battle.attackResultCalculated = false
    Battle.projectileSpawned = false  -- Reset projectile flag for counterattacks
    Battle.projectileFrame4Time = 0  -- Reset frame 4 time for counterattacks
end

local function transitionToCounterattack()
    if Battle.counterattackEnabled and Battle.defender and Battle.defender.health > 0 then
        Battle.battlePhase = "counterattack"
        Battle.battleTimer = 0
        resetPhaseFlags()
        Battle.counterattackApplied = false
        
        -- Set animation durations for counterattack based on defender's weapon range
        local CombatSystem = require("modules.combat.combat_system")
        local defenderRange = CombatSystem.getAttackRange(Battle.defender)
        
        -- Skip walk animation for ranged counterattacks
        if defenderRange > 1 then
            Battle.runDuration = 0
            Battle.returnDuration = 0
            Battle.attackDuration = 1.6  -- Extended duration to accommodate projectile flight
        else
            -- Reset to default values for melee counterattacks
            Battle.runDuration = 0.8
            Battle.returnDuration = 0.8
            Battle.attackDuration = 0.7
        end
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
    -- Pre-calculate the attack result on first frame
    if not Battle.attackResultCalculated and Battle.attacker and Battle.defender then
        -- Reset effect states for this attack phase
        Battle.hitEffectActive = false
        Battle.missEffectActive = false
        Battle.hitFrameStartTime = 0
        Battle.missFrameStartTime = 0
        local CombatSystem = require("modules.combat.combat_system")
        local damage = 0
        
        -- Check if attack hits
        Battle.currentAttackHit = CombatSystem.doesHit(Battle.attacker, Battle.defender)
        Battle.currentAttackIsCritical = false
        if Battle.currentAttackHit then
            local isCritical = CombatSystem.isCritical(Battle.attacker, Battle.defender)
            Battle.currentAttackIsCritical = isCritical
            damage = CombatSystem.calculateTotalDamage(Battle.attacker, Battle.defender, isCritical)
            
            -- Check for double attack
            if CombatSystem.canDoubleAttack(Battle.attacker, Battle.defender) then
                if CombatSystem.doesHit(Battle.attacker, Battle.defender) then
                    local isCritical2 = CombatSystem.isCritical(Battle.attacker, Battle.defender)
                    damage = damage + CombatSystem.calculateTotalDamage(Battle.attacker, Battle.defender, isCritical2)
                end
            end
        end
        Battle.calculatedAttackDamage = damage
        Battle.attackResultCalculated = true
    end

    local attackFrameIndex = Anim.getAttackFrameIndex(Battle, Battle.attacker)
    Battle.attackFrameIndex = attackFrameIndex or 0
    
    -- Handle projectile spawning on frame 4 for ranged attacks with delay
    local Projectile = require("modules.combat.battle_projectile")
    if Projectile.needsProjectile(Battle.attacker) and not Battle.projectileSpawned then
        if attackFrameIndex == 4 and Battle.projectileFrame4Time == 0 then
            -- Mark when we reached frame 4
            Battle.projectileFrame4Time = Battle.battleTimer
        end
        
        if Battle.projectileFrame4Time > 0 and (Battle.battleTimer - Battle.projectileFrame4Time) >= Battle.projectileSpawnDelay then
            local screenW = love.graphics.getWidth()
            local platformW = Battle.platformImage and Battle.platformImage:getDimensions() or 0
            local platformY = Battle.platformY or 0
            Projectile.spawn(Battle, Battle.attacker, Battle.defender, screenW, platformW, platformY)
        end
    end
    
    -- Update projectile and check if it hit
    local projectileHit = Projectile.update(Battle)

    playAttackSounds(attackFrameIndex, Battle.attacker, projectileHit)
    Effects.update(Battle, attackFrameIndex, Battle.attacker, projectileHit)
    Effects.updateMiss(Battle, attackFrameIndex, Battle.attacker, projectileHit)

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
    -- Pre-calculate counterattack result on first frame
    if not Battle.attackResultCalculated and Battle.attacker and Battle.defender then
        -- Reset effect states for this new attack phase
        Battle.hitEffectActive = false
        Battle.missEffectActive = false
        Battle.hitFrameStartTime = 0
        Battle.missFrameStartTime = 0
        local CombatSystem = require("modules.combat.combat_system")
        local damage = 0
        
        -- Check if counterattack hits
        Battle.currentAttackHit = CombatSystem.doesHit(Battle.defender, Battle.attacker)
        Battle.currentAttackIsCritical = false
        if Battle.currentAttackHit then
            local isCritical = CombatSystem.isCritical(Battle.defender, Battle.attacker)
            Battle.currentAttackIsCritical = isCritical
            damage = CombatSystem.calculateTotalDamage(Battle.defender, Battle.attacker, isCritical)
            
            -- Check if defender can double attack
            if CombatSystem.canBeDoubleAttacked(Battle.attacker, Battle.defender) and Battle.attacker.health > 0 then
                if CombatSystem.doesHit(Battle.defender, Battle.attacker) then
                    damage = damage + CombatSystem.calculateTotalDamage(Battle.defender, Battle.attacker, false)
                end
            end
        end
        Battle.calculatedAttackDamage = damage
        Battle.attackResultCalculated = true
    end

    local attackFrameIndex = Anim.getAttackFrameIndex(Battle, Battle.defender)
    Battle.attackFrameIndex = attackFrameIndex or 0
    
    -- Handle projectile spawning on frame 4 for ranged counterattacks with delay
    local Projectile = require("modules.combat.battle_projectile")
    if Projectile.needsProjectile(Battle.defender) and not Battle.projectileSpawned then
        if attackFrameIndex == 4 and Battle.projectileFrame4Time == 0 then
            -- Mark when we reached frame 4
            Battle.projectileFrame4Time = Battle.battleTimer
        end
        
        if Battle.projectileFrame4Time > 0 and (Battle.battleTimer - Battle.projectileFrame4Time) >= Battle.projectileSpawnDelay then
            local screenW = love.graphics.getWidth()
            local platformW = Battle.platformImage and Battle.platformImage:getDimensions() or 0
            local platformY = Battle.platformY or 0
            Projectile.spawn(Battle, Battle.defender, Battle.attacker, screenW, platformW, platformY)
        end
    end
    
    -- Update projectile and check if it hit
    local projectileHit = Projectile.update(Battle)

    playAttackSounds(attackFrameIndex, Battle.defender, projectileHit)
    Effects.update(Battle, attackFrameIndex, Battle.defender, projectileHit)
    Effects.updateMiss(Battle, attackFrameIndex, Battle.defender, projectileHit)

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
