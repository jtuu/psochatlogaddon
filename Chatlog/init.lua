local core_mainmenu = require("core_mainmenu")
local cfg = require("Chatlog.configuration")
local optionsLoaded, options = pcall(require, "Chatlog.options")

local optionsFileName = "addons/Chatlog/options.lua"
local firstPresent = true
local ConfigurationWindow

-- Helpers in solylib
local function _getMenuState()
    local offsets = {
        0x00A98478,
        0x00000010,
        0x0000001E,
    }
    local address = 0
    local value = -1
    local bad_read = false
    for k, v in pairs(offsets) do
        if address ~= -1 then
            address = pso.read_u32(address + v)
            if address == 0 then
                address = -1
            end
        end
    end
    if address ~= -1 then
        value = bit.band(address, 0xFFFF)
    end
    return value
end
local function IsMenuOpen()
    local menuOpen = 0x43
    local menuState = _getMenuState()
    return menuState == menuOpen
end
local function IsSymbolChatOpen()
    local wordSelectOpen = 0x40
    local menuState = _getMenuState()
    return menuState == wordSelectOpen
end
local function IsMenuUnavailable()
    local menuState = _getMenuState()
    return menuState == -1
end
local function NotNilOrDefault(value, default)
    if value == nil then
        return default
    else
        return value
    end
end
local function GetPosBySizeAndAnchor(_x, _y, _w, _h, _anchor)
    local x
    local y

    local resW = pso.read_u16(0x00A46C48)
    local resH = pso.read_u16(0x00A46C4A)

    -- Top left
    if _anchor == 1 then
        x = _x
        y = _y

    -- Left
    elseif _anchor == 2 then
        x = _x
        y = (resH / 2) - (_h / 2) + _y

    -- Bottom left
    elseif _anchor == 3 then
        x = _x
        y = resH - _h + _y

    -- Top
    elseif _anchor == 4 then
        x = (resW / 2) - (_w / 2) + _x
        y = _y

    -- Center
    elseif _anchor == 5 then
        x = (resW / 2) - (_w / 2) + _x
        y = (resH / 2) - (_h / 2) + _y

    -- Bottom
    elseif _anchor == 6 then
        x = (resW / 2) - (_w / 2) + _x
        y = resH - _h + _y

    -- Top right
    elseif _anchor == 7 then
        x = resW - _w + _x
        y = _y

    -- Right
    elseif _anchor == 8 then
        x = resW - _w + _x
        y = (resH / 2) - (_h / 2) + _y

    -- Bottom right
    elseif _anchor == 9 then
        x = resW - _w + _x
        y = resH - _h + _y

    -- Whatever
    else
        x = _x
        y = _y
    end

    return { x, y }
end
-- End of helpers in solylib

if optionsLoaded then
    -- If options loaded, make sure we have all those we need
    options.configurationEnableWindow = NotNilOrDefault(options.configurationEnableWindow, true)
    options.enable                    = NotNilOrDefault(options.enable, true)
    options.useCustomTheme            = NotNilOrDefault(options.useCustomTheme, false)
    options.fontScale                 = NotNilOrDefault(options.fontScale, 1.0)

    options.clEnableWindow            = NotNilOrDefault(options.clEnableWindow, true)
    options.clHideWhenMenu            = NotNilOrDefault(options.clHideWhenMenu, true)
    options.clHideWhenSymbolChat      = NotNilOrDefault(options.clHideWhenSymbolChat, true)
    options.clHideWhenMenuUnavailable = NotNilOrDefault(options.clHideWhenMenuUnavailable, true)
    options.clChanged                 = NotNilOrDefault(options.clChanged, false)
    options.clAnchor                  = NotNilOrDefault(options.clAnchor, 1)
    options.clX                       = NotNilOrDefault(options.clX, 50)
    options.clY                       = NotNilOrDefault(options.clY, 50)
    options.clW                       = NotNilOrDefault(options.clW, 450)
    options.clH                       = NotNilOrDefault(options.clH, 350)
    options.clNoTitleBar              = NotNilOrDefault(options.clNoTitleBar, "")
    options.clNoResize                = NotNilOrDefault(options.clNoResize, "")
    options.clNoMove                  = NotNilOrDefault(options.clNoMove, "")
    options.clNoTimestamp             = NotNilOrDefault(options.clNoTimestamp, "")
    options.clTransparentWindow       = NotNilOrDefault(options.clTransparentWindow, false)
    options.clMessageSeparator        = NotNilOrDefault(options.clMessageSeparator, " | ")
    options.clFixedWidthNames         = NotNilOrDefault(options.clFixedWidthNames, true)
    options.clColoredNames            = NotNilOrDefault(options.clColoredNames, false)
    options.clNameColorR              = NotNilOrDefault(options.clNameColorR, 0.5)
    options.clNameColorG              = NotNilOrDefault(options.clNameColorG, 0.8)
    options.clNameColorB              = NotNilOrDefault(options.clNameColorB, 1.0)
    options.clNameColorA              = NotNilOrDefault(options.clNameColorA, 1.0)
    options.clCustomHighlight         = NotNilOrDefault(options.clCustomHighlight, false)
    options.clHighlightColorR         = NotNilOrDefault(options.clHighlightColorR, 0.5)
    options.clHighlightColorG         = NotNilOrDefault(options.clHighlightColorG, 1.0)
    options.clHighlightColorB         = NotNilOrDefault(options.clHighlightColorB, 0.0)
    options.clHighlightColorA         = NotNilOrDefault(options.clHighlightColorA, 1.0)

else
    options =
    {
        configurationEnableWindow = true,
        enable = true,
        useCustomTheme = false,
        fontScale = 1.0,

        clEnableWindow = true,
        clHideWhenMenu = false,
        clHideWhenSymbolChat = false,
        clHideWhenMenuUnavailable = false,
        clChanged = false,
        clAnchor = 1,
        clX = 50,
        clY = 50,
        clW = 450,
        clH = 350,
        clNoTitleBar = "",
        clNoResize = "",
        clNoMove = "",
        clNoTimestamp = "",
        clTransparentWindow = false,
        clMessageSeparator = " | ",
        clFixedWidthNames = true,
        clColoredNames = false,
        clNameColorR = 1,
        clNameColorG = 1,
        clNameColorB = 1,
        clNameColorA = 1,
        clCustomHighlight = false,
        clHighlightColorR = 0.5,
        clHighlightColorG = 1.0,
        clHighlightColorB = 0.0,
        clHighlightColorA = 1.0,

    }
end

local function SaveOptions(options)
    local file = io.open(optionsFileName, "w")
    if file ~= nil then
        io.output(file)

        io.write("return\n")
        io.write("{\n")
        io.write(string.format("    configurationEnableWindow = %s,\n", tostring(options.configurationEnableWindow)))
        io.write(string.format("    enable = %s,\n", tostring(options.enable)))
        io.write(string.format("    useCustomTheme = %s,\n", tostring(options.useCustomTheme)))
        io.write(string.format("    fontScale = %s,\n", tostring(options.fontScale)))
        io.write("\n")
        io.write(string.format("    clEnableWindow = %s,\n", tostring(options.clEnableWindow)))
        io.write(string.format("    clHideWhenMenu = %s,\n", tostring(options.clHideWhenMenu)))
        io.write(string.format("    clHideWhenSymbolChat = %s,\n", tostring(options.clHideWhenSymbolChat)))
        io.write(string.format("    clHideWhenMenuUnavailable = %s,\n", tostring(options.clHideWhenMenuUnavailable)))
        io.write(string.format("    clChanged = %s,\n", tostring(options.clChanged)))
        io.write(string.format("    clAnchor = %i,\n", options.clAnchor))
        io.write(string.format("    clX = %i,\n", options.clX))
        io.write(string.format("    clY = %i,\n", options.clY))
        io.write(string.format("    clW = %i,\n", options.clW))
        io.write(string.format("    clH = %i,\n", options.clH))
        io.write(string.format("    clNoTitleBar = \"%s\",\n", options.clNoTitleBar))
        io.write(string.format("    clNoResize = \"%s\",\n", options.clNoResize))
        io.write(string.format("    clNoMove = \"%s\",\n", options.clNoMove))
        io.write(string.format("    clNoTimestamp = \"%s\",\n", options.clNoTimestamp))
        io.write(string.format("    clTransparentWindow = %s,\n", tostring(options.clTransparentWindow)))
        io.write(string.format("    clMessageSeparator = \"%s\",\n", options.clMessageSeparator))
        io.write(string.format("    clFixedWidthNames = %s,\n", tostring(options.clFixedWidthNames)))
        io.write(string.format("    clColoredNames = %s,\n", tostring(options.clColoredNames)))
        io.write(string.format("    clNameColorR = %s,\n", tostring(options.clNameColorR)))
        io.write(string.format("    clNameColorG = %s,\n", tostring(options.clNameColorG)))
        io.write(string.format("    clNameColorB = %s,\n", tostring(options.clNameColorB)))
        io.write(string.format("    clNameColorA = %s,\n", tostring(options.clNameColorA)))
        io.write(string.format("    clCustomHighlight = %s,\n", tostring(options.clCustomHighlight)))
        io.write(string.format("    clHighlightColorR = %s,\n", tostring(options.clHighlightColorR)))
        io.write(string.format("    clHighlightColorG = %s,\n", tostring(options.clHighlightColorG)))
        io.write(string.format("    clHighlightColorB = %s,\n", tostring(options.clHighlightColorB)))
        io.write(string.format("    clHighlightColorA = %s,\n", tostring(options.clHighlightColorA)))

        io.write("}\n")

        io.close(file)
    end
end


local CHAT_PTR = 0x00A9A920
local prevmaxy = 0
-- E english
-- J japonese
-- B simple chinese
-- T traditional chinese
-- K korean
-- i think there's more but haven't run into any ingame yet
-- unknown locales will cause parsing issues
local LOCALES = "EJTKB"
local MSG_MATCH = "^(.-) > \t([" .. LOCALES .. "])(.+)"
local MSG_REPLACE = "^\t[" .. LOCALES .. "]"
local QCHAT_MATCH = "^(.-) >( )(.+)$"
local QCHAT_REPLACE = "(> )\t[" .. LOCALES .. "]"
local MAX_GAME_LOG = 29 -- max amount of messages the game stores
local MAX_MSG_SIZE = 100 -- not correct but close enough, character name length seems to affect it
local output_messages = {}

local function get_chat_log()
    local messages = {}
    for i = 0, MAX_GAME_LOG do -- for each pointer to a message
        local ptr = pso.read_u32(CHAT_PTR + i * 4)

        if ptr and ptr ~= 0 then
            local rawmsg = pso.read_wstr(ptr, MAX_MSG_SIZE)
            -- was there any message?
            if rawmsg ~= nil and #rawmsg > 0 then
                rawmsg = string.gsub(rawmsg, MSG_REPLACE, "") -- remove some shit
                local name, locale, msg = string.match(rawmsg, MSG_MATCH) -- try match the rights parts
                rawmsg = string.gsub(rawmsg, "\n", " ") -- replace newlines
                if not msg then
                    -- failed to match regular message format,
                    -- so it's probably a quickchat message
                    rawmsg = string.gsub(rawmsg, QCHAT_REPLACE, "%1") -- remove some shit
                    name, locale, msg = string.match(rawmsg, QCHAT_MATCH) -- try match again
                end
                -- good enough
                local sanitizedName = name
                if pso.require_version == nil or not pso.require_version(3, 6, 0) then
                    sanitizedName = string.gsub(name, "%%", "%%%%") -- escape '%'
                end
                sanitizedName = string.gsub(sanitizedName, "%s+$", "")
                table.insert(messages, {name = sanitizedName, text = msg, date = "??:??:??"})
            end
        end
    end
    return messages
end

local GC_PTR = 0x00A46B8C
-- Read character data from the player pointers and not the player & team data.
local CHARACTERLIST_PTR = 0x00A94254
local CHARACTERNAME_OFFSET = 0x980
local GC_OFFSET = 0xeb4
local MAX_PLAYERS = 12

-- Len is max number of wide chars to read.
local function read_wstr_max_size(addr, len)
    -- Read the UTF-16 string and convert it to UTF-8
    local wstr = pso.read_wstr(addr, len)

    -- If the first character is \t, then the name has a language code. This should 
    -- always be true while reading the character name out of the player object.
    -- utf8 library isn't available in the plugin's Lua implementation
    -- and string.byte() will truncate the return value to a single byte, so have
    -- to read the address again to check.
    local first_wchar = pso.read_u16(addr)
    if first_wchar == 0x0009 and #wstr >= 2 then
        wstr = string.sub(wstr, 3)
    end

    return wstr
end

local function get_gc()
    return pso.read_u32(GC_PTR)
end

local function get_charactername(gc)
    for i = 0, MAX_PLAYERS do

        local player = pso.read_u32(CHARACTERLIST_PTR + 4 * i)
        if player ~= 0 then
            local gc0 = pso.read_u32(player + GC_OFFSET)
            if gc == gc0 then
                -- 12 utf-16 chars because two for language code and then 10 for the name.
                return read_wstr_max_size(player + CHARACTERNAME_OFFSET, 12)
            end
        end
    end
    return nil
end

local UPDATE_INTERVAL = 30
local counter = UPDATE_INTERVAL - 1
local MAX_LOG_SIZE = 1000
local function getHighlightColor()
    if options.clCustomHighlight then
        return {
            options.clHighlightColorR,
            options.clHighlightColorG,
            options.clHighlightColorB,
            options.clHighlightColorA
        }
    else
        return {0.5, 1.0, 0.0, 1.0}
    end
end

local own_name = ""

local function TextCustomColored(r, g, b, a, text)
    if not r or not g or not b or not a then 
        return imgui.Text(text) 
    end
    return imgui.TextColored(r, g, b, a, text)
end

local function DoChat()
    counter = counter + 1

    if counter % UPDATE_INTERVAL == 0 then
        local sy = imgui.GetScrollY()
        local sym = imgui.GetScrollMaxY()
        scrolldown = false

        if sy <= 0 or prevmaxy == sy then
            scrolldown = true
        end

        -- Check if we have a character name, can be null if we are not online yet
        character_name = get_charactername(get_gc())
        if character_name ~= nil then
            -- apparently there's null characters in the name?
            -- so the gsub removes them
            own_name = string.gsub(string.lower(character_name), "%z", "")
            local updated_messages = get_chat_log()

            if #output_messages == 0 and #updated_messages > 0 then
                -- old list is empty but there are new messages
                output_messages = updated_messages
            elseif #output_messages == 0 or #updated_messages == 0 then
                -- do nothing
            else
                -- diff old and new messages

                local idx = 1
                -- find index of the latest matching message
                -- wrap loops in func so we can break both with return
                ;(function()
                    -- realistically we probably dont need the outer loop
                    -- since there's no way more than 30 messages could be sent
                    -- in between updates
                    for i = #output_messages, 1, -1 do
                        for j = #updated_messages, 1, -1 do
                            if output_messages[i].text == updated_messages[j].text and
                            output_messages[i].name == updated_messages[j].name then
                                idx = j + 1
                                return
                            end
                        end
                    end
                end)()

                -- add all new messages after that index
                for i = idx, #updated_messages do
                    local msg = updated_messages[i]
                    msg.date = os.date("%H:%M:%S", os.time())
                    table.insert(output_messages, msg)
                    -- remove from start if log is too long
                    if #output_messages > MAX_LOG_SIZE then
                        table.remove(output_messages, 1)
                    end
                end
            end
        end
        
        counter = 0
    end

    -- draw messages
    for i, msg in ipairs(output_messages) do
        local formattedText = msg.text
        -- Escape '%' if the base plugin is not updated. If the plugin is updated, then the output
        -- is written as-is without any additional substitutions.
        if pso.require_version == nil or not pso.require_version(3, 6, 0) then
            formattedText = string.gsub(msg.text, "%%", "%%%%") -- escape '%'
        end

        -- **Timestamp Display**
        local timestampPart = (options.clNoTimestamp ~= "NoTimestamp") and ("[" .. msg.date .. "] ") or ""

        -- **Name Formatting**
        local nameFormat = ""
        if options.clFixedWidthNames then
            nameFormat = string.format("%-11s", msg.name)
        else
            nameFormat = msg.name
        end

        -- **Format Message**
        local formatted = msg.formatted or (timestampPart .. nameFormat .. options.clMessageSeparator .. formattedText)
        msg.formatted = formatted -- cache result for performance
        local lower = string.lower(msg.text) -- for case-insensitive matching

        local highlightColor = getHighlightColor()

        -- full word match own name
-- Modify the highlighting code section (around line 424-445)
if msg.hilight or (#own_name > 0 and string.match(lower, own_name) and
    (
        string.match(lower, "^" .. own_name .. "[%p%s]") or
        string.match(lower, "[%p%s]" .. own_name .. "[%p%s]") or
        string.match(lower, "[%p%s]" .. own_name .. "$") or
        string.match(lower, "^" .. own_name .. "$")
    )) then
        -- hilight message - but use the same components as colored names
        local windowWidth = imgui.GetWindowWidth()
        imgui.PushTextWrapPos(windowWidth - 10)

        if options.clColoredNames then
            -- Display timestamp (if enabled) with highlight color
            if options.clNoTimestamp ~= "NoTimestamp" then
                imgui.TextColored(
                    highlightColor[1],
                    highlightColor[2],
                    highlightColor[3],
                    highlightColor[4],
                    timestampPart
                )

                imgui.SameLine(0, 0)  -- No spacing
            end

            -- Display name with highlight color
            imgui.TextColored(
                highlightColor[1],
                highlightColor[2],
                highlightColor[3],
                highlightColor[4],
                nameFormat
            )
            -- Display separator with highlight color
            imgui.SameLine(0, 0)
            imgui.TextColored(
                highlightColor[1],
                highlightColor[2],
                highlightColor[3],
                highlightColor[4],
                options.clMessageSeparator
            )
            imgui.SameLine(0, 0)

            -- Display message with highlight color
            imgui.TextColored(
                highlightColor[1],
                highlightColor[2],
                highlightColor[3],
                highlightColor[4],
                formattedText
            )
        else
            -- For non-colored names, just highlight the whole formatted text
            -- But recreate it with the current separator rather than using cached
            local currentFormatted = timestampPart .. nameFormat .. options.clMessageSeparator .. formattedText

            imgui.TextColored(
                highlightColor[1],
                highlightColor[2],
                highlightColor[3],
                highlightColor[4],
                currentFormatted
            )
        end

        imgui.PopTextWrapPos()
        msg.hilight = true

        else
            -- no hilight
            if options.clColoredNames then
                local windowWidth = imgui.GetWindowWidth()
                imgui.PushTextWrapPos(windowWidth - 10) -- Set wrap width to window width minus a small margin

                -- Display timestamp (if enabled) with default color
                if options.clNoTimestamp ~= "NoTimestamp" then
                    imgui.Text(timestampPart)
                    imgui.SameLine(0, 0)  -- No spacing
                end

                -- Display name with custom color
                imgui.TextColored(
                    options.clNameColorR,
                    options.clNameColorG,
                    options.clNameColorB,
                    options.clNameColorA,
                    nameFormat
                )

                -- Display separator and message with default color
                imgui.SameLine(0, 0)
                imgui.Text(options.clMessageSeparator)
                imgui.SameLine(0, 0)

                imgui.Text(formattedText)
                imgui.PopTextWrapPos()
            else
                local windowWidth = imgui.GetWindowWidth()
                imgui.PushTextWrapPos(windowWidth - 10)
                imgui.Text(formatted)
                imgui.PopTextWrapPos()
            end
        end

        if scrolldown then
            imgui.SetScrollY(imgui.GetScrollMaxY())
        end

        prevmaxy = imgui.GetScrollMaxY()
    end
end

local function present()
    -- If the addon has never been used, open the config window
    -- and disable the config window setting
    if options.configurationEnableWindow then
        ConfigurationWindow.open = true
        options.configurationEnableWindow = false
    end

    ConfigurationWindow.Update()
    if ConfigurationWindow.changed then
        ConfigurationWindow.changed = false
        SaveOptions(options)
    end

    -- Global enable here to let the configuration window work
    if options.enable == false then
        return
    end

    if (options.clEnableWindow == true)
        and (options.clHideWhenMenu == false or IsMenuOpen() == false)
        and (options.clHideWhenSymbolChat == false or IsSymbolChatOpen() == false)
        and (options.clHideWhenMenuUnavailable == false or IsMenuUnavailable() == false)
    then
        if firstPresent or options.clChanged then
            options.clChanged = false
            local ps = GetPosBySizeAndAnchor(options.clX, options.clY, options.clW, options.clH, options.clAnchor)
            imgui.SetNextWindowPos(ps[1], ps[2], "Always");
            imgui.SetNextWindowSize(options.clW, options.clH, "Always");
        end
        if options.clTransparentWindow == true then
            imgui.PushStyleColor("WindowBg", 0.0, 0.0, 0.0, 0.0)
        end
        if imgui.Begin("Chatlog", nil, { options.clNoTitleBar, options.clNoResize, options.clNoMove, options.clNoTimestamp }) then
            imgui.SetWindowFontScale(options.fontScale)
            DoChat()
        end
        imgui.End()
        if options.clTransparentWindow == true then
            imgui.PopStyleColor()
        end
        if firstPresent then
            firstPresent = false
        end
    end
end

local function init()
    ConfigurationWindow = cfg.ConfigurationWindow(options)

    local function mainMenuButtonHandler()
        ConfigurationWindow.open = not ConfigurationWindow.open
    end

    core_mainmenu.add_button("Chatlog", mainMenuButtonHandler)

    return
    {
        name = "Chatlog",
        version = "0.1.1",
        author = "esc",
        present = present
    }
end

return {
    __addon =
    {
        init = init,
    },
}
