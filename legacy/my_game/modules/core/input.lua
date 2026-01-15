-- modules/input.lua

Input = {}

local lastHoveredTile = nil

function Input.update()
    local mx, my = love.mouse.getPosition()
    local tile = Grid.screenToGrid(mx, my)
    Game.hoveredTile = tile

    if tile then
        if not lastHoveredTile or lastHoveredTile.x ~= tile.x or lastHoveredTile.y ~= tile.y then
            Effects.cursor((tile.x - 1) * TILE_SIZE, (tile.y - 1) * TILE_SIZE)
            lastHoveredTile = {x = tile.x, y = tile.y}
        end
    else
        lastHoveredTile = nil
        Effects.cursorEffect = nil
    end
end

function Input.mousepressed(x, y, button)
    local unit = Game.selectedUnit
    if unit and unit.isMoving then return end

    if button ~= 1 then return end
    if Turn.currentTeam ~= "player" then return end

    local tile = Grid.screenToGrid(x, y)
    if not tile then return end

    local unit = Game.selectedUnit

    -- PHASE: Heal
    if unit and unit.class == "Mage"
    and (unit.phase == "ready" or unit.phase == "moved")
    and Game.healTiles then
        for _, t in ipairs(Game.healTiles) do
            if t.x == tile.x and t.y == tile.y then
                Combat.heal(unit, t.target)
                Game.movementTiles = nil
                Game.attackTiles = nil
                Game.healTiles = nil
                return
            end
        end
    end
    
    -- PHASE: Attack
    if unit and (unit.phase == "ready" or unit.phase == "moved") and Game.attackTiles then
        for _, t in ipairs(Game.attackTiles) do
            if t.x == tile.x and t.y == tile.y then

                -- If unit is a Soldier, open weapon menu
                if unit.class == "Soldier" then
                    WeaponSelector.open(unit, t.target)
                    return  -- wait for weapon selection
                else
                    Combat.attack(unit, t.target)
                    Turn.endUnitTurn(unit)
                    Game.movementTiles = nil
                    Game.attackTiles = nil
                    return
                end
            end
        end
    end

    -- PHASE: Movement
    if unit and (unit.phase == "ready" or unit.phase == "moved") and Game.movementTiles then
        for _, t in ipairs(Game.movementTiles) do
            if t.x == tile.x and t.y == tile.y then
                    local moved = Movement.moveUnit(unit, tile.x, tile.y)
                    if moved then
                        unit.phase = "moved"
                        Game.movementTiles = nil 
                        Game.attackTiles = nil
                    end
                    return
                end
        end
    end

    -- PHASE: Selecting a unit
    local clickedUnit = Units.getAt(tile.x, tile.y)
    if clickedUnit and clickedUnit.team == "player" and not clickedUnit.hasActed then
        Game.selectedUnit = clickedUnit
        Game.movementTiles = Movement.getReachableTiles(clickedUnit)
        Game.attackTiles = Combat.getAttackableTiles(clickedUnit)

        if clickedUnit.class == "Mage" then
            Game.healTiles = Combat.getHealableTiles(clickedUnit)
        else
            Game.healTiles = nil
        end

        clickedUnit.phase = "ready"
        Game.selectedTile = nil
        Input.checkUnitTurn(clickedUnit)
    else
        -- Deselect
        Game.selectedUnit = nil
        Game.movementTiles = nil
        Game.attackTiles = nil
        Game.selectedTile = tile
        Game.healTiles = nil
    end

end

function Input.keypressed(key)
    if key == "space" and Game.selectedUnit and not Game.selectedUnit.hasActed then
        Turn.endUnitTurn(Game.selectedUnit)
        Game.selectedUnit = nil
        Game.movementTiles = nil
        Game.attackTiles = nil
        Game.healTiles = nil
    end

    if WeaponSelector.active then
        WeaponSelector.keypressed(key)
        return
    end
end

function Input.checkUnitTurn(unit)
    if not unit then return end

    if unit.class ~= "Mage" then
        local attacks = Combat.getAttackableTiles(unit)
        if unit.movePoints <= 0 and #attacks == 0 then
            Turn.endUnitTurn(unit)
            Game.movementTiles = nil
            Game.attackTiles = nil
        end
    else
        local attacks = Combat.getAttackableTiles(unit)
        local heals = Combat.getHealableTiles(unit)
        if unit.movePoints <= 0 and #attacks == 0 and #heals == 0 then
            Turn.endUnitTurn(unit)
            Game.movementTiles = nil
            Game.attackTiles = nil
            Game.healTiles = nil
        end
    end
end
