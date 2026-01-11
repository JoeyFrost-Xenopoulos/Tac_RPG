-- modules/enemy.lua
Enemy = {}

-- Define all enemy types and their animations
function Enemy.init()
    Enemy.data = {}

    -- Example: Enemy Soldier
    Enemy.data["soldier"] = {
        animations = {
            idle = {
                img = love.graphics.newImage("units/Enemies/Warrior/Warrior_idle.png"),
                frames = {
                    {x=0,   y=0, width=80, height=124},
                    {x=192, y=0, width=80, height=124},
                    {x=384, y=0, width=82, height=124},
                    {x=576, y=0, width=82, height=124},
                    {x=768, y=0, width=82, height=124},
                    {x=960, y=0, width=82, height=124},
                    {x=1152, y=0, width=82, height=124},
                    {x=1344, y=0, width=82, height=124},
                },
                speed = 0.10
            },
            walk = {
                img = love.graphics.newImage("units/Enemies/Warrior/Warrior_Run.png"),
                frames = {
                    {x=0,   y=0, width=80, height=124},
                    {x=192, y=0, width=80, height=124},
                    {x=384, y=0, width=82, height=124},
                    {x=576, y=0, width=82, height=124},
                    {x=768, y=0, width=90, height=124},
                    {x=960, y=0, width=90, height=124},
                },
                speed = 0.08
            },
            attack = {
                img = love.graphics.newImage("units/Enemies/Warrior/Warrior_Attack1.png"),
                frames = {
                    {x=0,   y=0, width=68, height=126},
                    {x=188, y=0, width=70, height=126},
                    {x=370, y=0, width=126, height=126},
                    {x=560, y=0, width=126, height=126},
                },
                speed = 0.15
            },
            hurt = {
                img = love.graphics.newImage("units/Enemies/Warrior/Warrior_Guard.png"),
                frames = {
                    {x=0,   y=0, width=80, height=110},
                    {x=192, y=0, width=80, height=110},
                    {x=384, y=0, width=80, height=110},
                    {x=576, y=0, width=80, height=110},
                    {x=768, y=0, width=80, height=110},
                    {x=960, y=0, width=80, height=110},
                },
                speed = 0.10
            }
        }
    }

    for _, enemy in pairs(Enemy.data) do
        for _, anim in pairs(enemy.animations) do
            anim.quads = {}
            local imgWidth, imgHeight = anim.img:getDimensions()
            for _, f in ipairs(anim.frames) do
                table.insert(anim.quads, love.graphics.newQuad(f.x, f.y, f.width, f.height, imgWidth, imgHeight))
            end
            anim.frameCount = #anim.quads
        end
    end
end

function Enemy.assignToUnit(unit, name)
    local enemy = Enemy.data[name]
    if not enemy then
        print("Enemy type not found: " .. tostring(name))
        return
    end

    unit.animations = enemy.animations
    unit.currentAnimation = "idle"
    unit.currentFrame = 1
    unit.frameTimer = 0
    unit.team = "enemy"

    unit.facingX = -1 
end


return Enemy
