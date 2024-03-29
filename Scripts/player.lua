---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by arciesis.
--- DateTime: 2/22/24 5:19 PM
---
local party_team = require("partyTeam")
local otomo_unique_id = require("otomoUniqueId")
local otomo = require("otomo")

--- @module PalDpsMeter.player
local player = {}

--- My player is not really a player but a game really but its okay
---@class Player The Subject of the observer pattern
---@field team PartyTeam
local Player = {}

---@return PartyTeam team the team of the player
function Player:get_team()
   return self.team
end

---@param team PartyTeam
function Player:set_team(team)
   self.team = team
end

-- FIXME: need to be on the PartyTeam class
--- Test if the team is empty or not
---@return boolean bool true if the team is empty and false otherwise
function Player:is_team_empty()
   local actual_team = self:get_team()
   return not actual_team
end

--- Update all the team by a new one
---@param new_party_team PartyTeam
---@param out_otomo_slot_index number
function Player:update_all_team(new_party_team, out_otomo_slot_index)
   self:set_team(new_party_team)
   new_party_team:set_nb_otomos(#new_party_team)
   new_party_team:set_currently_out_otomo(out_otomo_slot_index)
end

--- update the team of the player
--- @param new_party_team PartyTeam the new PartTeam
--- @param out_otomo_slot_index number the slot index of thrown out otomo
--- @public
function Player:update_team(new_party_team, out_otomo_slot_index)
   if self:is_team_empty() then
      self:update_all_team(new_party_team, out_otomo_slot_index)
   else
      -- test if only a few have changed and update them
      local modified_otomos = self:get_team():get_modified_otomos(new_party_team)

      -- used with the recursive version of the function which is not implemented
      -- swappedOtomos = Player.getRecursiveSwappedOtomos(newPartyTeam:getMembers(),
      --     oldPartyTeam:getMembers(), constants.MIN_PER_TEAM,
      --     constants.MAX_PER_TEAM, {})

      if not modified_otomos[1] then
         -- Not nil then swap the otomos as needed
         -- What I got => oldTeam, newTeam and NotSwappedOtomos from oldTeam
         for _, an_otomo in ipairs(modified_otomos) do
            self:get_team():update_otomo_by_otomo(an_otomo)
         end
         -- return to leave the function
         return
      end

      -- if nil then it's a complete different team and we need to modify it all
      self:update_all_team(new_party_team, out_otomo_slot_index)
   end
end

--- Hook function that retrieve the Team of a player
function Player:retrieve_party_members_hook()
   RegisterHook(
         "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:ActivateOtomo",
         function(component, slot_index, transform, is_success)
            if not is_success then
               return
            end

            local otomos = {}

            local holder_component = component:get()
            local slots = holder_component.CharacterContainer.SlotArray

            slots:ForEach(function(index, elem)
               local slot = elem:get()
               local is_empty = slot:isEmpty()

               if not is_empty then
                  local handle = slot:GetHandle()
                  local otomo_individual_parameter = handle:TryGetIndividualParameter()
                  local otomo_id = otomo_individual_parameter:GetCharacterID()

                  --In game FPalInstanceID representation: Guid: InstanceId / Guid: PlayerUId / Guid: DebugName
                  local indeividual_id = otomo_individual_parameter.IndividualId
                  print(tostring(index))
                  local an_otomo_unique_id = otomo_unique_id.new(indeividual_id:GetStructAddress())
                  local tmp_otomo = otomo.new(otomo_id:ToString(), index, an_otomo_unique_id, 0, 0)
                  table.insert(otomos, tmp_otomo)
               end
            end)

            local found_team = party_team.new(otomos)

            print(found_team:ToString())
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
   self.team = party_team.new({})
   return self
end

return player