-- modules/units/manager.lua
local UnitManager = {
    units = {},
    unitGrid = {},
    selectedUnit = nil,
    state = "idle",
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

local Utils = require("modules.manager.utils")
UnitManager._isUnitDead = Utils.isUnitDead

require("modules.manager.core")(UnitManager)
require("modules.manager.movement")(UnitManager)
require("modules.manager.ui")(UnitManager)
require("modules.manager.combat")(UnitManager)
require("modules.manager.damage")(UnitManager)
require("modules.manager.update")(UnitManager)

return UnitManager