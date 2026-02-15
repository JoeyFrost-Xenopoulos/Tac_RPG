-- modules/ui/unit_stats/config.lua
-- Layout and styling constants for unit stats screen

local Config = {}

-- Panel layout
Config.PANEL_PADDING = 20
Config.PANEL_OFFSET_RIGHT = 60
Config.PANEL_HEIGHT_OFFSET = 80

-- Avatar positioning
Config.AVATAR_SIZE = 160
Config.AVATAR_SCALE = 2
Config.AVATAR_X_OFFSET = -550
Config.AVATAR_Y_OFFSET = -70

-- Text positioning
Config.NAME_Y_OFFSET = 170
Config.TYPE_X_OFFSET = -450
Config.TYPE_Y_OFFSET = 100
Config.NAME_Y_OFFSET_FROM_TYPE = 36

-- HP and Level display
Config.HP_X_OFFSET = -540
Config.HP_Y_OFFSET = 270
Config.LEVEL_Y_OFFSET = 306

-- Animation positioning
Config.ANIM_X_OFFSET = -240
Config.ANIM_Y_OFFSET = 140
Config.ANIM_DRAW_X_OFFSET = -140
Config.ANIM_DRAW_Y_OFFSET = 60

-- Stats display
Config.STATS_Y_BASE_OFFSET = 90
Config.STATS_LINE_HEIGHT = 55
Config.STATS_LABEL_X_OFFSET = -120
Config.STATS_VALUE_X_OFFSET = 0
Config.STATS_COLUMN_GAP = 240
Config.STATS_Y_DRAW_OFFSET = -250

-- Header and UI
Config.HEADER_X_OFFSET = 180
Config.HEADER_Y = 30
Config.BACK_TEXT_Y_OFFSET = 40

-- Font sizes
Config.MAIN_FONT_SIZE = 46
Config.SMALL_FONT_SIZE = 38
Config.STATS_FONT_SIZE = 48
Config.HEADER_FONT_SIZE = 46

return Config
