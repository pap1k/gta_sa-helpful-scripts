working = false
function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	repeat wait(0) until isSampAvailable()
	sampRegisterChatCommand('fl', fl)
	sampRegisterChatCommand('flstop', fls)
	sampRegisterChatCommand('fls', fls)
	wait(-1)
end
function fls()
flooadthread:terminate()
sampAddChatMessage("Флудер остановлен", 0xaaaaaa)
working = false
end
function fl(str)
	if str ~= "" then
		local data = mysplit(str)
		if data[1] == "" or data[2] == "" or data[3] == "" then
			sampAddChatMessage("Используй: /fl [команда|текст] [кол-во повторений] [задержка в мс]", 0xaaaaaa)
		else
			local text = tryToSent(data[1])
			local times = tonumber(data[2])
			if times and times >= 0 then
				local delay = tonumber(data[3])
				if delay and delay > 0 then
					if not working then
						flooadthread = lua_thread.create(flood, text, times, delay)
					else
						sampAddChatMessage("Уже запущен флудер. Дождитесь окончания его работы.", 0xaaaaaa)
					end
				else
					sampAddChatMessage("Задержка должна быть положительным числом", 0xaaaaaa)
				end
			else
				sampAddChatMessage("Количество посторений должно быть положительным числом", 0xaaaaaa)
			end
		end
	else
		sampAddChatMessage("Используй: /fl [команда|текст] [кол-во повторений] [задержка в мс]", 0xaaaaaa)
	end
end

function flood(str, times, delay)
	working = true
	if times == 0 then
		while true do
			sampSendChat(str)
			times = times - 1
			wait(delay)
		end
	else
		while times > 0 do
			sampSendChat(str)
			times = times - 1
			wait(delay)
		end
	end
	working = false
end

function tryToSent(str)
	local s = string.gsub(str, "_", " ")
	print(s)
	return s
end

function mysplit(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end