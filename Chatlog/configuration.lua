local function ConfigurationWindow(configuration)
    local this = 
    {
        title = "Chatlog - Configuration",
        fontScale = 1.0,
        open = false,
        changed = false,
    }

    local _configuration = configuration

    local function PresentColorEditor(label, default, custom)
        custom = custom or 0xFFFFFFFF

        local changed = false
        local i_default =
        {
            bit.band(bit.rshift(default, 24), 0xFF),
            bit.band(bit.rshift(default, 16), 0xFF),
            bit.band(bit.rshift(default, 8), 0xFF),
            bit.band(default, 0xFF)
        }
        local i_custom =
        {
            bit.band(bit.rshift(custom, 24), 0xFF),
            bit.band(bit.rshift(custom, 16), 0xFF),
            bit.band(bit.rshift(custom, 8), 0xFF),
            bit.band(custom, 0xFF)
        }

        local ids = { "##X", "##Y", "##Z", "##W" }
        local fmt = { "A:%3.0f", "R:%3.0f", "G:%3.0f", "B:%3.0f" }

        imgui.BeginGroup()
        imgui.PushID(label)

        imgui.PushItemWidth(75)
        for n = 1, 4, 1 do
            local success = false
            if n ~= 1 then
                imgui.SameLine(0, 5)
            end

            success, i_custom[n] = imgui.DragInt(ids[n], i_custom[n], 1.0, 0, 255, fmt[n])
            if success then
                this.changed = true
            end
        end
        imgui.PopItemWidth()

        imgui.SameLine(0, 5)
        imgui.ColorButton(i_custom[2] / 255, i_custom[3] / 255, i_custom[4] / 255, i_custom[1] / 255)
        if imgui.IsItemHovered() then
            imgui.SetTooltip(
                string.format(
                    "#%02X%02X%02X%02X",
                    i_custom[4],
                    i_custom[1],
                    i_custom[2],
                    i_custom[3]
                )
            )
        end

        imgui.SameLine(0, 5)
        imgui.Text(label)

        default =
        bit.lshift(i_default[1], 24) +
        bit.lshift(i_default[2], 16) +
        bit.lshift(i_default[3], 8) +
        bit.lshift(i_default[4], 0)

        custom =
        bit.lshift(i_custom[1], 24) +
        bit.lshift(i_custom[2], 16) +
        bit.lshift(i_custom[3], 8) +
        bit.lshift(i_custom[4], 0)

        if custom ~= default then
            imgui.SameLine(0, 5)
            if imgui.Button("Revert") then
                custom = default
                this.changed = true
            end
        end

        imgui.PopID()
        imgui.EndGroup()

        return custom
    end

    local function RGBAToHex(r, g, b, a)
        local alpha = math.floor(a * 255)
        local red = math.floor(r * 255)
        local green = math.floor(g * 255)
        local blue = math.floor(b * 255)
        
        return bit.lshift(alpha, 24) + bit.lshift(red, 16) + bit.lshift(green, 8) + blue
    end

    local function HexToRGBA(hex)
        local alpha = bit.band(bit.rshift(hex, 24), 0xFF) / 255
        local red = bit.band(bit.rshift(hex, 16), 0xFF) / 255
        local green = bit.band(bit.rshift(hex, 8), 0xFF) / 255
        local blue = bit.band(hex, 0xFF) / 255
        
        return red, green, blue, alpha
    end

    local _showWindowSettings = function()
        local success
        local anchorList =
        {
            "Top Left (Disabled)", "Left", "Bottom Left",
            "Top", "Center", "Bottom",
            "Top Right", "Right", "Bottom Right",
        }

        if imgui.TreeNodeEx("General", "DefaultOpen") then
            if imgui.Checkbox("Enable", _configuration.enable) then
                _configuration.enable = not _configuration.enable
                this.changed = true
            end

            success, _configuration.fontScale = imgui.InputFloat("Font Scale", _configuration.fontScale)
            if success then
                this.changed = true
            end

            imgui.TreePop()
        end

        if imgui.TreeNodeEx("Chatlog", "DefaultOpen") then
            if imgui.Checkbox("Hide when menus are open", _configuration.clHideWhenMenu) then
                _configuration.clHideWhenMenu = not _configuration.clHideWhenMenu
                this.changed = true
            end
            if imgui.Checkbox("Hide when symbol chat/word select is open", _configuration.clHideWhenSymbolChat) then
                _configuration.clHideWhenSymbolChat = not _configuration.clHideWhenSymbolChat
                this.changed = true
            end
            if imgui.Checkbox("Hide when the menu is unavailable", _configuration.clHideWhenMenuUnavailable) then
                _configuration.clHideWhenMenuUnavailable = not _configuration.clHideWhenMenuUnavailable
                this.changed = true
            end

            if imgui.Checkbox("No title bar", _configuration.clNoTitleBar == "NoTitleBar") then
                if _configuration.clNoTitleBar == "NoTitleBar" then
                    _configuration.clNoTitleBar = ""
                else
                    _configuration.clNoTitleBar = "NoTitleBar"
                end
                this.changed = true
            end
            if imgui.Checkbox("No resize", _configuration.clNoResize == "NoResize") then
                if _configuration.clNoResize == "NoResize" then
                    _configuration.clNoResize = ""
                else
                    _configuration.clNoResize = "NoResize"
                end
                this.changed = true
            end
            if imgui.Checkbox("No Move", _configuration.clNoMove == "NoMove") then
                if _configuration.clNoMove == "NoMove" then
                    _configuration.clNoMove = ""
                else
                    _configuration.clNoMove = "NoMove"
                end
                this.changed = true
            end
            if imgui.Checkbox("No Timestamps", _configuration.clNoTimestamp == "NoTimestamp") then
                if _configuration.clNoTimestamp == "NoTimestamp" then
                    _configuration.clNoTimestamp = ""
                else
                    _configuration.clNoTimestamp = "NoTimestamp"
                end
                this.changed = true
            end
            if imgui.Checkbox("Transparent window", _configuration.clTransparentWindow) then
                _configuration.clTransparentWindow = not _configuration.clTransparentWindow
                this.changed = true
            end
            
            imgui.Text("Message Format")

            if imgui.Checkbox("Fixed-width names", _configuration.clFixedWidthNames) then
                _configuration.clFixedWidthNames = not _configuration.clFixedWidthNames
                this.changed = true
            end
            
            imgui.PushItemWidth(40) 
            success, _configuration.clMessageSeparator = imgui.InputText("Separator", _configuration.clMessageSeparator, 5)
            imgui.PopItemWidth()
            imgui.Spacing()
            if success then
                _configuration.clChanged = true
                this.changed = true
            end

            if imgui.Checkbox("Colored names", _configuration.clColoredNames) then
                _configuration.clColoredNames = not _configuration.clColoredNames
                this.changed = true
            end
            
            -- Only show color picker if colored names is enabled
            if _configuration.clColoredNames then
                imgui.Text("Name Color")

                local nameColorHex = RGBAToHex(
                    _configuration.clNameColorR,
                    _configuration.clNameColorG,
                    _configuration.clNameColorB,
                    _configuration.clNameColorA
                )

                local defaultNameColorHex = RGBAToHex(0.5, 1.0, 0.0, 1.0)

                local newNameColorHex = PresentColorEditor("Name Color", defaultNameColorHex, nameColorHex)

                if newNameColorHex ~= nameColorHex then
                    _configuration.clNameColorR, _configuration.clNameColorG, 
                    _configuration.clNameColorB, _configuration.clNameColorA = HexToRGBA(newNameColorHex)
                    this.changed = true
                end
            end

            imgui.Spacing()
            if imgui.Checkbox("Customize highlight color", _configuration.clCustomHighlight) then
                _configuration.clCustomHighlight = not _configuration.clCustomHighlight
                this.changed = true
            end

            if _configuration.clCustomHighlight then
                imgui.Text("Highlight Color")

                local highlightColorHex = RGBAToHex(
                    _configuration.clHighlightColorR,
                    _configuration.clHighlightColorG,
                    _configuration.clHighlightColorB,
                    _configuration.clHighlightColorA
                )

                local defaultHighlightColorHex = RGBAToHex(0.5, 1.0, 0.0, 1.0)

                local newHighlightColorHex = PresentColorEditor("Highlight Color", defaultHighlightColorHex, highlightColorHex)

                if newHighlightColorHex ~= highlightColorHex then
                    _configuration.clHighlightColorR, _configuration.clHighlightColorG, 
                    _configuration.clHighlightColorB, _configuration.clHighlightColorA = HexToRGBA(newHighlightColorHex)
                    this.changed = true
                end
            end

            imgui.Text("Position and Size")
            imgui.PushItemWidth(200)
            success, _configuration.clAnchor = imgui.Combo("Anchor", _configuration.clAnchor, anchorList, table.getn(anchorList))
            imgui.PopItemWidth()
            if success then
                _configuration.clChanged = true
                this.changed = true
            end
            
            imgui.PushItemWidth(100)
            success, _configuration.clX = imgui.InputInt("X", _configuration.clX)
            imgui.PopItemWidth()
            if success then
                _configuration.clChanged = true
                this.changed = true
            end
            
            imgui.SameLine(0, 38)
            imgui.PushItemWidth(100)
            success, _configuration.clY = imgui.InputInt("Y", _configuration.clY)
            imgui.PopItemWidth()
            if success then
                _configuration.clChanged = true
                this.changed = true
            end
            
            imgui.PushItemWidth(100)
            success, _configuration.clW = imgui.InputInt("Width", _configuration.clW)
            imgui.PopItemWidth()
            if success then
                _configuration.clChanged = true
                this.changed = true
            end
            
            imgui.SameLine(0, 10)
            imgui.PushItemWidth(100)
            success, _configuration.clH = imgui.InputInt("Height", _configuration.clH)
            imgui.PopItemWidth()
            if success then
                _configuration.clChanged = true
                this.changed = true
            end

            imgui.TreePop()
        end
    end

    this.Update = function()
        if this.open == false then
            return
        end

        local success

        imgui.SetNextWindowSize(500, 400, 'FirstUseEver')
        success, this.open = imgui.Begin(this.title, this.open)
        imgui.SetWindowFontScale(this.fontScale)

        _showWindowSettings()

        imgui.End()
    end

    return this
end

return 
{
    ConfigurationWindow = ConfigurationWindow,
}
