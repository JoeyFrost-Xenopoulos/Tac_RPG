-- modules/engine/attack.lua
local Attack = {}

local function getEnemiesInRange(attacker)
    local UnitManager = require("modules.units.manager")
    local attackRange = attacker.attackRange or 1
    local enemies = {}
    
    for _, unit in ipairs(UnitManager.units) do
        if unit ~= attacker and unit.isPlayer ~= attacker.isPlayer then
            local dist = math.abs(unit.tileX - attacker.tileX) + math.abs(unit.tileY - attacker.tileY)
            if dist <= attackRange then
                table.insert(enemies, unit)
            end
        end
    end
    
    return enemies
end

function Attack.canAttack(unit)
    local enemies = getEnemiesInRange(unit)
    return #enemies > 0
end

function Attack.getEnemiesInRange(unit)
    return getEnemiesInRange(unit)
end

function Attack.performAttack(attacker, target)
    local damage = attacker.attackDamage or 5
    target.health = math.max(0, target.health - damage)
    return damage
end

return Attack
