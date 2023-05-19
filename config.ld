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
topics = "./build/ldoc/manual.md"
file={
    "./math/vector.lua",
	"./core/actor.lua",
    "./core/action.lua",
    "./core/cell.lua",
    "./core/component.lua",
    "./core/condition.lua",
    "./core/event.lua",
    "./core/reaction.lua",
    "./core/scheduler.lua",
    "./core/system.lua",
    "./core/target.lua",
}