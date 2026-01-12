-- modules/audio/music.lua

local Music = {}

Music.track = nil

function Music.load()
    Music.track = love.audio.newSource("sound/music/Raid!.mp3", "stream")
    Music.track:setLooping(true)  -- Loop the music
    Music.track:setVolume(0.35) 
end

function Music.play()
    if Music.track then
        love.audio.play(Music.track)
    end
end

function Music.stop()
    if Music.track then
        love.audio.stop(Music.track)
    end
end

return Music
