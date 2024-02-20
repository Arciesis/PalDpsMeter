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

---@TODO: make a GUID generator based on the level + rank + passive of the otomo

---@class Otomo
---@field characterID string|nil
---@field slotInParty nil
---@field damageTaken number|nil
---@field damageInfilcted number|nil
local Otomo = {
    characterID = nil,
    slotInParty = -1,
    damageTaken = nil,
    damageInflicted = nil
}

--- Constructor like for the class
---@param o any object itself, passe nil to create a new one
---@param characterID string @characterID represent The pal name in the datatables
---@param slotInParty number @slotInParty represent the slot in the party (Biggining at 0)
---@param damageTaken number|nil @damageTaken represent the amount of real damage it has taken during a fight
---@param damageInflicted number|nil @damageInflicted represent the real amount of damage the it has inflicted
function Otomo:new(o, characterID, slotInParty, damageTaken, damageInflicted)
    local otomo = o or {}
    otomo = setmetatable(otomo, self)
    self.__index = self

    otomo._characterID = characterID or nil
    otomo._slotInParty = slotInParty or -1
    otomo._damageTaken = damageTaken or nil
    otomo._damageInflicted = damageInflicted or -1

    return otomo
end

function Otomo:getCharacterID()
    return self._characterID
end

---@return number _slotInParty
function Otomo:getSlotInParty()
    return self._slotInParty
end

function Otomo:getDamageTaken()
    return self._damageTaken
end

function Otomo:getDamageInflicted()
    return self._damageInflicted
end

function Otomo:setCharacterID(newCharacterID)
    self._characterID = newCharacterID
end

function Otomo:setSlotInParty(newSlotInParty)
    self._slotInParty = newSlotInParty
end

function Otomo:setDamageTaken(newDamageTaken)
    self._damageTaken = newDamageTaken
end

function Otomo:setDamageInflicted(newDamageInflicted)
    self._damageInflicted = newDamageInflicted
end

function Otomo:__index(key)
    if string.sub(key, 1, 1) == "_" then
        error("Attempting to access private member:", key)
    end
end

---@class PartyTeam that represent the team of otomo that the player cary
---@field o any
---@field team table a table that contains all of the otomo in the team of the player
---@field nbOtomoCurrentlyInTeam number The number of otomo currently in the team
local PartyTeam = {
    _team = {},
    _currentlyOutOtomo = nil,
    _nbOtomoCurrentlyInTeam = 0,

}

---@param o any
---@param otomos table The otomos that are in the team, can be 1 to 5
function PartyTeam:new(o, otomos)
    local party = o or {}
    party = setmetatable(party, self)
    self.constants = setmetatable({}, { __index = function(_, key) return nil end })
    self.constants.MIN_PER_TEAM = 0
    self.constants.MAX_PER_TEAM = 5


    party._team = otomos or nil
    party._currentlyOutOtomo = nil ---@TODO: Need to be hooked
    party._nbOtomoCurrentlyInTeam = 0 ---@TODO: Need to be hooked too

    self:setTeam(otomos)

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
    if (not otomos) or #otomos > self.constants.MAX_PER_TEAM then
        print("[PalDpsMeter]passed arguments are wrong, cannot set the team")
        return
    end

    for i = 1, #otomos, 1 do
        self:_addOtomo(otomos[i])
    end
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
function PartyTeam:setNbOtomoCurrentlyInTeam(nb)
    if nb < 0 and nb > 5 then
        print("[PalDpsMeter] try to set more otomo than you can have in your team")
        return
    end
    self._nbOtomoCurrentlyInTeam = nb
end

--- Add an Otomo via its slotID replacing the previous one
---@param otomo Otomo
function PartyTeam:_addOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    table.insert(self:getTeam(), otomoSlotID, otomo)
    self:setNbOtomoCurrentlyInTeam(self:getNbOtomoCurrentlyInTeam() + 1)
end

---@param slotID number
function PartyTeam:_removeOtomoBySlotID(slotID)
    table.remove(self:getTeam(), slotID - 1)
    self._nbOtomoCurrentlyInTeam = self._nbOtomoCurrentlyInTeam - 1
end

---@param otomo Otomo
function PartyTeam:replaceOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    self._removeOtomoBySlotID(self, otomoSlotID)
    self._addOtomo(self, otomo)
end

---@param otomo Otomo
function PartyTeam:removeOtomo(otomo)
    local otomoSlotID = otomo:getSlotInParty()
    self:_removeOtomoBySlotID(otomoSlotID)
end

---@param otomo Otomo
function PartyTeam:addOtomo(otomo)
    self:_addOtomo(otomo)
end

---@param slotID number
function PartyTeam:_getOtomoBySlotID(slotID)
    local otomo = table.unpack(self:getTeam(), slotID - 1, slotID - 1)
    return otomo
end

---Update the otomo who is out
---@param newSlotID number the new @slotID
---@param oldSlotID number|nil the old @slotID or nil if its the first throw of the play time
function PartyTeam:_updateCurrentlyOutOtomo(newSlotID, oldSlotID)
    self:setCurrentlyOutOtomo(new)
    ---@TODO: Maybe do some stuff with the @oldslotID
end

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

function PartyTeam:__index(key)
    if string.sub(key, 1, 1) == "_" then
        error("Attempting to access private member:", key)
    end
end

local IPlayer = setmetatable({}, self)

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
---@field team PartyTeam|nil}
---@field observers table
local Player = {
    _team = nil,
    _observers = {}
}
--- Constructor
---@param o any
function Player:new(o)
    local player = o or {}
    local observers = {}
    setmetatable(Player, { __index = IPlayer })

    local _team = PartyTeam:new(nil, {}) or nil
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
            -- local isOtomoPresent = true
            local HolderComponent = component:get()
            -- local otomoCount = HolderComponent:GetOtomoCount()
            local slots = HolderComponent.CharacterContainer.SlotArray
            slots:ForEach(function(index, elem)
                if not elem:get():isEmpty() then
                    local otomoHandle = elem:get():GetHandle()
                    local otomoIndividualParameter = otomoHandle:TryGetIndividualParameter()
                    local otomoID = otomoIndividualParameter:GetCharacterID()
                    local tmpOtomo = Otomo:new(nil, otomoID:ToString(), index, nil, nil)


                    otomos[index] = tmpOtomo
                end
            end)


            local team = PartyTeam:new(nil, otomos)
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

            local HolderComponent = self:get()
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
