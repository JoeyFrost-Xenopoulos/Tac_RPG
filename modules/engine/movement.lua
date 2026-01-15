local Movement = {}

function Movement.start(unit, path)
    if not path or #path <= 1 then return end

    unit.path = path
    unit.pathIndex = 2
    Movement._startNextStep(unit)
end

function Movement._startNextStep(unit)
    local nextTile = unit.path[unit.pathIndex]
    if not nextTile then
        unit.path = nil
        unit.isMoving = false
        unit.currentAnimation = "idle"
        return
    end

    unit.startX = unit.tileX
    unit.startY = unit.tileY
    unit.targetX = nextTile.x
    unit.targetY = nextTile.y

    unit.moveTime = 0
    unit.isMoving = true
    unit.currentAnimation = "walk"

    if unit.targetX > unit.tileX then unit.facingX = 1 end
    if unit.targetX < unit.tileX then unit.facingX = -1 end
end

function Movement.update(unit, dt)
    if not unit.isMoving then return end

    unit.moveTime = unit.moveTime + dt
    if unit.moveTime >= unit.moveDuration then
        unit.tileX = unit.targetX
        unit.tileY = unit.targetY
        unit.isMoving = false

        unit.pathIndex = unit.pathIndex + 1
        Movement._startNextStep(unit)
    end
end

return Movement
