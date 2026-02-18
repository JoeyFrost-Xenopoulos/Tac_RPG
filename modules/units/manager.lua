-- modules/units/manager.lua
local UnitManager = {
    units = {},
    selectedUnit = nil,
    state = "idle",
    damageDisplays = {}
}

local Utils = require("modules.manager.utils")
UnitManager._isUnitDead = Utils.isUnitDead

require("modules.manager.core")(UnitManager)
require("modules.manager.movement")(UnitManager)
require("modules.manager.ui")(UnitManager)
require("modules.manager.combat")(UnitManager)
require("modules.manager.damage")(UnitManager)
require("modules.manager.update")(UnitManager)

return UnitManager