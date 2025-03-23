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
            
                imgui.PushItemWidth(60)
                success, _configuration.clNameColorR = imgui.SliderFloat("R", _configuration.clNameColorR, 0.0, 1.0)
                if success then
                    this.changed = true
                end
            
                imgui.SameLine(0, 10)
                success, _configuration.clNameColorG = imgui.SliderFloat("G", _configuration.clNameColorG, 0.0, 1.0)
                if success then
                    this.changed = true
                end
            
                imgui.SameLine(0, 10)
                success, _configuration.clNameColorB = imgui.SliderFloat("B", _configuration.clNameColorB, 0.0, 1.0)
                if success then
                    this.changed = true
                end
            
                imgui.SameLine(0, 10)
                success, _configuration.clNameColorA = imgui.SliderFloat("A", _configuration.clNameColorA, 0.0, 1.0)
                if success then
                    this.changed = true
                end
                imgui.PopItemWidth()
                imgui.SameLine(0, 10)
                imgui.PushStyleColor("Button", _configuration.clNameColorR, _configuration.clNameColorG, _configuration.clNameColorB, _configuration.clNameColorA)
                if imgui.Button("", 30, 30) then
                end
                imgui.PopStyleColor()
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
