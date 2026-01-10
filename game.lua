-- game.lua

Game = {
    state = "battle",
    grid = {},
    hoveredTile = nil,
    selectedTile = nil,
    selectedUnit = nil,
    movementTiles = nil,
    attackTiles = nil
}

Game.flashTimer = 0