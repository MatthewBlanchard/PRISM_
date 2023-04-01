local function New(level, map)
  local actors_by_unique_id = {}
  local callback_queue = {}
  
  local function spawn_actor(actor, x, y, callback, unique_id)  
    actors_by_unique_id[unique_id] = actor
    actor.position.x = x + 1
    actor.position.y = y + 1

    if callback then
      local status = callback(actor, actors_by_unique_id)
      if status == 'Delay' then
        table.insert(callback_queue, function() callback(actor, actors_by_unique_id) end)
      end
    end

    level:addActor(actor)
  end

  local function spawn_actors()
    for i, v in ipairs(map.actors.list) do
      local id, unique_id, x, y, callback = v.id, v.unique_id, v.pos.x, v.pos.y, v.callback
      if game[id] == nil then
        spawn_actor(actors[id](), x, y, callback, unique_id)
      else
        spawn_actor(game[id], x, y, callback, unique_id)
      end
    end
  end

  spawn_actors()

  for i, v in ipairs(callback_queue) do
    v()
  end

  return map
end

return New
