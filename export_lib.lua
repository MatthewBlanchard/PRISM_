-- A simple prelude library to export a bunch of libs to the global namespace.

require 'lib.safe_require'

-- TODO: Refactor this! We need a World object that holds all of the loaded actors, actions, etc. and the current level.
ROT = require 'lib.rot.rot'
MusicManager = require "music.musicmanager"
Actor = require "core.actor"

require "lib.batteries":export()