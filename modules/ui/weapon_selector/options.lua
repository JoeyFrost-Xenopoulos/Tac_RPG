local Options = {}
local Config = require("modules.ui.weapon_selector.config")

local function prettifyWeaponName(weaponId)
    if not weaponId or weaponId == "" then
        return "Unknown"
    end
    local mapped = Config.WEAPON_NAMES[weaponId]
    if mapped then
        return mapped
    end
    local text = tostring(weaponId):gsub("_", " ")
    return text:sub(1, 1):upper() .. text:sub(2)
end

function Options.buildOptions(unit)
    local options = {}
    local seen = {}

    if unit and type(unit.weapons) == "table" then
        for _, weapon in ipairs(unit.weapons) do
            local id
            local name
            if type(weapon) == "table" then
                id = weapon.id or weapon.weapon or weapon.name
                name = weapon.name or weapon.label
            else
                id = weapon
            end
            if id and not seen[id] then
                local option = { id = id, name = name or prettifyWeaponName(id) }
                -- Check if weapon is in range
                option.inRange = Options.isWeaponInRange(unit, id)
                table.insert(options, option)
                seen[id] = true
            end
        end
    end

    if #options == 0 and unit and unit.weapon then
        local option = { id = unit.weapon, name = prettifyWeaponName(unit.weapon) }
        option.inRange = Options.isWeaponInRange(unit, unit.weapon)
        table.insert(options, option)
    end

    if #options == 0 then
        table.insert(options, { id = "unarmed", name = "Unarmed", inRange = true })
    end

    if #options == 1 then
        local option = { id = "sword_test", name = prettifyWeaponName("sword_test") }
        option.inRange = Options.isWeaponInRange(unit, "sword_test")
        table.insert(options, option)
    end

    -- Sort so equipped weapon is first
    if unit and unit.weapon then
        table.sort(options, function(a, b)
            local aEquipped = a.id == unit.weapon
            local bEquipped = b.id == unit.weapon
            if aEquipped and not bEquipped then
                return true
            elseif bEquipped and not aEquipped then
                return false
            end
            return false -- Keep original order for non-equipped items
        end)
    end

    return options
end

function Options.isWeaponInRange(unit, weaponId)
    if not unit then return false end
    local Attack = require("modules.engine.attack")
    
    -- Temporarily check with this weapon
    local originalWeapon = unit.weapon
    unit.weapon = weaponId
    
    local enemies = Attack.getEnemiesInRange(unit)
    
    -- Restore original weapon
    unit.weapon = originalWeapon
    
    return #enemies > 0
end

return Options
