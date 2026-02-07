-- modules/combat/battle.lua
local State = require("modules.combat.battle_state")
local Assets = require("modules.combat.battle_assets")
local Effects = require("modules.combat.battle_effects")
local Anim = require("modules.combat.battle_anim")
local Draw = require("modules.combat.battle_draw")
local CameraManager = require("modules.engine.camera_manager")

local Battle = State

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function easeOutQuad(t)
    return 1 - (1 - t) * (1 - t)
end

local function getPlayerUnit(attacker, defender)
    if attacker and attacker.isPlayer then
        return attacker
    end
    if defender and defender.isPlayer then
        return defender
    end
    return nil
end

local function getEnemyUnit(attacker, defender)
    if attacker and not attacker.isPlayer then
        return attacker
    end
    if defender and not defender.isPlayer then
        return defender
    end
    return nil
end

function Battle.load()
    Assets.load(Battle)
end

function Battle.startBattle(attacker, defender)
    Battle.attacker = attacker
    Battle.defender = defender
    Battle.visible = true
    Battle.resetTimers()
    local playerUnit = getPlayerUnit(attacker, defender)
    local enemyUnit = getEnemyUnit(attacker, defender)
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
end

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
    local attackFrameIndex = Anim.getAttackFrameIndex(Battle, Battle.attacker)
    Battle.attackFrameIndex = attackFrameIndex or 0

    local Audio = require("modules.audio.sound_effects")
    if attackFrameIndex == 2 and not Battle.attackSwingPlayed then
        Audio.playAttackSwing()
        Battle.attackSwingPlayed = true
    end
    if attackFrameIndex == 3 and not Battle.attackHitPlayed then
        Audio.playAttackHit()
        Battle.attackHitPlayed = true
    end

    Effects.update(Battle, attackFrameIndex)

    if Battle.battleTimer >= Battle.battleDuration and not Battle.damageApplied then
        if Battle.attacker and Battle.defender then
            local Attack = require("modules.engine.attack")
            local UnitManager = require("modules.units.manager")
            local playerUnit = getPlayerUnit(Battle.attacker, Battle.defender)
            local enemyUnit = getEnemyUnit(Battle.attacker, Battle.defender)

            -- Store previous health for animation
            Battle.defenderPreviousHealth = enemyUnit and enemyUnit.health or 0
            Battle.playerPreviousHealth = playerUnit and playerUnit.health or 0

            local damage = Attack.performAttack(Battle.attacker, Battle.defender)
            UnitManager.showDamage(Battle.defender, damage)

            -- Start health animation
            Battle.isHealthAnimating = true
            Battle.healthAnimStartTime = Battle.battleTimer
            Battle.damageApplied = true
        end
    end

    if Battle.damageApplied and Battle.isHealthAnimating then
        local elapsedTime = Battle.battleTimer - Battle.healthAnimStartTime
        local t = clamp(elapsedTime / Battle.healthAnimDuration, 0, 1)
        local eased = easeOutQuad(t)
        local playerUnit = getPlayerUnit(Battle.attacker, Battle.defender)
        local enemyUnit = getEnemyUnit(Battle.attacker, Battle.defender)

        Battle.defenderHealthDisplay = Battle.defenderPreviousHealth
            + ((enemyUnit and enemyUnit.health or 0) - Battle.defenderPreviousHealth) * eased
        Battle.playerHealthDisplay = Battle.playerPreviousHealth
            + ((playerUnit and playerUnit.health or 0) - Battle.playerPreviousHealth) * eased

        if t >= 1 then
            Battle.isHealthAnimating = false
            Battle.defenderHealthDisplay = enemyUnit and enemyUnit.health or 0
            Battle.playerHealthDisplay = playerUnit and playerUnit.health or 0
            local TurnManager = require("modules.engine.turn")
            TurnManager.markUnitAsMoved(Battle.attacker)
            if TurnManager.areAllUnitsMoved() then
                TurnManager.endTurn()
            end
            Battle.endBattle()
        end
    end
end

function Battle.draw()
    Draw.draw(Battle)
end

function Battle.clicked(mx, my)
    if not Battle.visible then return false end
    return true
end

return Battle
