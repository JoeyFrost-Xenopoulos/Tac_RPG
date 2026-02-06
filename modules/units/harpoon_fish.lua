local UnitFactory = require("modules.units.unit_factory")

local Harpoon_Fish = {
    name = "James",
    type = "Soldier",
    avatar = love.graphics.newImage("assets/ui/avatars/Harpoon_Fish.png"),
    uiVariant = 2,
    isPlayer = false,
    maxMoveRange = 4,
    maxHealth = 120,
    health = 120,
    attackRange = 1,
    attackDamage = 5,
    animations = {
        idle = {
            img = love.graphics.newImage("assets/units/Enemy/HarpoonFish/HarpoonFish_Idle.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192},
                {x=1152,y=0,width=192,height=192},{x=1344,y=0,width=192,height=192},
            },
            speed = 0.10
        },
        walk = {
            img = love.graphics.newImage("assets/units/Enemy/HarpoonFish/HarpoonFish_Run.png"),
            frames = {
                {x=0,y=0,width=192,height=192},{x=192,y=0,width=192,height=192},
                {x=384,y=0,width=192,height=192},{x=576,y=0,width=192,height=192},
                {x=768,y=0,width=192,height=192},{x=960,y=0,width=192,height=192}
            },
            speed = 0.08
        },
        attack = {
            img = love.graphics.newImage("assets/units/Enemy/HarpoonFish/HarpoonFish_Throw.png"),
            frames = {
                {x=0,y=0,width=68,height=126},{x=188,y=0,width=70,height=126}
            },
            speed = 0.15
        }
    }
}

Harpoon_Fish.unit = UnitFactory.create(Harpoon_Fish)

function Harpoon_Fish.update(dt) Harpoon_Fish.unit:update(dt) end
function Harpoon_Fish.draw() Harpoon_Fish.unit:draw() end
function Harpoon_Fish.setPosition(x, y) Harpoon_Fish.unit:setPosition(x, y) end
function Harpoon_Fish.tryMove(x, y) return Harpoon_Fish.unit:tryMove(x, y) end
function Harpoon_Fish.setSelected(v) Harpoon_Fish.unit:setSelected(v) end
function Harpoon_Fish.isHovered(mx, my) return Harpoon_Fish.unit:isHovered(mx, my) end
function Harpoon_Fish.isClicked(mx, my) return Harpoon_Fish.unit:isClicked(mx, my) end

return Harpoon_Fish