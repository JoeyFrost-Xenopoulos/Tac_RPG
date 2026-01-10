-- modules/turn.lua

Turn = {
    currentTeam = "player",
    round = 1
}

function Turn.start()
    Turn.currentTeam = "player"
    Turn.round = 1
    Turn.resetTeam("player")
end

function Turn.resetTeam(team)
    for _, unit in ipairs(Units.list) do
        if unit.team == team then
            unit.hasActed = false
            unit.movePoints = unit.move
            unit.phase = "ready"
        end
    end
end

function Turn.endUnitTurn(unit)
    unit.hasActed = true
    Game.selectedUnit = nil
    Game.movementTiles = nil

    Turn.checkEndOfTeam()
end

function Turn.checkEndOfTeam()
    for _, unit in ipairs(Units.list) do
        if unit.team == Turn.currentTeam and not unit.hasActed then
            return
        end
    end

    Turn.endTeamTurn()
end

function Turn.endTeamTurn()
    if Turn.currentTeam == "player" then
        Turn.currentTeam = "enemy"
        Turn.resetTeam("enemy")
    else
        Turn.currentTeam = "player"
        Turn.round = Turn.round + 1
        Turn.resetTeam("player")
    end
end

function Turn.updateEnemyTurn()
    if Turn.currentTeam ~= "enemy" then return end

    for _, enemy in ipairs(Units.list) do
        if enemy.team == "enemy" and not enemy.hasActed then
            Turn.processEnemy(enemy)
            return
        end
    end
end

function Turn.processEnemy(enemy)
    local target = Turn.findClosestPlayer(enemy)

    if target then
        local tiles = Movement.getReachableTiles(enemy)
        local bestTile = nil
        local bestDist = math.huge

        for _, tile in ipairs(tiles) do
            local dist =
                math.abs(tile.x - target.x) +
                math.abs(tile.y - target.y)

            if dist < bestDist then
                bestDist = dist
                bestTile = tile
            end
        end

        if bestTile then
            Movement.moveUnit(enemy, bestTile.x, bestTile.y)
        end

        -- Attack if possible
        local attacks = Combat.getAttackableTiles(enemy)
        if #attacks > 0 then
            Combat.attack(enemy, attacks[1].target)
        end
    end

    Turn.endUnitTurn(enemy)
end

function Turn.findClosestPlayer(enemy)
    local closest = nil
    local bestDist = math.huge

    for _, unit in ipairs(Units.list) do
        if unit.team == "player" then
            local dist =
                math.abs(unit.x - enemy.x) +
                math.abs(unit.y - enemy.y)

            if dist < bestDist then
                bestDist = dist
                closest = unit
            end
        end
    end

    return closest
end
