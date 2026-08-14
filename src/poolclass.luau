--!strict
-- Handles object PoolClass
local CONFIGS = {
    POSITION = CFrame.new(9999,9999,9999),
    DEBUG = false
}

local PoolClass = {}
PoolClass.__index = PoolClass

type poolFields<T> = {
    cache : { [string] : { PVInstance } },
    history : { [string] : PVInstance }
}

type PoolInstance<T> = T & PVInstance

export type PoolObject<T> = typeof(
    setmetatable({} :: poolFields<T>, {} :: typeof(PoolClass))
)

local function lwarn(message : string)
    if CONFIGS.DEBUG then
        warn(message)
    end
end

function PoolClass.new<T>() : PoolObject<T>
    return setmetatable({
        cache = {},
        history = {},
    }, PoolClass) 
end

function PoolClass.addToHistory<T>(self : PoolObject<T>, tag : string, instance : PoolInstance<T>)
    if self:checkHistory(tag) then -- item is already in history
        return
    end

    self.history[tag] = instance:Clone()
end

-- checks history for instance
function PoolClass.checkHistory<T>(self : PoolObject<T>, tag : string) : boolean
    return self.history[tag] and true or false
end

function PoolClass.cloneFromHistory<T>(self : PoolObject<T>, tag : string) : PoolInstance<T>?
    if self:checkHistory(tag) then
        return self.history[tag]:Clone()
    end
    
    return nil
end

-- grab objects from pool
function PoolClass.grab<T>(self : PoolObject<T>, tag : string) : PoolInstance<T>?
    local model

    if #self.cache[tag] > 0 then
        model = table.remove(self.cache[tag])
    elseif self:checkHistory(tag) then
        model = self:cloneFromHistory(tag) :: Model?
    else -- cache miss, history miss
        lwarn("[PoolClassService] object was never pooled.")
        return nil
    end

    return model
end

-- pools the model provided. Note: doesn't clone it. 
-- uses Name as default tag
function PoolClass.pool<T>(self : PoolObject<T>, models : { PoolInstance<T> }, tag : string?)
    for index, model : Model in models do
        local Id = tag or model.Name -- use name as default identifier

        table.insert(self.cache[Id], model)
        
        model:PivotTo(CONFIGS.POSITION)
        self:addToHistory(Id, model)
    end
end

function PoolClass.clean<T>(self : PoolObject<T>)
    for _, template in self.history do
        template:Destroy()
    end
    for _, stack in self.cache do
        for _, item in stack do
            item:Destroy()
        end
    end

    self.history = {}
    self.cache = {}
end

-- Configurations
function PoolClass._setDebugMode(mode : boolean)
    CONFIGS.DEBUG = mode
end

function PoolClass._setPoolPosition(new : CFrame)
    CONFIGS.POSITION = new
end

return PoolClass :: typeof(PoolClass)