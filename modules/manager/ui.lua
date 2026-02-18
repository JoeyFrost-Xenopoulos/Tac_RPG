-- modules/manager/ui.lua
local function attach(UnitManager)
    local Menu = require("modules.ui.menu")
    local Grid = require("modules.ui.grid")
    local Effects = require("modules.audio.sound_effects")
    local Attack = require("modules.engine.attack")
    local Options = require("modules.ui.options")
    local WeaponSelect = require("modules.ui.weapon_selector")
    local MovementRange = require("modules.engine.movement_range")

    function UnitManager.showWaitMenu()
        local unit = UnitManager.selectedUnit
        if not unit then return end

        UnitManager.state = "menu"
        local screenW = love.graphics.getWidth()
        local unitPixelX = unit.tileX * Grid.tileSize

        local mx
        local my = 60

        if unitPixelX < screenW / 2 then
            mx = screenW - Menu.width - 100
        else
            mx = 60
        end

        local menuOptions = {}

        if unit.isPlayer and Attack.canAttack(unit) then
            table.insert(menuOptions, { text = "Attack", callback = function()
                Effects.playConfirm()
                UnitManager.performAttackPrompt()
            end, playSound = false })
        end

        table.insert(menuOptions, { text = "Wait", callback = function()
            Effects.playConfirm()
            UnitManager.confirmMove()
        end })
        table.insert(menuOptions, { text = "Item", callback = function()
            Effects.playConfirm()
            UnitManager.showItemSelector()
        end })
        table.insert(menuOptions, { text = "Cancel", callback = function()
            Effects.playConfirm()
            UnitManager.state = "idle"
            Menu.hide()
        end })

        Menu.show(mx, my, menuOptions, 40)
    end

    function UnitManager.returnToWaitMenuFromWeaponSelect(unit)
        local resolvedUnit = unit or UnitManager.selectedUnit
        if not resolvedUnit then return end

        -- Check if the unit has moved
        local hasMoved = (resolvedUnit.tileX ~= resolvedUnit.prevX) or (resolvedUnit.tileY ~= resolvedUnit.prevY)

        if UnitManager.selectedUnit ~= resolvedUnit then
            UnitManager.selectedUnit = resolvedUnit
            if hasMoved then
                -- Only show attack range if unit has moved
                MovementRange.showAttackRange(resolvedUnit)
            else
                resolvedUnit:setSelected(true)
            end
        end

        UnitManager.state = "menu"
        UnitManager.showWaitMenu()
    end

    function UnitManager.showEndTurnMenu(tx, ty)
        UnitManager.state = "menu"
        local screenW = love.graphics.getWidth()

        local clickPixelX = tx * Grid.tileSize

        local mx
        local my = 60

        if clickPixelX < screenW / 2 then
            mx = screenW - Menu.width - 100
        else
            mx = 60
        end

        Menu.show(mx, my, {
            { text = "End All", callback = function()
                Effects.playConfirm()
                UnitManager.endPlayerTurn()
            end },
            { text = "Unit Stats", callback = function()
                local UnitStats = require("modules.ui.unit_stats")
                Effects.playConfirm()
                UnitManager.state = "idle"
                Menu.hide()
                UnitStats.show()
            end },
            { text = "Options", callback = function()
                Effects.playConfirm()
                UnitManager.state = "idle"
                Menu.hide()
                Options.show()
            end },
            { text = "Suspend", callback = function()
                Effects.playConfirm()
                Menu.hide()
                love.event.quit()
            end },
            { text = "Cancel", callback = function()
                Effects.playConfirm()
                UnitManager.state = "idle"
                Menu.hide()
            end }
        }, 40)
    end

    function UnitManager.showWeaponSelect(unit)
        if not unit then return end

        if UnitManager.selectedUnit ~= unit then
            UnitManager.selectedUnit = unit
            unit:setSelected(true)
        end

        UnitManager.state = "selectingWeapon"
        Menu.hide(true)

        WeaponSelect.show(unit, function(option)
            unit.weapon = option.id or unit.weapon
            UnitManager.beginAttackTargeting(unit)
        end, function()
            UnitManager.returnToWaitMenuFromWeaponSelect(unit)
        end)
    end

    function UnitManager.showItemSelector()
        local unit = UnitManager.selectedUnit
        if not unit then return end

        UnitManager.state = "selectingItem"
        Menu.hide(true)

        local ItemSelector = require("modules.ui.item_selector")
        ItemSelector.show(unit, function(option)
            if option.type == "weapon" then
                unit.weapon = option.id
                Effects.playConfirm()
                UnitManager.showItemSelector()
            elseif option.usable then
                Effects.playConfirm()
                UnitManager.returnToWaitMenuFromItemSelector(unit)
            else
                Effects.backPlay()
                UnitManager.showItemSelector()
            end
        end, function()
            UnitManager.returnToWaitMenuFromItemSelector(unit)
        end)
    end

    function UnitManager.returnToWaitMenuFromItemSelector(unit)
        local resolvedUnit = unit or UnitManager.selectedUnit
        if not resolvedUnit then return end

        -- Check if the unit has moved
        local hasMoved = (resolvedUnit.tileX ~= resolvedUnit.prevX) or (resolvedUnit.tileY ~= resolvedUnit.prevY)

        if UnitManager.selectedUnit ~= resolvedUnit then
            UnitManager.selectedUnit = resolvedUnit
            if hasMoved then
                -- Only show attack range if unit has moved
                MovementRange.showAttackRange(resolvedUnit)
            else
                resolvedUnit:setSelected(true)
            end
        else
            -- Unit is already selected but we need to refresh the ranges after weapon change
            if hasMoved then
                -- Only show attack range if unit has moved
                MovementRange.showAttackRange(resolvedUnit)
            else
                resolvedUnit:setSelected(false)
                resolvedUnit:setSelected(true)
            end
        end

        UnitManager.showWaitMenu()
    end
end

return attach
