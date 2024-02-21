---@diagnostic disable: undefined-global
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
--#################### Globals #####################--
--##################################################--


-- isFirstPressed = true
---@type nil|string
LAST_OTOMO_OUT = nil

---@type number
LAST_SLOT_ID = -1

---@type boolean
LAST_BATTLE_MODE = false


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

-- ---Intercept when the Otomo is swaped or throw in
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
--         print("[PalDpsMeter] Otomo has been swaped")
--     end
--     ---@TODO: finish all the cases, I may need The swapIn function
-- end

local function onSwapOtomoIn()
    ---@TODO: Do something with that
    print("[PalDPsMeter] Deactivation of the otomo")
end

--- Intercept when the battle mode is swaping
---@param mode boolean true if the battle mode is ON and false otherwise
local function onBattleSwap(mode)
    if (not LAST_BATTLE_MODE) and mode then
        -- if the mode swap to ON
        print("[PalDpsMeter] Mode switching to ON starting the analytics")
    elseif LAST_BATTLE_MODE and (not mode) then
        -- if the mode swap to OFF
        print("[PalDpsMeter] Mode switching to OFF ending the analytics")
    elseif LAST_BATTLE_MODE and mode then
        -- should not happend, both values are the same
        print("[PalDpsMeter] Error in battle mode both are to ON")
    else
        -- idem
        print("[PalDpsMeter] Error in battle mode both are to OFF")
    end
end


--##################################################--
--################## Classes like ##################--
--##################################################--

Event = {}

local events = {}


-- accepts any amount and type of arguments after the event name
-- NOTE: triggered events have no guaranteed order in which callback objects are called
function Event.Trigger(eventname, ...)
    local eventlist = events[eventname] or {}

    for obj, callback in pairs(eventlist) do
        if type(obj) == "function" then
            obj(eventname, ...)
        elseif obj[eventname] then
            obj[eventname](obj, eventname, ...)
        elseif obj.OnEvent then
            obj:OnEvent(eventname, ...)
        end
    end
end

-- can register multiple events at the same time
-- any arguments after the object are treated as event names to be registered
function Event.Register(obj, ...)
    if not obj then
        return error("Event.Register error: nil callback object", 2)
    end

    local eventnames = type(...) == "table" and ... or { ... }

    if #eventnames == 0 then
        return error("Event.Register error: nil event name", 2)
    end

    for i, eventname in ipairs(eventnames) do
        if type(eventname) == "string" then
            local eventlist = events[eventname]

            if not eventlist then
                eventlist = {}
                setmetatable(eventlist, { __mode = "k" }) -- weak keys so garbage collector can clean up properly
            end

            if type(obj) ~= "function" and type(obj) ~= "table" then
                return error("Event.Register error: callback object is not a table or function", 2)
            end

            eventlist[obj] = true
            events[eventname] = eventlist
        end
    end

    return obj
end

-- can unregister multiple events at the same time
-- any arguments after the object are treated as event names to be unregistered
function Event.Unregister(obj, ...)
    if not obj then
        return error("Event.Unregister error: nil callback object", 2)
    end

    local eventnames = type(...) == "table" and ... or { ... }

    if #eventnames == 0 then
        return error("Event.Unregister error: nil event name", 2)
    end

    for i, eventname in ipairs(eventnames) do
        local eventlist = events[eventname]
        if eventlist and eventlist[obj] then
            eventlist[obj] = nil
        end
    end
end

-- returns array of event names registered to an object
function Event.LookUp(obj)
    if type(obj) ~= "table" and type(obj) ~= "function" then
        return error("Event.LookUp error: callback object is not a table or function", 2)
    end

    local registeredevents = {}

    for eventname, eventlist in pairs(events) do
        for _obj, callback in pairs(eventlist) do
            if obj == _obj then
                table.insert(registeredevents, eventname)
                break
            end
        end
    end

    return registeredevents
end

--- Representation of a Guid each number is 32bit long which give a us 128 bit
---@class Guid
---@field A integer
---@field B integer
---@field C integer
---@field D integer
local Guid = {
    A = 0,
    B = 0,
    C = 0,
    D = 0,
}

---Constructor of the class
---@param A integer
---@param B integer
---@param C integer
---@param D integer
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
function Guid:ToString()
    return self:__tostring()
end

--- Return true if self is eaual to the @otherGuid and false otherwise
---@param otherGuid Guid the other @Guid to test
---@return boolean isEqual
function Guid:isEqual(otherGuid)
    if self:getA() == otherGuid:getA() and self:getB() == otherGuid:getB() and self:getC() == otherGuid:getC() and self:getD() == otherGuid:getD() then
        return true
    else
        return false
    end
end

--- Represent the in game data of a PalInstanceID, in addition we got the struct address to test unicity
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
    return string.format("OtomoUinique Identifier: %i", self:getAddr())
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
local Otomo = {
}

--- Constructor like for the class
---@param o any object itself, passe nil to create a new one
---@param characterID string @characterID represent The pal name in the datatables
---@param slotInParty integer @slotInParty represent the slot in the party (Biggining at 0)
---@param uid OtomoUniqueId The Unique id of the otomo (Aka an address of its ID in the game)
---@param damageTaken integer|nil @damageTaken represent the amount of real damage it has taken during a fight
---@param damageInflicted integer|nil @damageInflicted represent the real amount of damage the it has inflicted
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

function Otomo:__tostring()
    local damageTaken = self:getDamageTaken()
    local damageInflicted = self:getDamageInflicted()

    print("%s", type(damageTaken))

    if damageTaken == -1 then
        damageTaken = 0
    end

    if damageInflicted == -1 then
        damageInflicted = 0
    end

    local uidStr = self:getUid():ToString()

    return (string.format("Name: %s,\t slootIndex: %i,\t damageTaken: %i,\t damageInflicted: %i,\t Guid: %s", self:getCharacterID(),
        self:getSlotInParty(), damageTaken, damageInflicted, uidStr))
end

function Otomo:ToString()
    return self:__tostring()
end

function Otomo:getCharacterID()
    return self.characterID
end

---@return number _slotInParty
function Otomo:getSlotInParty()
    return self.slotInParty
end

---@return OtomoUniqueId uid the guid of the otomo
function Otomo:getUid()
    return self.uid
end

function Otomo:getDamageTaken()
    return self.damageTaken
end

function Otomo:getDamageInflicted()
    return self.damageInflicted
end

-- function Otomo:setCharacterID(newCharacterID)
--     self.characterID = newCharacterID
-- end

-- function Otomo:setSlotInParty(newSlotInParty)
--     self.slotInParty = newSlotInParty
-- end

function Otomo:setDamageTaken(newDamageTaken)
    self.damageTaken = newDamageTaken
end

function Otomo:setDamageInflicted(newDamageInflicted)
    self.damageInflicted = newDamageInflicted
end

function Otomo:isSame(otherOtomo)
    return (self:getUid():getAddr() == otherOtomo:getUid():isEqual())
end

function Otomo:__index(key)
    if string.sub(key, 1, 1) == "_" then
        error("Attempting to access private member:", key)
    end
end

---@class PartyTeam that represent the team of otomo that the player cary
---@field team table a table that contains all of the otomo in the team of the player
---@field currentlyOutOtomo number the out otomo or -1 if none
---@field nbOtomoCurrentlyInTeam number The number of otomo currently in the team
local PartyTeam = {
    team = {},
    currentlyOutOtomo = -1,
    nbOtomoCurrentlyInTeam = -1,

}

---@param otomos table The otomos that are in the team, can be 1 to 5
function PartyTeam:new(otomos)
    local party = setmetatable({}, self)
    self.__index = self
    self.constants = setmetatable({}, { __index = function(_, key) return nil end })
    self.constants.MIN_PER_TEAM = 0
    self.constants.MAX_PER_TEAM = 5

    self._team = otomos
    self._currentlyOutOtomo = -1 ---@TODO: Need to be hooked
    self._nbOtomoCurrentlyInTeam = #self._team ---@TODO: Need to be hooked too


    return party
end

---@return table theTeam
function PartyTeam:getTeam()
    return self._team
end

---@return number slotID of the currently out otomo
function PartyTeam:getCurrentlyOutOtomo()
    return self._currentlyOutOtomo
end

---@return number @nbOtomoCurrentlyInTeam
function PartyTeam:getNbOtomoCurrentlyInTeam()
    return self._nbOtomoCurrentlyInTeam
end

---@param otomos table the @Otomo to set in the team
function PartyTeam:setTeam(otomos)

end

---@param slotID number
function PartyTeam:setCurrentlyOutOtomo(slotID)
    ---@FIXME set the 1/5 values to a var to be more carefull if the team span expand in the future
    if slotID < 1 or slotID > 5 then
        print("[PalDpsMeter] Your are trying to set a slot out of band")
        return
    end
    self._currentlyOutOtomo = slotID
end

---@param nb number
---@private
function PartyTeam:_setNbOtomoCurrentlyInTeam(nb)
    if nb < self.constants.MIN_PER_TEAM and nb > self.constants.MAX_PER_TEAM then
        print("[PalDpsMeter] try to set more otomo than you can have in your team")
        return
    end
    self._nbOtomoCurrentlyInTeam = nb
end

--- Add an Otomo via its slotID replacing the previous one
---@param otomo Otomo the new otomo to place in the team
---@private
function PartyTeam:_addOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    local team = self:getTeam()
    team[otomoSlotID] = otomo

    -- table.insert(self:getTeam(), otomoSlotID, otomo)

    if self:getNbOtomoCurrentlyInTeam() == nil or self:getNbOtomoCurrentlyInTeam() == 0 then
        self:_setNbOtomoCurrentlyInTeam(1)
    end

    self:_setNbOtomoCurrentlyInTeam(self:getNbOtomoCurrentlyInTeam() + 1)
end

---@param slotID number
---@private
function PartyTeam:_removeOtomoBySlotID(slotID)
    -- self:getTeam()[slotID] =
    table.remove(self:getTeam(), slotID)
    self._nbOtomoCurrentlyInTeam = self._nbOtomoCurrentlyInTeam - 1
end

---@param otomo Otomo
---@private
function PartyTeam:_replaceOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    self:getTeam()[otomoSlotID] = otomo
end

---@param otomo Otomo
function PartyTeam:removeOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    self:_removeOtomoBySlotID(otomoSlotID)
end

---@param slotIndex number the index of the otomo to retrieve
---@return Otomo|nil otomo at the index or nil if none was found
---@private
function PartyTeam:_getOtomoBySlotID(slotIndex)
    if slotIndex < self.constants.MIN_PER_TEAM or slotIndex > self.constants.MAX_PER_TEAM then
        error("indexing a wrong slotID")
        return
    end

    local currentTeam = self:getTeam()

    if not currentTeam then
        error("team is empty")
    end

    if not currentTeam[slotIndex] then
        print(string.format("index of the current team: %d", slotIndex))
        error("No otomo found at this index")
        return
    end
    local otomo = currentTeam[slotIndex]
    return otomo
end

---Update the otomo who is out
---@param newSlotID number the new @slotID
---@param oldSlotID number|nil the old @slotID or nil if its the first throw of the play time
---@private
function PartyTeam:_updateCurrentlyOutOtomo(newSlotID, oldSlotID)
    self:setCurrentlyOutOtomo(new)
    ---@TODO: Maybe do some stuff with the @oldslotID
end

---@return string|nil str the string to print
---@private
function PartyTeam:__tostring()
    local str = ""
    str = string.format("nbOtomoInTeam: %d, currentlyOutOtomo: %d\n", self:getNbOtomoCurrentlyInTeam(),
        self:getCurrentlyOutOtomo())
    for i = 1, self:getNbOtomoCurrentlyInTeam(), 1 do
        local otomo = self:_getOtomoBySlotID(i)
        if not otomo then
            return
        end
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

--- Intercept when an otomo is throwing out and do what is necessary
---@param slotID number the @slotID of the otomo who is thrown out
function PartyTeam:onActivateOtomo(slotID)
    local outOtomo = self:getCurrentlyOutOtomo()
    if not outOtomo then
        print("[PalDpsMeter] No Otomo is out for now")
        return
    end

    self:_updateCurrentlyOutOtomo(newSlotID, oldSlotID)

    ---@TODO: Do some stuff later when the code will be more advanced
end

local IPlayer = setmetatable({}, OtomoUniqueId)

function IPlayer:__index(key)
    if key == eventName.ActivateOtomo or
        key == eventName.battleModeSwaped or
        key == eventName.InactivateCurrentOtomo or
        key == "notifyObservers" or
        key == "registerObservers" then
        error("Abstract method", key)
    else
        error("Invalid key for a Player")
    end
end

---@class Player The Subject of the observer pattern
---@field team PartyTeam
---@field observers table
local Player = {
    _team = {},
    _observers = {}
}
--- Constructor
---@param o any
function Player:new(o)
    local player = o or {}
    local observers = {}
    setmetatable(Player, { __index = IPlayer })

    local _team = PartyTeam:new({})
    local _observers = {} or nil
    player._team = _team
    player._observers = _observers
    return player
end

function Player:registerObserver(observer)
    table.insert(observers, observer)
end

function Player:notifyObservers()
    for _, observer in ipairs(observers) do
        observer:update(self)
    end
end

---@return PartyTeam
function Player:getTeam()
    return self._team
end

---@param team PartyTeam
function Player:setTeam(team)
    self._team = team
    self:notifyObservers()
end

function Player:retrievePartyMember()
    RegisterHook(
        "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:ActivateOtomo",
        function(component, SlotID, StartTransform, isSuccess)
            local otomos = {}
            if not isSuccess then
                return
            end
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
                    tmpOtomo = Otomo:new(nil, otomoID:ToString(), index, otomoUID,0, 0)

                    otomos[index] = tmpOtomo
                end
            end)
            local foundTeam = PartyTeam:new(otomos)
            print(foundTeam:ToString())





            -- print(tostring(self))
            --[[ TODO need to be tested if its already the team playing
                    and fighting before we can notify the update
                    if its a new team update and if its the same fight update accordingly
                ]]

            -- self:notifyObservers()
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



--- Retrieve the Otomo that is out, get reexecuted each time another is out
---@return string | nil OtomoCharacterID return the string of the characterID if found and nil otherwise
--- FIXME it need to be on the observer feature
local function ActiveOtomo()
    local activeOtomo = nil
    RegisterHook(
        "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:ActivateOtomo",
        function(self, SlotID, StartTransform, isSuccess)
            if not isSuccess then
                return
            end
            local slotID = SlotID:get()
            print(string.format("[PalDpsMeter] The slot id of the Otomo is : %d", slotID))

            local HolderComponent = OtomoUniqueId:get()
            local otomoCharacter = HolderComponent:TryGetOtomoActorBySlotIndex(slotID)
            local OtomoParameterComponent = otomoCharacter.CharacterParameterComponent
            local OtomoIndividualParameter = OtomoParameterComponent:GetIndividualParameter()
            activeOtomo = OtomoIndividualParameter:GetCharacterID()

            print(string.format("[PalDpsMeter] The out Otomo is: %s of slot %d", activeOtomo:ToString(), slotID))
            -- return OtomoCharacterID:ToString()
            Event.Trigger("on_swap_otomo", activeOtomo:ToString(), slotID)
        end)
end

--- Only retrie the moment a player deactivate his otomo
-- FIXME it needs to be on the observer feature
local function InactivateCurrentOtomo()
    RegisterHook(
        "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:InactivateCurrentOtomo",
        function(self)
            Event.Trigger(eventName.onInactivateCurrentOtomo)
        end)
end

local function getPartyMember()
    RegisterHook("/Script/Pal.PalPlayerPartyPalHolder:GetPartyMember", function(self, OutPartyMember)
        ---@TODO: Create a class to handle this myself and populate all the needed data more precisely
    end)
end

--- Is being trigger only when battlemode is ON
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
--################### Main ####################--
--##################################################--

local player = Player:new(nil)


ExecuteAsync(function()
    local HUDService = FindFirstOf("PalHUDService")

    if HUDService ~= nil and HUDService:IsValid() then
        -- retrieveActiveOtomo()
        -- retrieveInactivateOtomo()
        -- whenBattleModeIsOn()
        Player:retrievePartyMember()

        return
    end

    NotifyOnNewObject("/Script/Pal.PalHUDService", function(context)
        -- retrieveActiveOtomo()
        -- retrieveInactivateOtomo()
        -- whenBattleModeIsOn()
        Player:retrievePartyMember()
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
