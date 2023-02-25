encoding = require("encoding")
encoding.default = 'CP1251'
u8 = encoding.UTF8

local se = require 'lib.samp.events'
active = 0
theItem = "Freeman"
wasattempt = false

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("break", process)
	while true do 
		wait(0)
        while not doFlag do wait(500) end
        while doFlag do
			while active ~= 0 do wait(100) end
			wasattempt = false
			sampSendChat("/invex")
			active = 1
        end
	end
    wait(-1)
end

doFlag = false
function process(param)
    if param == "start" then
        doFlag = true
		active = 0
        sampAddChatMessage(u8:decode("Запущено ломание"), -1)
    elseif param == "stop" then
        doFlag = false
		active = 0
        sampAddChatMessage(u8:decode("ломание остановлено"), -1)
	elseif param == "test" then
		print(doFlag, active)
    else
        sampAddChatMessage(u8:decode("Используйте /break start или /break stop"), -1)
    end
end

function se.onServerMessage(color, text)
	if active > 0 then
		if text:find(u8:decode("дотронулся до шкафа")) then
			active = 228
			doFlag = false
			sampAddChatMessage(u8:decode("Шкаф сломан. Чиним"), -1)
			sampSendChat("/fix case")
		end
		if text:find(u8:decode("Шкаф успешно")) then
			doFlag = true
			active = 0
		end
	end
end

function se.onShowDialog(dialogId, _, title, _, _, text)
    if active > 0 then
        if title:find(u8:decode("Ваш инвентарь")) then
            if active == 1 then
                local items = split(text, '\n')
				for i = 1, #items do
					if items[i]:find(theItem) then
						active = 2
						sampSendDialogResponse(dialogId, 1, i-1, items[i])
						return false
					end
				end
				if wasattempt then
					doFlag = false
					active = 0
					sampAddChatMessage(u8:decode("Не найден указанный предмет"), -1)
				else
					wasattempt = true
					active = 4
					sampSendDialogResponse(dialogId, 0, 0, "")
					sampSendChat("/storeex")
					return false
				end
            elseif active == 3 then
                sampSendDialogResponse(dialogId, 0, 0, "")
                active = 4
                sampSendChat("/storeex")
                return false
            end
        elseif title:find(u8:decode("Выберите действие")) then
            if active == 2 then
				active = 3
                sampSendDialogResponse(dialogId, 1, 3, u8:decode("Положить в шкаф"))
                return false
            end
        elseif title:find(u8:decode("Cодержимое шкафа")) then
            if active == 4 then
				local items = split(text, '\n')
				active = 5
				for i = 1, #items do
					if items[i]:find(theItem) then
						active = 5
						sampSendDialogResponse(dialogId, 1, i-1, items[i])
						return false
					end
				end
                sampSendDialogResponse(dialogId, 0, 0, "")
				active = 0
                return false
            elseif active == 5 then
				sampSendDialogResponse(dialogId, 0, 0, "")
				active = 0
                return false
			end
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