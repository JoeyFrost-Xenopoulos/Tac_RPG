-- modules/combat/battle_lifecycle.lua
-- Handles battle initialization and lifecycle management

local Lifecycle = {}

function Lifecycle.load(battle, battleAssets)
    battleAssets.load(battle)
end

function Lifecycle.startBattle(battle, attacker, defender)
    local Helpers = require("modules.combat.battle_helpers")
    local CameraManager = require("modules.engine.camera_manager")
    local CombatSystem = require("modules.combat.combat_system")
    local Audio = require("modules.audio.sound_effects")
    
    battle.attacker = attacker
    battle.defender = defender
    battle.visible = true
    battle.resetTimers()
    
    -- Calculate distance between attacker and defender
    local distance = math.abs(attacker.tileX - defender.tileX) + math.abs(attacker.tileY - defender.tileY)
    local defenderRange = CombatSystem.getAttackRange(defender)
    local attackerRange = CombatSystem.getAttackRange(attacker)
    
    -- Disable counterattack if attacker is outside defender's range or inside defender's minimum range
    local defenderWeapon = CombatSystem.getWeapon(defender.weapon)
    local defenderMinRange = defenderWeapon.minRange or 1
    if distance > defenderRange or distance < defenderMinRange then
        battle.counterattackEnabled = false
    end

    -- Determine follow-up attack (double hit) after the initial exchange
    local attackerDouble = CombatSystem.canDoubleAttack(attacker, defender)
    local defenderDouble = CombatSystem.canBeDoubleAttacked(attacker, defender)
    battle.followupQueued = false
    battle.followupAttackerIsDefender = false
    if defenderDouble and battle.counterattackEnabled then
        battle.followupQueued = true
        battle.followupAttackerIsDefender = true
    elseif attackerDouble then
        battle.followupQueued = true
        battle.followupAttackerIsDefender = false
    end
    
    -- Skip walk animation for ranged attacks (range > 1)
    if attackerRange > 1 then
        battle.runDuration = 0
        battle.returnDuration = 0
        battle.attackDuration = 1.6  -- Extended duration to accommodate projectile flight
    else
        -- Reset to default values for melee attacks
        battle.runDuration = 0.8
        battle.returnDuration = 0.8
        battle.attackDuration = 0.7
    end
    
    -- Start battle music transition
    Audio.transitionToBattleTheme()
    
    local playerUnit = Helpers.getPlayerUnit(attacker, defender)
    local enemyUnit = Helpers.getEnemyUnit(attacker, defender)
    battle.defenderHealthDisplay = enemyUnit and enemyUnit.health or 0
    battle.playerHealthDisplay = playerUnit and playerUnit.health or 0
    battle.defenderPreviousHealth = enemyUnit and enemyUnit.health or 0
    battle.playerPreviousHealth = playerUnit and playerUnit.health or 0

    -- Calculate and set battle preview stats
    if playerUnit and enemyUnit then
        battle.playerAttackPreview = {
            hit = CombatSystem.calculateHitChance(playerUnit, enemyUnit),
            damage = CombatSystem.calculateTotalDamage(playerUnit, enemyUnit, false),
            crit = CombatSystem.calculateCritChance(playerUnit)
        }
    end
    
    -- Enemy stats
    if enemyUnit and playerUnit then
        battle.enemyAttackPreview = {
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

    battle.transitionStartAttackerX = attackerX
    battle.transitionStartAttackerY = attackerY
    battle.transitionStartDefenderX = defenderX
    battle.transitionStartDefenderY = defenderY

    battle.transitionCenterX = (attackerX + defenderX) / 2
    battle.transitionCenterY = (attackerY + defenderY) / 2

    battle.transitionSquareSize = math.min(screenW, screenH) * 0.2
    battle.transitionTargetW = battle.transitionSquareSize
    battle.transitionTargetH = battle.transitionSquareSize
    battle.transitionPhase = "platform_move"
    battle.transitionTimer = 0
end

function Lifecycle.endBattle(battle)
    local UnitManager = require("modules.units.manager")
    local Audio = require("modules.audio.sound_effects")
    
    battle.visible = false
    battle.attacker = nil
    battle.defender = nil
    battle.resetTimers()

    UnitManager.removeDeadUnits()
    
    -- Return to main theme
    Audio.transitionToMainTheme()
end

return Lifecycle
