-- modules/turn.lua

Turn = {
    currentTeam = "player",
    round = 1,
    activeEnemy = nil -- Define it inside the table
}

function Turn.start()
    Turn.currentTeam = "player"
    Turn.round = 1
    Turn.activeEnemy = nil
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
    unit.phase = "finished"
    Game.selectedUnit = nil
    Game.movementTiles = nil
    Game.attackTiles = nil

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
        Turn.activeEnemy = nil
        Turn.resetTeam("enemy")
    else
        Turn.currentTeam = "player"
        Turn.round = Turn.round + 1
        Turn.resetTeam("player")
    end
end

function Turn.updateEnemyTurn()
    if Turn.currentTeam ~= "enemy" then return end

    if not Turn.activeEnemy then
        for _, enemy in ipairs(Units.list) do
            if enemy.team == "enemy" and not enemy.hasActed then
                Turn.activeEnemy = enemy
                enemy.phase = "deciding"
                return
            end
        end
    end

    if Turn.activeEnemy then
        local enemy = Turn.activeEnemy

        if enemy.isMoving then return end

        if enemy.phase == "deciding" then
            Turn.enemyDecideMove(enemy)
        elseif enemy.phase == "moved" then
            Turn.enemyDecideAttack(enemy)
        end
    end
end

function Turn.enemyDecideMove(enemy)
    local target = Turn.findClosestPlayer(enemy)

    if target then
        local tiles = Movement.getReachableTiles(enemy)
        local bestTile = nil
        local bestDist = math.huge

        for _, tile in ipairs(tiles) do
            local dist = math.abs(tile.x - target.x) + math.abs(tile.y - target.y)
            if dist < bestDist then
                bestDist = dist
                bestTile = tile
            end
        end

        if bestTile then
            Movement.moveUnit(enemy, bestTile.x, bestTile.y)
        end
    end
    
    enemy.phase = "moved"
end

function Turn.enemyDecideAttack(enemy)
    local attacks = Combat.getAttackableTiles(enemy)
    
    if #attacks > 0 then
        Combat.attack(enemy, attacks[1].target)
    end
    Turn.activeEnemy = nil 
    Turn.endUnitTurn(enemy)
end

function Turn.findClosestPlayer(enemy)
    local closest = nil
    local bestDist = math.huge

    for _, unit in ipairs(Units.list) do
        if unit.team == "player" then
            local dist = math.abs(unit.x - enemy.x) + math.abs(unit.y - enemy.y)
            if dist < bestDist then
                bestDist = dist
                closest = unit
            end
        end
    end

    return closest
end