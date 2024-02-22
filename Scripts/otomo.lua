---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by arciesis.
--- DateTime: 2/22/24 5:17 PM
---
local OtomoUniqueId = require("otomoUniqueId")

--- @module PalDpsMeter.otomo
local otomo = {}

-- TODO: Make a damage class with the stuff needed I think
--- @class Otomo
--- @field characterID string
--- @field slotInParty number
--- @field uid OtomoUniqueId
--- @field damageTaken number
--- @field damageInflicted number
--- @type Otomo
local Otomo = {}

--- Internal tostring
--- @return string the representation of the data
function Otomo:__tostring()
   local damageTaken = self:getDamageTaken()
   local damageInflicted = self:getDamageInflicted()

   if damageTaken == -1 then
      damageTaken = 0
   end

   if damageInflicted == -1 then
      damageInflicted = 0
   end

   local uniqueId = self:getUid()
   --if not uniqueId then
   --   return (
   --         string.format(
   --               "Name: %s,\t slotIndex: %i,\t damageTaken: %i,\t damageInflicted: %i,\t %s",
   --               "emptySlot",
   --               0,
   --               0,
   --               0,
   --               0
   --         )
   --   )
   --end
   local uidStr = uniqueId:ToString()

   return (
         string.format(
               "Name: %s,\t slotIndex: %i,\t damageTaken: %i,\t damageInflicted: %i,\t %s",
               self:getCharacterID(),
               self:getSlotInParty(),
               damageTaken,
               damageInflicted,
               uidStr
         )
   )
end

--- ToString method
--@return string str the representation of the data
function Otomo:ToString()
   return self:__tostring()
end

--- Getter of the class for
--@return string characterID The ID of the otomo (e.g. teh species)
function Otomo:getCharacterID()
   return self.characterID
end

--- Getter
--@return number slotInParty the
function Otomo:getSlotInParty()
   return self.slotInParty
end

--- Getter
--@return OtomoUniqueId uid the guid of the otomo
function Otomo:getUid()
   return self.uid
end

---@return number damageTaken the damage taken by that otomo during a fight
function Otomo:getDamageTaken()
   return self.damageTaken
end

---@return number damageInflicted the damage inflicted by that otomo during a fight
function Otomo:getDamageInflicted()
   return self.damageInflicted
end

-- function Otomo:setCharacterID(newCharacterID)
--     self.characterID = newCharacterID
-- end

-- function Otomo:setSlotInParty(newSlotInParty)
--     self.slotInParty = newSlotInParty
-- end

--- Setter of damageTaken
---@param newDamageTaken number the new amount of damage taken by that otomo during a fight
function Otomo:setDamageTaken(newDamageTaken)
   self.damageTaken = newDamageTaken
end

--- setter of damageInflicted
---@param newDamageInflicted number the new amount of damage inflicted by that otomo during a fight
function Otomo:setDamageInflicted(newDamageInflicted)
   self.damageInflicted = newDamageInflicted
end

--- Return if the two otomos are the same
---@param otherOtomo Otomo
---@return boolean isSame Return true if they are the sme and false otherwise
function Otomo:isSame(otherOtomo)
   local otherUniqueId = otherOtomo:getUid()
   return (self:getUid():isEqual(otherUniqueId))
end

--- Constructor like for the class
--- @param characterID string @characterID represent The pal name in the datatables
--- @param slotInParty number @slotInParty represent the slot in the party (Beginning at 0)
--- @param uid OtomoUniqueId The Unique id of the otomo (Aka an address of its ID in the game)
--- @param damageTaken number|nil @damageTaken represent the amount of real damage it has taken during a fight
--- @param damageInflicted number|nil @damageInflicted represent the real amount of damage the it has inflicted
function otomo.new(characterID, slotInParty, uid, damageTaken, damageInflicted)
   local self = {}
   setmetatable(self, { __index = Otomo })

   self.characterID = characterID
   self.slotInParty = slotInParty
   self.uid = uid
   self.damageTaken = damageTaken or -1
   self.damageInflicted = damageInflicted or -1

   return self
end

return otomo