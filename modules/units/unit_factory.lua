local BaseUnit = require("modules.units.base")

local UnitFactory = {}

function UnitFactory.create(config)
    return BaseUnit.new(config)
end

return UnitFactory
