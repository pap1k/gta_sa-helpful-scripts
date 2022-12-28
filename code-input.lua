local se = require("samp.events")
local step = 0
local collation = { }
local added = 0
local submit = 0
local nextnum = -1

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end

    while true do
        if step == 4 then
            local id = -1
            if wasKeyPressed(13) then
                id = submit
            else
                for i = 48, 57 do
                    if wasKeyPressed(i) then
                        print(i-47)
                        id = collation[i-47]
                        break
                    end
                end
            end
            if id ~= -1 then
                sampSendClickTextdraw(id)
                if id == submit then
                   reset()
                end
            end
        end
        wait(0)
    end
end

function se.onSendClientJoin()
    reset()
end


function se.onShowTextDraw(id, data)
    print(id, data.text)
    if step ~= 3 then
        if step == 0 and data.text == 'submit' then
            step = 1
            submit = id
        elseif step == 1 and data.text == 'enter your password:' then
            step = 3
        end
    else
        if data.text == '_' then
            if nextnum ~= -1 then
                collation[nextnum] = id
                added = added +1
            end
        else
            num = trim(data.text)
            if tonumber(num) then
                nextnum = tonumber(num)+1
            end
        end
        
        if added == 10 then
            step = 4
        end
    end
end

function reset()
    step = 0
    submit = -1
    collation = {}
    added = 0
    nextnum = -1
end

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
 end