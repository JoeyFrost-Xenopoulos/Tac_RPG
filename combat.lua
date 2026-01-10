-- modules/combat.lua

Combat = {}

Combat.ATTACK_RANGE = 1
Combat.BASE_DAMAGE = 3

function Combat.getAttackableTiles(unit)
    local tiles = {}

    local directions = {
        { x = 1, y = 0 },
        { x = -1, y = 0 },
        { x = 0, y = 1 },
        { x = 0, y = -1 }
    }

    for _, d in ipairs(directions) do
        local tx = unit.x + d.x
        local ty = unit.y + d.y

        local target = Units.getAt(tx, ty)
        if target and target.team ~= unit.team then
            table.insert(tiles, {
                x = tx,
                y = ty,
                target = target
            })
        end
    end

    return tiles
end

function Combat.attack(attacker, defender)
    defender.hp = defender.hp - Combat.BASE_DAMAGE
    
    Effects.damage(
        defender.x * TILE_SIZE,      -- convert grid x to pixels
        defender.y * TILE_SIZE - 20, -- slightly above the unit
        Combat.BASE_DAMAGE           -- amount to display
    )

    if defender.hp <= 0 then
        Units.remove(defender)
    end
end
