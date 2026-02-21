-- modules/combat/battle_phase_manager.lua
-- Manages different battle phases: initial_attack, counterattack, death_anim, done

local PhaseManager = {}

function PhaseManager.transitionToCounterattack(battleState)
    if battleState.counterattackEnabled and battleState.defender and battleState.defender.health > 0 then
        local CombatSystem = require("modules.combat.combat_system")
        local AttackHelpers = require("modules.combat.battle_attack_helpers")
        
        battleState.battlePhase = "counterattack"
        battleState.battleTimer = 0
        AttackHelpers.resetPhaseFlags(battleState)
        battleState.counterattackApplied = false
        
        -- Set animation durations for counterattack based on defender's weapon range
        local defenderRange = CombatSystem.getAttackRange(battleState.defender)
        
        -- Skip walk animation for ranged counterattacks
        if defenderRange > 1 then
            battleState.runDuration = 0
            battleState.returnDuration = 0
            battleState.attackDuration = 1.6
        else
            battleState.runDuration = 0.8
            battleState.returnDuration = 0.8
            battleState.attackDuration = 0.7
        end
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
            
            -- Check for double attack
            if CombatSystem.canDoubleAttack(battleState.attacker, battleState.defender) then
                if CombatSystem.doesHit(battleState.attacker, battleState.defender) then
                    local isCritical2 = CombatSystem.isCritical(battleState.attacker, battleState.defender)
                    damage = damage + CombatSystem.calculateTotalDamage(battleState.attacker, battleState.defender, isCritical2)
                end
            end
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
            if AttackHelpers.startDeathAnimationIfNeeded(battleState, battleState.defender) then
                battleState.battlePhase = "death_anim"
            else
                PhaseManager.transitionToCounterattack(battleState)
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
            
            -- Check if defender can double attack
            if CombatSystem.canBeDoubleAttacked(battleState.attacker, battleState.defender) and battleState.attacker.health > 0 then
                if CombatSystem.doesHit(battleState.defender, battleState.attacker) then
                    damage = damage + CombatSystem.calculateTotalDamage(battleState.defender, battleState.attacker, false)
                end
            end
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
            if AttackHelpers.startDeathAnimationIfNeeded(battleState, battleState.attacker) then
                battleState.battlePhase = "death_anim"
            else
                battleState.battlePhase = "done"
            end
        end
    end
end

function PhaseManager.updateDone(battleState)
    -- Wait for slide-back animation to complete before ending battle
    if battleState.slideBackActive then
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
