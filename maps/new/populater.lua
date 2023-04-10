local function New(level, map)
  local entities_by_unique_id = {}
  local callback_queue = {}

  local function spawn_cell(cell, x, y, callback, unique_id)
    entities_by_unique_id[unique_id] = cell
    cell.position = {}
    cell.position.x = x + 1
    cell.position.y = y + 1

    if callback then
      local status = callback(cell, entities_by_unique_id)
      if status == 'Delay' then
        table.insert(callback_queue, function() callback(cell, entities_by_unique_id) end)
      end
    end
    level:setCell(x + 1, y + 1, cell)
  end
  
  local function spawn_actor(actor, x, y, callback, unique_id)  
    entities_by_unique_id[unique_id] = actor
    actor.position.x = x + 1
    actor.position.y = y + 1

    if callback then
      local status = callback(actor, entities_by_unique_id)
      if status == 'Delay' then
        table.insert(callback_queue, function() callback(actor, entities_by_unique_id) end)
      end
    end

    level:addActor(actor)
  end

  local function spawn_entities()
    for x, y, v in map.entities.sparsemap:each() do
      local id, unique_id, x, y, callback = v.id, v.unique_id, v.pos.x, v.pos.y, v.callback
      if cells[id] ~= nil then
        spawn_cell(cells[id](), x, y, callback, unique_id)
      elseif game[id] == nil then
        spawn_actor(actors[id](), x, y, callback, unique_id)
      else
        spawn_actor(game[id], x, y, callback, unique_id)
      end
    end
  end

  spawn_entities()

  for i, v in ipairs(callback_queue) do
    v()
  end

  return map
end

return New
