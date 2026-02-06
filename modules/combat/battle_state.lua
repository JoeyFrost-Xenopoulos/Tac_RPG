-- modules/combat/battle_state.lua
local State = {}

State.visible = false
State.attacker = nil
State.defender = nil
State.platformImage = nil
State.platformX = 0
State.platformY = 0
State.battleTimer = 0
State.battleDuration = 1.5
State.runDuration = 0.8
State.attackDuration = 0.7

State.hitEffectImage = nil
State.hitEffectActive = false
State.hitEffectStartTime = 0
State.hitEffectDuration = 0.6
State.breakAnimDuration = 0.7
State.hitFrameStartTime = 0
State.defenderHitX = 0
State.defenderHitY = 0
State.attackFrameIndex = 0
State.attackSwingPlayed = false
State.attackHitPlayed = false

function State.resetTimers()
    State.battleTimer = 0
    State.hitEffectActive = false
    State.hitFrameStartTime = 0
    State.attackFrameIndex = 0
    State.attackSwingPlayed = false
    State.attackHitPlayed = false
end

return State
