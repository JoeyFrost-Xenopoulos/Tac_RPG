local Interaction = {}

function Interaction.init(self) end

function Interaction.isHovered(self, mx, my)
    local px = (self.tileX - 1) * self.tileSize
    local py = (self.tileY - 1) * self.tileSize
    return mx >= px and mx < px + self.tileSize and my >= py and my < py + self.tileSize
end

Interaction.isClicked = Interaction.isHovered

return Interaction
