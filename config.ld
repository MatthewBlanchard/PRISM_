-- Configuration file for Luadoc API generation
project="PRISM"
title="PRISM roguelike engine documentation"
format="markdown"
style="./build/ldoc"
dir="./docs"
sort=true
merge=true
no_space_before_args=true
not_luadoc=true
file={
    "./math/vector.lua",
	"./core/actor.lua",
    "./core/action.lua",
}