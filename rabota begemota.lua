local SampEvents = require 'lib.samp.events'
GameKeys = require 'game.keys'
curr = 3
slot = 0

function getSlot(a)
	return (a - 150) / 24 + 1
end

function getYellowSlot(a)
	return (a - 170) / 24 + 1
end

function PressY()
	setGameKeyState(GameKeys.player.CONVERSATIONYES, -1)
	setGameKeyState(0, -1)
end

function PressN()
	setGameKeyState(GameKeys.player.CONVERSATIONNO, -1)
	setGameKeyState(0, -1)
end

delay = 0.2
last = os.clock() - delay

function Move()
	lua_thread.create(function()
		while os.clock() - last < delay do wait(10) end
		last = os.clock()
		if slot == 0 or curr == 0 then
			return
		end
		if slot > curr then
			setGameKeyState(GameKeys.player.CONVERSATIONNO, -1)
			setGameKeyState(0, -1)
			curr = 0
		end
		if curr > slot then
			setGameKeyState(GameKeys.player.CONVERSATIONYES, -1)
			setGameKeyState(0, -1)
			curr = 0
		end
		if slot == curr then
			setGameKeyState(GameKeys.player.SPRINT, -1)
			setGameKeyState(0, -1)
			slot = 0
		end
	end)
end
--[[
function SampEvents.onShowDialog(dialogId, _, title, _, _, text)
	if title:find("Удаление татуировки") then
		sampSendDialogResponse(dialogId, 1, 0, "")
		return false
	end
end
]]

function SampEvents.onShowTextDraw(id, data)
	if data.position.x == 247 and (data.position.y - 150) % 24 == 0 and data.modelId == 19265 then
		slot = getSlot(data.position.y)
		Move()
	end
	if data.letterColor == -16711681 and data.position.x == 215.5 and (data.position.y - 170) % 24 == 0 then
		curr = getYellowSlot(data.position.y)
		Move()
	end
	-- YN
	if data.text == '~r~Y' then
		PressY()
	end
	if data.text == '~g~Y' then
		PressY()
	end
	if data.text == '~r~N' then
		PressN()
	end
	if data.text == '~g~N' then
		PressN()
	end
end
