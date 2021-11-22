--[[
	Target on a player and press Z to get fast info about him. Works only on Trinity	
]]
script_name('FastInfo')
script_author('papercut')

require "lib.moonloader"
local memory = require 'memory'
local ffi = require "ffi"
local se = require "lib.samp.events"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
isact = false
pid = -1

--===================
local ACTIVEKEY = 90
--===================

function main() 
	repeat wait(0) until isSampAvailable()
	sampRegisterChatCommand('inf', function(lid)
		if lid ~= '' then
			if not tonumber(lid) then sampAddChatMessage('Используйте /inf [id]', 0x5fdbea) return end
			isact = true
			pid = lid
			sampSendChat('/num '..pid)
		else
			sampAddChatMessage('Используйте /inf [id]', 0x5fdbea)
		end
	end)
	sampAddChatMessage('FastInfo by {ee3142}papercut. {2dd282}Активация: {e6f02b}прицел + Z {2dd282}или {e6f02b}/inf', 0x5fdbea)
	while true do
		wait(0)
		if wasKeyPressed(ACTIVEKEY) then
			local result, ped = getCharPlayerIsTargeting(player)
			if result then
				result, id = sampGetPlayerIdByCharHandle(ped)
				if result then
					isact = true
					pid = id
					sampSendChat('/num '..pid)
				end
			else
				local result, id = getId()
				if result then
					isact = true
					pid = id
					sampSendChat('/num '..pid)
				end				
			end
		end
	end
end

function getId()
	local camMode = getActiveCamMode()
	local camAiming = (camMode == 53 or camMode == 7 or camMode == 8 or camMode == 51)
	if camAiming then
			for id = 0, 1004 do
				if sampIsPlayerConnected(id) then
				local result, handle = sampGetCharHandleBySampPlayerId(id)
					if result and doesCharExist(handle) and isCharOnScreen(handle) then
			        local X, Y, Z = getBodyPartCoordinates(3, handle) 
			        local X, Y = convert3DCoordsToScreen(X, Y, Z)
			        local X, Y = convertWindowScreenCoordsToGameScreenCoords(X, Y)
			        local X1, Y1, Z1 = getBodyPartCoordinates(3, handle)
			        local X2, Y2, Z2 = getBodyPartCoordinates(4, handle)
			        local X1, Y1 = convert3DCoordsToScreen(X1, Y1, Z1)
			        local X2, Y2 = convert3DCoordsToScreen(X2, Y2, Z2)
			        local X1, Y1 = convertWindowScreenCoordsToGameScreenCoords(X1, Y1)
			        local X2, Y2 = convertWindowScreenCoordsToGameScreenCoords(X2, Y2)
				        if X < (339.0 + (Y1 - Y2)) and X > (339.0 - (Y1 - Y2)) and Y < (179.0 + ((Y1 - Y2) * 3.0)) and Y > (179.0 - ((Y1 - Y2) * 3.0)) then
							local r, id = sampGetPlayerIdByCharHandle(handle)
							if r then return true, id end
				       end
					end
				end
			end
		end
	return false
end

function se.onServerMessage(color, text)
	if isact and text:find('{F5DEB3}Имя: .* Телефон: .* Проживает в: .*') then
		local country = ''
			if text:find('{F5DEB3}Имя: .* Телефон: .* Проживает в: .*') then
				country = string.match(text, '{F5DEB3}Имя: {ffffff}.*{F5DEB3} Телефон: {ffffff}.*{F5DEB3} Проживает в: {ffffff}(%a+){F5DEB3}%.')
			end
		sampAddChatMessage('Игрок {5fdbea}'..sampGetPlayerNickname(pid).. '['..pid..']{e64c5a} Уровень {5fdbea}'..sampGetPlayerScore(pid)..'{e64c5a} Проживает в {5fdbea}'..country, 0xe64c5a)
		isact = false
		return false
	end
	if isact and text:find('Телефонный справочник') then
		return false
	end
	if isact and text:find('не найден в телефонном справочнике') then
		sampAddChatMessage('Игрок {5fdbea}'..sampGetPlayerNickname(pid).. '['..pid..']{e64c5a} Уровень {5fdbea}'..sampGetPlayerScore(pid)..'{e64c5a} Нет данных по стране проживания', 0xe64c5a)
		isact = false
		return false
	end
end
function getBodyPartCoordinates(id, handle)
  local pedptr = getCharPointer(handle)
  local vec = ffi.new("float[3]")
  getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
  return vec[0], vec[1], vec[2]
end

function getActiveCamMode()
	local activeCamId = memory.getint8(0x00B6F028 + 0x59)
	return getCamMode(activeCamId)
end

function getCamMode(id)
	local cams = 0x00B6F028 + 0x174
	local cam = cams + id * 0x238
	return memory.getint16(cam + 0x0C)
end