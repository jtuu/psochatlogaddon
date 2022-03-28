local function ConfigurationWindow(configuration)
    local this = 
    {
        title = "Chatlog - Configuration",
        fontScale = 1.0,
        open = false,
        changed = false,
    }

    local _configuration = configuration

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

            if imgui.Checkbox("Transparent window", _configuration.clTransparentWindow) then
                _configuration.clTransparentWindow = not _configuration.clTransparentWindow
                this.changed = true
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
