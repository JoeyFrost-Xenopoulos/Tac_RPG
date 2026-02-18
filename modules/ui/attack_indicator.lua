-- modules/ui/attack_indicator.lua
-- Displays a red highlight cursor on the enemy's attack target during enemy turns

local AttackIndicator = {}

function AttackIndicator.draw()
    local TurnManager = require("modules.engine.turn")
    
    -- Only show if an enemy is attacking and has a target
    if TurnManager.currentTurn ~= "enemy" or not TurnManager.enemyAttackTarget then
        return
    end
    
    local target = TurnManager.enemyAttackTarget
    if not target or not _G.Cursor or not _G.Cursor.image then return end
    
    local CursorModule = _G.Cursor
    
    -- Draw red cursor on the target's tile
    love.graphics.push()
    love.graphics.scale(CursorModule.scaleX, CursorModule.scaleY)
    
    local tilePx = (target.tileX - 1) * CursorModule.tileSize
    local tilePy = (target.tileY - 1) * CursorModule.tileSize
    
    local imgW, imgH = CursorModule.image:getDimensions()
    local scale = CursorModule.tileSize / CursorModule.imageWidth
    
    -- Add a pulse effect  
    local pulse = 1 + math.sin(CursorModule.pulse * 5) * 0.05
    scale = scale * pulse
    
    local drawX = tilePx + CursorModule.tileSize / 2
    local drawY = tilePy + CursorModule.tileSize / 2
    
    -- Red color for attack indicator
    love.graphics.setColor(1, 0.2, 0.2, 0.8)
    love.graphics.draw(CursorModule.image, drawX, drawY, 0, scale, scale, imgW / 2, imgH / 2)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
    
    love.graphics.pop()
end

return AttackIndicator
