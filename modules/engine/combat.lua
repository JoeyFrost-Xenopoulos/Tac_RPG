-- modules/combat.lua

Combat = {}

Combat.ATTACK_RANGE = 1
Combat.BASE_DAMAGE = 3
Combat.HEAL_AMOUNT = 5

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

function Combat.getHealableTiles(unit)
    local tiles = {}

    for dy = -1, 1 do
        for dx = -1, 1 do
            if math.abs(dx) + math.abs(dy) == 1 then
                local tx = unit.x + dx
                local ty = unit.y + dy

                local target = Units.getAt(tx, ty)
                if target 
                   and target.team == unit.team 
                   and target ~= unit
                   and target.hp < target.maxHp  -- only include if missing HP
                then
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

function Combat.getAdjacentFreeTile(target, mover)
    local dirs = {
        {1, 0}, {-1, 0}, {0, 1}, {0, -1}
    }

    for _, d in ipairs(dirs) do
        local x = target.x + d[1]
        local y = target.y + d[2]

        local tile = Grid.getTile(x, y)
        if tile and not tile.unit then
            return { x = x, y = y }
        end
    end

    return nil
end

function Combat.attack(attacker, defender)
    local damageAmount = attacker.damage or Combat.BASE_DAMAGE
    defender.hp = defender.hp - damageAmount

    defender.isHurt = true
    attacker.attackDirX = (defender.x < attacker.x) and -1 or 1

    attacker.isAttacking = true
    attacker.attackTarget = defender
    attacker.actionType = "attack"  -- ✅ Add this

    Effects.damage(defender.pixelX + TILE_SIZE / 2, defender.pixelY, damageAmount, "damage")
    Effects.spawnParticles(defender.pixelX + TILE_SIZE / 2, defender.pixelY + TILE_SIZE / 2, "melee")

    if defender.hp <= 0 then
        Units.remove(defender)
    end
end


function Combat.heal(healer, target)
    local dx = math.abs(target.x - healer.x)
    local dy = math.abs(target.y - healer.y)
    if dx + dy ~= 1 then return end

    target.hp = math.min(target.maxHp or target.hp, target.hp + Combat.HEAL_AMOUNT)

    healer.isAttacking = true
    healer.attackTarget = target
    healer.attackDirX = (target.x < healer.x) and -1 or 1
    healer.actionType = "heal"  -- ✅ Add this

    Effects.damage(target.pixelX + TILE_SIZE / 2, target.pixelY, Combat.HEAL_AMOUNT, "heal")

    Turn.endUnitTurn(healer)
end

