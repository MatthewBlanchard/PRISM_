local Action = require "core.action"

local targetProduct = targets.Actor:extend()

function targetProduct:validate(owner, actor) return actor:is(actors.Product) end

local Buy = Action:extend()
Buy.name = "buy"
Buy.targets = { targetProduct }

function Buy:__new(owner, targets)
   Action.__new(self, owner, targets)
   self.product = self:getTarget(1)
   self.price = self.product.price
end

function Buy:perform(level)
   local wallet_component = self.owner:getComponent(components.Wallet)
   local sellable_component = self.product:getComponent(components.Sellable)
   local effects_system = level:getSystem "Effects"

   assert(sellable_component, "Product is not a Sellable!")

   if
      wallet_component
      and wallet_component:withdraw(sellable_component.currency, sellable_component.price)
   then
      local buyer_inventory_component = self.owner:getComponent(components.Inventory)
      buyer_inventory_component:addItem(sellable_component.item)
      level:removeActor(self.product)

      if sellable_component.shopkeep then
         effects_system:addEffect(level, sellable_component.soldEffect())
      end
   elseif sellable_component.shopkeep then
      effects_system:addEffect(level, sellable_component.notSoldEffect())
   end
end

return Buy
