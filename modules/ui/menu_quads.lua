-- modules/ui/menu_quads.lua
local MenuQuads = {}

function MenuQuads.get(image)
    local imgW, imgH = image:getDimensions()
    return {
        topLeft   = love.graphics.newQuad(0,   0,   105, 105, imgW, imgH),
        topMid    = love.graphics.newQuad(128, 0,   64,  64,  imgW, imgH),
        topRight  = love.graphics.newQuad(256, 0,   64,  64,  imgW, imgH),
        midLeft   = love.graphics.newQuad(0,   128, 105, 105, imgW, imgH),
        midMid    = love.graphics.newQuad(128, 128, 64,  64,  imgW, imgH),
        midRight  = love.graphics.newQuad(256, 128, 64,  64,  imgW, imgH),
        botLeft   = love.graphics.newQuad(0,   256, 105, 105, imgW, imgH),
        botMid    = love.graphics.newQuad(128, 256, 64,  64,  imgW, imgH),
        botRight  = love.graphics.newQuad(256, 256, 64,  64,  imgW, imgH)
    }
end

return MenuQuads
