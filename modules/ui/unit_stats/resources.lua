-- modules/ui/unit_stats/resources.lua
-- Font and image resource loading

local Config = require("modules.ui.unit_stats.config")

local Resources = {}

Resources.font = nil
Resources.smallFont = nil
Resources.hpFont = nil
Resources.levelFont = nil
Resources.statsFont = nil
Resources.headerFont = nil
Resources.backgroundPlayer = nil
Resources.backgroundEnemy = nil
Resources.barBase = nil
Resources.barFill = nil
Resources.arrowImage = nil

function Resources.load()
    Resources.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", Config.MAIN_FONT_SIZE)
    Resources.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", Config.SMALL_FONT_SIZE)
    Resources.hpFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", Config.HP_FONT_SIZE)
    Resources.levelFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", Config.LEVEL_FONT_SIZE)
    Resources.statsFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", Config.STATS_FONT_SIZE)
    Resources.headerFont = love.graphics.newFont("assets/ui/font/Star_Crush_Font.otf", Config.HEADER_FONT_SIZE)
    Resources.backgroundPlayer = love.graphics.newImage("assets/ui/menu/stats_menu_player.png")
    Resources.backgroundEnemy = love.graphics.newImage("assets/ui/menu/stats_menu_enemy.png")
    Resources.barBase = love.graphics.newImage("assets/ui/bars/BigBar_Base.png")
    Resources.barFill = love.graphics.newImage("assets/ui/bars/BigBar_Fill_Stats.png")
    Resources.barBase:setFilter("nearest", "nearest")
    Resources.barFill:setFilter("nearest", "nearest")
    Resources.barBase:setWrap("clamp", "clamp")
    Resources.barFill:setWrap("clamp", "clamp")
    Resources.arrowImage = love.graphics.newImage("assets/ui/arrows/up_down.png")
end

return Resources
