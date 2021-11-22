--[[
	Start to type nick into chat window and press TAB to autocomplete it
]]

script_name('tab-nick')
script_author('papercut')

require "lib.moonloader"

function check(sn, cn)
	local l = cn:len()
    snlower = sn:lower()
	for i = 1, l do
		if cn:byte(i) ~= snlower:byte(i) then return "-1" end
	end
	return sn
end

function main()
	repeat wait(0) until isSampAvailable()
	while true do
		wait(0)
		if wasKeyPressed(VK_TAB) and sampIsChatInputActive() then
			local curtext = sampGetChatInputText()
			local l = curtext:len()
			local curnick = ""
			local save = ""
			local done = false
			for i = l, 1, -1 do
				if curtext:byte(i) == 32 then
					for j = i+1, l do
						curnick = curnick..string.char(curtext:byte(j))
					end
					for j = i, 1, -1 do
						save = string.char(curtext:byte(j))..save
					end
					done = true
					break
				end
				if i == 1 then
					for j = i, l do
						curnick = curnick..string.char(curtext:byte(j))
					end
					for j = i-1, 1, -1 do
						save = string.char(curtext:byte(j))..save
					end
					done = true
					break
				end
			end
			if done then
			local m = sampGetMaxPlayerId(false)
				for i = 0, m do
					if sampIsPlayerConnected(i) and not sampIsPlayerNpc(i) then
						local n = check(sampGetPlayerNickname(i), curnick:lower())
						if n ~= "-1" then
							sampSetChatInputText(save..n)
						end
					end
				end
				local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				local n = check(sampGetPlayerNickname(myid), curnick)
				if n ~= "-1" then
					sampSetChatInputText(save..n)
				end
			end
		end
	end
end