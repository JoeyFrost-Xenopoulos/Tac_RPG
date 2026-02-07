-- modules/combat/battle_state.lua
local State = {}

State.visible = false
State.attacker = nil
State.defender = nil
State.platformImage = nil
State.platformX = 0
State.platformY = 0
State.battleTimer = 0
State.runDuration = 0.8
State.attackDuration = 0.7
State.returnDuration = 0.8
State.battleDuration = State.runDuration + State.attackDuration + State.returnDuration
State.transitionPhase = "none"
State.transitionTimer = 0
State.transitionCloseDuration = 0.4
State.transitionWhiteDuration = 0.08
State.transitionMoveDuration = 0.4
State.transitionCenterX = 0
State.transitionCenterY = 0
State.transitionTargetW = 0
State.transitionTargetH = 0
State.transitionSquareSize = 0
State.transitionStartAttackerX = 0
State.transitionStartAttackerY = 0
State.transitionStartDefenderX = 0
State.transitionStartDefenderY = 0

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
State.playerAttackPreview = { hit = 0, damage = 0, crit = 0 }
State.enemyAttackPreview = { hit = 0, damage = 0, crit = 0 }
State.defenderHealthDisplay = 0
State.playerHealthDisplay = 0
State.defenderPreviousHealth = 0
State.playerPreviousHealth = 0
State.healthAnimDuration = 0.8
State.healthAnimStartTime = 0
State.isHealthAnimating = false
State.damageApplied = false

function State.resetTimers()
    State.battleTimer = 0
    State.hitEffectActive = false
    State.hitFrameStartTime = 0
    State.attackFrameIndex = 0
    State.attackSwingPlayed = false
    State.attackHitPlayed = false
    State.transitionPhase = "none"
    State.transitionTimer = 0
    State.isHealthAnimating = false
    State.healthAnimStartTime = 0
    State.damageApplied = false
end

return State
