-- modules/combat/combat_system.lua
-- Handles all combat calculations: damage, hit chance, crit chance, avoid

local CombatSystem = {}

-- Weapon definitions with might values and range
local weapons = {
    sword = {
        name = "Heavy Sword",
        type = "physical",
        might = 5,
        hitRate = 90,
        critical = 0,
        weight = 5,
        range = 1,
    },
    sword_test = {
        name = "Practice Sword",
        type = "physical",
        might = 3,
        hitRate = 95,
        critical = 0,
        weight = 3,
        range = 1,
    },
    harpoon = {
        name = "Harpoon",
        type = "physical",
        might = 6,
        hitRate = 80,
        critical = 5,
        weight = 7,
        range = 2,
    },
    bow = {
        name = "Bow",
        type = "physical",
        might = 4,
        hitRate = 85,
        critical = 10,
        weight = 4,
        range = 2,
        minRange = 2,
    },
    iron_sword = {
        name = "Iron Sword",
        type = "physical",
        might = 6,
        hitRate = 85,
        critical = 5,
        weight = 6,
        range = 1,
    },
    steel_sword = {
        name = "Steel Sword",
        type = "physical",
        might = 8,
        hitRate = 75,
        critical = 5,
        weight = 10,
        range = 1,
    },
    fire = {
        name = "Fire",
        type = "magic",
        might = 4,
        hitRate = 100,
        critical = 0,
        weight = 3,
        range = 1,
    },
    thunder = {
        name = "Thunder",
        type = "magic",
        might = 6,
        hitRate = 80,
        critical = 10,
        weight = 4,
        range = 1,
    },
}

function CombatSystem.getWeapon(weaponKey)
    return weapons[weaponKey] or weapons.sword
end

function CombatSystem.getAllWeapons()
    return weapons
end

-- Get the attack range for a unit based on their equipped weapon
function CombatSystem.getAttackRange(unit)
    if not unit then return 1 end
    local weapon = CombatSystem.getWeapon(unit.weapon)
    return weapon.range or 1
end

-- Calculate physical/weapon damage
-- Damage = Str + Weapon Mt - Defender's Def
function CombatSystem.calculateWeaponDamage(attacker, defender)
    local weapon = CombatSystem.getWeapon(attacker.weapon)
    local baseDamage = (attacker.strength or 10) + (weapon.might or 0)
    local defenseReduction = defender.defense or 0
    local damage = math.max(1, baseDamage - defenseReduction)
    
    return damage
end

-- Calculate magic damage
-- Damage = Mag + Tome Mt - Defender's Res
function CombatSystem.calculateMagicDamage(attacker, defender)
    local weapon = CombatSystem.getWeapon(attacker.weapon)
    local baseDamage = (attacker.magic or 5) + (weapon.might or 0)
    local resistanceReduction = defender.resistance or 0
    local damage = math.max(1, baseDamage - resistanceReduction)
    
    return damage
end

-- Calculate total damage (applies critical multiplier)
function CombatSystem.calculateTotalDamage(attacker, defender, isCritical)
    local weapon = CombatSystem.getWeapon(attacker.weapon)
    local damage
    
    if weapon.type == "magic" then
        damage = CombatSystem.calculateMagicDamage(attacker, defender)
    else
        damage = CombatSystem.calculateWeaponDamage(attacker, defender)
    end
    
    if isCritical then
        damage = damage * 2
    end
    
    return damage
end

-- Calculate hit chance
-- Hit = [(Skill x 3 + Luck) / 2] + Weapon Hit Rate
function CombatSystem.calculateHitChance(attacker, defender)
    local weapon = CombatSystem.getWeapon(attacker.weapon)
    local skill = attacker.skill or 10
    local luck = attacker.luck or 0
    
    local hitChance = math.floor((skill * 3 + luck) / 2) + (weapon.hitRate or 90)
    
    -- Apply defender's avoid chance as reduction
    local avoidChance = CombatSystem.calculateAvoidChance(defender)
    hitChance = math.max(0, hitChance - avoidChance)
    
    -- Clamp between 0 and 100
    return math.min(100, math.max(0, hitChance))
end

-- Calculate critical chance
-- Crit = (Skill / 2) + Weapon's Critical
function CombatSystem.calculateCritChance(attacker)
    local weapon = CombatSystem.getWeapon(attacker.weapon)
    local skill = attacker.skill or 10
    
    local critChance = math.floor(skill / 2) + (weapon.critical or 0)
    
    -- Clamp between 0 and 100
    return math.min(100, math.max(0, critChance))
end

-- Calculate avoid chance
-- Avoid = (Speed x 3 + Luck) / 2
function CombatSystem.calculateAvoidChance(unit)
    local speed = unit.speed or 10
    local luck = unit.luck or 0
    
    local avoidChance = math.floor((speed * 3 + luck) / 2)
    
    -- Clamp between 0 and 100
    return math.min(100, math.max(0, avoidChance))
end

-- Calculate critical avoid (from luck)
-- Crit Avoid = Luck
function CombatSystem.calculateCritAvoid(unit)
    return unit.luck or 0
end

-- Check if attacker hits
function CombatSystem.doesHit(attacker, defender)
    local hitChance = CombatSystem.calculateHitChance(attacker, defender)
    return love.math.random(100) <= hitChance
end

-- Check if it's a critical hit
function CombatSystem.isCritical(attacker, defender)
    local critChance = CombatSystem.calculateCritChance(attacker)
    local critAvoid = CombatSystem.calculateCritAvoid(defender)
    local adjustedCritChance = math.max(0, critChance - critAvoid)
    
    return love.math.random(100) <= adjustedCritChance
end

-- Check if attacker can double attack
-- If your Spd is 5 points higher than the enemy, you attack twice
function CombatSystem.canDoubleAttack(attacker, defender)
    return (attacker.speed or 10) - (defender.speed or 10) >= 5
end

-- Check if defender can double attack
-- If your Spd is 5 points lower than the enemy, they attack twice
function CombatSystem.canBeDoubleAttacked(attacker, defender)
    return (defender.speed or 10) - (attacker.speed or 10) >= 5
end

return CombatSystem
