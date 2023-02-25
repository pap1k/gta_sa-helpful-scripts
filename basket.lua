encoding = require("encoding")
encoding.default = 'CP1251'
u8 = encoding.UTF8

local se = require 'lib.samp.events'
local action = 0
local MODEL_ID = 2114
local HOOP_MODEL_ID = 946

checkchar = 0
ballId = 0
hoopId = 0
drawBall = false
ballSampId = 0
throwPos = nil
running = false

moveTimeout = 0.5
ts = os.clock()

lastFunc = ""
dbg = false

function se.onSetPlayerAttachedObject(playerid, index, create, obj)
	if obj.modelId == MODEL_ID then
		if action == 2 then
			action = 3
		end
	end
end

function se.onStopObject(id)
	if id == ballSampId then
		if dbg then sampAddChatMessage("STOP, action: "..action, -1) end
		if action == 6 then
			ts = os.clock()
			lastFunc = "onStopObject"
		end
	end
end


function se.onMoveObject(id, _)
	if id == ballSampId and action == 6 then
		ts = os.clock()
		lastFunc = "onMoveObject"
	end
end

function se.onSetObjectPosition(id, _)
	if id == ballSampId and action == 6 then
		ts = os.clock()
		lastFunc = "onSetObjectPosition"
	end
end

function se.onShowTextDraw(id, data)
	if data.text == u8:decode("~g~OЏ‡…ЌHO") and checkchar == 0 then
		checkchar = 1
	end
end


function se.onShowDialog(dialogId, _, title, _, _, text)
	if checkchar == 2 then
		local progress = text:match("D8A903}%( (%d+) / 900 %)")
		if tonumber(progress) and tonumber(progress) % 10 == 0 then
			sampAddChatMessage(progress.." / 900", -1)
		end
		lua_thread.create(function()
			wait(2000)
			checkchar = 0
		end)
		sampSendDialogResponse(dialogId, 0, 0, "")
		return false
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	
	sampRegisterChatCommand("b", command)
	
	while true do
		wait(0)
		if drawBall then
			if ballId ~= 0 then
				local result, positionX, positionY, positionZ = getObjectCoordinates(ballId)
				if result then
					local x, y = convert3DCoordsToScreen(positionX, positionY, positionZ)
					renderDrawBox(x, y, 10, 10, 0xAA42f5e9)
				end
			end
			if hoopId ~= 0 then
				local result, positionX, positionY, positionZ = getObjectCoordinates(hoopId)
				if result then
					local x, y = convert3DCoordsToScreen(positionX, positionY, positionZ)
					renderDrawBox(x, y, 10, 10, 0xAAf542ec)
				end
			end
		end
		if not running then
			if checkchar == 1 then
				sampSendChat("/charinfo")
				checkchar = 2
			end
			if action == 6 then
				if os.clock() - ts > moveTimeout then
				if dbg then sampAddChatMessage("LF: "..lastFunc, -1) end
					start()
				end
			elseif action == 1 then
				action = 2 -- pick and run to point
				local mx, my, mz = getCharCoordinates(playerPed)
				ballId = sampGetObjectHandleBySampId(ballSampId)
				local _, ox, oy, oz = getObjectCoordinates(ballId)
				if getDistanceBetweenCoords2d(mx, my, ox, oy) >= 0.9 then
					lua_thread.create(go_to_point, {x = ox, y = oy, z = oz}, false, function() action = 1 end)
				else
					lua_thread.create(function()
						while action == 2 do
							sendKey(2)
							wait(1000)
						end
					end)
				end
			elseif action == 3 then
				lua_thread.create(go_to_point, throwPos, false, function() action = 4 end)
			elseif action == 4 then
				local result, positionX, positionY, positionZ = getObjectCoordinates(hoopId)
				lua_thread.create(function(x, y, z)
					local startPosX, startPosY, startPosZ = getCharCoordinates(playerPed)
					setVirtualKeyDown(87, true)
					repeat
						set_camera_direction{x=x, y=y, z=z}
						wait(0)
						local curposX, curposY, curposZ = getCharCoordinates(playerPed)
					until getDistanceBetweenCoords2d(startPosX, startPosY, curposX, curposY ) > 1
					setVirtualKeyDown(87, false)
					action = 5
				end,
				positionX, positionY, positionX,Z)
			elseif action == 5 then
				sendKey(4)
				ts = os.clock()
				action = 6 -- wait
			end
		end
	end
end

function command(param)
	if param == "find" then
		ballId = getBallId()
		ballSampId = sampGetObjectSampIdByHandle(ballId)
		hoopId = getHoopId()
		drawBall = true
	elseif param == "dbg" then
		dbg = not dbg
	elseif param == "stop" then
		action = 0
		sampAddChatMessage(u8:decode("Остановлено"), -1)
	elseif param == "test" then
		local old = ballId
		local new = getBallId()
		print(old, new)
		local result, positionX, positionY, positionZ = getObjectCoordinates(old)
	elseif param == "start" then
		if not throwPos then
			sampAddChatMessage(u8:decode("Для начала установите позицию броска через /b pos"), -1)
		else
			start()
			drawBall = false
		end
	elseif param == "pos" then
		local x, y, z = getCharCoordinates(playerPed)
		throwPos = {x=x,y=y,z=z}
		sampAddChatMessage(u8:decode("Позиция сохранена"), -1)
	else
		sampAddChatMessage(u8:decode("Используйте /b find; /b pos; /b start"), -1)
	end
end

function tryGetCoords(callback)
	local ok, r = pcall(getObjectCoordinates(ballId))
	while not ok do wait(100) end
	callback()
end

function start()
	ballId = sampGetObjectHandleBySampId(ballSampId)
	local result, positionX, positionY, positionZ = getObjectCoordinates(ballId)
	if result then
		lua_thread.create(go_to_point, {x = positionX, y = positionY, z = positionZ}, false, function() action = 1 end)
	else
		sampAddChatMessage(u8:decode("Не могу получить корды мяча"), -1)
	end
end

function getBallId()
	local objects = getAllObjects()
	local ids = {}
	for k, v in ipairs(objects) do
		if doesObjectExist(v) and getObjectModel(v) == MODEL_ID then
			table.insert(ids, v)
		end
	end
	local x, y, z = getCharCoordinates(PLAYER_PED)
	local closest = 300
	local closestid = 0
	for k, v in ipairs(ids) do
		local result, positionX, positionY, positionZ = getObjectCoordinates(v)
		if result then
			local dist = getDistanceBetweenCoords3d(x, y, z, positionX, positionY, positionZ)
			if closest > dist then
				closestid = v
				closest = dist
			end
		end
	end
	return closestid
end

function getHoopId()
	local objects = getAllObjects()
	local ids = {}
	for k, v in ipairs(objects) do
		if doesObjectExist(v) and getObjectModel(v) == HOOP_MODEL_ID then
			table.insert(ids, v)
		end
	end
	local x, y, z = getCharCoordinates(PLAYER_PED)
	local closest = 300
	local closestid = 0
	for k, v in ipairs(ids) do
		local result, positionX, positionY, positionZ = getObjectCoordinates(v)
		if result then
			local dist = getDistanceBetweenCoords3d(x, y, z, positionX, positionY, positionZ)
			if closest > dist then
				closestid = v
				closest = dist
			end
		end
	end
	return closestid
end

function sendKey(key)
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local data = allocateMemory(68)
    sampStorePlayerOnfootData(myId, data)
    setStructElement(data, 4, 2, key)
    sampSendOnfootData(data)
    freeMemory(data)
end

function go_to_point(point, is_sprint, after)
	running = true
    local dist
    repeat
		setVirtualKeyDown(87, true)
        set_camera_direction(point)
        wait(0)
        local mx, my, mz = getCharCoordinates(playerPed)
        if is_sprint then setGameKeyState(16, 255) end
        dist = getDistanceBetweenCoords2d(point.x, point.y, mx, my)
    until dist < 0.6
	setVirtualKeyDown(87, false)
	if after then
		after()
	end
	running = false
end

function set_camera_direction(point)
    local c_pos_x, c_pos_y, c_pos_z = getActiveCameraCoordinates()
    local vect = {x = point.x - c_pos_x, y = point.y - c_pos_y}
    local ax = math.atan2(vect.y, -vect.x)
    setCameraPositionUnfixed(0.0, -ax)
end