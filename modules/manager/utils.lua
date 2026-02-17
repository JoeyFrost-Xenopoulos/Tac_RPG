-- modules/manager/utils.lua
local Utils = {}

function Utils.isUnitDead(unit)
    return unit and ((unit.health or 0) <= 0 or unit.isDead)
end

return Utils
