-- modulues.audio.sound_effects
local Effects = {}

function Effects.load()
    Effects.menuIn   = love.audio.newSource("assets/audio/Menu_In.wav", "static")
    Effects.menuOut  = love.audio.newSource("assets/audio/Menu_Out.wav", "static")
    Effects.click    = love.audio.newSource("assets/audio/Click.wav", "static")

    Effects.runGrass = love.audio.newSource("assets/audio/Running_In_Grass.wav", "static")
    Effects.runGrass:setLooping(true)
end

function Effects.playRunGrass()
    if Effects.runGrass:isPlaying() then return end
    Effects.runGrass:setPitch(0.95 + love.math.random() * 0.1)
    Effects.runGrass:play()
end

function Effects.stopRunGrass()
    Effects.runGrass:stop()
end

function Effects.playClick()
    Effects.click:stop()
    Effects.click:play()
end

function Effects.playMenuIn()
    Effects.menuIn:stop()
    Effects.menuIn:play()
end

function Effects.playMenuOut()
    Effects.menuOut:stop()
    Effects.menuOut:play()
end

return Effects