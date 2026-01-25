-- modules/units/base.lua
local BaseUnit = {}
BaseUnit.__index = BaseUnit

local Pathfinding = require("modules.engine.pathfinding")
local Movement = require("modules.engine.movement")
local Map = require("modules.world.map")
local MovementRange = require("modules.engine.movement_range")
local Arrows = require("modules.ui.movement_arrows")

-- Default settings
local DEFAULTS = {
    moveDuration = 0.25,
    scaleX = 0.85,
    scaleY = 0.85,
    tileSize = 64,
    maxMoveRange = 4,
    isPlayer = false,
    attackRange = 1
}

function BaseUnit.new(config)
    local self = setmetatable({}, BaseUnit)

    -- Apply Config or Defaults
    self.name = config.name or config.type or "Unknown"
    self.type = config.type or "Unknown"
    self.moveDuration = config.moveDuration or DEFAULTS.moveDuration
    self.scaleX = config.scaleX or DEFAULTS.scaleX
    self.scaleY = config.scaleY or DEFAULTS.scaleY
    self.tileSize = config.tileSize or DEFAULTS.tileSize
    self.maxMoveRange = config.maxMoveRange or DEFAULTS.maxMoveRange
    self.isPlayer = config.isPlayer or false
    
    -- State
    self.tileX = 1
    self.tileY = 1
    self.prevX = 1 -- [NEW] Store previous X
    self.prevY = 1 -- [NEW] Store previous Y
    self.facingX = 1
    self.selected = false
    
    -- Animation State
    self.animations = {}
    self.currentAnimation = "idle"
    self.currentFrame = 1
    self.frameTimer = 0

    -- Avatars
    self.avatar = config.avatar
    self.uiVariant = config.uiVariant
    self.uiAnchor = config.uiAnchor

    -- Stats
    self.maxHealth = config.maxHealth or 100
    self.health = config.health or self.maxHealth

    if config.animations then
        self:loadAnimations(config.animations)
    end
    return self
end

function BaseUnit:loadAnimations(animConfig)
    for name, data in pairs(animConfig) do
        local img = data.img
        local imgW, imgH = img:getDimensions()
        local quads = {}
        
        for _, f in ipairs(data.frames) do
            table.insert(quads, love.graphics.newQuad(f.x, f.y, f.width, f.height, imgW, imgH))
        end

        self.animations[name] = {
            img = img,
            quads = quads,
            frameCount = #quads,
            speed = data.speed or 0.1
        }
    end
end

function BaseUnit:setPosition(tileX, tileY)
    self.tileX = tileX
    self.tileY = tileY
    self.prevX = tileX -- [NEW] Init prev
    self.prevY = tileY -- [NEW] Init prev
end

function BaseUnit:update(dt)
    local wasMoving = self.isMoving
    Movement.update(self, dt)
    if wasMoving and not self.isMoving then
        self.currentAnimation = "idle"
        self.currentFrame = 1
    end

    local anim = self.animations[self.currentAnimation]
    if anim and anim.frameCount > 1 then
        self.frameTimer = self.frameTimer + dt
        if self.frameTimer >= anim.speed then
            self.frameTimer = self.frameTimer - anim.speed
            self.currentFrame = self.currentFrame + 1
            if self.currentFrame > anim.frameCount then
                self.currentFrame = 1
            end
        end
    end
end

function BaseUnit:draw()
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

    love.graphics.draw(anim.img, quad, px, py, 0, sX, self.scaleY, offsetX, offsetY)

    if self.selected and not self.isMoving then
        local color = self.isPlayer and {0, 1, 0, 0.3} or {1, 0, 0, 0.3}
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", 
            (self.tileX - 1) * self.tileSize, 
            (self.tileY - 1) * self.tileSize, 
            self.tileSize, self.tileSize
        )
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function BaseUnit:tryMove(targetX, targetY)
    if not self.isPlayer then return false end 
    if self.isMoving then return false end
    if targetX == self.tileX and targetY == self.tileY then return false end

    local path = Pathfinding.findPath(self.tileX, self.tileY, targetX, targetY, Map.canMove)
    if not path then
        self:setSelected(false)
        return false
    end

    local validPath = path
    if self.maxMoveRange and #path > (self.maxMoveRange + 1) then
        validPath = {}
        for i=1, self.maxMoveRange + 1 do
            table.insert(validPath, path[i])
        end
    end

    -- [NEW] Save Previous Position before moving
    self.prevX = self.tileX
    self.prevY = self.tileY

    Movement.start(self, validPath)
    Arrows.clear()
    
    -- [CHANGED] Do NOT deselect yet. We wait for menu confirmation.
    -- self:setSelected(false) 
    
    self.currentAnimation = "walk"
    return true
end

function BaseUnit:setSelected(value)
    self.selected = value
    if value then
        MovementRange.show(self)
    else
        MovementRange.clear()
    end
end

function BaseUnit:isHovered(mx, my)
    local px = (self.tileX - 1) * self.tileSize
    local py = (self.tileY - 1) * self.tileSize
    return mx >= px and mx < px + self.tileSize
        and my >= py and my < py + self.tileSize
end

BaseUnit.isClicked = BaseUnit.isHovered

return BaseUnit