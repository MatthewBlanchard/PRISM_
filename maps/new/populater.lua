local function New(level, map)
  local function spawn_actor(actor, x, y)
    local x, y = x or _x, y or _y
    actor.position.x = x
    actor.position.y = y
    level:addActor(actor)
  end

  local function spawn_actors()
    for i, v in ipairs(map.actors.list) do
      local id, x, y = v.id, v.pos.x, v.pos.y
      if game[id] == nil then
        spawn_actor(actors[id](), x, y)
      else
        spawn_actor(game[id], x, y)
      end
    end
  end

  local function draw_heat_map()
    for i, v in ipairs(heat_map.map) do
      for i2, v2 in ipairs(v) do
        if v2 ~= 999 then
          local color_modifier = v2*5
          local custom = {
            color = {
              math.max(0, (255-color_modifier)/255),
              0/255,
              math.max(0, (0+color_modifier)/255),
              1
            }
          }
          local coloredtile = actors.Coloredtile(custom)
          spawn_actor(coloredtile, i, i2)
        end
      end
    end
  end

  --draw_heat_map()

  spawn_actors()
  --spawn_actor(game['Player'], 10, 10)

  return map
end

return New
