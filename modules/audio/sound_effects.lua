-- modulues.audio.sound_effects
local Effects = {}

function Effects.load()
    Effects.menuIn   = love.audio.newSource("assets/audio/Menu_In.wav", "static")
    Effects.menuOut  = love.audio.newSource("assets/audio/Menu_Out.wav", "static")
    Effects.click    = love.audio.newSource("assets/audio/Click.wav", "static")
    Effects.select   = love.audio.newSource("assets/audio/Select.wav", "static")
    Effects.runGrass = love.audio.newSource("assets/audio/Running_In_Grass.wav", "static")
    Effects.runGrass:setLooping(true)

    Effects.back = love.audio.newSource("assets/audio/Back.wav", "static")
    Effects.confirm = love.audio.newSource("assets/audio/Confirmation.wav", "static")
    Effects.attackSwing = love.audio.newSource("assets/audio/combat/Attack_1.wav", "static")
    Effects.attackHit = love.audio.newSource("assets/audio/combat/Attack_Hit_1.wav", "static")

    Effects.mainTheme = love.audio.newSource("assets/audio/Main_Theme.mp3", "stream")
    Effects.mainTheme:setLooping(true)
    Effects.mainTheme:setVolume(0.1)

    Effects.baseVolumes = {
        menuIn   = 1.0,
        menuOut  = 1.0,
        click    = 1.0,
        select   = 0.05,
        runGrass = 1.0,
        back     = 1.0,
        confirm  = 1.0,
        attackSwing = 0.8,
        attackHit = 0.8
    }

    -- Apply default SFX volume immediately
    Effects.setSFXVolume(0.6)
end

function Effects.setMusicVolume(v)
    if Effects.mainTheme then
        Effects.mainTheme:setVolume(v * 0.1)
    end
end

function Effects.setSFXVolume(v)
    local sfx = {
        menuIn   = Effects.menuIn,
        menuOut  = Effects.menuOut,
        click    = Effects.click,
        select   = Effects.select,
        runGrass = Effects.runGrass,
        back     = Effects.back,
        confirm  = Effects.confirm,
        attackSwing = Effects.attackSwing,
        attackHit = Effects.attackHit
    }

    for name, src in pairs(sfx) do
        if src then
            local base = Effects.baseVolumes[name] or 1
            src:setVolume(v * base)
        end
    end
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

function Effects.playAttackSwing()
    if Effects.attackSwing then
        Effects.attackSwing:stop()
        Effects.attackSwing:play()
    end
end

function Effects.playAttackHit()
    if Effects.attackHit then
        Effects.attackHit:stop()
        Effects.attackHit:play()
    end
end

return Effects