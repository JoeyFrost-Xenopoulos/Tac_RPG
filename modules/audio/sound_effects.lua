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

    Effects.battleTheme = love.audio.newSource("assets/audio/Battle_Theme.mp3", "stream")
    Effects.battleTheme:setLooping(true)
    Effects.battleTheme:setVolume(0.1)

    -- Fading system
    Effects.currentMusicVolume = 0.1
    Effects.targetMusicVolume = 0.1
    Effects.fadeSpeed = 0.3  -- volume units per second
    Effects.activeMusicTrack = nil

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

function Effects.update(dt)
    -- Update music fading
    if Effects.currentMusicVolume ~= Effects.targetMusicVolume then
        local diff = Effects.targetMusicVolume - Effects.currentMusicVolume
        local step = Effects.fadeSpeed * dt
        
        if math.abs(diff) <= step then
            Effects.currentMusicVolume = Effects.targetMusicVolume
        else
            Effects.currentMusicVolume = Effects.currentMusicVolume + (diff > 0 and step or -step)
        end
        
        -- Apply volume to active track
        if Effects.activeMusicTrack == "main" then
            Effects.mainTheme:setVolume(Effects.currentMusicVolume)
        elseif Effects.activeMusicTrack == "battle" then
            Effects.battleTheme:setVolume(Effects.currentMusicVolume)
        end
    end
end

function Effects.playMainTheme()
    if Effects.mainTheme:isPlaying() then return end
    Effects.activeMusicTrack = "main"
    Effects.currentMusicVolume = 0.1
    Effects.targetMusicVolume = 0.1
    Effects.mainTheme:setVolume(0.1)
    Effects.mainTheme:play()
end

function Effects.stopMainTheme()
    Effects.mainTheme:stop()
end

function Effects.pauseMainTheme()
    if Effects.mainTheme:isPlaying() then
        Effects.mainTheme:pause()
    end
end

function Effects.resumeMainTheme()
    if not Effects.mainTheme:isPlaying() then
        Effects.activeMusicTrack = "main"
        Effects.currentMusicVolume = 0
        Effects.targetMusicVolume = 0.1
        Effects.mainTheme:setVolume(0)
        Effects.mainTheme:play()
    end
end

function Effects.playBattleTheme()
    if not Effects.battleTheme:isPlaying() then
        Effects.activeMusicTrack = "battle"
        Effects.currentMusicVolume = 0
        Effects.targetMusicVolume = 0.1
        Effects.battleTheme:setVolume(0)
        Effects.battleTheme:play()
    end
end

function Effects.pauseBattleTheme()
    if Effects.battleTheme:isPlaying() then
        Effects.battleTheme:pause()
    end
end

function Effects.fadeOutCurrentMusic(callback)
    Effects.targetMusicVolume = 0
    Effects.fadeCallback = callback
end

function Effects.fadeInCurrentMusic()
    Effects.targetMusicVolume = 0.1
end

function Effects.transitionToBattleTheme()
    -- If already on battle theme, just ensure it's playing and faded in
    if Effects.activeMusicTrack == "battle" then
        if Effects.pendingTransition == "main" then
            -- Cancel transition to main, stay on battle
            Effects.pendingTransition = nil
            Effects.targetMusicVolume = 0.1
        end
        return
    end
    
    -- Fade out main theme and transition to battle
    Effects.targetMusicVolume = 0
    Effects.pendingTransition = "battle"
end

function Effects.transitionToMainTheme()
    -- If already on main theme, just ensure it's playing and faded in
    if Effects.activeMusicTrack == "main" then
        if Effects.pendingTransition == "battle" then
            -- Cancel transition to battle, stay on main
            Effects.pendingTransition = nil
            Effects.targetMusicVolume = 0.1
        end
        return
    end
    
    -- Fade out battle theme and transition to main
    Effects.targetMusicVolume = 0
    Effects.pendingTransition = "main"
end

function Effects.checkTransition()
    if Effects.pendingTransition and Effects.currentMusicVolume == 0 then
        if Effects.pendingTransition == "battle" then
            Effects.pauseMainTheme()
            Effects.playBattleTheme()
        elseif Effects.pendingTransition == "main" then
            Effects.pauseBattleTheme()
            Effects.resumeMainTheme()
        end
        Effects.pendingTransition = nil
    end
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

-- Called every frame to handle fading
Effects.update = function(dt)
    -- Update music fading
    if Effects.currentMusicVolume ~= Effects.targetMusicVolume then
        local diff = Effects.targetMusicVolume - Effects.currentMusicVolume
        local step = Effects.fadeSpeed * dt
        
        if math.abs(diff) <= step then
            Effects.currentMusicVolume = Effects.targetMusicVolume
        else
            Effects.currentMusicVolume = Effects.currentMusicVolume + (diff > 0 and step or -step)
        end
        
        -- Apply volume to active track
        if Effects.activeMusicTrack == "main" then
            Effects.mainTheme:setVolume(Effects.currentMusicVolume)
        elseif Effects.activeMusicTrack == "battle" then
            Effects.battleTheme:setVolume(Effects.currentMusicVolume)
        end
    end
    
    -- Check if we need to complete a transition
    Effects.checkTransition()
end

return Effects