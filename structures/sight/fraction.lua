local Object = require("object")

Fraction = Object:extend()

function Fraction:__new(numerator, denominator)
<<<<<<< HEAD
   self.numerator = numerator
   self.denominator = denominator or 1
end

function Fraction:__tostring() return self.numerator .. "/" .. self.denominator end

function Fraction:to_number() return self.numerator / self.denominator end

function Fraction:__mul(other)
   if type(other) == "number" then
      return Fraction(self.numerator * other, self.denominator)
   else
      return Fraction(self.numerator * other.numerator, self.denominator * other.denominator)
   end
end

function Fraction.__eq(lhs, rhs)
   return lhs.numerator * rhs.denominator == lhs.denominator * rhs.numerator
end

function Fraction.__lt(lhs, rhs)
   return lhs.numerator * rhs.denominator < lhs.denominator * rhs.numerator
end

function Fraction.__le(lhs, rhs)
   return lhs.numerator * rhs.denominator <= lhs.denominator * rhs.numerator
end

function Fraction.__add(lhs, rhs)
   return Fraction(
      lhs.numerator * rhs.denominator + lhs.denominator * rhs.numerator,
      lhs.denominator * rhs.denominator
   )
end

function Fraction.__sub(lhs, rhs)
   return Fraction(
      lhs.numerator * rhs.denominator - lhs.denominator * rhs.numerator,
      lhs.denominator * rhs.denominator
   )
end

function Fraction:__unm() return Fraction(-self.numerator, self.denominator) end
=======
	self.numerator = numerator
	self.denominator = denominator or 1
end

function Fraction:__tostring()
	return self.numerator .. "/" .. self.denominator
end

function Fraction:to_number()
	return self.numerator / self.denominator
end

function Fraction:__mul(other)
	if type(other) == "number" then
		return Fraction(self.numerator * other, self.denominator)
	else
		return Fraction(self.numerator * other.numerator, self.denominator * other.denominator)
	end
end

function Fraction.__eq(lhs, rhs)
	return lhs.numerator * rhs.denominator == lhs.denominator * rhs.numerator
end

function Fraction.__lt(lhs, rhs)
	return lhs.numerator * rhs.denominator < lhs.denominator * rhs.numerator
end

function Fraction.__le(lhs, rhs)
	return lhs.numerator * rhs.denominator <= lhs.denominator * rhs.numerator
end

function Fraction.__add(lhs, rhs)
	return Fraction(
		lhs.numerator * rhs.denominator + lhs.denominator * rhs.numerator,
		lhs.denominator * rhs.denominator
	)
end

function Fraction.__sub(lhs, rhs)
	return Fraction(
		lhs.numerator * rhs.denominator - lhs.denominator * rhs.numerator,
		lhs.denominator * rhs.denominator
	)
end

function Fraction:__unm()
	return Fraction(-self.numerator, self.denominator)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Fraction
