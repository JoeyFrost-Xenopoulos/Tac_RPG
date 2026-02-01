local Clouds = {}

Clouds.images = {}
Clouds.instances = {}

Clouds.minSpeed = 10
Clouds.maxSpeed = 30
Clouds.minY = 0
Clouds.maxY = WINDOW_HEIGHT * 0.8
Clouds.spawnDelay = 0
Clouds.timer = 0
Clouds.maxClouds = 5

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

    local fromLeft = love.math.random() < 0.5

    local cloud = {
        img = img,
        y = love.math.random(Clouds.minY, Clouds.maxY),
        speed = love.math.random(Clouds.minSpeed, Clouds.maxSpeed),
        dir = fromLeft and 1 or -1
    }

    if fromLeft then
        cloud.x = -w
    else
        cloud.x = WINDOW_WIDTH + w
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

        if c.dir == 1 and c.x > WINDOW_WIDTH then
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