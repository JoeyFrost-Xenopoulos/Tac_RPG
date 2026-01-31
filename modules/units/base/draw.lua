local Draw = {}

function Draw.init(self) end

function Draw.draw(self)
    local anim = self.animations[self.currentAnimation]
    if not anim then return end
    local quad = anim.quads[self.currentFrame]
    if not quad then return end

    local _, _, qw, qh = quad:getViewport()
    local offsetX = qw / 2
    local offsetY = qh - 50
    local drawX, drawY = self.tileX, self.tileY

    if self.isMoving then
        local t = self.moveTime / self.moveDuration
        drawX = self.startX + (self.targetX - self.startX) * t
        drawY = self.startY + (self.targetY - self.startY) * t
    end

    local px = (drawX - 1) * self.tileSize + self.tileSize / 2
    local py = (drawY - 1) * self.tileSize + self.tileSize
    local sX = self.scaleX
    if self.facingX < 0 then sX = -sX end

    local TurnManager = require("modules.engine.turn")
    if self.hasActed and not self.selected then
        local isEnemyTurn = TurnManager.getCurrentTurn() == "enemy"
        if not (not self.isPlayer and isEnemyTurn) then
            love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
        end
    end

    love.graphics.draw(anim.img, quad, px, py, 0, sX, self.scaleY, offsetX, offsetY)
    love.graphics.setColor(1, 1, 1, 1)

    if self.selected and not self.isMoving then
        local color = self.isPlayer and {0,1,0,0.3} or {1,0,0,0.3}
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", (self.tileX-1)*self.tileSize, (self.tileY-1)*self.tileSize, self.tileSize, self.tileSize)
        love.graphics.setColor(1,1,1,1)
    end
end

return Draw
