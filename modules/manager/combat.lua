-- modules/manager/combat.lua
local function attach(UnitManager)
    local Attack = require("modules.engine.attack")
    local Menu = require("modules.ui.menu")
    local Grid = require("modules.ui.grid")
    local MovementRange = require("modules.engine.movement_range")
    local Effects = require("modules.audio.sound_effects")

    function UnitManager.performAttackPrompt()
        local unit = UnitManager.selectedUnit
        if not unit then return end

        local enemies = Attack.getEnemiesInRange(unit)
        if #enemies == 0 then
            Menu.hide()
            UnitManager.state = "idle"
            return
        end

        UnitManager.showWeaponSelect(unit)
    end

    function UnitManager.beginAttackTargeting(unit)
        if not unit then return end

        if UnitManager.selectedUnit ~= unit then
            UnitManager.selectedUnit = unit
            unit:setSelected(true)
        end

        local enemies = Attack.getEnemiesInRange(unit)
        if #enemies == 0 then
            UnitManager.state = "idle"
            return
        end

        UnitManager.state = "selectingAttack"
        MovementRange.clear()
        Grid.clearHighlights()

        for _, enemy in ipairs(enemies) do
            Grid.highlightTile(enemy.tileX, enemy.tileY, {1.0, 0.0, 0.0, 0.6})
        end
    end

    function UnitManager.performAttack(attacker, target)
        if not attacker or not target then return end

        if target.tileX > attacker.tileX then
            attacker.facingX = 1
        elseif target.tileX < attacker.tileX then
            attacker.facingX = -1
        end

        if attacker.tileX > target.tileX then
            target.facingX = 1
        elseif attacker.tileX < target.tileX then
            target.facingX = -1
        end

        Effects.playSelect()

        local CombatSummary = require("modules.ui.combat_summary")
        CombatSummary.show(attacker, target)

        UnitManager.battleAttacker = attacker
        UnitManager.battleTarget = target

        UnitManager.state = "combatSummary"
    end

    function UnitManager.returnToAttackSelection()
        local attacker = UnitManager.battleAttacker or UnitManager.selectedUnit
        if attacker then
            UnitManager.selectedUnit = attacker
            attacker:setSelected(true)
            UnitManager.performAttackPrompt()
        else
            UnitManager.deselectAll()
        end
    end
end

return attach
