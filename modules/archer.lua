-- modules/archer.lua
Archer = {}

function Archer.init()
    Archer.data = {}

    Archer.data["archer"] = {
        animations = {
            idle = {
                img = love.graphics.newImage("units/Archer/Archer_idle.png"),
                frames = {
                    {x=0,   y=0, width=80, height=110},
                    {x=192, y=0, width=80, height=110},
                    {x=384, y=0, width=80, height=110},
                    {x=576, y=0, width=80, height=110},
                    {x=768, y=0, width=80, height=110},
                    {x=960, y=0, width=80, height=110},
                },
                speed = 0.12
            },

            walk = {
                img = love.graphics.newImage("units/Archer/Archer_Run.png"),
                frames = {
                    {x=0,   y=0, width=80, height=110},
                    {x=192, y=0, width=80, height=110},
                    {x=384, y=0, width=80, height=110},
                    {x=576, y=0, width=80, height=110}
                },
                speed = 0.09
            },

            attack = {
                img = love.graphics.newImage("units/Archer/Archer_Shoot.png"),
                frames = {
                    {x=0,   y=0, width=96, height=128},
                    {x=192, y=0, width=96, height=128},
                    {x=384, y=0, width=96, height=128},
                    {x=576, y=0, width=96, height=128},
                    {x=768, y=0, width=96, height=128},
                    {x=960, y=0, width=96, height=128},
                    {x=1052, y=0, width=96, height=128},
                    {x=1144, y=0, width=96, height=128}
                },
                speed = 0.10
            },

            hurt = {
                img = love.graphics.newImage("units/Archer/Archer_Idle.png"),
                frames = {
                    {x=0,   y=0, width=80, height=120},
                    {x=192, y=0, width=80, height=120},
                    {x=384, y=0, width=80, height=120},
                },
                speed = 0.12
            }
        }
    }

    -- Build quads (same as Enemy / old Character)
    for _, archer in pairs(Archer.data) do
        for _, anim in pairs(archer.animations) do
            anim.quads = {}
            local imgW, imgH = anim.img:getDimensions()

            for _, f in ipairs(anim.frames) do
                table.insert(
                    anim.quads,
                    love.graphics.newQuad(
                        f.x, f.y,
                        f.width, f.height,
                        imgW, imgH
                    )
                )
            end

            anim.frameCount = #anim.quads
        end
    end
end

function Archer.assignToUnit(unit, name)
    local archer = Archer.data[name]
    if not archer then
        print("Archer type not found: " .. tostring(name))
        return
    end

    unit.animations = archer.animations
    unit.currentAnimation = "idle"
    unit.currentFrame = 1
    unit.frameTimer = 0

    unit.facingX = 1
end

return Archer
