local Color = {}

<<<<<<< HEAD
function Color.mul(c, s) return { c[1] * s, c[2] * s, c[3] * s } end

function Color.lerp(start, finish, t)
   local c = {}
   for i = 1, 4 do
      if not start[i] or not finish[i] then break end
      c[i] = (1 - t) * start[i] + t * finish[i]
   end

   return c
=======
function Color.mul(c, s)
	return { c[1] * s, c[2] * s, c[3] * s }
end

function Color.lerp(start, finish, t)
	local c = {}
	for i = 1, 4 do
		if not start[i] or not finish[i] then
			break
		end
		c[i] = (1 - t) * start[i] + t * finish[i]
	end

	return c
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Color
