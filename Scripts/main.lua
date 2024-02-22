-- RegisterHook(FunctionName, Callback)
-- FunctionName => function name from UE4SS
-- Callback => our function callback
print("[PalDpsMeter] Pal DPS Meter has started!")
print(_VERSION)
-- RegisterHook(FunctionName, Callback)
-- FunctionName => function name from UE4SS
-- Callback => our function callback

-- RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()

-- end)

-- NotifyOnNewObject("", function(self, )

-- end)

-- More simple way to write a function with RegisterHook or NotifyOnNewObject:
-- local function complicatedFunction(self)
-- some stuff
-- end
-- RegisterHook("/some/function:theFunction", complicatedFunction)

-- otomo.GetBattleMode

local Config = require("config")
local EventName = require("eventName")
local OtomoUniqueId = require("otomoUniqueId")
local Otomo = require("Otomo")
local PartyTeam = require("partyTeam")
local PlayerClass = require("player")
--##################################################--
--################### Constants ####################--
--##################################################--
--##################################################--
--##################### Utils ######################--
--##################################################--

-- gender
-- memory addr of GUID
-- passive skill list
-- PalUtility.GetPassiveSkillManager
--

--##################################################--
--################### Listeners ####################--
--##################################################--

-- ---Intercept when the Otomo is swapped or throw in
-- ---@param otomo string the nickname of the otomo in the datatables
-- ---@param slotID number the number of the slot of the Otomo, start at 0
-- local function onSwapOtomoOut(otomo, slotID)
--     if not otomo then
--         print("[PalDpsMeter] no otomo is out")
--         return
--     end

--     if not slotID then
--         print("[PalDpsMeter] no SlotID found")
--         return
--     end

--     if (LAST_OTOMO_OUT and LAST_SLOT_ID == -1) then
--         print("[PalDPSMeter] Something went wrong!")
--         return
--     end

--     if ((not LAST_OTOMO_OUT) and LAST_SLOT_ID ~= -1) then
--         print("[PalDPSMeter] Something went wrong!")
--         return
--     end

--     if (LAST_OTOMO_OUT ~= otomo and LAST_SLOT_ID == slotID) then
--         -- TODO : Do something about that !!!
--         LAST_OTOMO_OUT = nil
--         LAST_SLOT_ID = -1
--         print("[PalDpsMeter] Otomo team has been modified ?")
--         return
--     end

--     --if this is the first throw in since the load of the save
--     if (not LAST_OTOMO_OUT) and LAST_SLOT_ID == -1 then
--         LAST_OTOMO_OUT = otomo
--         LAST_SLOT_ID = slotID
--         print("[PalDpsMeter] first throw in since login in")
--         -- TODO: Do something with that
--     end

--     -- if the otomos ids differ and the slot differ too (Most use case)
--     if (LAST_OTOMO_OUT ~= otomo and LAST_SLOT_ID ~= slotID) then
--         LAST_OTOMO_OUT = otomo
--         LAST_SLOT_ID = slotID
--         print("[PalDpsMeter] Otomo has been swapped")
--     end
--     -- TODO: finish all the cases, I may need The swapIn function
-- end

--local function onSwapOtomoIn()
--    -- TODO: Do something with that
--    print("[PalDPsMeter] Deactivation of the otomo")
--end

-- Intercept when the battle mode is swapping
-- ---@param mode boolean true if the battle mode is ON and false otherwise
--local function onBattleSwap(mode)
--    if (not LAST_BATTLE_MODE) and mode then
--        -- if the mode swap to ON
--        print("[PalDpsMeter] Mode switching to ON starting the analytics")
--    elseif LAST_BATTLE_MODE and (not mode) then
--        -- if the mode swap to OFF
--        print("[PalDpsMeter] Mode switching to OFF ending the analytics")
--    elseif LAST_BATTLE_MODE and mode then
--        -- should not happened, both values are the same
--        print("[PalDpsMeter] Error in battle mode both are to ON")
--    else
--        -- idem
--        print("[PalDpsMeter] Error in battle mode both are to OFF")
--    end
--end

--##################################################--
--################## Classes like ##################--
--##################################################--

-- TODO : Some refacto to do for making the code style linear

-- ---@class AObserver a abstract-ish class for observer object
-- local AObserver = {}

-- --- To instantiate the required function
-- ---@return any newObject the newly created object
-- function AObserver:new()
--     local newObject = setmetatable({}, self)
--     self.__index = self
--     return newObject
-- end

-- ---@param listener function the callback function
-- function AObserver:registerUpdateListener(listener)
--     self.triggerUpdate = listener
-- end

-- function AObserver:processUpdate()
--     self:triggerUpdate()
-- end

----- Representation of a Guid each number is 32bit long which give a us 128 bit
-----@class Guid
-----@field A number
-----@field B number
-----@field C number
-----@field D number
--local Guid = {}
--
-----Constructor of the class
-----@param A number
-----@param B number
-----@param C number
-----@param D number
-----@public
--function Guid:new(A, B, C, D)
--   local guid = {}
--   guid = setmetatable(guid, self)
--   self.__index = self
--
--   self._A = A
--   self._B = B
--   self._C = C
--   self._D = D
--
--   return guid
--end
--
----- A field Getter
-----@return number A
--function Guid:getA()
--   return self._A
--end
--
----- B field Getter
-----@return number B
--function Guid:getB()
--   return self._B
--end
--
----- C field Getter
-----@return number C
--function Guid:getC()
--   return self._C
--end
--
----- D field Getter
-----@return number D
--function Guid:getD()
--   return self._D
--end
--
----- return a string representing the @Guid
-----@private
--function Guid:__tostring()
--   local guidStr = ""
--   guidStr = string.format(
--         "A: %d,\t B: %d,\t C: %d,\t D: %d",
--         self:getA(),
--         self:getB(),
--         self:getC(),
--         self:getD()
--   )
--   return guidStr
--end
--
----- Return a string representing the data inside the @Guid
-----@return string str
-----@public
--function Guid:ToString()
--   return self:__tostring()
--end
--
----- Return true if self is equal to the @otherGuid and false otherwise
-----@param otherGuid Guid the other @Guid to test
-----@return boolean isEqual
--function Guid:isEqual(otherGuid)
--   if
--   self:getA() == otherGuid:getA()
--         and self:getB() == otherGuid:getB()
--         and self:getC() == otherGuid:getC()
--         and self:getD() == otherGuid:getD()
--   then
--      return true
--   else
--      return false
--   end
--end





--- Intercept when an otomo is throwing out and do what is necessary
--function PartyTeam:onActivateOtomo()
--   local outOtomo = self:getCurrentlyOutOtomo()
--   if outOtomo == -1 then
--      print("[PalDpsMeter] No Otomo is out for now")
--      return
--   end
--
--   self:updateCurrentlyOutOtomo(newSlotID)
--   -- TODO : Do some stuff later when the code will be more advanced
--end

--- FIXME:


--##################################################--
--################### Registers ####################--
--##################################################--

-- Event.Register(onSwapOtomoOut, eventName.onActivateOtomo)
-- Event.Register(onBattleSwap, eventName.onBattleSwapMode)
-- Event.Register(onSwapOtomoIn, eventName.onInactivateCurrentOtomo)
-- Event.Register(getPartyMember, eventName.getPartyMember)

--##################################################--
--##################### Hooks ######################--
--##################################################--

-- Retrieve the Otomo that is out, get executed each time another is out
-- @return string | nil OtomoCharacterID return the string of the characterID if found and nil otherwise
--local function ActiveOtomo()
--    local activeOtomo = nil
--    RegisterHook(
--        "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:ActivateOtomo",
--        function(_, SlotID, StartTransform, isSuccess)
--            if not isSuccess then
--                return
--            end
--            local slotID = SlotID:get()
--            print(string.format("[PalDpsMeter] The slot id of the Otomo is : %d", slotID))
--
--            local HolderComponent = OtomoUniqueId:get()
--            local otomoCharacter = HolderComponent:TryGetOtomoActorBySlotIndex(slotID)
--            local OtomoParameterComponent = otomoCharacter.CharacterParameterComponent
--            local OtomoIndividualParameter = OtomoParameterComponent:GetIndividualParameter()
--            activeOtomo = OtomoIndividualParameter:GetCharacterID()
--
--            print(string.format("[PalDpsMeter] The out Otomo is: %s of slot %d", activeOtomo:ToString(), slotID))
--            -- return OtomoCharacterID:ToString()
--            Event.Trigger("on_swap_otomo", activeOtomo:ToString(), slotID)
--        end)
--end

--- Only retrieve the moment a player deactivate his otomo
-- FIXME it needs to be on the observer feature
--local function InactivateCurrentOtomo()
--    RegisterHook(
--        "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:InactivateCurrentOtomo",
--        function(self)
--            Event.Trigger(eventName.onInactivateCurrentOtomo)
--        end)
--end
--
--local function getPartyMember()
--    RegisterHook("/Script/Pal.PalPlayerPartyPalHolder:GetPartyMember", function(self, OutPartyMember)
--    end)
--end

-- Is being trigger only when battle mode is ON
-- local function whenBattleModeIsOn()
--     local preIdIsBattleMode, postIdIsBattleMode = RegisterHook("/Script/Pal.PalAICombatModule:IsBattleMode",
--         function(self, value)
--             if value then
--                 print("[PalDpsMeter] Battle mode is ON")
--                 Event.Trigger("on_battle_swap_mode", true)
--             else
--                 print("[PalDpsMeter] Battle mode is OFF")
--                 Event.Trigger("on_battle_swap_mode", false)
--             end
--         end)
-- end

--##################################################--
--##################### Main #######################--
--##################################################--

--- @type Player
local player = PlayerClass.new()

ExecuteAsync(function()
   local HUDService = FindFirstOf("PalHUDService")

   if HUDService ~= nil and HUDService:IsValid() then
      -- retrieveActiveOtomo()
      -- retrieveInactivateOtomo()
      -- whenBattleModeIsOn()
      player:retrievePartyMemberHook()

      return
   end

   -- don't really know what is the purpose of this, most likely for the server part
   NotifyOnNewObject("/Script/Pal.PalHUDService", function()
      -- retrieveActiveOtomo()
      -- retrieveInactivateOtomo()
      -- whenBattleModeIsOn()
      --player:retrievePartyMemberHook()
   end)
end)

--- If I can make it work with the guy method then I should go for it otherwise doesn't matter
-- local preClientRestartId = nil
-- local postClientRestartId = nil

-- local preIdOnOtomoActive = nil
-- local postIdOnOtomoActive = nil

-- local preIdIsBattleMode = nil
-- local postIdIsBattleMode = nil

-- local preGetSpawnedOtomoId = nil
-- local postGetSpawnedOtomoId = nil

-- RegisterKeyBind(config.key, function()
--     if isFirstPressed then
--         isFirstPressed = false
--         print("[PalDpsMeter] Key pressed, starting the dps meter")
--         -- preIdOnOtomoActive, postIdOnOtomoActive = RegisterHook(
--         -- "/Script/Pal.PalOtomoHolderComponentBase:OnChangeOtomoActive", onChangeOtomoActive)
--         -- preIdIsBattleMode, postIdIsBattleMode = RegisterHook("/Script/Pal.PalAICombatModule:IsBattleMode",
--         -- whenBattleModeIsOn)
--         -- preGetSpawnedOtomoId, postGetSpawnedOtomoId = RegisterHook(
--         -- "Function /Script/Pal.PalOtomoHolderComponentBase:GetSelectedOtomoID", getSpawnedOtomoId)
--         -- preClientRestartId, postClientRestartId = RegisterHook("/Script/Engine.PlayerController:ClientRestart",
--         --     clientRestart)
--     else
--         print("[PalDpsMeter] key pressed stopping the dps meter")
--         -- UnregisterHook("/Script/Pal.PalOtomoHolderComponentBase:OnChangeOtomoActive", preIdOnOtomoActive,
--         -- postIdOnOtomoActive)

--         -- UnregisterHook("/Script/Pal.PalAICombatModule:IsBattleMode", preIdIsBattleMode, postIdIsBattleMode)

--         -- UnregisterHook("/Script/Pal.PalOtomoHolderComponentBase:GetSpawnedOtomoID", preGetSpawnedOtomoId,
--         --     postGetSpawnedOtomoId)
--         -- UnregisterHook("/Script/Engine.PlayerController:ClientRestart", preClientRestartId, postClientRestartId)

--         isFirstPressed = true
--     end
-- end)
