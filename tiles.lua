local json = require 'lib.json'
local atlas = love.filesystem.read('display/atlas.json')

local tile_mapping = json.decode(atlas)
local auto_tiles = {}
for k, v in pairs(tile_mapping.regions) do
	if v.idx >= 256 then
		auto_tiles[v.name] = v.idx
	end
end

local tiles = {
	arrow_down = 291,

	bubble_exclamation = 293,
	bubble_question = 294,
	bubble_sleep = 295,
	bubble_lines = 296,
	bubble_ellipsis = 297,
	bubble_heart = 298,
	bubble_stun = 299,
	bubble_sad = 300,
	bubble_food = 301,
	bubble_music = 302,
	bubble_angry = 303,

	axe = 343,
	armor = 354,
	arrow = 378,
	barrel = 281,
	belt = 370,
	bomb = 360,
	bow = 336,
	steak = 338,
	cleaver = 339,

	box = 265,
	projectile1 = 266,
	projectile2 = 267,
	projectile3 = 268,
	grass = 269,
	boots = 372,
	cloak = 357,
	chest = 276,
	chest_open = 277,
	chest_large = 278,
	chest_large_open = 279,
	glowshroom = 282,
	stationarytorch = 283,
	web = 284,
	dagger = 359,
	floor = 261,
	gloves = 373,
	gobbo = 357,
	golem = 309,
	heal = 289,
	key = 369,
	pants = 374,
	parsnip = 368,
	inivs_player = 305,
	fink = 306,
	gazer = 305,
	pointy_poof = 290,
	potion = 353,
	poof = 288,
	pot = 280,
	rat = 306,
	ring = 356,
	scroll = 361,
	shard = 362,
	shoes = 376,
	shortsword = 358,
	shop = 310,
	gloop = 311,
	spider = 312,
	snip = 313,
	lizbop = 314,

	stairs_up = 274,
	stairs_down = 275,
	wall = 256,
	wand = 355,
	wand_pointy = 371,
	wand_gnarly = 377,
	zombie = 305,

	rocks_1 = 262,
	rocks_2 = 263,
	rocks_3 = 264,

	b_top_left_corner = 315,
	b_top_left = 316,
	b_top_middle = 334,
	b_top_right = 318,
	b_top_right_corner = 319,
	b_left_top = 331,
	b_left_middle = 332,
	b_left_bottom = 363,
	b_left_bottom_corner = 379,
	b_bottom_left = 380,
	b_bottom_middle = 364,
	b_bottom_right = 382,
	b_bottom_right_corner = 383,
	b_right_bottom = 367,
	b_right_top = 335,
	b_right_middle = 366
}

local tablex = require 'lib.batteries.tablex'
tablex.overlay(tiles, auto_tiles)

return tiles
