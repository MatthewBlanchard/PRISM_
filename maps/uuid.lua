local id_generator_index = 0

local id_generator = function()
  id_generator_index = id_generator_index + 1
  return id_generator_index
end

return id_generator