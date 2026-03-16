-- modules/combat/battle_phase_manager.lua
-- Manages different battle phases: initial_attack, counterattack, death_anim, done

local PhaseManager = {}

local function applyLevelGrowths(unit, levelsGained)
    if not unit or levelsGained <= 0 then return end

    local growthRates = unit.growthRates or {}
    local growthStats = {
        "maxHealth",
        "strength",
        "magic",
        "skill",
        "speed",
        "luck",
        "defense",
        "resistance",
        "constitution",
        "aid",
    }

    for _ = 1, levelsGained do
        for _, statName in ipairs(growthStats) do
            local chance = growthRates[statName] or 0
            if love.math.random(100) <= chance then
                unit[statName] = (unit[statName] or 0) + 1
                if statName == "maxHealth" then
                    unit.health = (unit.health or 0) + 1
                end
            end
        end
    end
end

local function applyAttackDurations(battleState, unit)
    local Helpers = require("modules.combat.battle_helpers")
    local CombatSystem = require("modules.combat.combat_system")
    local unitRange = CombatSystem.getAttackRange(unit)

    if Helpers.isMonkCaster(unit) or unitRange > 1 then
        battleState.runDuration = 0
        battleState.returnDuration = 0
        battleState.attackDuration = 1.6
    else
        battleState.runDuration = 0.8
        battleState.returnDuration = 0.8
        battleState.attackDuration = 0.7
    end
end

local function recordResolvedAttack(battleState, actingUnit, targetUnit, damageAmount, wasCritical)
    if not actingUnit or not targetUnit then return end

    if targetUnit.isPlayer then
        battleState.playerWasAttackedThisBattle = true
        battleState.playerWasCounterattacked = true
    end

    if actingUnit.isPlayer and damageAmount > 0 then
        battleState.playerAttackedThisBattle = true

        if wasCritical then
            battleState.playerCriticalThisBattle = true
        end

        if not targetUnit.isPlayer and (targetUnit.isDead or (targetUnit.health or 0) <= 0) then
            battleState.enemyWasKilled = true
        end
    end
end

function PhaseManager.startFollowupAttack(battleState, isDefenderAttacking)
    local AttackHelpers = require("modules.combat.battle_attack_helpers")

    battleState.battleTimer = 0
    battleState.damageApplied = false
    battleState.counterattackApplied = false
    battleState.attackResultCalculated = false
    battleState.isHealthAnimating = false
    battleState.healthAnimStartTime = 0
    battleState.hitEffectActive = false
    battleState.missEffectActive = false
    battleState.critEffectActive = false
    battleState.hitFrameStartTime = 0
    battleState.missFrameStartTime = 0
    battleState.critFrameStartTime = 0
    battleState.projectileActive = false
    battleState.projectileSpawned = false
    battleState.projectileFrame4Time = 0
    battleState.projectileStartTime = 0
    battleState.projectileStartX = 0
    battleState.projectileStartY = 0
    battleState.projectileTargetX = 0
    battleState.projectileTargetY = 0
    battleState.fireEffectActive = false
    battleState.fireEffectStartTime = 0
    battleState.fireImpactTriggered = false
    battleState.slideBackActive = false
    battleState.slideBackTarget = nil
    battleState.slideBackStartTime = 0

    AttackHelpers.resetPhaseFlags(battleState)

    battleState.battlePhase = isDefenderAttacking and "counterattack" or "initial_attack"
    if not isDefenderAttacking then
        battleState.counterattackEnabled = false
    end

    local actingUnit = isDefenderAttacking and battleState.defender or battleState.attacker
    if actingUnit then
        applyAttackDurations(battleState, actingUnit)
    end
end

function PhaseManager.transitionToCounterattack(battleState)
    if battleState.counterattackEnabled and battleState.defender and battleState.defender.health > 0 then
        local AttackHelpers = require("modules.combat.battle_attack_helpers")
        
        battleState.battlePhase = "counterattack"
        battleState.playerWasCounterattacked = true
        battleState.battleTimer = 0
        AttackHelpers.resetPhaseFlags(battleState)
        battleState.counterattackApplied = false
        
        -- Set animation durations for counterattack based on defender's weapon range
        applyAttackDurations(battleState, battleState.defender)
    else
        battleState.battlePhase = "done"
    end
end

function PhaseManager.updateInitialAttack(battleState, anim, effects, projectile)
    local CombatSystem = require("modules.combat.combat_system")
    local AttackHelpers = require("modules.combat.battle_attack_helpers")
    local BattleHelpers = require("modules.combat.battle_helpers")
    
    -- Pre-calculate the attack result on first frame
    if not battleState.attackResultCalculated and battleState.attacker and battleState.defender then
        -- Reset effect states for this attack phase
        battleState.hitEffectActive = false
        battleState.missEffectActive = false
        battleState.critEffectActive = false
        battleState.hitFrameStartTime = 0
        battleState.missFrameStartTime = 0
        battleState.critFrameStartTime = 0
        battleState.slideBackActive = false
        battleState.slideBackTarget = nil
        battleState.slideBackStartTime = 0
        local damage = 0
        
        -- Check if attack hits
        battleState.currentAttackHit = CombatSystem.doesHit(battleState.attacker, battleState.defender)
        battleState.currentAttackIsCritical = false
        if battleState.currentAttackHit then
            local isCritical = CombatSystem.isCritical(battleState.attacker, battleState.defender)
            battleState.currentAttackIsCritical = isCritical
            damage = CombatSystem.calculateTotalDamage(battleState.attacker, battleState.defender, isCritical)
        end
        battleState.calculatedAttackDamage = damage
        battleState.attackResultCalculated = true
    end

    local attackFrameIndex = anim.getAttackFrameIndex(battleState, battleState.attacker)
    battleState.attackFrameIndex = attackFrameIndex or 0
    
    -- Handle projectile spawning for ranged attacks
    if projectile.needsProjectile(battleState.attacker) and not battleState.projectileSpawned then
        local spawnFrame = projectile.getSpawnFrame(battleState.attacker.weapon)
        
        if attackFrameIndex == spawnFrame and battleState.projectileFrame4Time == 0 then
            battleState.projectileFrame4Time = battleState.battleTimer
        end
        
        if battleState.projectileFrame4Time > 0 then
            local spawnDelay = projectile.getSpawnDelay(battleState.attacker.weapon)
            if (battleState.battleTimer - battleState.projectileFrame4Time) >= spawnDelay then
                local screenW = love.graphics.getWidth()
                local platformW = battleState.platformImage and battleState.platformImage:getDimensions() or 0
                local platformY = battleState.platformY or 0
                projectile.spawn(battleState, battleState.attacker, battleState.defender, screenW, platformW, platformY)
            end
        end
    end
    
    -- Update projectile and check if it hit
    local projectileHit = projectile.update(battleState)

    AttackHelpers.playAttackSounds(battleState, attackFrameIndex, battleState.attacker, projectileHit)
    effects.update(battleState, attackFrameIndex, battleState.attacker, projectileHit)
    effects.updateMiss(battleState, attackFrameIndex, battleState.attacker, projectileHit)
    effects.updateCrit(battleState, attackFrameIndex, battleState.attacker, projectileHit)

    -- Apply damage when animation completes
    local totalDuration = battleState.runDuration + battleState.attackDuration + (battleState.returnDuration or 0)
    if battleState.battleTimer >= totalDuration and not battleState.damageApplied then
        if battleState.attacker and battleState.defender then
            AttackHelpers.applyDamageAndStartAnimation(battleState, battleState.attacker, battleState.defender, false)
            battleState.damageApplied = true
        end
    end

    -- Update health animation and transition
    if battleState.damageApplied and battleState.isHealthAnimating then
        if AttackHelpers.updateHealthAnimation(battleState) then
            AttackHelpers.finalizeDamageAnimation(battleState)
            recordResolvedAttack(
                battleState,
                battleState.attacker,
                battleState.defender,
                battleState.damageAmount or 0,
                battleState.currentAttackIsCritical
            )
            
            if AttackHelpers.startDeathAnimationIfNeeded(battleState, battleState.defender) then
                battleState.battlePhase = "death_anim"
            else
                if battleState.counterattackEnabled then
                    PhaseManager.transitionToCounterattack(battleState)
                else
                    local canFollowup = battleState.followupQueued
                        and not battleState.followupAttackerIsDefender
                        and battleState.attacker and battleState.attacker.health > 0
                        and battleState.defender and battleState.defender.health > 0
                    if canFollowup then
                        battleState.followupQueued = false
                        PhaseManager.startFollowupAttack(battleState, false)
                    else
                        battleState.battlePhase = "done"
                    end
                end
            end
        end
    end
end

function PhaseManager.updateCounterattack(battleState, anim, effects, projectile)
    local CombatSystem = require("modules.combat.combat_system")
    local AttackHelpers = require("modules.combat.battle_attack_helpers")
    
    -- Pre-calculate counterattack result on first frame
    if not battleState.attackResultCalculated and battleState.attacker and battleState.defender then
        -- Reset effect states for this new attack phase
        battleState.hitEffectActive = false
        battleState.missEffectActive = false
        battleState.critEffectActive = false
        battleState.hitFrameStartTime = 0
        battleState.missFrameStartTime = 0
        battleState.critFrameStartTime = 0
        battleState.slideBackActive = false
        battleState.slideBackTarget = nil
        battleState.slideBackStartTime = 0
        local damage = 0
        
        -- Check if counterattack hits
        battleState.currentAttackHit = CombatSystem.doesHit(battleState.defender, battleState.attacker)
        battleState.currentAttackIsCritical = false
        if battleState.currentAttackHit then
            local isCritical = CombatSystem.isCritical(battleState.defender, battleState.attacker)
            battleState.currentAttackIsCritical = isCritical
            damage = CombatSystem.calculateTotalDamage(battleState.defender, battleState.attacker, isCritical)
        end
        battleState.calculatedAttackDamage = damage
        battleState.attackResultCalculated = true
    end

    local attackFrameIndex = anim.getAttackFrameIndex(battleState, battleState.defender)
    battleState.attackFrameIndex = attackFrameIndex or 0
    
    -- Handle projectile spawning for ranged counterattacks
    if projectile.needsProjectile(battleState.defender) and not battleState.projectileSpawned then
        local spawnFrame = projectile.getSpawnFrame(battleState.defender.weapon)
        
        if attackFrameIndex == spawnFrame and battleState.projectileFrame4Time == 0 then
            battleState.projectileFrame4Time = battleState.battleTimer
        end
        
        if battleState.projectileFrame4Time > 0 then
            local spawnDelay = projectile.getSpawnDelay(battleState.defender.weapon)
            if (battleState.battleTimer - battleState.projectileFrame4Time) >= spawnDelay then
                local screenW = love.graphics.getWidth()
                local platformW = battleState.platformImage and battleState.platformImage:getDimensions() or 0
                local platformY = battleState.platformY or 0
                projectile.spawn(battleState, battleState.defender, battleState.attacker, screenW, platformW, platformY)
            end
        end
    end
    
    -- Update projectile and check if it hit
    local projectileHit = projectile.update(battleState)

    AttackHelpers.playAttackSounds(battleState, attackFrameIndex, battleState.defender, projectileHit)
    effects.update(battleState, attackFrameIndex, battleState.defender, projectileHit)
    effects.updateMiss(battleState, attackFrameIndex, battleState.defender, projectileHit)
    effects.updateCrit(battleState, attackFrameIndex, battleState.defender, projectileHit)

    -- Apply counterattack damage when animation completes
    local totalDuration = battleState.runDuration + battleState.attackDuration + (battleState.returnDuration or 0)
    if battleState.battleTimer >= totalDuration and not battleState.counterattackApplied then
        if battleState.attacker and battleState.defender then
            AttackHelpers.applyDamageAndStartAnimation(battleState, battleState.defender, battleState.attacker, true)
            battleState.counterattackApplied = true
        end
    end

    -- Update health animation and finish battle
    if battleState.counterattackApplied and battleState.isHealthAnimating then
        if AttackHelpers.updateHealthAnimation(battleState) then
            AttackHelpers.finalizeDamageAnimation(battleState)
            recordResolvedAttack(
                battleState,
                battleState.defender,
                battleState.attacker,
                battleState.counterattackDamage or 0,
                battleState.currentAttackIsCritical
            )
            if AttackHelpers.startDeathAnimationIfNeeded(battleState, battleState.attacker) then
                battleState.battlePhase = "death_anim"
            else
                if battleState.followupQueued then
                    local attackerAlive = battleState.attacker and battleState.attacker.health > 0
                    local defenderAlive = battleState.defender and battleState.defender.health > 0
                    if battleState.followupAttackerIsDefender and attackerAlive and defenderAlive then
                        battleState.followupQueued = false
                        PhaseManager.startFollowupAttack(battleState, true)
                    elseif (not battleState.followupAttackerIsDefender) and attackerAlive and defenderAlive then
                        battleState.followupQueued = false
                        PhaseManager.startFollowupAttack(battleState, false)
                    else
                        battleState.battlePhase = "done"
                    end
                else
                    battleState.battlePhase = "done"
                end
            end
        end
    end
end

function PhaseManager.updateDone(battleState, dt)
    -- Wait for slide-back animation to complete before ending battle
    if battleState.slideBackActive then
        return
    end

    if not battleState.expBarActive then
        local Helpers = require("modules.combat.battle_helpers")
        local Audio = require("modules.audio.sound_effects")
        local playerUnit = Helpers.getPlayerUnit(battleState.attacker, battleState.defender)
        local enemyUnit = Helpers.getEnemyUnit(battleState.attacker, battleState.defender)
        
        -- Determine EXP gain based on battle outcome
        local expGain = 0
        local playerSurvived = playerUnit and not playerUnit.isDead and (playerUnit.health or 0) > 0
        if playerSurvived then
            if battleState.enemyWasKilled or (enemyUnit and enemyUnit.isDead) then
                expGain = 70
            elseif battleState.playerAttackedThisBattle then
                expGain = 30
            elseif battleState.playerWasAttackedThisBattle then
                expGain = 10
            end
        end

        if expGain > 0 and battleState.playerCriticalThisBattle then
            expGain = expGain * 2
        end

        if playerUnit then
            local maxExperience = math.max(playerUnit.maxExperience or 100, 1)
            local previousExperience = playerUnit.experience or 0
            local previousLevel = playerUnit.level or 1
            local totalExperience = previousExperience + expGain
            local gainedLevels = math.floor(totalExperience / maxExperience)
            local newExperience = totalExperience % maxExperience

            playerUnit.level = previousLevel + gainedLevels
            playerUnit.experience = newExperience
            applyLevelGrowths(playerUnit, gainedLevels)

            battleState.expBarStartFillPercent = previousExperience / maxExperience
            battleState.expBarFillPercent = newExperience / maxExperience
            battleState.expBarTargetFillUnits = battleState.expBarStartFillPercent + (expGain / maxExperience)
            battleState.expBarGainAmount = expGain
            battleState.expBarStartValue = previousExperience
            battleState.expBarEndValue = newExperience
            battleState.expBarMaxValue = maxExperience
            battleState.expLeveledUp = gainedLevels > 0
            battleState.expLevelBefore = previousLevel
            battleState.expLevelAfter = playerUnit.level

            if gainedLevels > 0 then
                Audio.playLevelUp()
            elseif expGain > 0 then
                Audio.playExpGain()
            end
        else
            battleState.expBarStartFillPercent = 0
            battleState.expBarFillPercent = 0
            battleState.expBarTargetFillUnits = 0
            battleState.expBarGainAmount = 0
            battleState.expBarStartValue = 0
            battleState.expBarEndValue = 0
            battleState.expBarMaxValue = 100
            battleState.expLeveledUp = false
            battleState.expLevelBefore = 1
            battleState.expLevelAfter = 1
        end

        battleState.expBarActive = true
        battleState.expBarTimer = 0
        return
    end

    battleState.expBarTimer = (battleState.expBarTimer or 0) + dt
    local expBarTotalDuration = (battleState.expBarAnimDelay or 0)
        + (battleState.expBarAnimDuration or 1.0)
        + (battleState.expBarPostHoldDuration or 0.8)
    if battleState.expBarTimer < expBarTotalDuration then
        return
    end
    
    local TurnManager = require("modules.engine.turn")
    TurnManager.markUnitAsMoved(battleState.attacker)
    if TurnManager.areAllUnitsMoved() then
        TurnManager.endTurn()
    end
    
    local Lifecycle = require("modules.combat.battle_lifecycle")
    Lifecycle.endBattle(battleState)
end

return PhaseManager
