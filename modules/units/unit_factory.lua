-- modules/units/unit_factory.lua
-- Factory for creating BaseUnit instances from config tables.
-- All unit definition modules should use this to create instances.

local BaseUnit = require("modules.units.base")

local UnitFactory = {}

function UnitFactory.create(config)
    return BaseUnit.new(config)
end

return UnitFactory
