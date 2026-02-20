-- modules/combat/battle_attack_helpers.lua
-- Handles attack sounds, damage calculations, and health animations

local Helpers = {}

function Helpers.playAttackSounds(battleState, attackFrameIndex, attacker, projectileHit)
    local Audio = require("modules.audio.sound_effects")
    local Projectile = require("modules.combat.battle_projectile")

    if attacker and attacker.weapon == "bow" and attackFrameIndex == 1 and not battleState.attackBowPlayed then
        Audio.playBowArrow()
        battleState.attackBowPlayed = true
    end

    if attacker and attacker.weapon == "harpoon" and attackFrameIndex == 5 and not battleState.attackHarpoonPlayed then
        Audio.playHarpoonThrow()
        battleState.attackHarpoonPlayed = true
    end
    
    -- For ranged attacks, play sounds based on projectile hit
    if attacker and Projectile.needsProjectile(attacker) then
        if projectileHit then
            if battleState.currentAttackHit then
                if battleState.currentAttackIsCritical then
                    Audio.playAttackCritical()
                else
                    Audio.playAttackHit()
                end
            else
                Audio.playAttackMiss()
            end
            battleState.attackHitPlayed = true
        end
    else
        -- For melee attacks, use frame-based timing
        if attackFrameIndex == 2 and not battleState.attackSwingPlayed then
            Audio.playAttackSwing()
            battleState.attackSwingPlayed = true
        end
        if attackFrameIndex == 3 and not battleState.attackHitPlayed then
            if battleState.currentAttackHit then
                if battleState.currentAttackIsCritical then
                    Audio.playAttackCritical()
                else
                    Audio.playAttackHit()
                end
            else
                Audio.playAttackMiss()
            end
            battleState.attackHitPlayed = true
        end
    end
end

function Helpers.calculateHealthAnimDuration(damage, targetUnit)
    if targetUnit and targetUnit.maxHealth and targetUnit.maxHealth > 0 then
        local healthLossPercent = damage / targetUnit.maxHealth
        return 0.3 + (healthLossPercent * 0.9)
    end
    return 0.5  -- Default duration
end

function Helpers.applyDamageAndStartAnimation(battleState, attacker, defender, isCounterattack)
    local UnitManager = require("modules.units.manager")
    local Audio = require("modules.audio.sound_effects")
    local BattleHelpers = require("modules.combat.battle_helpers")
    
    local playerUnit = BattleHelpers.getPlayerUnit(battleState.attacker, battleState.defender)
    local enemyUnit = BattleHelpers.getEnemyUnit(battleState.attacker, battleState.defender)

    -- Store previous health
    battleState.defenderPreviousHealth = enemyUnit and enemyUnit.health or 0
    battleState.playerPreviousHealth = playerUnit and playerUnit.health or 0

    -- Use pre-calculated damage (calculated in updateInitialAttack or updateCounterattack)
    local damage = battleState.calculatedAttackDamage
    
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
        battleState.counterattackDamage = damage
    else
        battleState.damageAmount = damage
    end
    
    battleState.isLastAttackHit = damage > 0
    UnitManager.showDamage(defender, damage)

    -- Calculate animation duration
    battleState.healthAnimDurationActual = Helpers.calculateHealthAnimDuration(damage, defender)

    -- Start health animation
    battleState.isHealthAnimating = true
    battleState.healthAnimStartTime = battleState.battleTimer
end

function Helpers.updateHealthAnimation(battleState)
    local BattleHelpers = require("modules.combat.battle_helpers")
    
    local elapsedTime = battleState.battleTimer - battleState.healthAnimStartTime
    local t = BattleHelpers.clamp(elapsedTime / battleState.healthAnimDurationActual, 0, 1)
    local eased = BattleHelpers.easeOutQuad(t)
    local playerUnit = BattleHelpers.getPlayerUnit(battleState.attacker, battleState.defender)
    local enemyUnit = BattleHelpers.getEnemyUnit(battleState.attacker, battleState.defender)

    battleState.defenderHealthDisplay = battleState.defenderPreviousHealth
        + ((enemyUnit and enemyUnit.health or 0) - battleState.defenderPreviousHealth) * eased
    battleState.playerHealthDisplay = battleState.playerPreviousHealth
        + ((playerUnit and playerUnit.health or 0) - battleState.playerPreviousHealth) * eased

    return t >= 1
end

function Helpers.resetPhaseFlags(battleState)
    battleState.attackSwingPlayed = false
    battleState.attackHitPlayed = false
    battleState.attackBowPlayed = false
    battleState.attackHarpoonPlayed = false
    battleState.hitEffectActive = false
    battleState.hitFrameStartTime = 0
    battleState.isLastAttackHit = true
    battleState.calculatedAttackDamage = 0
    battleState.currentAttackHit = false
    battleState.attackResultCalculated = false
    battleState.projectileSpawned = false
    battleState.projectileFrame4Time = 0
end

function Helpers.finalizeDamageAnimation(battleState)
    local BattleHelpers = require("modules.combat.battle_helpers")
    
    battleState.isHealthAnimating = false
    local playerUnit = BattleHelpers.getPlayerUnit(battleState.attacker, battleState.defender)
    local enemyUnit = BattleHelpers.getEnemyUnit(battleState.attacker, battleState.defender)
    battleState.defenderHealthDisplay = enemyUnit and enemyUnit.health or 0
    battleState.playerHealthDisplay = playerUnit and playerUnit.health or 0
end

function Helpers.startDeathAnimationIfNeeded(battleState, targetUnit)
    if battleState.deathAnimActive then return true end
    if not targetUnit or not targetUnit.isDead then return false end
    if targetUnit.isPlayer then return false end

    local breakEndTime = battleState.hitFrameStartTime + (battleState.breakAnimDuration or 0)
    local startDelay = 0
    if battleState.hitFrameStartTime and battleState.hitFrameStartTime > 0 then
        startDelay = math.max(0, breakEndTime - battleState.battleTimer)
    end

    battleState.deathAnimActive = true
    battleState.deathAnimUnit = targetUnit
    battleState.deathAnimStartTime = battleState.battleTimer + startDelay
    return true
end

function Helpers.updateDeathAnimation(battleState)
    if not battleState.deathAnimActive then
        battleState.battlePhase = "done"
        return
    end

    local totalDeathDuration = battleState.deathAnimBlinkDuration + battleState.deathAnimFadeDuration
    local elapsed = battleState.battleTimer - battleState.deathAnimStartTime
    if elapsed >= totalDeathDuration then
        battleState.battlePhase = "done"
    end
end

return Helpers
