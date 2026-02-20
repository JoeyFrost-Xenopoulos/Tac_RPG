-- modules/audio/sfx.lua
local Sfx = {}

function Sfx.load()
    Sfx.menuIn   = love.audio.newSource("assets/audio/Menu_In.wav", "static")
    Sfx.menuOut  = love.audio.newSource("assets/audio/Menu_Out.wav", "static")
    Sfx.click    = love.audio.newSource("assets/audio/Click.wav", "static")
    Sfx.select   = love.audio.newSource("assets/audio/Select.wav", "static")
    Sfx.flip     = love.audio.newSource("assets/audio/Flip.ogg", "static")
    Sfx.runGrass = love.audio.newSource("assets/audio/Running_In_Grass.wav", "static")
    Sfx.runGrass:setLooping(true)

    Sfx.back = love.audio.newSource("assets/audio/Back.wav", "static")
    Sfx.confirm = love.audio.newSource("assets/audio/Confirmation.wav", "static")
    Sfx.nextTurn = love.audio.newSource("assets/audio/Next_Turn.wav", "static")
    Sfx.attackSwing = love.audio.newSource("assets/audio/combat/Attack_1.wav", "static")
    Sfx.attackHit = love.audio.newSource("assets/audio/combat/Attack_Hit_1.wav", "static")
    Sfx.attackMiss = love.audio.newSource("assets/audio/combat/Attack_Miss_1.wav", "static")
    Sfx.criticalHit = love.audio.newSource("assets/audio/combat/Critical_Hit_1.wav", "static")
    Sfx.deathBell = love.audio.newSource("assets/audio/combat/Death_Bell.wav", "static")
    Sfx.bowArrow = love.audio.newSource("assets/audio/combat/bow_arrow.mp3", "static")
    Sfx.harpoonThrow = love.audio.newSource("assets/audio/combat/harpoon_throw.mp3", "static")

    Sfx.baseVolumes = {
        menuIn   = 1.0,
        menuOut  = 1.0,
        click    = 1.0,
        select   = 0.05,
        flip     = 1.0,
        runGrass = 1.0,
        back     = 1.0,
        confirm  = 1.0,
        nextTurn = 1.0,
        attackSwing = 0.8,
        attackHit = 0.8,
        attackMiss = 0.8,
        criticalHit = 0.8,
        deathBell = 0.9,
        bowArrow = 0.85,
        harpoonThrow = 0.85
    }

    Sfx.setSFXVolume(0.6)
end

function Sfx.setSFXVolume(v)
    local sources = {
        menuIn   = Sfx.menuIn,
        menuOut  = Sfx.menuOut,
        click    = Sfx.click,
        select   = Sfx.select,
        flip     = Sfx.flip,
        runGrass = Sfx.runGrass,
        back     = Sfx.back,
        confirm  = Sfx.confirm,
        nextTurn = Sfx.nextTurn,
        attackSwing = Sfx.attackSwing,
        attackHit = Sfx.attackHit,
        attackMiss = Sfx.attackMiss,
        criticalHit = Sfx.criticalHit,
        deathBell = Sfx.deathBell,
        bowArrow = Sfx.bowArrow,
        harpoonThrow = Sfx.harpoonThrow
    }

    for name, src in pairs(sources) do
        if src then
            local base = Sfx.baseVolumes[name] or 1
            src:setVolume(v * base)
        end
    end
end

function Sfx.backPlay()
    if Sfx.back then
        Sfx.back:stop()
        Sfx.back:play()
    end
end

function Sfx.playConfirm()
    if Sfx.confirm then
        Sfx.confirm:setPitch(0.9)
        Sfx.confirm:stop()
        Sfx.confirm:play()
    end
end

function Sfx.playNextTurn()
    if Sfx.nextTurn then
        Sfx.nextTurn:stop()
        Sfx.nextTurn:play()
    end
end

function Sfx.playRunGrass()
    if not Sfx.runGrass or Sfx.runGrass:isPlaying() then return end
    Sfx.runGrass:setPitch(0.95 + love.math.random() * 0.1)
    Sfx.runGrass:play()
end

function Sfx.stopRunGrass()
    if Sfx.runGrass then
        Sfx.runGrass:stop()
    end
end

function Sfx.playClick()
    if Sfx.click then
        Sfx.click:stop()
        Sfx.click:play()
    end
end

function Sfx.playSelect()
    if Sfx.select then
        Sfx.select:stop()
        Sfx.select:play()
    end
end

function Sfx.playFlip()
    if Sfx.flip then
        Sfx.flip:stop()
        Sfx.flip:play()
    end
end

function Sfx.playMenuIn()
    if Sfx.menuIn then
        Sfx.menuIn:stop()
        Sfx.menuIn:play()
    end
end

function Sfx.playMenuOut()
    if Sfx.menuOut then
        Sfx.menuOut:stop()
        Sfx.menuOut:play()
    end
end

function Sfx.playAttackSwing()
    if Sfx.attackSwing then
        Sfx.attackSwing:stop()
        Sfx.attackSwing:play()
    end
end

function Sfx.playAttackHit()
    if Sfx.attackHit then
        Sfx.attackHit:stop()
        Sfx.attackHit:play()
    end
end

function Sfx.playAttackMiss()
    if Sfx.attackMiss then
        Sfx.attackMiss:stop()
        Sfx.attackMiss:play()
    end
end

function Sfx.playAttackCritical()
    if Sfx.criticalHit then
        Sfx.criticalHit:stop()
        Sfx.criticalHit:play()
    end
end

function Sfx.playDeathBell()
    if Sfx.deathBell then
        Sfx.deathBell:stop()
        Sfx.deathBell:play()
    end
end

function Sfx.playBowArrow()
    if Sfx.bowArrow then
        Sfx.bowArrow:stop()
        Sfx.bowArrow:play()
    end
end

function Sfx.playHarpoonThrow()
    if Sfx.harpoonThrow then
        Sfx.harpoonThrow:stop()
        Sfx.harpoonThrow:play()
    end
end

return Sfx
