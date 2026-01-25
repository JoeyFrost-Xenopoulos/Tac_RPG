local Movement = {}
local Pathfinding = require("modules.engine.pathfinding")
local MovementEngine = require("modules.engine.movement")
local Map = require("modules.world.map")
local Arrows = require("modules.ui.movement_arrows")

function Movement.init(self)
    self.isMoving = false
    self.startX, self.startY = 1, 1
    self.targetX, self.targetY = 1, 1
    self.moveTime = 0
end

function Movement.setPosition(self, x, y)
    self.tileX = x
    self.tileY = y
    self.prevX = x
    self.prevY = y
end

function Movement.tryMove(self, targetX, targetY)
    if not self.isPlayer or self.isMoving then return false end
    if targetX == self.tileX and targetY == self.tileY then return false end

    local path = Pathfinding.findPath(self.tileX, self.tileY, targetX, targetY, Map.canMove)
    if not path then
        self:setSelected(false)
        return false
    end

    local validPath = path
    if self.maxMoveRange and #path > (self.maxMoveRange + 1) then
        validPath = {}
        for i = 1, self.maxMoveRange + 1 do
            table.insert(validPath, path[i])
        end
    end

    self.prevX = self.tileX
    self.prevY = self.tileY
    MovementEngine.start(self, validPath)
    Arrows.clear()
    self.currentAnimation = "walk"
    return true
end

function Movement.update(self, dt)
    local wasMoving = self.isMoving
    MovementEngine.update(self, dt)
    if wasMoving and not self.isMoving then
        self.currentAnimation = "idle"
        self.currentFrame = 1
    end
end

return Movement
