-- modules/combat/battle_config.lua
-- Configuration constants for the battle system

local Config = {}

-- Phase durations (in seconds)
Config.RUN_DURATION = 0.8
Config.ATTACK_DURATION = 0.7
Config.RETURN_DURATION = 0.8
Config.TOTAL_DURATION = Config.RUN_DURATION + Config.ATTACK_DURATION + Config.RETURN_DURATION

-- Bar configuration
Config.BAR = {
    WIDTH = 320,
    HEIGHT = 64,
    MARGIN = 40,
    BOTTOM_MARGIN = 30,
    CENTER_OFFSET = 30,
    FILL_INSET = 50,
}

Config.HEALTH_TEXT = {
    OFFSET_X = -20,
    OFFSET_Y = 35,
}

-- Preview indicators configuration
Config.PREVIEW = {
    ENEMY_X = 80,
    PLAYER_X = -300,
    TOP_Y = 60,
    OFFSET_Y = 620,
    WIDTH = 220,
}

-- Weapon display configuration
Config.WEAPON = {
    ATTACKER_X = 290,
    DEFENDER_X = -500,
    ICON_Y = 735,
    ICON_SCALE = 0.80,
    TEXT_OFFSET = 10,
}

-- Animation configuration
Config.ANIMATION = {
    HIT_EFFECT_DURATION = 0.6,
    BREAK_ANIM_DURATION = 0.7,
    HEALTH_ANIM_DURATION = 0.8,
}

-- Transition configuration
Config.TRANSITION = {
    CLOSE_DURATION = 0.4,
    WHITE_DURATION = 0.08,
    MOVE_DURATION = 0.4,
}

return Config
