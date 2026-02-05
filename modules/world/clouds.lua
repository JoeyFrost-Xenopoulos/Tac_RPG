local Clouds = {}

Clouds.images = {}
Clouds.instances = {}

Clouds.minSpeed = 10
Clouds.maxSpeed = 30
Clouds.spawnDelay = 0
Clouds.timer = 0
Clouds.maxClouds = 8

-- Map bounds (in world pixels)
Clouds.mapWidth = 18 * 64  -- 1152
Clouds.mapHeight = 15 * 64  -- 960

function Clouds.load()
    for i = 1, 6 do
        local img = love.graphics.newImage(
            string.format("map/clouds/Clouds_%02d.png", i)
        )
        table.insert(Clouds.images, img)
    end
end

function Clouds.spawn()
    if #Clouds.images == 0 then return end

    local img = Clouds.images[love.math.random(#Clouds.images)]
    local w = img:getWidth()
    local h = img:getHeight()

    local fromLeft = love.math.random() < 0.5

    local cloud = {
        img = img,
        y = love.math.random(0, Clouds.mapHeight - h),
        speed = love.math.random(Clouds.minSpeed, Clouds.maxSpeed),
        dir = fromLeft and 1 or -1
    }

    if fromLeft then
        cloud.x = -w
    else
        cloud.x = Clouds.mapWidth
    end

    table.insert(Clouds.instances, cloud)

    Clouds.spawnDelay = 1 + love.math.random() * 2
    Clouds.timer = 0
end

function Clouds.update(dt)
    Clouds.timer = Clouds.timer + dt

    if Clouds.timer >= Clouds.spawnDelay and #Clouds.instances < Clouds.maxClouds then
        Clouds.spawn()
    end

    for i = #Clouds.instances, 1, -1 do
        local c = Clouds.instances[i]
        c.x = c.x + c.speed * c.dir * dt
        if c.dy then
            c.y = c.y + c.dy * dt
        end

        local w = c.img:getWidth()

        if c.dir == 1 and c.x > Clouds.mapWidth then
            table.remove(Clouds.instances, i)
        elseif c.dir == -1 and c.x + w < 0 then
            table.remove(Clouds.instances, i)
        end
    end
end

function Clouds.draw()
    for _, c in ipairs(Clouds.instances) do
        love.graphics.draw(c.img, c.x, c.y)
    end
end

return Clouds