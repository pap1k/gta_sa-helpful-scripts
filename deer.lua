local se = require("samp.events")

local DEER_MODEL_ID = 19315
local deer_samp_id = 0
local iconId = 0
local font_flag = require('moonloader').font_flag
local my_font = renderCreateFont('Verdana', FontSize, font_flag.BOLD+font_flag.SHADOW)

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

    while true do
        wait(0)
        if deer_samp_id ~= 0 then
            local r, posx, posy, posz = getObjectCoordinates(deer_samp_id)
            if r then
                local x, y = convert3DCoordsToScreen(posx,posy, posz)
                renderDrawBox(x, y, 5, 5, -1)
                local myposx, myposy, myposz = getCharCoordinates(PLAYER_PED)
                local dist = getDistanceBetweenCoords3d(posx, posy, posz, myposx, myposy, myposz)
                dist = math.floor(dist)
                renderFontDrawText(my_font, dist, x, y+10, -1)
            end
        end
    end
    
end

function se.onSetMapIcon(id, pos, itype, color, style)
    if itype == 19 then
        deer_samp_id = getDeerId(pos)
        iconId = id
    end
end

function se.onRemoveMapIcon(id)
    if id == iconId then
        drawtest = false
        iconId = 0
        deer_samp_id = 0
    end
end

function getDeerId(pos)
	local objects = getAllObjects()
	local ids = {}
	for k, v in ipairs(objects) do
		if doesObjectExist(v) and getObjectModel(v) == DEER_MODEL_ID then
			table.insert(ids, v)
		end
	end
	local closest = 300
	local closestid = 0
	for k, v in ipairs(ids) do
		local result, positionX, positionY, positionZ = getObjectCoordinates(v)
		if result then
			local dist = getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, positionX, positionY, positionZ)
			if closest > dist then
				closestid = v
				closest = dist
			end
		end
	end
	return closestid
end