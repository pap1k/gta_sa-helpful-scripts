--[[
	Adds /taketable command to take table for auction	
]]

encoding = require("encoding")
encoding.default = 'CP1251'
u8 = encoding.UTF8

local se = require 'lib.samp.events'
active = 0

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("craft", process)
	while true do 
		wait(0)
        while not doFlag do wait(500) end
        local last = os.clock() -4 
        while doFlag do
            while os.clock() - last < 4 or active ~= 0 do wait(100) end
			last = os.clock()
            active = 1
            sampSendChat("/invex")
        end
	end
    wait(-1)
end

doFlag = false
function process(param)
    if param == "start" then
        doFlag = true
        sampAddChatMessage(u8:decode("Запущен крафт"), -1)
    elseif param == "stop" then
        doFlag = false
        sampAddChatMessage(u8:decode("Крафт остановлен"), -1)
    else
        sampAddChatMessage(u8:decode("Используйте /craft start или /craft stop"), -1)
    end
end

function se.onShowDialog(dialogId, _, title, _, _, text)
    if active > 0 then
        if title:find(u8:decode("Ваш инвентарь")) then
            if active == 1 then
                local items = split(text, '\n')
                if active == 1 then
                    for i = 1, #items do
                        if items[i]:find(u8:decode("Оружейная деталь")) then
                            sampSendDialogResponse(dialogId, 1, i-1, items[i])
                            active = 2
                            return false
                        end
                    end
                end
            elseif active == 6 then
                sampSendDialogResponse(dialogId, 0, 0, "")
                active = 0
                sampAddChatMessage(u8:decode("Вы скрафтили 1 снаряд"), -1)
                sampSendChat("/fstore take 3000")
                return false
            end
        elseif title:find(u8:decode("Выберите действие")) then
            if active == 2 then
                sampSendDialogResponse(dialogId, 1, 6, u8:decode("Создание патронов"))
                active = 3
                return false
            end
        elseif title:find(u8:decode("Создание патронов")) then
            if active == 4 then
                active = 5
                sampSendDialogResponse(dialogId, 1, 0, "1")
                return false
            elseif active == 3 then
                active = 4
                sampSendDialogResponse(dialogId, 1, 6, "")
                return false
            end
        elseif active == 5 then
            active = 6
            sampSendDialogResponse(dialogId, 1, 0, "")
            return false
        end
    end
end

function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end