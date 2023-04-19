local Component = require("core.component")

local Wallet = Component:extend()
Wallet.name = "wallet"

function Wallet:__new(options)
<<<<<<< HEAD
   self.wallet = {}
   self.autoPick = options.autoPick
end

function Wallet:initialize(actor)
   if self.autoPick then actor:applyCondition(conditions.Autopickup()) end
end

function Wallet:deposit(currency, amount)
   if not self.wallet[currency] then self.wallet[currency] = 0 end
   self.wallet[currency] = self.wallet[currency] + amount
end

function Wallet:hasAmount(currency, amount)
   if not self.wallet[currency] then return nil end
   return self.wallet[currency] >= amount
end

function Wallet:withdraw(currency, amount)
   if self:hasAmount(currency, amount) then
      self.wallet[currency] = self.wallet[currency] - amount
      return true
   else
      return nil
   end
=======
	self.wallet = {}
	self.autoPick = options.autoPick
end

function Wallet:initialize(actor)
	if self.autoPick then
		actor:applyCondition(conditions.Autopickup())
	end
end

function Wallet:deposit(currency, amount)
	if not self.wallet[currency] then
		self.wallet[currency] = 0
	end
	self.wallet[currency] = self.wallet[currency] + amount
end

function Wallet:hasAmount(currency, amount)
	if not self.wallet[currency] then
		return nil
	end
	return self.wallet[currency] >= amount
end

function Wallet:withdraw(currency, amount)
	if self:hasAmount(currency, amount) then
		self.wallet[currency] = self.wallet[currency] - amount
		return true
	else
		return nil
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Wallet
