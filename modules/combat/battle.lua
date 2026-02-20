-- modules/combat/battle.lua
-- Main battle orchestrator that delegates to specialized modules
local State = require("modules.combat.battle_state")
local Assets = require("modules.combat.battle_assets")
local VisualEffects = require("modules.combat.battle_visual_effects")
local MovementEffects = require("modules.combat.battle_movement_effects")
local Anim = require("modules.combat.battle_anim")
local Draw = require("modules.combat.battle_draw")
local Lifecycle = require("modules.combat.battle_lifecycle")
local AttackHelpers = require("modules.combat.battle_attack_helpers")
local PhaseManager = require("modules.combat.battle_phase_manager")

local Battle = State

-- ============================================================================
-- INITIALIZATION & LIFECYCLE
-- ============================================================================

function Battle.load()
    Lifecycle.load(Battle, Assets)
end

function Battle.startBattle(attacker, defender)
    Lifecycle.startBattle(Battle, attacker, defender)
end

function Battle.endBattle()
    Lifecycle.endBattle(Battle)
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
    
    -- Update slide-back animation state
    MovementEffects.update(Battle)

    if Battle.battlePhase == "initial_attack" then
        PhaseManager.updateInitialAttack(Battle, Anim, VisualEffects, 
            require("modules.combat.battle_projectile"))
    elseif Battle.battlePhase == "counterattack" then
        PhaseManager.updateCounterattack(Battle, Anim, VisualEffects, 
            require("modules.combat.battle_projectile"))
    elseif Battle.battlePhase == "death_anim" then
        AttackHelpers.updateDeathAnimation(Battle)
    elseif Battle.battlePhase == "done" then
        PhaseManager.updateDone(Battle)
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
