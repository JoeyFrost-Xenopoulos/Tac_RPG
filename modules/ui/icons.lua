-- modules/ui/icons.lua
local Icons = {}

function Icons.getWeaponIcons()
    if not Icons.weaponIcons then
        Icons.weaponIcons = {}
        Icons.weaponIcons.sword = love.graphics.newImage("assets/ui/icons/sword.png")
        Icons.weaponIcons.sword:setFilter("nearest", "nearest")
        Icons.weaponIcons.harpoon = love.graphics.newImage("assets/ui/icons/harpoon.png")
        Icons.weaponIcons.harpoon:setFilter("nearest", "nearest")
        Icons.weaponIcons.bow = love.graphics.newImage("assets/ui/icons/bow.png")
        Icons.weaponIcons.bow:setFilter("nearest", "nearest")
        Icons.weaponIcons.fire = love.graphics.newImage("assets/ui/icons/fire_book.png")
        Icons.weaponIcons.fire:setFilter("nearest", "nearest")
        Icons.weaponIcons.ice = love.graphics.newImage("assets/ui/icons/ice_book.png")
        Icons.weaponIcons.ice:setFilter("nearest", "nearest")
        Icons.weaponIcons.thunder = love.graphics.newImage("assets/ui/icons/ice_book.png")
        Icons.weaponIcons.thunder:setFilter("nearest", "nearest")
    end
    return Icons.weaponIcons
end

return Icons
