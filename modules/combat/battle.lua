-- modules/combat/battle.lua
local State = require("modules.combat.battle_state")
local Assets = require("modules.combat.battle_assets")
local Effects = require("modules.combat.battle_effects")
local Anim = require("modules.combat.battle_anim")
local Draw = require("modules.combat.battle_draw")

local Battle = State

function Battle.load()
    Assets.load(Battle)
end

function Battle.startBattle(attacker, defender)
    Battle.attacker = attacker
    Battle.defender = defender
    Battle.visible = true
    Battle.resetTimers()
end

function Battle.endBattle()
    Battle.visible = false
    Battle.attacker = nil
    Battle.defender = nil
    Battle.resetTimers()
end

function Battle.update(dt)
    if not Battle.visible then return end

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

    if Battle.battleTimer >= Battle.battleDuration then
        if Battle.attacker and Battle.defender then
            local Attack = require("modules.engine.attack")
            local TurnManager = require("modules.engine.turn")
            local UnitManager = require("modules.units.manager")

            local damage = Attack.performAttack(Battle.attacker, Battle.defender)
            UnitManager.showDamage(Battle.defender, damage)

            TurnManager.markUnitAsMoved(Battle.attacker)

            if TurnManager.areAllUnitsMoved() then
                TurnManager.endTurn()
            end
        end

        Battle.endBattle()
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
