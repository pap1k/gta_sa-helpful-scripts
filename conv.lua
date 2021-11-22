--[[
    Adds indicator on screen which shows convoy state. Move text - /conv
]]
local se = require 'lib.samp.events'
local font_flag = require('moonloader').font_flag

local rx, ry = getScreenResolution()
local scr = thisScript()

local isSet = false

local my_font = renderCreateFont('Verdana', FontSize, font_flag.BOLD+font_flag.SHADOW)
local nows = {ls = "{bcbcbc}", lv = "{bcbcbc}", sf = "{bcbcbc}"}
local ids = {}

function ACM(txt) sampAddChatMessage("[CONV] {54b5e2}"..txt, 0xff0000) end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
    repeat wait(0) until isSampAvailable()
    sampRegisterChatCommand("conv",function() isSet = not isSet showCursor(isSet, isSet) end)

    if not doesFileExist(scr.directory.."\\config\\cnv.txt") then
        saveSets('X="def"Y="def"')
    end

    local f = io.open(scr.directory.."\\config\\cnv.txt","r")
    local sets = f:read('*a')
    io.close(f)

    local func, err = load(sets)
    if func then
        local ok, err = pcall(func)
        if not ok then
            ACM("Ошибка какая-то")
            thisScript():unload()
        end
    end

    X = X == "def" and rx/2 or X
    Y = Y == "def" and ry-100 or Y

	while true do
        wait(0)
        if isSet then
            local nx, ny = getCursorPos()
            X = nx
            Y = ny
			if wasKeyPressed(1) then
				showCursor(false)
				isSet = false

                saveSets("X="..X.." Y="..Y)
			end
        end
		if sampGetChatDisplayMode() ~= 0 then
			renderFontDrawText(my_font, "{ffffff}-"..nows.ls.."LS{ffffff}-\n{ffffff}-"..nows.lv.."LV{ffffff}-\n{ffffff}-"..nows.sf.."SF{ffffff}-", X, Y, 0xFFFFFFFF)
		end
	end
end

function saveSets(str_to_insert)
    local newf = io.open(scr.directory.."\\config\\cnv.txt", "w")
    newf:write(str_to_insert)
    io.close(newf)
end

function se.onCreateGangZone(id, sqStart, sqEnd, color)
    if color == 1141969407 then --red color
        if sqStart.x > 1000 and sqStart.x > 1500 then
            ids.LS = id
        elseif sqStart.x < -1500 then
            ids.SF = id
        elseif sqStart.x > 0 and sqStart.x < 1000 then
            ids.LV = id
        end
    end
end

function se.onGangZoneFlash(id, color)
    if id == ids.SF then
        ACM("В SF начался конвой")
		nows.sf = "{20ff34}"
    end
	if id == ids.LS then
        ACM("В LS начался конвой")
		nows.ls = "{20ff34}"
    end
	if id == ids.LV then
        ACM("В LV начался конвой")
		nows.lv = "{20ff34}"
    end
end

function se.onGangZoneStopFlash(id)
	if id == ids.SF then
        ACM("В SF закончился конвой")
		nows.sf = "{bcbcbc}"
    end
	if id == ids.LS then
        ACM("В LS закончился конвой")
		nows.ls = "{bcbcbc}"
    end
	if id == ids.LV then
        ACM("В LV закончился конвой")
		nows.lv = "{bcbcbc}"
    end
end