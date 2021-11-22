--[[
	Adds /taketable command to take table for auction	
]]
local se = require 'lib.samp.events'
local active = 0
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("taketable", take)
end

function take()
	sampSendChat("/invex")
	active = 1
	function se.onShowDialog(dialogId, _, title, _, _, text)
		if active > 0 then
			local items = split(text, '\n')
			if title:find("инвентарь") then
				if active == 1 then
					for i = 1, #items do
						if items[i]:find("Табличка для аукциона") then
							sampSendDialogResponse(dialogId, 1, i-1, "")
							active = 2
							return false
						end
					end
				elseif active == 3 then
					active = 0
					sampSendDialogResponse(dialogId, 0, 0, "")
					return false
				end
			end
			if title:find("Выберите действие") then
				active = 3
				sampSendDialogResponse(dialogId, 1, 5, "")
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