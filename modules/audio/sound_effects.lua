-- modulues.audio.sound_effects
local Effects = {}

function Effects.load()
    Effects.menuIn   = love.audio.newSource("assets/audio/Menu_In.wav", "static")
    Effects.menuOut  = love.audio.newSource("assets/audio/Menu_Out.wav", "static")
    Effects.click    = love.audio.newSource("assets/audio/Click.wav", "static")
    Effects.select   = love.audio.newSource("assets/audio/Select.wav", "static")
    Effects.select:setVolume(0.1)
    Effects.runGrass = love.audio.newSource("assets/audio/Running_In_Grass.wav", "static")
    Effects.runGrass:setLooping(true)

    Effects.back = love.audio.newSource("assets/audio/Back.wav", "static")
    Effects.confirm = love.audio.newSource("assets/audio/Confirmation.wav", "static")

    Effects.mainTheme = love.audio.newSource("assets/audio/Main_Theme.mp3", "stream")
    Effects.mainTheme:setLooping(true)
    Effects.mainTheme:setVolume(0.1)
end

function Effects.playMainTheme()
    if Effects.mainTheme:isPlaying() then return end
    Effects.mainTheme:play()
end

function Effects.stopMainTheme()
    Effects.mainTheme:stop()
end

function Effects.backPlay()
    Effects.back:stop()
    Effects.back:play()
end

function Effects.playConfirm()
    Effects.confirm:setPitch(0.9)
    Effects.confirm:stop()
    Effects.confirm:play()
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

function Effects.playSelect()
    if Effects.select then
        Effects.select:stop()
        Effects.select:play()
    end
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