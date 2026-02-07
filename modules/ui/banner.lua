local Banner = {}

Banner.image = nil
Banner.quads = {}
Banner.width = 448
Banner.height = 640
Banner.x = 0
Banner.y = 0

Banner.currentWidth = 0
Banner.targetWidth = 150
Banner.speed = 300
Banner.animating = false
Banner.duration = 0.4
Banner.timer = 0
Banner.done = false
Banner.anchor = "left" 

function Banner.load()
    Banner.image = love.graphics.newImage("assets/ui/ribbons/BigRibbons.png")
    local imgW, imgH = Banner.image:getDimensions()

    Banner.variants = {
        -- banner 1 (already used)
        {
            left  = love.graphics.newQuad(0,   0, 128, 128, imgW, imgH),
            mid   = love.graphics.newQuad(192, 0, 64,  128, imgW, imgH),
            right = love.graphics.newQuad(320, 0, 130, 128, imgW, imgH),
        },
        -- banner 2 (enemy)
        {
            left  = love.graphics.newQuad(0,   128, 128, 128, imgW, imgH),
            mid   = love.graphics.newQuad(192, 128, 64,  128, imgW, imgH),
            right = love.graphics.newQuad(320, 128, 130, 128, imgW, imgH),
        }
    }

    Banner.activeVariant = 1
end


local function easeOutQuad(t)
    return 1 - (1 - t) * (1 - t)
end

function Banner.start()
    if Banner.done then return end

    Banner.timer = 0
    Banner.currentWidth = 0
    Banner.animating = true
end

function Banner.update(dt)
    if not Banner.animating or Banner.done then return end

    Banner.timer = Banner.timer + dt
    local t = Banner.timer / Banner.duration

    if t >= 1 then
        t = 1
        Banner.animating = false
        Banner.done = true
    end

    local eased = easeOutQuad(t)
    Banner.currentWidth = Banner.targetWidth * eased
end

function Banner.draw()
    if not Banner.image then return end
    if Banner.currentWidth <= 0 then return end 

    local v = Banner.variants[Banner.activeVariant]
    local left, mid, right = v.left, v.mid, v.right

    local _, _, lw = left:getViewport()
    local _, _, mw = mid:getViewport()
    local _, _, rw = right:getViewport()

    local scaleX = (mw + Banner.currentWidth) / mw
    local totalWidth = lw + mw * scaleX + rw

    local x = Banner.x
    if Banner.anchor == "right" then
        x = Banner.x - totalWidth
    end

    love.graphics.draw(Banner.image, left, x, Banner.y)

    local midX = x + lw - 1
    love.graphics.draw(Banner.image, mid, midX, Banner.y, 0, scaleX, 1)

    local rightX = midX + mw * scaleX
    love.graphics.draw(Banner.image, right, rightX - 2, Banner.y)
end

function Banner.reset()
    Banner.timer = 0
    Banner.currentWidth = 0
    Banner.animating = false
    Banner.done = false
end

return Banner
