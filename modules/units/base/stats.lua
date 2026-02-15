local Stats = {}

function Stats.init(self, config)
    self.name = config.name or config.type or "Unknown"
    self.type = config.type or "Unknown"
    self.isPlayer = config.isPlayer or false
    self.maxMoveRange = config.maxMoveRange or 4
    self.moveDuration = config.moveDuration or 0.25
    self.tileSize = config.tileSize or 64
    self.scaleX = config.scaleX or 0.85
    self.scaleY = config.scaleY or 0.85

    self.tileX = 1
    self.tileY = 1
    self.prevX = 1
    self.prevY = 1
    self.facingX = 1
    self.selected = false
    self.hasActed = false

    self.maxHealth = config.maxHealth or 100
    self.health = config.health or self.maxHealth
    self.attackRange = config.attackRange or 1
    self.attackDamage = config.attackDamage or 5
    self.weapon = config.weapon or "sword"
    self.weapons = config.weapons

    -- Combat stats
    self.strength = config.strength or 10
    self.magic = config.magic or 5
    self.skill = config.skill or 10
    self.speed = config.speed or 10
    self.luck = config.luck or 0
    self.defense = config.defense or 5
    self.resistance = config.resistance or 3
    self.constitution = config.constitution or 10
    self.aid = config.aid or 0

    self.avatar = config.avatar
    self.uiVariant = config.uiVariant
    self.uiAnchor = config.uiAnchor
end

function Stats.setSelected(self, value)
    self.selected = value
    local MovementRange = require("modules.engine.movement_range")
    if value then
        MovementRange.show(self)
    else
        MovementRange.clear()
    end
end

return Stats
