local Vector2 = require "math.vector"
local Grass = require "modules.core.cells.grass"

local function randDirection()
  local x = math.random(1, 3) - 2
  local y = math.random(1, 3) - 2

  while x == 0 and y == 0 do
    x = math.random(1, 3) - 2
    y = math.random(1, 3) - 2
  end

  return Vector2(x, y)
end

local function randDirectionCardinal()
  if math.random() > 0.5 then 
    return Vector2(0, math.random(1, 2) * 2 - 3)
  else
    return Vector2(math.random(1, 2) * 2 - 3, 0)
  end
end

local function getRandomWalkableAdjacent(level, x, y)
  local dir = randDirection()

  while not level:getCellPassable(x + dir.x, y + dir.y) do
    dir = randDirection()
  end

  local final = Vector2(x + dir.x, y + dir.y)

  return final
end

local function getRandomWalkableAdjacentCardinal(level, x, y)
  local dir = randDirectionCardinal()

  local tries = 0
  while not level:getCellPassable(x + dir.x, y + dir.y) do
    dir = randDirectionCardinal()
    tries = tries + 1
    if tries > 10 then
      return nil
    end
  end

  local final = Vector2(x + dir.x, y + dir.y)

  return final
end

function Populater(level, map)
  local spawnedPrism = false
  local treasureRoom = false
  local store = false
  local toSpawn = {}
  local roomsLeft = #map._rooms - 1 -- subtract the starting room
  local doors = {}
  local grassID = 0

  local function hash(x, y)
    return x and y * 0x4000000 + x or false --  26-bit x and y
  end

  local function spawnGrass(room)
    local x, y = room:getRandomWalkableTile()

    local grass = Grass()
    grass.grassID = grassID

    level:setCell(x, y, grass)

    local curCell = Vector2(x, y)
    for i = 1, math.random(6) do
      local adjacent = getRandomWalkableAdjacentCardinal(level, curCell.x, curCell.y)

      if not adjacent then break end

      local grass = Grass()
      grass.grassID = grassID
  
      level:setCell(adjacent.x, adjacent.y, grass)

      curCell = adjacent
    end

    grassID = grassID + 1
  end

  local function spawnActor(room, actor, x, y)
    local tries = 0
    repeat 
      local _x, _y = room:getRandomWalkableTile()
      x, y = x or _x, y or _y
      tries = tries + 1
    until level:getCellPassable(x, y) or tries > 10

    actor.position = Vector2(x, y)
    level:addActor(actor)
  end

  local function moveActorToRoom(room, actor)
    local x, y = room:getRandomWalkableTile()
    actor.position.x = x
    actor.position.y = y
  end

  local function spawnDoors(room)
    for _, x, y in room._doors:each() do
      if not doors[hash(x, y)] and math.random() > 0.50 then
        local door = actors.Door()
        door.position.x = x
        door.position.y = y

        level:addActor(door)
        doors[hash(x,y)] = true
      end
    end
  end

  local function spawnShards(room, i, j)
    for i = 1, love.math.random(i, j) do
      spawnActor(room, actors.Shard())
    end
  end

  local function spawnShrooms(room, i, j)
    for i = 1, love.math.random(i, j) do
      spawnActor(room, actors.Glowshroom_1())
    end
  end

  local function populateStartRoom(room)
    spawnDoors(room)
    spawnActor(room, game.Player)
    spawnActor(room, actors.Box())
    spawnActor(room, actors.Snip())
    spawnActor(room, actors.Gelatinous_cube())
    --spawnActor(room, actors.Lizbop())
    --spawnActor(room, actors.Webweaver())
    --spawnActor(room, actors.Gazer())
    spawnActor(room, actors.Rusty_shortsword())
  end

  local chestContents = {
    actors.Ring_of_protection,
    actors.Ring_of_vitality,
    actors.Cloak_of_invisibility,
    actors.Slippers_of_swiftness,
    actors.Wand_of_lethargy,
    actors.Wand_of_swapping,
    actors.Wand_of_fireball,
    actors.Wand_of_displacement,
    actors.Wand_of_lightning,
    actors.Dagger_of_venom,
    actors.Crystal_sword,
    actors.Lightning_blade,
    actors.Sword_of_wand_recovery
  }

  local function populateShopRoom(room)
    local shop = actors.Shopkeep()
    shop.position.x, shop.position.y = room:getCenterTile()
    shop.position.x = shop.position.x - 3
    level:addActor(shop)

    local torch = actors.Stationarytorch()
    torch.position.x, torch.position.y = shop.position.x, shop.position.y
    torch.position.x = shop.position.x - 1
    level:addActor(torch)

    local shopItems = {
      {
        components.Weapon,
        components.Wand
      },
      {
        components.Equipment
      },
      {
        components.Edible,
        components.Drinkable,
        components.Readable
      }
    }
    for i = 1, 3 do
      local itemTable =shopItems[i]
      local item = Loot.generateLoot(itemTable[love.math.random(1, #itemTable)])
      local product = actors.Product()
      product.position.x = shop.position.x + i*2
      product.position.y = shop.position.y

      local sellable_component = product:getComponent(components.Sellable)
      sellable_component:setItem(item)
      sellable_component:setPrice(actors.Shard, item:getComponent(components.Cost).cost)
      sellable_component:setShopkeep(shop)
      level:addActor(product)
    end
  end

  local function populateTreasureRoom(room)
    treasureRoom = true
    local locked = false

    if roomsLeft <= #toSpawn then
      locked = false
    elseif love.math.random() > .5 then
      locked = true
    end

    local chest = actors.Chest_lock_id()
    local key = actors.Key_id()

    local chest_inventory = chest:getComponent(components.Inventory)
    chest_inventory:addItem(chestContents[math.random(#chestContents)]())

    local chest_lock = chest:getComponent(components.Lock_id)
    chest_lock:setKey(key)
    
    spawnActor(room, chest)
    table.insert(toSpawn, key)

    spawnShards(room, 10, 12)
  end

  local function populateRoom(room)
    spawnGrass(room)
    
    if #room._doors == 2 and not treasureRoom then
      populateTreasureRoom(room)
      return
    end

    if not store and love.math.random(1, roomsLeft)/roomsLeft > 0.6 then
      store = true
      populateShopRoom(room)
      return
    end

    if roomsLeft <= #toSpawn and not (#toSpawn == 0) then
      local actor = table.remove(toSpawn, 1)
      spawnActor(room, actor)
      room.actors = room.actors or {}
      table.insert(room.actors, actor)
      return
    end

    if false then
      spawnShards(room, 2, 4)
      spawnShrooms(room, 0, 2)
      spawnActor(room, actors.Snip())
      spawnActor(room, actors.Snip())
      spawnActor(room, actors.Snip())
      return
    end

    spawnShards(room, 0, 2)
    spawnShrooms(room, 0, 2)
    spawnActor(room, actors.Sqeeto())
    spawnActor(room, actors.Gloop())
  end

  table.insert(toSpawn, actors.Prism())
  table.insert(toSpawn, actors.Stairs())
  table.insert(toSpawn, actors.Webweaver())
  table.insert(toSpawn, actors.Lizbop())
 --table.insert(toSpawn, actors.Stingboy())

  local startRoom = table.remove(map._rooms, love.math.random(1, #map._rooms))

  for _, room in ipairs(map._rooms) do
    roomsLeft = roomsLeft - 1
    populateRoom(room)
  end

  populateStartRoom(startRoom)
end

return Populater
