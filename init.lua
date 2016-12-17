local function init()
    return {
        name = "chatlog",
        version = "0.0.1",
        author = "esc"
    }
end

local CHAT_PTR = 0x00A9A920
local prevmaxy = 0
-- E english
-- J japonese
-- T traditional chinese i think
-- K korean
-- i think there"s more but haven"t run into any ingame yet
local LOCALES = "EJTK"
local MSG_MATCH = "^(.-) > \t([" .. LOCALES .. "])(.+)"
local MSG_REPLACE = "^\t[" .. LOCALES .. "]"
local QCHAT_MATCH = "^(.-) >( )(.+)$"
local QCHAT_REPLACE = "(> )\t[" .. LOCALES .. "]"
local UPDATE_INTERVAL = 30
local counter = UPDATE_INTERVAL - 1
local MSG_OFFSET = 0
local output_messages = {}

local function get_chat_log()
    local messages = {}
    for i = 0, 30 do -- for each pointer to a message, 30 seems like a good amount
        local buf = {}
        pso.read_mem(buf, CHAT_PTR + i * 4, 4)
        local ptr = 0 -- message pointer
        for k,v in ipairs(buf) do
            ptr = ptr .. string.format("%.2X", v, 8)
        end
        ptr = bit.bswap(tonumber(ptr, 16)) + MSG_OFFSET
        local cur_byte = -1 -- msg data
        local prev_byte = -1
        local i = 0 -- msg pos
        local rawmsg = ""
        -- read message one byte at a time
        while (cur_byte and cur_byte ~= 0) or (prev_byte and prev_byte ~= 0) do -- eof if both are null
            local msgbuf = {}
            pcall(pso.read_mem, msgbuf, ptr + i, 2) -- for some reason the read_mem throws errors
            cur_byte = msgbuf[1]
            -- multibyte char
            if(msgbuf[2] and msgbuf[2] ~= 0) then
                -- cur_byte = tonumber(string.format("%.2X", msgbuf[2], 8) .. string.format("%.2X", msgbuf[1], 8), 16)
                -- nvm lua doesn"t seem to support unicode...
                -- also the default imgui font doesn"t have many chars anyway
            end
            if cur_byte and cur_byte ~= 0x0 then
                rawmsg = rawmsg .. string.char(cur_byte) end
            prev_byte = msgbuf[2]
            i = i + 2
        end
        if rawmsg ~= nil and #rawmsg > 0 then
            rawmsg = string.gsub(rawmsg, MSG_REPLACE, "")
            local name, locale, msg = string.match(rawmsg, MSG_MATCH)
            rawmsg = string.gsub(rawmsg, "\n", " ")
            if not msg then
                rawmsg = string.gsub(rawmsg, QCHAT_REPLACE, "%1")
                name, locale, msg = string.match(rawmsg, QCHAT_MATCH)
            end
            table.insert(messages, {name = name, text = msg})
        end
    end
    return messages
end

local GC_PTR = 0x00A46B8C
local CHARACTERLIST_PTR = 0x00AAACC0
local CHARACTERNAME_OFFSET = 36
local GC_OFFSET = 4
local CHARACTER_OFFSET = 68
local MAX_PLAYERS = 12

local function read_pso_str(addr, len)
    local buf = {}
    pso.read_mem(buf, addr, len)
    local str = ""

    local i = 0
    while i < len do
        i = i + 2
        local b1 = buf[i - 1]
        local b2 = buf[i]

        xpcall(function() str = str .. string.char(b1) end, function(err) str = str .. "?" end)
    end

    return str
end

local function get_gc()
    return pso.read_u32(GC_PTR)
end

local function get_charactername(gc)
    for i = 0, MAX_PLAYERS do
        local gc0 = pso.read_u32(CHARACTERLIST_PTR + CHARACTER_OFFSET * i + GC_OFFSET)
        if(gc == gc0) then
            return read_pso_str(CHARACTERLIST_PTR + CHARACTER_OFFSET * i + CHARACTERNAME_OFFSET, 20)
        end
    end
    return nil
end

local HILIGHT_COLOR = {0.5, 1, 0, 1}
imgui.SetNextWindowSize(550, 350)
local own_name = ""
local function present()
    counter = counter + 1

    imgui.Begin("Chatlog")

    local sy = imgui.GetScrollY()
    local sym = imgui.GetScrollMaxY()
    scrolldown = false
    if imgui.GetScrollY() <= 0 or prevmaxy == imgui.GetScrollY() then
        scrolldown = true
    end

    if counter % UPDATE_INTERVAL == 0 then
        own_name = string.gsub(string.lower(get_charactername(get_gc())), "%z", "")
        output_messages = get_chat_log()
        counter = 0
    end

    for i,msg in ipairs(output_messages) do
        local formatted = string.format("%-11s", msg.name) .. -- rpad name
                          "| " .. string.gsub(msg.text, "%%", "%%%%") -- escape %
        local lower = string.lower(msg.text) -- for case insensitive matching

        -- full word match own name
        if string.match(lower, own_name) and
            (
                string.match(lower, "^" .. own_name .. "[%p%s]") or
                string.match(lower, "[%p%s]" .. own_name .. "[%p%s]") or
                string.match(lower, "[%p%s]" .. own_name .. "$") or
                string.match(lower, "^" .. own_name .. "$")
            ) then
                -- hilight message
                imgui.PushTextWrapPos(0)
                imgui.TextColored(HILIGHT_COLOR[1], HILIGHT_COLOR[2], HILIGHT_COLOR[3], HILIGHT_COLOR[4], formatted)
                imgui.PopTextWrapPos()
        else
            imgui.TextWrapped(formatted)
        end
    end

    if scrolldown then
        imgui.SetScrollY(imgui.GetScrollMaxY())
    end

    prevmaxy = imgui.GetScrollMaxY()
    imgui.End()
end

pso.on_init(init)
pso.on_present(present)

return {
    init = init,
    present = present
}
