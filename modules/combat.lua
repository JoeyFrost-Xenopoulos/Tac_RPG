-- modules/combat.lua

Combat = {}

Combat.ATTACK_RANGE = 1
Combat.BASE_DAMAGE = 3

function Combat.getAttackableTiles(unit)
    local tiles = {}
    local range = unit.attackRange or 1

    local minRange = (unit.class == "Archer") and 2 or 1

    for dy = -range, range do
        for dx = -range, range do
            local dist = math.abs(dx) + math.abs(dy)
            
            if dist >= minRange and dist <= range then
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
    local damageAmount = attacker.damage or Combat.BASE_DAMAGE
    defender.hp = defender.hp - damageAmount

    defender.isHurt = true
    if defender.x < attacker.x then
        attacker.attackDirX = -1
    else
        attacker.attackDirX = 1
    end

    attacker.isAttacking = true

    -- Effects
    Effects.damage(defender.pixelX + TILE_SIZE / 2, defender.pixelY, damageAmount, "damage")
    Effects.spawnParticles(defender.pixelX + TILE_SIZE / 2, defender.pixelY + TILE_SIZE / 2, "melee")

    if defender.hp <= 0 then
        Units.remove(defender)
    end
end
