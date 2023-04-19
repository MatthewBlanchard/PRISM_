local System = require("core.system")

local Projectile = System:extend()
Projectile.name = "Projectile"

function Projectile:process(level)
	while level:hasActorWithComponent(components.Projectile) do
		local to_remove = {}
		for actor, projectile_component in level:eachActor(components.Projectile) do
			level:moveActor(actor, actor.position + projectile_component.direction)
			projectile_component.traveled = projectile_component.traveled + 1

			local hit
			for other in level:eachActorAt(actor.position.x, actor.position.y) do
				if other:hasComponent(components.Stats) then
					hit = other
					break
				end
			end

			if hit then
				local damage = ROT.Dice.roll(projectile_component.damage)
				local damage_action = reactions.Damage(hit, actor, damage)
				level:performAction(damage_action)
				table.insert(to_remove, actor)
			elseif not level:getCellPassable(actor.position.x, actor.position.y) then
				projectile_component.direction = -projectile_component.direction
				projectile_component.bounce = projectile_component.bounce - 1
				if projectile_component.bounce < 0 then
					table.insert(to_remove, actor)
				end
			end

			if projectile_component.traveled > projectile_component.range then
				table.insert(to_remove, actor)
			end
		end

		level:yield("wait", 0.1)

		for _, actor in ipairs(to_remove) do
			level:removeActor(actor)
		end
	end
end

return Projectile
