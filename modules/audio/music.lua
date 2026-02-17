-- modules/audio/music.lua
local Music = {}

function Music.load()
    Music.mainTheme = love.audio.newSource("assets/audio/themes/Main_Theme.mp3", "stream")
    Music.mainTheme:setLooping(false)
    Music.mainTheme:setVolume(0.1)

    Music.overworld2 = love.audio.newSource("assets/audio/themes/Overworld_2.mp3", "stream")
    Music.overworld2:setLooping(false)
    Music.overworld2:setVolume(0.1)

    Music.battleTheme = love.audio.newSource("assets/audio/themes/battle_theme.mp3", "stream")
    Music.battleTheme:setLooping(true)
    Music.battleTheme:setVolume(0.1)

    -- Fading system (normalized 0..1, scaled by musicMaxVolume)
    Music.musicMaxVolume = 0.1
    Music.currentMusicVolume = 1
    Music.targetMusicVolume = 1
    Music.fadeSpeed = 0.8  -- volume units per second
    Music.activeMusicTrack = nil
    Music.pendingTransition = nil
    Music.fadeCallback = nil
    
    -- Music queue for cycling main theme and overworld_2
    Music.musicQueue = {"main", "overworld2"}
    Music.currentQueueIndex = 1
end

function Music.setMusicVolume(v)
    Music.musicMaxVolume = (v or 1) * 0.1

    if Music.activeMusicTrack == "main" and Music.mainTheme then
        Music.mainTheme:setVolume(Music.currentMusicVolume * Music.musicMaxVolume)
    elseif Music.activeMusicTrack == "battle" and Music.battleTheme then
        Music.battleTheme:setVolume(Music.currentMusicVolume * Music.musicMaxVolume)
    end

    if Music.pendingTransition == "battle" and Music.battleTheme then
        Music.battleTheme:setVolume((1 - Music.currentMusicVolume) * Music.musicMaxVolume)
    elseif Music.pendingTransition == "main" and Music.mainTheme then
        Music.mainTheme:setVolume((1 - Music.currentMusicVolume) * Music.musicMaxVolume)
    end
end

function Music.update(dt)
    if Music.currentMusicVolume ~= Music.targetMusicVolume then
        local diff = Music.targetMusicVolume - Music.currentMusicVolume
        local step = Music.fadeSpeed * dt

        if math.abs(diff) <= step then
            Music.currentMusicVolume = Music.targetMusicVolume
        else
            Music.currentMusicVolume = Music.currentMusicVolume + (diff > 0 and step or -step)
        end
    end

    if Music.activeMusicTrack == "main" and Music.mainTheme then
        Music.mainTheme:setVolume(Music.currentMusicVolume * Music.musicMaxVolume)
        if Music.pendingTransition == "battle" and Music.battleTheme then
            Music.battleTheme:setVolume((1 - Music.currentMusicVolume) * Music.musicMaxVolume)
        end
    elseif Music.activeMusicTrack == "overworld2" and Music.overworld2 then
        Music.overworld2:setVolume(Music.currentMusicVolume * Music.musicMaxVolume)
    elseif Music.activeMusicTrack == "battle" and Music.battleTheme then
        Music.battleTheme:setVolume(Music.currentMusicVolume * Music.musicMaxVolume)
        if Music.pendingTransition == "main" and Music.mainTheme then
            Music.mainTheme:setVolume((1 - Music.currentMusicVolume) * Music.musicMaxVolume)
        end
    end

    Music.checkTransition()
    Music.checkMusicQueue()

    if Music.fadeCallback and Music.currentMusicVolume == 0 then
        local cb = Music.fadeCallback
        Music.fadeCallback = nil
        cb()
    end
end

function Music.playMainTheme()
    if not Music.mainTheme or Music.mainTheme:isPlaying() then return end
    Music.activeMusicTrack = "main"
    Music.currentMusicVolume = 1
    Music.targetMusicVolume = 1
    Music.mainTheme:setVolume(Music.musicMaxVolume)
    Music.mainTheme:play()
    Music.currentQueueIndex = 1  -- Start queue cycle
end

function Music.stopMainTheme()
    if Music.mainTheme then
        Music.mainTheme:stop()
    end
end

function Music.pauseMainTheme()
    if Music.mainTheme and Music.mainTheme:isPlaying() then
        Music.mainTheme:pause()
    end
end

function Music.resumeMainTheme()
    if Music.mainTheme and not Music.mainTheme:isPlaying() then
        Music.activeMusicTrack = "main"
        Music.currentMusicVolume = 0
        Music.targetMusicVolume = 1
        Music.mainTheme:setVolume(0)
        Music.mainTheme:play()
    end
end

function Music.playBattleTheme()
    if Music.battleTheme and not Music.battleTheme:isPlaying() then
        Music.activeMusicTrack = "battle"
        Music.currentMusicVolume = 0
        Music.targetMusicVolume = 1
        Music.battleTheme:setVolume(0)
        Music.battleTheme:play()
    end
end

function Music.pauseBattleTheme()
    if Music.battleTheme and Music.battleTheme:isPlaying() then
        Music.battleTheme:pause()
    end
end

function Music.fadeOutCurrentMusic(callback)
    Music.targetMusicVolume = 0
    Music.fadeCallback = callback
end

function Music.fadeInCurrentMusic()
    Music.targetMusicVolume = 1
end

function Music.transitionToBattleTheme()
    if Music.activeMusicTrack == "battle" then
        if Music.pendingTransition == "main" then
            Music.pendingTransition = nil
            Music.targetMusicVolume = 1
        end
        return
    end

    if Music.battleTheme then
        if not Music.battleTheme:isPlaying() then
            Music.battleTheme:setVolume(0)
            Music.battleTheme:play()
        else
            Music.battleTheme:setVolume(0)
        end
    end

    Music.targetMusicVolume = 0
    Music.pendingTransition = "battle"
end

function Music.transitionToMainTheme()
    if Music.activeMusicTrack == "main" then
        if Music.pendingTransition == "battle" then
            Music.pendingTransition = nil
            Music.targetMusicVolume = 1
        end
        return
    end

    if Music.mainTheme then
        if not Music.mainTheme:isPlaying() then
            Music.mainTheme:setVolume(0)
            Music.mainTheme:play()
        else
            Music.mainTheme:setVolume(0)
        end
    end

    Music.targetMusicVolume = 0
    Music.pendingTransition = "main"
end

function Music.checkTransition()
    if Music.pendingTransition and Music.currentMusicVolume == 0 then
        if Music.pendingTransition == "battle" then
            Music.pauseMainTheme()
            Music.activeMusicTrack = "battle"
            if Music.battleTheme then
                Music.battleTheme:setVolume(Music.musicMaxVolume)
            end
        elseif Music.pendingTransition == "main" then
            Music.pauseBattleTheme()
            Music.activeMusicTrack = "main"
            if Music.mainTheme then
                Music.mainTheme:setVolume(Music.musicMaxVolume)
            end
        end
        Music.currentMusicVolume = 1
        Music.targetMusicVolume = 1
        Music.pendingTransition = nil
    end
end

function Music.checkMusicQueue()
    -- Check if current track has finished and queue the next one
    if Music.activeMusicTrack == "main" and Music.mainTheme and not Music.mainTheme:isPlaying() then
        -- Main theme finished, play overworld2
        Music.currentQueueIndex = 2
        if Music.overworld2 then
            Music.activeMusicTrack = "overworld2"
            Music.overworld2:setVolume(Music.musicMaxVolume)
            Music.overworld2:play()
        end
    elseif Music.activeMusicTrack == "overworld2" and Music.overworld2 and not Music.overworld2:isPlaying() then
        -- Overworld2 finished, loop back to main theme
        Music.currentQueueIndex = 1
        if Music.mainTheme then
            Music.activeMusicTrack = "main"
            Music.mainTheme:setVolume(Music.musicMaxVolume)
            Music.mainTheme:play()
        end
    end
end

return Music
