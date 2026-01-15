Foam = {}

Foam.image = nil
Foam.quads = {}
Foam.frameTime = 0.08 -- animation speed
Foam.totalFrames = 16
Foam.tileSize = 192 -- size per frame
Foam.tileFrames = {}
Foam.timer = 0

function Foam.load()
    Foam.image = love.graphics.newImage("map/Water Foam.png")

    local imgW, imgH = Foam.image:getDimensions()
    local cols = imgW / Foam.tileSize

    for i = 0, Foam.totalFrames - 1 do
        local x = (i % cols) * Foam.tileSize
        local y = math.floor(i / cols) * Foam.tileSize

        Foam.quads[i + 1] = love.graphics.newQuad(
            x, y,
            Foam.tileSize, Foam.tileSize,
            imgW, imgH
        )
    end
    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local tile = Grid.getTile(x, y)
            if tile and tile.terrain == "grass" then
                Foam.tileFrames[x .. "_" .. y] = math.random(1, Foam.totalFrames)
            end
        end
    end
end

function Foam.update(dt)
    Foam.timer = Foam.timer + dt
    if Foam.timer >= Foam.frameTime then
        Foam.timer = Foam.timer - Foam.frameTime
        for key, frame in pairs(Foam.tileFrames) do
            Foam.tileFrames[key] = frame % Foam.totalFrames + 1
        end
    end
end

function Foam.shouldDraw(x, y)
    local tile = Grid.getTile(x, y)
    return tile and tile.terrain == "grass"
end

function Foam.draw()
    love.graphics.setColor(1, 1, 1)
    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            if Foam.shouldDraw(x, y) then
                local px = (x - 1) * TILE_SIZE
                local py = (y - 1) * TILE_SIZE
                local scale = (TILE_SIZE / Foam.tileSize) * 2.75
                local offset = TILE_SIZE * (2.75 - 1) * 0.5
                local key = x .. "_" .. y
                local frame = Foam.tileFrames[key] or 1

                love.graphics.draw(
                    Foam.image,
                    Foam.quads[frame],
                    px - offset,
                    py - offset,
                    0,
                    scale,
                    scale
                )
            end
        end
    end
end

function Foam.initTiles()
    Foam.tileFrames = {}

    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local tile = Grid.getTile(x, y)
            if tile and tile.terrain == "grass" then
                Foam.tileFrames[x.."_"..y] = math.random(1, Foam.totalFrames)
            end
        end
    end
end
