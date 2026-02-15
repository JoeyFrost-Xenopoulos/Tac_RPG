-- modules/ui/unit_stats/resources.lua
-- Font and image resource loading

local Config = require("modules.ui.unit_stats.config")

local Resources = {}

Resources.font = nil
Resources.smallFont = nil
Resources.statsFont = nil
Resources.headerFont = nil
Resources.background = nil

function Resources.load()
    Resources.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", Config.MAIN_FONT_SIZE)
    Resources.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", Config.SMALL_FONT_SIZE)
    Resources.statsFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", Config.STATS_FONT_SIZE)
    Resources.headerFont = love.graphics.newFont("assets/ui/font/Star_Crush_Font.otf", Config.HEADER_FONT_SIZE)
    Resources.background = love.graphics.newImage("assets/ui/menu/stats_menu.png")
end

return Resources
