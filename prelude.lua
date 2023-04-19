-- A simple prelude library to export a bunch of libs to the global namespace.

<<<<<<< HEAD
require "lib.safe_require"

-- TODO: Refactor this! We need a World object that holds all of the loaded actors, actions, etc. and the current level.
ROT = require "lib.rot.rot"
MusicManager = require "music.musicmanager"
Actor = require "core.actor"
profiler = require "lib.profile"
=======
require("lib.safe_require")

-- TODO: Refactor this! We need a World object that holds all of the loaded actors, actions, etc. and the current level.
ROT = require("lib.rot.rot")
MusicManager = require("music.musicmanager")
Actor = require("core.actor")
profiler = require("lib.profile")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

require("lib.batteries"):export()
