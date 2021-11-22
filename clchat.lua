local memory = require("memory")
function main()
	sampRegisterChatCommand("cls", function()
		local chatptr = sampGetChatInfoPtr()
		memory.fill(chatptr+306, 0x0, 25200)
		setStructElement(chatptr, 25562, 4, 1)
	end)
	wait(-1)
end
