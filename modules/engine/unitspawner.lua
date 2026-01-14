-- modules/engine/unitspawner.lua

UnitSpawner = {}

-- Check whether a tile is valid for spawning
function UnitSpawner.canSpawnAt(x, y)
    local tile = Grid.getTile(x, y)
    if not tile then return false end
    if not tile.walkable then return false end
    if tile.unit then return false end
    return true
end

-- Try to spawn at an exact position
function UnitSpawner.spawn(def)
    if not UnitSpawner.canSpawnAt(def.x, def.y) then
        return nil, "Invalid spawn tile"
    end

    local unit = Units.create(def)
    return unit
end

-- Optional: find nearest valid tile (simple radius search)
function UnitSpawner.spawnNear(def, radius)
    radius = radius or 3

    for r = 0, radius do
        for dy = -r, r do
            for dx = -r, r do
                local x = def.x + dx
                local y = def.y + dy

                if UnitSpawner.canSpawnAt(x, y) then
                    local newDef = {}
                    for k, v in pairs(def) do newDef[k] = v end
                    newDef.x = x
                    newDef.y = y

                    return Units.create(newDef)
                end
            end
        end
    end

    return nil, "No valid spawn location found"
end

return UnitSpawner
