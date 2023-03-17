local Actor = require "actor"
local Tiles = require "tiles"
local Condition = require "condition"

local onkill_messages = {
    "Well done, old sport! That's one less spider to ruin a perfectly good afternoon tea.",
    "Looks like that spider won't be spinning any more webs. Cheers to that!",
    "Smashing work! That spider had it coming for interrupting my afternoon nap.",
    "Jolly good show! That spider won't be bothering anyone anymore.",
    "My dear chap, I must say that was quite satisfying. I do loathe those wretched spiders.",
    "Well struck! That spider won't be crawling around anymore, bothering the fine folks of this... place.",
    "Brilliant work, my dear. That spider didn't stand a chance against us.",
    "Top-notch performance, if I may say so myself. That spider was no match for the likes of us.",
    "Excellent show! That spider won't be interrupting any more civilized gatherings, that's for sure.",
    "Well, I must say, that was rather satisfying. Nothing quite like ridding the world of those ghastly spiders.",
}

local onsee_messages = {
    "Oh my, it seems we have some uninvited guests. I'll make sure those spiders get a proper welcome.",
    "Looks like we have some spiders to deal with. I've got a score to settle with those eight-legged fiends.",
    "Oh bother, not spiders again. It's time to show them the true meaning of fear, my dear boy.",
    "I say, it's quite rude of those spiders to interrupt our little outing.",
    "Spiders. How dreadfully unbecoming. Let's put an end to their shenanigans, shall we?",
    "Goodness gracious, a spider. Fear not, my dear player, we shall dispatch it posthaste.",
    "A spider, my dear boy? How dreadfully unoriginal. Let us make it regret its existence.",
    "Oh my, what a ghastly creature. But fear not, we'll make sure it meets its end in style."
}

local SentientWeapon = Condition:extend()

SentientWeapon:afterAction(actions.Attack,
  function(self, level, actor, action)
    local effect_system = level:getSystem("Effects")

    local defender = action:getTarget(1)
    local faction_component = defender:getComponent(components.Faction)

    local defender_died = defender.HP <= 0
    if faction_component:has("arachnid") and action.hit and defender_died then
        local speak_effect = effects.SpeakEffect(
            actor,
            onkill_messages[math.random(1, #onkill_messages)],
            { 0.0, 1.0, 0.0, 1.0 }
        )

        effect_system:addEffect(speak_effect)
    end
  end
)

local SpidersBane = Actor:extend()
SpidersBane.char = Tiles["shortsword"]
SpidersBane.name = "Phinneas, Spider's Bane"

SpidersBane.components = {
    components.Item(),
    components.Light{
        color = { 1.0, 1.0, 1.0, 1},
        intensity = 1,
    }, 
    components.Weapon{
        stat = "ATK",
        name = "Shortsword",
        dice = "1d6",
        time = 75,
        effects = {
            SentientWeapon
        }
    }
}

return SpidersBane
