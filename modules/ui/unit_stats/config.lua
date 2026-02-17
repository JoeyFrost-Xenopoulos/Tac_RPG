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
Config.LEVEL_Y_OFFSET = 316

-- Animation positioning
Config.ANIM_X_OFFSET = -240
Config.ANIM_Y_OFFSET = 140
Config.ANIM_DRAW_X_OFFSET = -140
Config.ANIM_DRAW_Y_OFFSET = 60

-- Stats display
Config.STATS_Y_BASE_OFFSET = 120
Config.STATS_LINE_HEIGHT = 80
Config.STATS_LABEL_X_OFFSET = -150
Config.STATS_VALUE_X_OFFSET = 0
Config.STATS_COLUMN_GAP = 240
Config.STATS_Y_DRAW_OFFSET = -250

-- Stats bar display
Config.STATS_BAR_WIDTH = 160
Config.STATS_BAR_HEIGHT = 32
Config.STATS_BAR_X_OFFSET = -80
Config.STATS_BAR_Y_OFFSET = 25
Config.STATS_BAR_TEXT_OVERLAP = 18

-- Header and UI
Config.HEADER_X_OFFSET = 180
Config.HEADER_Y = 30
Config.BACK_TEXT_Y_OFFSET = 40
Config.ARROW_SIZE = 80
Config.ARROW_LEFT_X_OFFSET = 270
Config.ARROW_LEFT_Y_OFFSET = -35
Config.ARROW_RIGHT_X_OFFSET = -350
Config.ARROW_RIGHT_Y_OFFSET = -10

-- Arrow pendulum animation
Config.ARROW_ANIM_AMPLITUDE = 12  -- How far arrows move up and down in pixels
Config.ARROW_ANIM_SPEED = 0.8  -- Speed of the pendulum motion (cycles per second)

-- Font sizes
Config.MAIN_FONT_SIZE = 46
Config.SMALL_FONT_SIZE = 38
Config.HP_FONT_SIZE = 50
Config.LEVEL_FONT_SIZE = 44
Config.STATS_FONT_SIZE = 48
Config.HEADER_FONT_SIZE = 46

-- Transition animation
Config.TRANSITION_DURATION = 0.2  -- Duration in seconds
Config.TRANSITION_SLIDE_DISTANCE = 800  -- How far to slide in pixels (off screen)

return Config
