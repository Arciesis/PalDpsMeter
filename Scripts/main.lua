-- RegisterHook(FunctionName, Callback)
-- FunctionName => function name from UE4SS
-- Callback => our function callback
print("[PalDpsMeter] Pal DPS Meter has started!")

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

local config = require "config"
local eventName = require "eventName"
--##################################################--
--################### Constants ####################--
--##################################################--
local constants = {
    MIN_PER_TEAM = 1,
    MAX_PER_TEAM = 5,
}

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
--         ---@TODO : Do something about that !!!
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
--         ---@TODO: Do something with that
--     end

--     -- if the otomos ids differ and the slot differ too (Most use case)
--     if (LAST_OTOMO_OUT ~= otomo and LAST_SLOT_ID ~= slotID) then
--         LAST_OTOMO_OUT = otomo
--         LAST_SLOT_ID = slotID
--         print("[PalDpsMeter] Otomo has been swapped")
--     end
--     ---@TODO: finish all the cases, I may need The swapIn function
-- end

--local function onSwapOtomoIn()
--    ---@TODO: Do something with that
--    print("[PalDPsMeter] Deactivation of the otomo")
--end

-- Intercept when the battle mode is swapping
---@param mode boolean true if the battle mode is ON and false otherwise
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

--TODO : Some refacto to do for making the code style linear


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




--- Representation of a Guid each number is 32bit long which give a us 128 bit
---@class Guid
---@field A integer
---@field B integer
---@field C integer
---@field D integer
local Guid = {}

---Constructor of the class
---@param A integer
---@param B integer
---@param C integer
---@param D integer
---@public
function Guid:new(A, B, C, D)
    local guid = {}
    guid = setmetatable(guid, self)
    self.__index = self

    self._A = A
    self._B = B
    self._C = C
    self._D = D

    return guid
end

--- A field Getter
---@return integer A
function Guid:getA()
    return self._A
end

--- B field Getter
---@return integer B
function Guid:getB()
    return self._B
end

--- C field Getter
---@return integer C
function Guid:getC()
    return self._C
end

--- D field Getter
---@return integer D
function Guid:getD()
    return self._D
end

--- return a string representing the @Guid
---@private
function Guid:__tostring()
    local guidStr = ""
    guidStr = string.format("A: %d,\t B: %d,\t C: %d,\t D: %d", self:getA(), self:getB(), self:getC(), self:getD())
    return guidStr
end

--- Return a string representing the data inside the @Guid
---@return string str
---@public
function Guid:ToString()
    return self:__tostring()
end

--- Return true if self is equal to the @otherGuid and false otherwise
---@param otherGuid Guid the other @Guid to test
---@return boolean isEqual
function Guid:isEqual(otherGuid)
    if self:getA() == otherGuid:getA() and self:getB() == otherGuid:getB() and self:getC() == otherGuid:getC()
    and self:getD() == otherGuid:getD() then
        return true
    else
        return false
    end
end

--- Represent an unique id for otomo, it's actually the address of a ScriptStruct: PalInstanceId
---@class OtomoUniqueId
---@field Addr integer
local OtomoUniqueId = {
}

--- Constructor of a PalInstanceID
---@param structAddr integer
---@return OtomoUniqueId palInstanceId the class
function OtomoUniqueId:new(structAddr)
    local OtomoUId = {}
    OtomoUId = setmetatable(OtomoUId, self)
    self.__index = self

    OtomoUId.Addr = structAddr

    return OtomoUId
end

--- getter of the structAddr property
---@return integer theStructAddr
function OtomoUniqueId:getAddr()
    return self.Addr
end

--- internal tostring method
---@return string str
---@private
function OtomoUniqueId:__tostring()
    return string.format("OtomoUnique Identifier: %i", self:getAddr())
end

--- ToString method
---@return string str the string representing the data
function OtomoUniqueId:ToString()
    return self:__tostring()
end

--- Test if two Instances of this class are isEqual
---@param otherUId OtomoUniqueId
---@return boolean bool true if there are equal and false otherwise
function OtomoUniqueId:isEqual(otherUId)
    if self:getAddr() == 0 or otherUId:getAddr() == 0 then
        return false
    end

    return (self:getAddr() == otherUId:getAddr())
end

---@class Otomo
---@field characterID string|nil
---@field slotInParty number|nil
---@field uid OtomoUniqueId|nil
---@TODO Make a damage class with the stuff needed I think
---@field damageTaken number
---@field damageInfilcted number
local Otomo = {}

--- Constructor like for the class
---@param o any object itself, passe nil to create a new one
---@param characterID string @characterID represent The pal name in the datatables
---@param slotInParty integer @slotInParty represent the slot in the party (Biggining at 0)
---@param uid OtomoUniqueId The Unique id of the otomo (Aka an address of its ID in the game)
---@param damageTaken number|nil @damageTaken represent the amount of real damage it has taken during a fight
---@param damageInflicted number|nil @damageInflicted represent the real amount of damage the it has inflicted
function Otomo:new(o, characterID, slotInParty, uid, damageTaken, damageInflicted)
    local otomo = o or {}
    otomo = setmetatable(otomo, self)
    self.__index = self

    otomo.characterID = characterID
    otomo.slotInParty = slotInParty
    otomo.uid = uid
    otomo.damageTaken = damageTaken or -1
    otomo.damageInflicted = damageInflicted or -1

    return otomo
end

--- Internal tostring
---@return string str the representation of the data
function Otomo:__tostring()
    local damageTaken = self:getDamageTaken()
    local damageInflicted = self:getDamageInflicted()

    if damageTaken == -1 then
        damageTaken = 0
    end

    if damageInflicted == -1 then
        damageInflicted = 0
    end

    local uidStr = self:getUid():ToString()

    return (string.format("Name: %s,\t slotIndex: %i,\t damageTaken: %i,\t damageInflicted: %i,\t
        %s", self:getCharacterID(),
        self:getSlotInParty(), damageTaken, damageInflicted, uidStr))
end

--- ToString method
---@return string str the representation of the data
function Otomo:ToString()
    return self:__tostring()
end

---@return string characterID The ID of the otomo (e.g. teh species)
function Otomo:getCharacterID()
    return self.characterID
end

---@return number slotInParty the
function Otomo:getSlotInParty()
    return self.slotInParty
end

---@return OtomoUniqueId uid the guid of the otomo
function Otomo:getUid()
    return self.uid
end

---@return number damageTaken the damage taken by that otomo during a fight
function Otomo:getDamageTaken()
    return self.damageTaken
end

---@return number damageInflicted the damage inflicted by that otomo duriong a fight
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
    local otherUId = otherOtomo:getUid()
    return (self:getUid():isEqual(othereUId))
end

---@class PartyTeam that represent the team of otomo of the player
---@field private members table a table that contains all of the otomo in the team of the player
---@field private currentlyOutOtomo number the out otomo slot index or -1 if none
---@field private nbOtomoCurrentlyInTeam number The number of otomo currently in the team
local PartyTeam = {}


---@TODO: modify the text
---@param otomos table The otomos in the team, can be 1 to 5 if its 0 then the team team is empty
function PartyTeam:new(otomos)
    local party = setmetatable({}, self)
    self.__index = self

    self.members = otomos
    ---@TODO: Need to be notify
    self.currentlyOutOtomo = -1
    self.nbOtomoCurrentlyInTeam = #self.members


    return party
end

---@return table theTeam
function PartyTeam:getMembers()
    return self.members
end

---@return integer slotID of the currently out otomo
function PartyTeam:getCurrentlyOutOtomo()
    return self.currentlyOutOtomo
end

---@return number @nbOtomoCurrentlyInTeam
function PartyTeam:getNbOtomoCurrentlyInTeam()
    return self.nbOtomoCurrentlyInTeam
end

---@param otomos table the @Otomo to set in the team
function PartyTeam:setMembers(otomos)
    self.members = otomos
end

---@param slotIndex integer
function PartyTeam:setCurrentlyOutOtomo(slotIndex)
    print(string.format("slotID: %i", slotIndex))
    if slotIndex < constants.MIN_PER_TEAM or slotIndex > constants.MAX_PER_TEAM then
        print("[PalDpsMeter] Your are trying to set a slot out of band")
        return
    end
    self.currentlyOutOtomo = slotIndex
end

---@param nb integer
function PartyTeam:setNbOtomoCurrentlyInTeam(nb)
    if nb < constants.MIN_PER_TEAM and nb > constants.MAX_PER_TEAM then
        print("[PalDpsMeter] try to set more otomo than you can have in your team")
        return
    end
    self.nbOtomoCurrentlyInTeam = nb
end

--- Add an Otomo via its slotID replacing the previous one
---@param otomo Otomo the new otomo to place in the team
function PartyTeam:addOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    local team = self:getMembers()
    team[otomoSlotID] = otomo

    -- table.insert(self:getTeam(), otomoSlotID, otomo)

    if self:getNbOtomoCurrentlyInTeam() == nil or self:getNbOtomoCurrentlyInTeam() == 0 then
        self:setNbOtomoCurrentlyInTeam(1)
    end

    self:setNbOtomoCurrentlyInTeam(self:getNbOtomoCurrentlyInTeam() + 1)
end

---@param slotID number
function PartyTeam:removeOtomoBySlotID(slotID)
    -- self:getTeam()[slotID] =
    table.remove(self:getMembers(), slotID)
    self._nbOtomoCurrentlyInTeam = self._nbOtomoCurrentlyInTeam - 1
end

---@param otomo Otomo
function PartyTeam:updateOtomoByOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    self:getMembers()[otomoSlotID] = otomo
end

---@param otomo Otomo
function PartyTeam:removeOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    self:removeOtomoBySlotID(otomoSlotID)
end

---@param slotIndex number the index of the otomo to retrieve
---@return Otomo otomo at the index or nil if none was found
---@private
function PartyTeam:getOtomoBySlotID(slotIndex)
    if slotIndex < constants.MIN_PER_TEAM or slotIndex > constants.MAX_PER_TEAM then
        error("indexing a wrong slotID")
    end

    local currentTeam = self:getMembers()

    if not currentTeam then
        error("team is empty")
    end

    if not currentTeam[slotIndex] then
        error("No otomo found at this index")
    end

    local otomo = currentTeam[slotIndex]
    return otomo
end

---Update the otomo who is out
---@param newSlotIndex number the new @slotID
function PartyTeam:updateCurrentlyOutOtomo(newSlotIndex)
    if newSlotId < constants.MIN_PER_TEAM or newSlotIndex > constants.MAX_PER_TEAM then
        error("[PalDpsMeter] Your are ttying to update the outOtomo with a wrong Index")
    end

    self:setCurrentlyOutOtomo(newSlotIndex)
end

---@return string|nil str the string to print
---@private
function PartyTeam:__tostring()
    local str = ""
    str = string.format("nbOtomoInTeam: %d, currentlyOutOtomo: %d\n", self:getNbOtomoCurrentlyInTeam(),
        self:getCurrentlyOutOtomo())
    for i = 1, self:getNbOtomoCurrentlyInTeam(), 1 do
        ::continue::

        -- if the one otomo is missing in the team in the first slots but in one of the last there is one
        if not self:getMembers()[i] then
            i = i +1
            goto continue
        end

        local otomo = self:getOtomoBySlotID(i)

        str = str .. string.format("TeamMember: [%s]\n", otomo:ToString())
    end
    return str
end

---@return string|nil str @PartyTeam object as string
function PartyTeam:ToString()
    return self:__tostring()
end

-- function PartyTeam:__index(key)
--     if string.sub(key, 1, 1) == "_" then
--         error("Attempting to access private member:")
--     end
-- end

--- Get the modified otomos between the actual Members (old/self) and the newTeam
---@param newPartyTeam PartyTeam the new set of members
---@return table modifiedOtomos the set of otomos to insert into the actual team
function PartyTeam:getModifiedOtomos(newPartyTeam)
    local modifiedOtomos = {}
    local oldPartyTeamMembers = self:getMembers()
    local newPartyTeamMembers = newPartyTeam:getMembers()

    -- iterate over each combination of otomos to find which one has been modified
    -- iterate each time by 1 to 5 because we can have only 1 otomo in the team in the last slot
    for newIndex = constants.MIN_PER_TEAM, constants.MAX_PER_TEAM, 1 do
        for oldIndex = constants.MIN_PER_TEAM, constants.MAX_PER_TEAM, 1 do
            if not newPartyTeamMembers[newIndex]  then
                break
            end

            if not oldPartyTeamMembers[oldIndex] then
                break
            end

            if not newPartyTeamMembers[newIndex].isEqual(oldPartyTeamMembers[oldIndex]) then
                table.insert(swappedOtomos, newOtomo)
                break
            end
        end
    end
    return modifiedOtomos
end

--- get an update on the otomos that has been swapped off the team
---@param newPartyTeam PartyTeam the complete set of the new team
---@return table swappedOtomos A table containing the newly added otomos
function PartyTeam:getNotSwappedOtomos(newPartyTeam)
    local swappedOtomos = {}
    local oldPartyTeamMembers = self:getMembers()
    local newPartyTeamMembers = newPartyTeam:getMembers()

    -- iterate over each combination of otomos to find which one has not been swapped
    for newIndex, newOtomo in ipairs(newPartyTeamMembers) do
        for oldIndex, oldOtomo in ipairs(oldPartyTeamMembers) do
            if newOtomo.isEqual(oldOtomo) then
                table.insert(swappedOtomos, newOtomo)
                break
            end
        end
    end
    return swappedOtomos
end

--- Intercept when an otomo is throwing out and do what is necessary
--@param slotID number the @slotID of the otomo who is thrown out
---@param self PartyTeam
function PartyTeam:onActivateOtomo()
    local outOtomo = self:getCurrentlyOutOtomo()
    if outOtomo == -1 then
        print("[PalDpsMeter] No Otomo is out for now")
        return
    end

    self:updateCurrentlyOutOtomo(newSlotID)

    ---@TODO: Do some stuff later when the code will be more advanced
end

---@class Player The Subject of the observer pattern
---@field team PartyTeam
---@field observers table
local Player = {}

--- Constructor
function Player:new()
    local player = setmetatable({}, self)

    -- create an empty team
    player.team = PartyTeam:new({})
    player.observers = {}

    return player
end

---@return PartyTeam team the team of the player
function Player:getTeam()
    return self.team
end

---@param team PartyTeam
function Player:setTeam(team)
    self._team = team
end

--- Test if the team is empty or not
---@return boolean bool true if the team is empty and false otherwise
function Player:isTeamEmpty()
    local actualTeam = self:getTeam()
    return not actualTeam
end

--- Update all the team by a new one
---@param newPartyTeam PartyTeam
---@param outOtomoSlotIndex integer
function Player:updateAllTeam(newPartyTeam, outOtomoSlotIndex)
    self:setTeam(newPartyTeam)
    newPartyTeam:setNbOtomoCurrentlyInTeam(#newPartyTeam)
    newPartyTeam:setCurrentlyOutOtomo(outOtomoSlotIndex)
end

---@param self Player
---@param newPartyTeam PartyTeam the new PartTeam
---@param outOtomoSlotIndex integer the slot index of thrown out otomo
---@private
function Player:updateTeam(newPartyTeam, outOtomoSlotIndex)

    if self:isTeamEmpty() then
        self:updateAllTeam(newPartyTeam, outOtomoSlotIndex)
    else
        -- test if olny a few have changed and update them
        local modifiedOtomos = Player:getTeam():getModifiedOtomos(newPartyTeam)

        -- used with the recursive version of the function which is not implemented
        -- swapedOtomos = Player.getRecursiveSwapedOtomos(newPartyTeam:getMembers(),
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

--Hook function that retrieve the Team of a player
function Player:retrievePartyMemberHook()
    RegisterHook(
        "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:ActivateOtomo",
        function(component, slotID, StartTransform, isSuccess)
            if not isSuccess then
                return
            end

            local otomos = {}

            ---@diagnostic disable-next-line: undefined-field
            local HolderComponent = component:get()
            local tmpOtomo = nil
            local slots = HolderComponent.CharacterContainer.SlotArray

            slots:ForEach(function(index, elem)
                if not elem:get():isEmpty() then
                    local slot = elem:get()
                    local handle = slot:GetHandle()
                    local otomoIndividualParameter = handle:TryGetIndividualParameter()
                    local otomoID = otomoIndividualParameter:GetCharacterID()

                    --In game FPalInstanceID representation: Guid: InstanceId / Guid: PlayerUId / Guid: DebugName
                    local ID = otomoIndividualParameter.IndividualId

                    -- print(string.format("instanceID: %i", ID:GetStructAddress()))
                    local otomoUID = OtomoUniqueId:new(ID:GetStructAddress())
                    tmpOtomo = Otomo:new(nil, otomoID:ToString(), index, otomoUID, 0, 0)

                    otomos[index] = tmpOtomo
                end
            end)

            local foundTeam = PartyTeam:new(otomos)
            print(foundTeam:ToString())
            self:updateTeam(foundTeam,slotID:get() + 1)
            print(self:getTeam():ToString())



            -- print(tostring(self))
            --[[ TODO need to be tested if its already the team playing
                    and fighting before we can notify the update
                    if its a new team update and if its the same fight update accordingly
                ]]

             self:notifyObservers()
        end)
end

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



-- Retrieve the Otomo that is out, get reexecuted each time another is out
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

local player = Player:new()

ExecuteAsync(function()
    local HUDService = FindFirstOf("PalHUDService")

    if HUDService ~= nil and HUDService:IsValid() then
        -- retrieveActiveOtomo()
        -- retrieveInactivateOtomo()
        -- whenBattleModeIsOn()
        player:retrievePartyMemberHook()

        return
    end

    NotifyOnNewObject("/Script/Pal.PalHUDService", function()
        -- retrieveActiveOtomo()
        -- retrieveInactivateOtomo()
        -- whenBattleModeIsOn()
        player:retrievePartyMemberHook()
    end)
end)







--- If I can make it work with the guy method then I shoulg go for it otherwise doesn't matter
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
--         print("[PalDpsMeter] key pressed stoping the dps meter")
--         -- UnregisterHook("/Script/Pal.PalOtomoHolderComponentBase:OnChangeOtomoActive", preIdOnOtomoActive,
--         -- postIdOnOtomoActive)

--         -- UnregisterHook("/Script/Pal.PalAICombatModule:IsBattleMode", preIdIsBattleMode, postIdIsBattleMode)

--         -- UnregisterHook("/Script/Pal.PalOtomoHolderComponentBase:GetSpawnedOtomoID", preGetSpawnedOtomoId,
--         --     postGetSpawnedOtomoId)
--         -- UnregisterHook("/Script/Engine.PlayerController:ClientRestart", preClientRestartId, postClientRestartId)

--         isFirstPressed = true
--     end
-- end)
