---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by arciesis.
--- DateTime: 2/22/24 5:19 PM
---
local PartyTeamClass = require("partyTeam")
local OtomoUniqueIdClass = require("otomoUniqueId")
local OtomoClass = require("otomo")

--- @module PalDpsMeter.player
local player = {}

--- My player is not really a player but a game really but its okay
---@class Player The Subject of the observer pattern
---@field team PartyTeam
---@field observers table
local Player = {}

---@return PartyTeam team the team of the player
function Player:getTeam()
   return self.team
end

---@param team PartyTeam
function Player:setTeam(team)
   self._team = team
end

-- FIXME: need to be on the PartyTeam class
--- Test if the team is empty or not
---@return boolean bool true if the team is empty and false otherwise
function Player:isTeamEmpty()
   local actualTeam = self:getTeam()
   return not actualTeam
end

--- Update all the team by a new one
---@param newPartyTeam PartyTeam
---@param outOtomoSlotIndex number
function Player:updateAllTeam(newPartyTeam, outOtomoSlotIndex)
   self:setTeam(newPartyTeam)
   newPartyTeam:setNbOtomoCurrentlyInTeam(#newPartyTeam)
   newPartyTeam:setCurrentlyOutOtomo(outOtomoSlotIndex)
end

--- update the team of the player
--- @param newPartyTeam PartyTeam the new PartTeam
--- @param outOtomoSlotIndex number the slot index of thrown out otomo
--- @public
function Player:updateTeam(newPartyTeam, outOtomoSlotIndex)
   if self:isTeamEmpty() then
      self:updateAllTeam(newPartyTeam, outOtomoSlotIndex)
   else
      -- test if only a few have changed and update them
      local modifiedOtomos = self:getTeam():getModifiedOtomos(newPartyTeam)

      -- used with the recursive version of the function which is not implemented
      -- swappedOtomos = Player.getRecursiveSwappedOtomos(newPartyTeam:getMembers(),
      --     oldPartyTeam:getMembers(), constants.MIN_PER_TEAM,
      --     constants.MAX_PER_TEAM, {})

      if not modifiedOtomos[1] then
         -- Not nil then swap the otomos as needed
         -- What I got => oldTeam, newTeam and NotSwappedOtomos from oldTeam
         for _, otomo in ipairs(modifiedOtomos) do
            self:getTeam():updateOtomoByOtomo(otomo)
         end
         -- return to leave the function
         return
      end

      -- if nil then it's a complete different team and we need to modify it all
      self:updateAllTeam(newPartyTeam, outOtomoSlotIndex)
   end
end

--- Hook function that retrieve the Team of a player
function Player:retrievePartyMemberHook()
   RegisterHook(
         "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:ActivateOtomo",
         function(component, slotID, StartTransform, isSuccess)
            if not isSuccess then
               return
            end

            local otomos = {}

            local HolderComponent = component:get()
            local slots = HolderComponent.CharacterContainer.SlotArray

            slots:ForEach(function(index, elem)
               local slot = elem:get()
               local isEmpty = slot:isEmpty()

               if not isEmpty then
                  local handle = slot:GetHandle()
                  local otomoIndividualParameter = handle:TryGetIndividualParameter()
                  local otomoID = otomoIndividualParameter:GetCharacterID()

                  --In game FPalInstanceID representation: Guid: InstanceId / Guid: PlayerUId / Guid: DebugName
                  local Id = otomoIndividualParameter.IndividualId
                  print(tostring(index))
                  local otomoUid = OtomoUniqueIdClass.new(Id:GetStructAddress())
                  local tmpOtomo = OtomoClass.new(otomoID:ToString(), index, otomoUid, 0, 0)
                  table.insert(otomos, tmpOtomo)
               end
            end)

            local foundTeam = PartyTeamClass.new(otomos)

            print(foundTeam:ToString())
            --
            --self:updateTeam(foundTeam, slotID:get() + 1)
            --print(self:getTeam():ToString())

            --print(tostring(self))
         end
   )
end

--- Constructor
--- @return table the table representing the object Player
function player.new()
   local self = {}
   setmetatable(self, { __index = Player })

   -- create an empty team
   self.team = PartyTeamClass.new({})
   return self
end

return player