local BaseUnit = {}
BaseUnit.__index = BaseUnit

local Stats = require("modules.units.base.stats")
local Animation = require("modules.units.base.animation")
local Movement = require("modules.units.base.movement")
local Draw = require("modules.units.base.draw")
local Interaction = require("modules.units.base.interaction")

function BaseUnit.new(config)
    local self = setmetatable({}, BaseUnit)

    -- Stats
    Stats.init(self, config)

    -- Animation
    Animation.init(self, config.animations or {})

    -- Movement
    Movement.init(self)

    -- Drawing (needs self.animations & self.stats)
    Draw.init(self)

    -- Interaction
    Interaction.init(self)

    return self
end

-- Proxy functions for each module
function BaseUnit:update(dt)
    Movement.update(self, dt)
    Animation.update(self, dt)
end

function BaseUnit:draw()
    Draw.draw(self)
end

function BaseUnit:setPosition(x, y)
    Movement.setPosition(self, x, y)
end

function BaseUnit:tryMove(x, y)
    return Movement.tryMove(self, x, y)
end

function BaseUnit:setSelected(v)
    Stats.setSelected(self, v)
end

function BaseUnit:isHovered(mx, my)
    return Interaction.isHovered(self, mx, my)
end

BaseUnit.isClicked = BaseUnit.isHovered

return BaseUnit
