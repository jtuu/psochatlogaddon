local function init()
    return {
        name = "chatlog",
        version = "0.0.1",
        author = "esc"
    }
end

local CHAT_PTR = 0x00A9A920
local prevmaxy = 0
local MSG_PATTERN = '^(.-) > \t([EJ])(.+)'
local QCHAT_PATTERN = '^(.-) >( )(.+)$'
local UPDATE_INTERVAL = 30
local counter = UPDATE_INTERVAL - 1
local MSG_OFFSET = 4
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
                -- nvm lua doesn't seem to support unicode...
                -- also the default imgui font doesn't have many chars anyway
            end
            if cur_byte and cur_byte ~= 0x0 then
                rawmsg = rawmsg .. string.char(cur_byte) end
            prev_byte = msgbuf[2]
            i = i + 2
        end
        if rawmsg ~= nil and #rawmsg > 0 then
            local name, locale, msg = string.match(rawmsg, MSG_PATTERN)
            rawmsg = string.gsub(rawmsg, '\n', ' ')
            if not msg then
                name, locale, msg = string.match(rawmsg, QCHAT_PATTERN)
            end
            table.insert(messages, string.format("%-11s", name) .. "| " .. msg)
        end
    end
    return messages
end

imgui.SetNextWindowSize(550, 350)
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
        output_messages = get_chat_log()
        counter = 0
    end

    for i,msg in ipairs(output_messages) do
        imgui.TextWrapped(msg)
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
