local Animation = {}

function Animation.init(self, animConfig)
    self.animations = {}
    self.currentAnimation = "idle"
    self.currentFrame = 1
    self.frameTimer = 0

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

function Animation.update(self, dt)
    local anim = self.animations[self.currentAnimation]
    if not anim or anim.frameCount <= 1 then return end

    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= anim.speed then
        self.frameTimer = self.frameTimer - anim.speed
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > anim.frameCount then
            self.currentFrame = 1
        end
    end
end

return Animation
