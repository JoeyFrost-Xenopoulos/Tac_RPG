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
                table.insert(options, { id = id, name = name or prettifyWeaponName(id) })
                seen[id] = true
            end
        end
    end

    if #options == 0 and unit and unit.weapon then
        table.insert(options, { id = unit.weapon, name = prettifyWeaponName(unit.weapon) })
    end

    if #options == 0 then
        table.insert(options, { id = "unarmed", name = "Unarmed" })
    end

    if #options == 1 then
        table.insert(options, { id = "sword_test", name = prettifyWeaponName("sword_test") })
    end

    return options
end

return Options
