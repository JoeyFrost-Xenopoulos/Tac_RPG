-- modules/input.lua

Input = {}

function Input.update()
    local mx, my = love.mouse.getPosition()
    Game.hoveredTile = Grid.screenToGrid(mx, my)
end

function Input.mousepressed(x, y, button)
    local unit = Game.selectedUnit
    if unit and unit.isMoving then return end

    if button ~= 1 then return end
    if Turn.currentTeam ~= "player" then return end

    local tile = Grid.screenToGrid(x, y)
    if not tile then return end

    local unit = Game.selectedUnit

    -- PHASE: Attack
    if unit and (unit.phase == "ready" or unit.phase == "moved") and Game.attackTiles then
        for _, t in ipairs(Game.attackTiles) do
            if t.x == tile.x and t.y == tile.y then
                Combat.attack(unit, t.target)
                Turn.endUnitTurn(unit)
                Game.movementTiles = nil
                Game.attackTiles = nil
                return
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
        clickedUnit.phase = "ready"
        Game.selectedTile = nil
        Input.checkUnitTurn(clickedUnit)
    else
        -- Deselect
        Game.selectedUnit = nil
        Game.movementTiles = nil
        Game.attackTiles = nil
        Game.selectedTile = tile
    end

end

function Input.keypressed(key)
    if key == "space" and Game.selectedUnit and not Game.selectedUnit.hasActed then
        Turn.endUnitTurn(Game.selectedUnit)
        Game.selectedUnit = nil
        Game.movementTiles = nil
        Game.attackTiles = nil
    end
end

function Input.checkUnitTurn(unit)
    if not unit then return end

    -- Get attackable tiles
    local attacks = Combat.getAttackableTiles(unit)

    -- If no movement left AND no attacks possible, end turn automatically
    if unit.movePoints <= 0 and #attacks == 0 then
        Turn.endUnitTurn(unit)
        Game.movementTiles = nil
        Game.attackTiles = nil
    end
end