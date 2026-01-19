-- modules/units/soldier.lua
local BaseUnit = require("modules.units.base")
local Soldier = {} 
local instance = nil

function Soldier.load()
    local config = {
        type = "Soldier",
        avatar = love.graphics.newImage("assets/ui/avatars/Avatars_01.png"),
        uiVariant = 1,
        uiAnchor = "left",
        isPlayer = true,
        maxMoveRange = 4,
        animations = {
            idle = {
                img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Idle.png"),
                frames = {
                    {x=0,    y=0, width=192, height=192},
                    {x=192,  y=0, width=192, height=192},
                    {x=384,  y=0, width=192, height=192},
                    {x=576,  y=0, width=192, height=192},
                    {x=768,  y=0, width=192, height=192},
                    {x=960,  y=0, width=192, height=192},
                    {x=1152, y=0, width=192, height=192},
                    {x=1344, y=0, width=192, height=192}
                },
                speed = 0.10
            },
            walk = {
                img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Run.png"),
                frames = {
                    {x=0,    y=0, width=192, height=192},
                    {x=192,  y=0, width=192, height=192},
                    {x=384,  y=0, width=192, height=192},
                    {x=576,  y=0, width=192, height=192},
                    {x=768,  y=0, width=192, height=192},
                    {x=960,  y=0, width=192, height=192}
                },
                speed = 0.08
            },
            attack = {
                img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Attack1.png"),
                frames = {
                    {x=0,    y=0, width=68, height=126},
                    {x=188,  y=0, width=70, height=126},
                },
                speed = 0.15
            }
        }
    }

    instance = BaseUnit.new(config)
    Soldier.unit = instance 
end

function Soldier.update(dt) instance:update(dt) end
function Soldier.draw() instance:draw() end
function Soldier.setPosition(x, y) instance:setPosition(x, y) end
function Soldier.tryMove(x, y) instance:tryMove(x, y) end
function Soldier.setSelected(v) instance:setSelected(v) end
function Soldier.isHovered(mx, my) return instance:isHovered(mx, my) end
function Soldier.isClicked(mx, my) return instance:isClicked(mx, my) end

return Soldier