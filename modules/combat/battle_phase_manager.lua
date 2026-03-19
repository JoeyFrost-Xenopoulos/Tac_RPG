-- modules/combat/battle_phase_manager.lua
-- Manages different battle phases: initial_attack, counterattack, death_anim, done

local PhaseManager = {}

local LEVEL_VALUE_UPDATE_DELAY = 0.7
local LEVEL_LIGHT_RECT_DURATION = 0.42
local STAR_ANIM_FRAME_COUNT = 11
local STAR_ANIM_FRAME_DURATION = 0.06
local LEVEL_TO_STATS_DELAY = 0.10
local STAT_ANIM_GAP = 0.08
local STAT_ANIM_OVERLAP = 0.45

local recordResolvedAttack

local function captureLevelUpStats(unit)
    return {
        strength = unit and unit.strength or 0,
        defense = unit and unit.defense or 0,
        luck = unit and unit.luck or 0,
        speed = unit and unit.speed or 0,
        magic = unit and unit.magic or 0,
        resistance = unit and unit.resistance or 0,
        skill = unit and unit.skill or 0,
        constitution = unit and unit.constitution or 0,
    }
end

local function countPlusOneStatGains(beforeStats, afterStats)
    local orderedKeys = {
        "strength",
        "defense",
        "luck",
        "speed",
        "magic",
        "resistance",
        "skill",
        "constitution",
    }

    local count = 0
    for _, key in ipairs(orderedKeys) do
        local beforeValue = beforeStats[key] or 0
        local afterValue = afterStats[key] or 0
        if afterValue == beforeValue + 1 then
            count = count + 1
        end
    end

    return count
end

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

local function resetAttackPhaseState(battleState)
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
end

local function computeAttackResult(battleState, actingUnit, targetUnit, CombatSystem)
    if battleState.attackResultCalculated or not actingUnit or not targetUnit then
        return
    end

    local damage = 0
    battleState.currentAttackHit = CombatSystem.doesHit(actingUnit, targetUnit)
    battleState.currentAttackIsCritical = false

    if battleState.currentAttackHit then
        local isCritical = CombatSystem.isCritical(actingUnit, targetUnit)
        battleState.currentAttackIsCritical = isCritical
        damage = CombatSystem.calculateTotalDamage(actingUnit, targetUnit, isCritical)
    end

    battleState.calculatedAttackDamage = damage
    battleState.attackResultCalculated = true
end

local function updateAttackProjectile(battleState, projectile, attackFrameIndex, actingUnit, targetUnit)
    if projectile.needsProjectile(actingUnit) and not battleState.projectileSpawned then
        local spawnFrame = projectile.getSpawnFrame(actingUnit.weapon)

        if attackFrameIndex == spawnFrame and battleState.projectileFrame4Time == 0 then
            battleState.projectileFrame4Time = battleState.battleTimer
        end

        if battleState.projectileFrame4Time > 0 then
            local spawnDelay = projectile.getSpawnDelay(actingUnit.weapon)
            if (battleState.battleTimer - battleState.projectileFrame4Time) >= spawnDelay then
                local screenW = love.graphics.getWidth()
                local platformW = battleState.platformImage and battleState.platformImage:getDimensions() or 0
                local platformY = battleState.platformY or 0
                projectile.spawn(battleState, actingUnit, targetUnit, screenW, platformW, platformY)
            end
        end
    end

    return projectile.update(battleState)
end

local function processFollowupAfterInitialAttack(battleState)
    if battleState.counterattackEnabled then
        PhaseManager.transitionToCounterattack(battleState)
        return
    end

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

local function processFollowupAfterCounterattack(battleState)
    if not battleState.followupQueued then
        battleState.battlePhase = "done"
        return
    end

    local attackerAlive = battleState.attacker and battleState.attacker.health > 0
    local defenderAlive = battleState.defender and battleState.defender.health > 0
    local bothAlive = attackerAlive and defenderAlive

    if bothAlive then
        battleState.followupQueued = false
        PhaseManager.startFollowupAttack(battleState, battleState.followupAttackerIsDefender)
    else
        battleState.battlePhase = "done"
    end
end

local function updateAttackPhase(battleState, anim, effects, projectile, phaseConfig)
    local CombatSystem = require("modules.combat.combat_system")
    local AttackHelpers = require("modules.combat.battle_attack_helpers")

    local actingUnit = phaseConfig.getActingUnit(battleState)
    local targetUnit = phaseConfig.getTargetUnit(battleState)

    computeAttackResult(battleState, actingUnit, targetUnit, CombatSystem)

    local attackFrameIndex = anim.getAttackFrameIndex(battleState, actingUnit)
    battleState.attackFrameIndex = attackFrameIndex or 0

    local projectileHit = updateAttackProjectile(battleState, projectile, attackFrameIndex, actingUnit, targetUnit)

    AttackHelpers.playAttackSounds(battleState, attackFrameIndex, actingUnit, projectileHit)
    effects.update(battleState, attackFrameIndex, actingUnit, projectileHit)
    effects.updateMiss(battleState, attackFrameIndex, actingUnit, projectileHit)
    effects.updateCrit(battleState, attackFrameIndex, actingUnit, projectileHit)

    local totalDuration = battleState.runDuration + battleState.attackDuration + (battleState.returnDuration or 0)
    if battleState.battleTimer >= totalDuration and not battleState[phaseConfig.appliedFlag] then
        if actingUnit and targetUnit then
            AttackHelpers.applyDamageAndStartAnimation(
                battleState,
                actingUnit,
                targetUnit,
                phaseConfig.isCounterattack
            )
            battleState[phaseConfig.appliedFlag] = true
        end
    end

    if battleState[phaseConfig.appliedFlag] and battleState.isHealthAnimating then
        if AttackHelpers.updateHealthAnimation(battleState) then
            AttackHelpers.finalizeDamageAnimation(battleState)

            recordResolvedAttack(
                battleState,
                actingUnit,
                targetUnit,
                battleState[phaseConfig.resolvedDamageField] or 0,
                battleState.currentAttackIsCritical
            )

            if AttackHelpers.startDeathAnimationIfNeeded(battleState, targetUnit) then
                battleState.battlePhase = "death_anim"
            else
                phaseConfig.onNoDeath(battleState)
            end
        end
    end
end

recordResolvedAttack = function(battleState, actingUnit, targetUnit, damageAmount, wasCritical)
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
    resetAttackPhaseState(battleState)

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
        battleState.battlePhase = "counterattack"
        battleState.playerWasCounterattacked = true
        resetAttackPhaseState(battleState)
        
        -- Set animation durations for counterattack based on defender's weapon range
        applyAttackDurations(battleState, battleState.defender)
    else
        battleState.battlePhase = "done"
    end
end

function PhaseManager.updateInitialAttack(battleState, anim, effects, projectile)
    updateAttackPhase(battleState, anim, effects, projectile, {
        getActingUnit = function(state) return state.attacker end,
        getTargetUnit = function(state) return state.defender end,
        appliedFlag = "damageApplied",
        resolvedDamageField = "damageAmount",
        isCounterattack = false,
        onNoDeath = processFollowupAfterInitialAttack,
    })
end

function PhaseManager.updateCounterattack(battleState, anim, effects, projectile)
    updateAttackPhase(battleState, anim, effects, projectile, {
        getActingUnit = function(state) return state.defender end,
        getTargetUnit = function(state) return state.attacker end,
        appliedFlag = "counterattackApplied",
        resolvedDamageField = "counterattackDamage",
        isCounterattack = true,
        onNoDeath = processFollowupAfterCounterattack,
    })
end

local function initializeExpBarStateForNoPlayer(battleState)
    battleState.expBarStartFillPercent = 0
    battleState.expBarFillPercent = 0
    battleState.expBarTargetFillUnits = 0
    battleState.expBarGainAmount = 0
    battleState.expBarStartValue = 0
    battleState.expBarEndValue = 0
    battleState.expBarMaxValue = 100
    battleState.expLeveledUp = false
    battleState.levelUpMenuTimer = 0
    battleState.expLevelBefore = 1
    battleState.expLevelAfter = 1
    battleState.levelUpStatsBefore = nil
    battleState.levelUpStatsAfter = nil
    battleState.levelUpAnimatedStatCount = 0
end

local function setupExpBarAnimationFromOutcome(battleState)
    local Helpers = require("modules.combat.battle_helpers")
    local Audio = require("modules.audio.sound_effects")
    local playerUnit = Helpers.getPlayerUnit(battleState.attacker, battleState.defender)
    local enemyUnit = Helpers.getEnemyUnit(battleState.attacker, battleState.defender)

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
        local levelUpStatsBefore = captureLevelUpStats(playerUnit)

        playerUnit.level = previousLevel + gainedLevels
        playerUnit.experience = newExperience
        applyLevelGrowths(playerUnit, gainedLevels)
        local levelUpStatsAfter = captureLevelUpStats(playerUnit)

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
        battleState.levelUpStatsBefore = levelUpStatsBefore
        battleState.levelUpStatsAfter = levelUpStatsAfter
        battleState.levelUpAnimatedStatCount = countPlusOneStatGains(levelUpStatsBefore, levelUpStatsAfter)

        if gainedLevels > 0 then
            Audio.playLevelUp()
        elseif expGain > 0 then
            Audio.playExpGain()
        end
    else
        initializeExpBarStateForNoPlayer(battleState)
    end

    battleState.expBarActive = true
    battleState.expBarTimer = 0
end

local function getExpBarTotalDuration(battleState)
    local expBarTotalDuration = (battleState.expBarAnimDelay or 0)
        + (battleState.expBarAnimDuration or 1.0)
        + (battleState.expBarPostHoldDuration or 0.8)

    if battleState.expLeveledUp then
        local starDuration = STAR_ANIM_FRAME_COUNT * STAR_ANIM_FRAME_DURATION
        local statStepDuration = math.max(0.05, LEVEL_LIGHT_RECT_DURATION + starDuration + STAT_ANIM_GAP - STAT_ANIM_OVERLAP)
        local animatedStatCount = battleState.levelUpAnimatedStatCount or 0
        local menuSequenceDuration = LEVEL_VALUE_UPDATE_DELAY + starDuration + LEVEL_TO_STATS_DELAY
            + (animatedStatCount * statStepDuration)
            + 0.2
        expBarTotalDuration = expBarTotalDuration + menuSequenceDuration
    end

    return expBarTotalDuration
end

local function endBattleAndAdvanceTurn(battleState)
    local TurnManager = require("modules.engine.turn")
    TurnManager.markUnitAsMoved(battleState.attacker)
    if TurnManager.areAllUnitsMoved() then
        TurnManager.endTurn()
    end

    local Lifecycle = require("modules.combat.battle_lifecycle")
    Lifecycle.endBattle(battleState)
end

function PhaseManager.updateDone(battleState, dt)
    -- Wait for slide-back animation to complete before ending battle
    if battleState.slideBackActive then
        return
    end

    if not battleState.expBarActive then
        setupExpBarAnimationFromOutcome(battleState)
        return
    end

    battleState.expBarTimer = (battleState.expBarTimer or 0) + dt
    if battleState.expLeveledUp then
        battleState.levelUpMenuTimer = (battleState.levelUpMenuTimer or 0) + dt
    end
    local expBarTotalDuration = getExpBarTotalDuration(battleState)
    if battleState.expBarTimer < expBarTotalDuration then
        return
    end

    endBattleAndAdvanceTurn(battleState)
end

return PhaseManager
