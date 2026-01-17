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

function Banner.load()
    Banner.image = love.graphics.newImage("assets/ui/ribbons/BigRibbons.png")

    local imgW, imgH = Banner.image:getDimensions()

    Banner.quads = {
        love.graphics.newQuad(0,   0, 128, 128, imgW, imgH), -- part 1
        love.graphics.newQuad(192, 0, 64,  128, imgW, imgH), -- part 2
        love.graphics.newQuad(320, 0, 130, 128, imgW, imgH)  -- part 3
    }
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

    local left  = Banner.quads[1]
    local mid   = Banner.quads[2]
    local right = Banner.quads[3]

    local lx, ly, lw, lh = left:getViewport()
    local mx, my, mw, mh = mid:getViewport()
    local rx, ry, rw, rh = right:getViewport()

    love.graphics.draw(Banner.image, left, Banner.x, Banner.y)

    local midX = Banner.x + lw
    local scaleX = (mw + Banner.currentWidth) / mw
    love.graphics.draw(
        Banner.image,
        mid,
        midX,
        Banner.y,
        0,
        scaleX,
        1
    )

    local rightX = midX + mw * scaleX
    love.graphics.draw(Banner.image, right, rightX, Banner.y)
end

function Banner.reset()
    Banner.timer = 0
    Banner.currentWidth = 0
    Banner.animating = false
    Banner.done = false
end

return Banner
