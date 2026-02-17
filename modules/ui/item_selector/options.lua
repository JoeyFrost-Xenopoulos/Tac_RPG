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
                table.insert(options, { id = id, name = name or prettifyItemName(id) })
                seen[id] = true
            end
        end
    end

    -- If no items, add some default items for testing
    if #options == 0 then
        table.insert(options, { id = "health_potion", name = prettifyItemName("health_potion") })
        table.insert(options, { id = "mana_potion", name = prettifyItemName("mana_potion") })
        table.insert(options, { id = "elixir", name = prettifyItemName("elixir") })
    end

    return options
end

return Options
