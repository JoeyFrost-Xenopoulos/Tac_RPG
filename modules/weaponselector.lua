-- weaponselector.lua

WeaponSelector = {}

-- Menu state
WeaponSelector.active = false
WeaponSelector.unit = nil
WeaponSelector.target = nil
WeaponSelector.options = { "Spear", "Axe", "Sword" }
WeaponSelector.selectedIndex = 1

local MENU_WIDTH = 110
local MENU_HEIGHT = 165
local OPTION_HEIGHT = 30
local PADDING = 10

local function getMenuPosition()
    local x = love.graphics.getWidth() - MENU_WIDTH - PADDING
    local y = PADDING
    return x, y
end

function WeaponSelector.open(unit, target)
    WeaponSelector.active = true
    WeaponSelector.unit = unit
    WeaponSelector.target = target
    WeaponSelector.selectedIndex = 1
end

function WeaponSelector.close()
    WeaponSelector.active = false
    WeaponSelector.unit = nil
    WeaponSelector.target = nil
end

function WeaponSelector.keypressed(key)
    if not WeaponSelector.active then return end

    if key == "up" then
        WeaponSelector.selectedIndex = WeaponSelector.selectedIndex - 1
        if WeaponSelector.selectedIndex < 1 then WeaponSelector.selectedIndex = #WeaponSelector.options end
    elseif key == "down" then
        WeaponSelector.selectedIndex = WeaponSelector.selectedIndex + 1
        if WeaponSelector.selectedIndex > #WeaponSelector.options then WeaponSelector.selectedIndex = 1 end
    elseif key == "return" or key == "space" then
        WeaponSelector.confirmSelection()
    elseif key == "escape" then
        WeaponSelector.close()
    end
end

function WeaponSelector.confirmSelection()
    local weapon = WeaponSelector.options[WeaponSelector.selectedIndex]
    local unit = WeaponSelector.unit
    local target = WeaponSelector.target

    if weapon == "Spear" then
        unit.damage = 5
    elseif weapon == "Axe" then
        unit.damage = 7
    elseif weapon == "Sword" then
        unit.damage = 6
    end

    Combat.attack(unit, target)
    Turn.endUnitTurn(unit)
    WeaponSelector.close()
end

function WeaponSelector.draw()
    if not WeaponSelector.active then return end
    local x, y = getMenuPosition()

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x, y, MENU_WIDTH, MENU_HEIGHT, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, MENU_WIDTH, MENU_HEIGHT, 5, 5)

    for i, option in ipairs(WeaponSelector.options) do
        local optionY = y + 10 + (i-1) * OPTION_HEIGHT
        if i == WeaponSelector.selectedIndex then
            love.graphics.setColor(0.8, 0, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.print(option, x + 10, optionY)
    end

    love.graphics.setColor(1, 1, 1)
end