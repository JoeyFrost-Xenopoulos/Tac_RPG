local Options = {}
local Config = require("modules.ui.item_selector.config")

local function prettifyItemName(itemId)
    if not itemId or itemId == "" then
        return "Unknown"
    end
    local mapped = Config.ITEM_NAMES[itemId]
    if mapped then
        return mapped
    end
    local text = tostring(itemId):gsub("_", " ")
    return text:sub(1, 1):upper() .. text:sub(2)
end

function Options.buildOptions(unit)
    local options = {}
    local seen = {}

    -- Add weapons first
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
                table.insert(options, { 
                    id = id, 
                    name = name or prettifyItemName(id),
                    type = "weapon"
                })
                seen[id] = true
            end
        end
    end
    
    -- Add items
    if unit and type(unit.items) == "table" then
        for _, item in ipairs(unit.items) do
            local id
            local name
            if type(item) == "table" then
                id = item.id or item.item or item.name
                name = item.name or item.label
            else
                id = item
            end
            if id and not seen[id] then
                table.insert(options, { 
                    id = id, 
                    name = name or prettifyItemName(id),
                    type = "item",
                    usable = false  -- Items not yet implemented
                })
                seen[id] = true
            end
        end
    end

    -- If no items, add some default items for testing (respecting max 5)
    if #options == 0 then
        table.insert(options, { id = "health_potion", name = prettifyItemName("health_potion"), type = "item", usable = false })
        table.insert(options, { id = "mana_potion", name = prettifyItemName("mana_potion"), type = "item", usable = false })
        table.insert(options, { id = "elixir", name = prettifyItemName("elixir"), type = "item", usable = false })
    end
    
    -- Enforce max items (weapons don't count toward item limit)
    local itemCount = 0
    local maxItems = (unit and unit.maxItems) or 5
    local filteredOptions = {}
    
    for _, option in ipairs(options) do
        if option.type == "weapon" then
            -- Weapons are always usable (equippable)
            option.usable = true
            table.insert(filteredOptions, option)
        elseif itemCount < maxItems then
            table.insert(filteredOptions, option)
            itemCount = itemCount + 1
        end
    end
    
    -- Sort so equipped weapon is first
    if unit and unit.weapon then
        table.sort(filteredOptions, function(a, b)
            local aEquipped = a.type == "weapon" and a.id == unit.weapon
            local bEquipped = b.type == "weapon" and b.id == unit.weapon
            if aEquipped and not bEquipped then
                return true
            elseif bEquipped and not aEquipped then
                return false
            end
            return false -- Keep original order for non-equipped items
        end)
    end

    return filteredOptions
end

return Options
