local SampEvents = require 'samp.events'

delay = 200

objectIndex = 0
active = false
doTake = false
doDrop = false

isAttached = false

function sendKey(key)
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local data = allocateMemory(68)
    sampStorePlayerOnfootData(myId, data)
    setStructElement(data, 4, 2, key)
    sampSendOnfootData(data)
    freeMemory(data)
end

function PressRMB()
	sendKey(128)
end

function PressF()
	sendKey(16)
end

function drop()
    lua_thread.create(function()
        while doDrop and active do
            PressF()
            wait(delay)
        end
    end)
end

function take()
    lua_thread.create(function()
        while doTake and active do
            PressRMB()
            wait(delay)
        end
    end)
end

function SampEvents.onSetPlayerAttachedObject(playerid, index, create, obj)
    local objectid = obj.modelId
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)

    if _ then
        if playerid == myid then
            if (index == objectIndex or objectid == 1224) and active then
                if create then
                    objectIndex = index
                    isAttached = true
                    doTake = false
                    doDrop = true
                    drop()
                else
                    isAttached = false
                    doDrop = false
                    doTake = true
                    take()
                end
            end
        end
    end
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    while true do
        wait(0)
        if not isCharInAnyCar(PLAYER_PED) then
            if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsCursorActive()  then
                if isKeyDown(191) then
                    if active == false then
                        active = true
                        if isAttached then
                            doDrop = true
                            drop()
                        else
                            doTake = true
                            take()
                        end
                    end
                    active = true
                else
                    active = false
                end
            end
        end
    end
end