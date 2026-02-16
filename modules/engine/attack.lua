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
    local CombatSystem = require("modules.combat.combat_system")
    
    local damage = 0
    
    -- Check if the attack hits
    if CombatSystem.doesHit(attacker, target) then
        -- Determine if it's a critical hit
        local isCritical = CombatSystem.isCritical(attacker, target)
        
        -- Calculate damage
        damage = CombatSystem.calculateTotalDamage(attacker, target, isCritical)
        
        -- Apply damage
        target.health = math.max(0, target.health - damage)
        
        -- Check for double attack
        if CombatSystem.canDoubleAttack(attacker, target) then
            -- Attacker gets a second attack
            if CombatSystem.doesHit(attacker, target) then
                local isCritical2 = CombatSystem.isCritical(attacker, target)
                local damage2 = CombatSystem.calculateTotalDamage(attacker, target, isCritical2)
                target.health = math.max(0, target.health - damage2)
                damage = damage + damage2
            end
        end
    end
    
    -- Defender can counterattack regardless of whether the attack hit
    if CombatSystem.canBeDoubleAttacked(attacker, target) and target.health > 0 then
        -- Defender gets a counter-attack
        if CombatSystem.doesHit(target, attacker) then
            local counterDamage = CombatSystem.calculateTotalDamage(target, attacker, false)
            attacker.health = math.max(0, attacker.health - counterDamage)
        end
    end
    
    return damage
end

return Attack
