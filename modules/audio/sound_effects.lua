-- modules/audio/sound_effects.lua
local Effects = {}
local Music = require("modules.audio.music")
local Sfx = require("modules.audio.sfx")

function Effects.load()
    Music.load()
    Sfx.load()
end

Effects.setMusicVolume = Music.setMusicVolume
Effects.setSFXVolume = Sfx.setSFXVolume
Effects.update = Music.update

Effects.playMainTheme = Music.playMainTheme
Effects.stopMainTheme = Music.stopMainTheme
Effects.pauseMainTheme = Music.pauseMainTheme
Effects.resumeMainTheme = Music.resumeMainTheme
Effects.playBattleTheme = Music.playBattleTheme
Effects.pauseBattleTheme = Music.pauseBattleTheme
Effects.fadeOutCurrentMusic = Music.fadeOutCurrentMusic
Effects.fadeInCurrentMusic = Music.fadeInCurrentMusic
Effects.transitionToBattleTheme = Music.transitionToBattleTheme
Effects.transitionToMainTheme = Music.transitionToMainTheme
Effects.checkTransition = Music.checkTransition

Effects.backPlay = Sfx.backPlay
Effects.playConfirm = Sfx.playConfirm
Effects.playNextTurn = Sfx.playNextTurn
Effects.playRunGrass = Sfx.playRunGrass
Effects.stopRunGrass = Sfx.stopRunGrass
Effects.playClick = Sfx.playClick
Effects.playSelect = Sfx.playSelect
Effects.playFlip = Sfx.playFlip
Effects.playMenuIn = Sfx.playMenuIn
Effects.playMenuOut = Sfx.playMenuOut
Effects.playAttackSwing = Sfx.playAttackSwing
Effects.playAttackHit = Sfx.playAttackHit
Effects.playAttackMiss = Sfx.playAttackMiss
Effects.playAttackCritical = Sfx.playAttackCritical
Effects.playDeathBell = Sfx.playDeathBell
Effects.playBowArrow = Sfx.playBowArrow

return Effects