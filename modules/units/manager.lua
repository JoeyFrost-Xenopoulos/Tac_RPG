-- modules/units/manager.lua
local UnitState = {
    IDLE = "idle",
    MOVING = "moving",
    MENU = "menu",
    SELECTING_ATTACK = "selectingAttack",
    SELECTING_WEAPON = "selectingWeapon",
    SELECTING_ITEM = "selectingItem",
    COMBAT_SUMMARY = "combatSummary",
}

local UnitManager = {
    units = {},
    unitGrid = {},
    selectedUnit = nil,
    state = UnitState.IDLE,
    damageDisplays = {},
    needsSort = false
}

function UnitManager.setFacing(attacker, target)
    if target.tileX > attacker.tileX then
        attacker.facingX = 1
    elseif target.tileX < attacker.tileX then
        attacker.facingX = -1
    end

    if attacker.tileX > target.tileX then
        target.facingX = 1
    elseif attacker.tileX < target.tileX then
        target.facingX = -1
    end
end

function UnitManager.hasUnitMoved(unit)
    return (unit.tileX ~= unit.prevX) or (unit.tileY ~= unit.prevY)
end

local Utils = require("modules.manager.utils")
UnitManager._isUnitDead = Utils.isUnitDead

require("modules.manager.core")(UnitManager)
require("modules.manager.movement")(UnitManager)
require("modules.manager.ui")(UnitManager)
require("modules.manager.combat")(UnitManager)
require("modules.manager.damage")(UnitManager)
require("modules.manager.update")(UnitManager)

UnitManager.UnitState = UnitState

return UnitManager