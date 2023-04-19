<<<<<<< HEAD
local Chunk = require "maps.chunk"

local snip_farm = Chunk:extend()
function snip_farm:parameters()
   self.width, self.height = 10, 10
=======
local Chunk = require("maps.chunk")

local snip_farm = Chunk:extend()
function snip_farm:parameters()
	self.width, self.height = 10, 10
end
function snip_farm:shaper(chunk)
	chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end
function snip_farm:shaper(chunk) chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1) end
function snip_farm:populater(chunk)
<<<<<<< HEAD
   local cx, cy = chunk:get_center()

   chunk:fill_perimeter(cx - 2, cy - 2, cx + 2, cy + 2)
   chunk:clear_cell(cx, cy + 2)

   local _, shopkeep_id = chunk:insert_actor("Shopkeep", cx, cy + 2)

   chunk:target_rect(
      cx - 1,
      cy - 1,
      cx + 1,
      cy + 1,
      function(x, y) chunk:insert_actor("Snip", x, y) end
   )
=======
	local cx, cy = chunk:get_center()

	chunk:fill_perimeter(cx - 2, cy - 2, cx + 2, cy + 2)
	chunk:clear_cell(cx, cy + 2)

	local _, shopkeep_id = chunk:insert_actor("Shopkeep", cx, cy + 2)

	chunk:target_rect(cx - 1, cy - 1, cx + 1, cy + 1, function(x, y)
		chunk:insert_actor("Snip", x, y)
	end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return snip_farm

-- local snip_farm = graph:new_node{
--   width = 10, height = 10,
--   shaper = function(params, chunk)
--     chunk:clear_rect(1,1, chunk.width-1, chunk.height-1)
--   end,
--   populater = function(params, chunk)
--     local cx, cy = math.floor(chunk.width/2)+1, math.floor(chunk.height/2)+1

--     chunk:fill_perimeter(cx-2, cy-2, cx+2, cy+2)
--     chunk:clear_cell(cx, cy+2)

--     local _, shopkeep_id = chunk:insert_actor('Shopkeep', cx, cy+2)

--     chunk:target_rect(cx-1, cy-1, cx+1, cy+1, function(x, y)
--         chunk:insert_actor('Snip', x, y)
--       end
--     )
--   end,
-- }
-- graph:add_node(snip_farm)
