-- modules/combat.lua

Combat = {}

Combat.ATTACK_RANGE = 1
Combat.BASE_DAMAGE = 3

function Combat.getAttackableTiles(unit)
    local tiles = {}
    local range = unit.attackRange or 1

    for dy = -range, range do
        for dx = -range, range do
            local dist = math.abs(dx) + math.abs(dy)
            
            if dist > 0 and dist <= range then
                local tx = unit.x + dx
                local ty = unit.y + dy

                local target = Units.getAt(tx, ty)
                -- Only add to list if there is an enemy there
                if target and target.team ~= unit.team then
                    table.insert(tiles, {
                        x = tx,
                        y = ty,
                        target = target
                    })
                end
            end
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
