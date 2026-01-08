_G.JxereasExistingHooks = _G.JxereasExistingHooks or {}
local hookFunctionImpl = hookfunc or hookfunction

if not _G.JxereasExistingHooks.GuiDetectionBypass then
    local hasSynContext = typeof(syn_context_get) == "function" and typeof(syn_context_set) == "function"
    local hasNamecallHooks = typeof(getnamecallmethod) == "function" and typeof(setnamecallmethod) == "function"
    local hasHookSupport = typeof(hookFunctionImpl) == "function" and typeof(hookmetamethod) == "function"

    if hasSynContext and hasNamecallHooks and hasHookSupport then
        local CoreGui = game.CoreGui
        local ContentProvider = game.ContentProvider
        local RobloxGuis = {"RobloxGui", "TeleportGui", "RobloxPromptGui", "RobloxLoadingGui", "PlayerList", "RobloxNetworkPauseNotification", "PurchasePrompt", "HeadsetDisconnectedDialog", "ThemeProvider", "DevConsoleMaster"}
        
        local function FilterTable(tbl)
            local context = syn_context_get()
            syn_context_set(7)
            local new = {}
            for i,v in ipairs(tbl) do --roblox iterates the array part
                if typeof(v) ~= "Instance" then
                    table.insert(new, v)
                else
                    if v == CoreGui or v == game then
                        --insert only the default roblox guis
                        for i,v in pairs(RobloxGuis) do
                            local gui = CoreGui:FindFirstChild(v)
                            if gui then
                                table.insert(new, gui)
                            end
                        end
        
                        if v == game then
                            for i,v in pairs(game:GetChildren()) do
                                if v ~= CoreGui then
                                    table.insert(new, v)
                                end
                            end
                        end
                    else
                        if not CoreGui:IsAncestorOf(v) then
                            table.insert(new, v)
                        else
                            --don't insert it if it's a descendant of a different gui than default roblox guis
                            for j,k in pairs(RobloxGuis) do
                                local gui = CoreGui:FindFirstChild(k)
                                if gui then
                                    if v == gui or gui:IsAncestorOf(v) then
                                        table.insert(new, v)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            syn_context_set(context)
            return new
        end
        
        local old
        old = hookFunctionImpl(ContentProvider.PreloadAsync, function(self, tbl, cb)
            if self ~= ContentProvider or type(tbl) ~= "table" or type(cb) ~= "function" then --note: callback can be nil but in that case it's useless anyways
                return old(self, tbl, cb)
            end
        
            --check for any errors that I might've missed (such as table being {[2] = "something"} which causes "Unable to cast to Array")
            local err
            task.spawn(function() --TIL pcalling a C yield function inside a C yield function is a bad idea ("cannot resume non-suspended coroutine")
                local s,e = pcall(old, self, tbl)
                if not s and e then
                    err = e
                end
            end)
        
            if err then
                return old(self, tbl) --don't pass the callback, just in case
            end
        
            tbl = FilterTable(tbl)
            return old(self, tbl, cb)
        end)
        
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if self == ContentProvider and (method == "PreloadAsync" or method == "preloadAsync") then
                local args = {...}
                if type(args[1]) ~= "table" or type(args[2]) ~= "function" then
                    return old(self, ...)
                end
        
                local err
                task.spawn(function()
                    setnamecallmethod(method) --different thread, different namecall method
                    local s,e = pcall(old, self, args[1])
                    if not s and e then
                        err = e
                    end
                end)
        
                if err then
                    return old(self, args[1])
                end
        
                args[1] = FilterTable(args[1])
                setnamecallmethod(method)
                return old(self, args[1], args[2])
            end
            return old(self, ...)
        end)
        
        _G.JxereasExistingHooks.GuiDetectionBypass = true
    else
        warn("[KFHub] Executor is missing hook APIs, skipping gui detection bypass for compatibility.")
        _G.JxereasExistingHooks.GuiDetectionBypass = true
    end
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Safely disable idle kick if getconnections is available
if typeof(getconnections) == "function" then
	for _, connection in pairs(getconnections(player.Idled)) do
		if connection.Enabled then
			connection:Disable()
		end
	end
else
	warn("[KFHub] getconnections not available, idle kick prevention disabled")
end


local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local sharedKeyForgeEnv = getgenv and getgenv() or _G

local forcedMobilePreference = rawget(sharedKeyForgeEnv, "__KF_FORCE_MOBILE")
local mouse = player:GetMouse()
local viewPortSize = workspace.CurrentCamera.ViewportSize
local isMobileClient = forcedMobilePreference

if isMobileClient == nil then
    local hasTouch = UserInputService.TouchEnabled
    local hasKeyboard = UserInputService.KeyboardEnabled
    local hasMouse = UserInputService.MouseEnabled
    local hasAccelerometer = UserInputService.AccelerometerEnabled
    local isConsole = GuiService:IsTenFootInterface()
    
    -- Advanced detection logic:
    -- 1. Accelerometer is a strong indicator of a mobile/tablet device.
    -- 2. If it has touch but NO keyboard and NO mouse, it's definitely mobile.
    -- 3. Explicitly exclude console interfaces.
    isMobileClient = not isConsole and (hasAccelerometer or (hasTouch and not hasKeyboard and not hasMouse))
end

local originalElements = {}
-- Add Tween Dictonary with format Tweens.ElementType.TweenName to ignore repetitive variables

local Library = {}
local elementHandler = {}
local windowHandler = {}
local tabHandler = {}
local sectionHandler = {}
local titleHandler = {}
local labelHandler = {}
local toggleHandler = {}
local buttonHandler = {}
local dropdownHandler = {}
local sliderHandler = {}
local searchBarHandler = {}
local keybindHandler = {}
local textBoxHandler = {}
local colorWheelHandler = {}

-- Theme and Config Integration
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local filesystemAvailable = exploitEnv and exploitEnv.isfolder and exploitEnv.makefolder and exploitEnv.writefile and exploitEnv.readfile and exploitEnv.listfiles and exploitEnv.isfile and exploitEnv.delfile

-- Initialize library properties
Library.Scheme = {
    BackgroundColor = Color3.fromRGB(21, 21, 21),
    MainColor = Color3.fromRGB(31, 31, 31),
    AccentColor = Color3.fromRGB(0, 170, 255),
    OutlineColor = Color3.fromRGB(37, 37, 51),
    FontColor = Color3.fromRGB(168, 168, 168),
    Font = Font.fromEnum(Enum.Font.Gotham)
}

Library.Options = {}
Library.Toggles = {}

-- Enhanced registry system for dynamic theme updates
Library.ThemeRegistry = {}

function Library:AddToRegistry(instance, property, themeKey)
    table.insert(self.ThemeRegistry, {
        Instance = instance,
        Property = property,
        ThemeKey = themeKey
    })
    
    if self.Scheme[themeKey] then
        instance[property] = self.Scheme[themeKey]
    end
end

-- Helper function to register elements for saving/loading
function Library:RegisterOption(element, identifier, elementType, defaultValue)
    self.Options[identifier] = {
        Type = elementType,
        Value = defaultValue,
        Instance = element,
        SetValue = function(val, skipCallback)
            if typeof(element.Set) == "function" then
                element:Set(val, skipCallback)
            elseif elementType == "Input" then
                element.Value = val
            elseif elementType == "Dropdown" then
                element:Select(val)
            end
        end
    }
    return self.Options[identifier]
end

function Library:RegisterToggle(element, identifier, defaultValue)
    self.Toggles[identifier] = {
        Type = "Toggle",
        Enabled = defaultValue,
        Instance = element,
        Set = function(val, skipCallback)
            if typeof(element.Set) == "function" then
                element:Set(val, skipCallback)
            end
        end
    }
    return self.Toggles[identifier]
end

-- Notification system
Library.NotificationArea = nil
Library.NotificationList = nil
Library.Notifications = {}
Library.NotifySide = "Right"

-- DPI scaling support
Library.DPIScale = 1

-- Helper functions for theming
function Library:UpdateColorsUsingRegistry()
    for i = #self.ThemeRegistry, 1, -1 do
        local entry = self.ThemeRegistry[i]
        if entry.Instance and entry.Instance.Parent then
            local color = self.Scheme[entry.ThemeKey]
            if color then
                entry.Instance[entry.Property] = color
            end
        else
            table.remove(self.ThemeRegistry, i)
        end
    end
end

function Library:SetFont(fontName)
    -- Implement font setting (placeholder)
    Library.Scheme.Font = Font.fromEnum(Enum.Font[fontName] or Enum.Font.Code)
end

-- Enhanced notification system (Modernized)
do
    local NotificationStyles = {
        Default = {
            TitleColor = Color3.fromRGB(255, 255, 255),
            ContentColor = Color3.fromRGB(240, 240, 240),
            BackgroundColor = Color3.fromRGB(30, 30, 40)
        }
    }

    function Library:InitNotifications()
        if Library.NotificationArea then return end

        Library.NotificationArea = Instance.new("ScreenGui")
        Library.NotificationArea.Name = "KeyForge_Notifications"
        Library.NotificationArea.Parent = game:GetService("CoreGui")
        Library.NotificationArea.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local Holder = Instance.new("Frame")
        Holder.Name = "Holder"
        Holder.Position = UDim2.new(1, -30, 1, -30)
        Holder.Size = UDim2.new(0, 310, 1, -30)
        Holder.AnchorPoint = Vector2.new(1, 1)
        Holder.BackgroundTransparency = 1
        Holder.Parent = Library.NotificationArea

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        UIListLayout.Padding = UDim.new(0, 10)
        UIListLayout.Parent = Holder

        Library.NotificationHolder = Holder
    end

    function Library:Notify(Config)
        self:InitNotifications()

        if typeof(Config) == "string" then
            Config = {
                Title = "Notification",
                Content = Config,
                Duration = 3
            }
        end

        local Title = Config.Title or "Title"
        local Content = Config.Content or Config.Description or "Content"
        local Duration = Config.Duration or Config.Time or 5

        local NewNotification = {
            Closed = false,
        }

        local Root = Instance.new("Frame")
        Root.Name = "Notification"
        Root.BackgroundColor3 = Library.Scheme.BackgroundColor
        Root.BackgroundTransparency = 0.1
        Root.BorderSizePixel = 0
        Root.Size = UDim2.new(1, 0, 0, 80) -- Initial size, will auto-adjust
        Root.ClipsDescendants = true
        Root.Parent = Library.NotificationHolder

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = Root

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = Library.Scheme.OutlineColor
        UIStroke.Thickness = 1
        UIStroke.Transparency = 0.5
        UIStroke.Parent = Root

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "Title"
        TitleLabel.Position = UDim2.new(0, 14, 0, 12)
        TitleLabel.Size = UDim2.new(1, -40, 0, 15)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = Title
        TitleLabel.TextColor3 = Library.Scheme.AccentColor
        TitleLabel.TextSize = 13
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Root

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Name = "Content"
        ContentLabel.Position = UDim2.new(0, 14, 0, 32)
        ContentLabel.Size = UDim2.new(1, -28, 0, 0)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.Text = Content
        ContentLabel.TextColor3 = Library.Scheme.FontColor
        ContentLabel.TextSize = 14
        ContentLabel.TextWrapped = true
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
        ContentLabel.Parent = Root

        -- Adjust root size based on content
        task.spawn(function()
            task.wait()
            local contentSize = ContentLabel.AbsoluteSize.Y
            Root.Size = UDim2.new(1, 0, 0, 45 + contentSize)
        end)

        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "Close"
        CloseButton.BackgroundTransparency = 1
        CloseButton.Position = UDim2.new(1, -25, 0, 10)
        CloseButton.Size = UDim2.new(0, 15, 0, 15)
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Library.Scheme.FontColor
        CloseButton.TextSize = 12
        CloseButton.Parent = Root

        -- Animation
        Root.Position = UDim2.new(1, 350, 0, 0)
        TweenService:Create(Root, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        local function Close()
            if NewNotification.Closed then return end
            NewNotification.Closed = true
            
            local OutTween = TweenService:Create(Root, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 350, 0, 0)
            })
            OutTween:Play()
            OutTween.Completed:Connect(function()
                Root:Destroy()
            end)
        end

        CloseButton.MouseButton1Click:Connect(Close)

        if Duration then
            task.delay(Duration, Close)
        end

        return NewNotification
    end
end

-- DPI scaling
function Library:GetTextBounds(text, font, size, width)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = text
    params.Font = font or Library.Scheme.Font
    params.Size = size * Library.DPIScale
    params.Width = width or workspace.CurrentCamera.ViewportSize.X - 32

    local bounds = TextService:GetTextBoundsAsync(params)
    return bounds.X / Library.DPIScale, bounds.Y / Library.DPIScale
end

function Library:UpdateDPI(instance, properties)
    if not Library.DPIRegistry then
        Library.DPIRegistry = {}
    end

    for property, value in pairs(properties) do
        if property == "TextSize" then
            instance[property] = value * Library.DPIScale
        end
    end
end

-- Create outline helper
function Library:MakeOutline(frame, cornerRadius)
    local outlineHolder = Instance.new("Frame")
    outlineHolder.Name = "Outline"
    outlineHolder.BackgroundColor3 = Color3.new(0, 0, 0)
    outlineHolder.BackgroundTransparency = 1
    outlineHolder.BorderSizePixel = 0
    outlineHolder.Position = UDim2.fromOffset(-2, -2)
    outlineHolder.Size = UDim2.new(1, 4, 1, 4)
    outlineHolder.ZIndex = frame.ZIndex - 1
    outlineHolder.Parent = frame

    local outline = Instance.new("Frame")
    outline.BackgroundColor3 = Library.Scheme.OutlineColor
    outline.BorderSizePixel = 0
    outline.Position = UDim2.fromOffset(1, 1)
    outline.Size = UDim2.new(1, -2, 1, -2)
    outline.Parent = outlineHolder

    if cornerRadius and cornerRadius > 0 then
        local corner1 = Instance.new("UICorner")
        corner1.CornerRadius = UDim.new(0, cornerRadius + 1)
        corner1.Parent = outlineHolder

        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(0, cornerRadius)
        corner2.Parent = outline
    end

    return outlineHolder, outline
end

-- Enhanced tooltip system
Library.TooltipLabel = nil
Library.CurrentHoverInstance = nil

function Library:InitTooltip()
    if Library.TooltipLabel then return end

    Library.TooltipLabel = Instance.new("TextLabel")
    Library.TooltipLabel.Name = "TooltipLabel"
    Library.TooltipLabel.BackgroundColor3 = Library.Scheme.BackgroundColor
    Library.TooltipLabel.BorderColor3 = Library.Scheme.OutlineColor
    Library.TooltipLabel.BorderSizePixel = 1
    Library.TooltipLabel.TextSize = 14
    Library.TooltipLabel.TextWrapped = true
    Library.TooltipLabel.Visible = false
    Library.TooltipLabel.ZIndex = 10000
    Library.TooltipLabel.Font = Library.Scheme.Font
    Library.TooltipLabel.TextColor3 = Library.Scheme.FontColor
    Library.TooltipLabel.Parent = game:GetService("CoreGui")

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Library.TooltipLabel

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.Parent = Library.TooltipLabel
end

function Library:AddTooltip(infoStr, disabledInfoStr, hoverInstance)
    Library:InitTooltip()

    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if Library.CurrentHoverInstance == hoverInstance or (TooltipTable.Disabled and not disabledInfoStr) or (not TooltipTable.Disabled and not infoStr) then
            return
        end
        Library.CurrentHoverInstance = hoverInstance

        Library.TooltipLabel.Text = TooltipTable.Disabled and (disabledInfoStr or infoStr) or infoStr
        Library.TooltipLabel.Visible = true

        while TooltipTable.Hovering do
            Library.TooltipLabel.Position = UDim2.fromOffset(mouse.X + 14, mouse.Y + 12)

            -- Resize tooltip based on text
            local textBounds = TextService:GetTextBoundsAsync({
                Text = Library.TooltipLabel.Text,
                Font = Library.Scheme.Font,
                Size = 14,
                Width = workspace.CurrentCamera.ViewportSize.X - Library.TooltipLabel.AbsolutePosition.X - 4
            })
            Library.TooltipLabel.Size = UDim2.fromOffset(textBounds.X + 12, textBounds.Y + 8)

            RunService.RenderStepped:Wait()
        end

        Library.TooltipLabel.Visible = false
        Library.CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end
        return Connection
    end

    GiveSignal(hoverInstance.MouseEnter:Connect(function()
        TooltipTable.Hovering = true
        DoHover()
    end))

    GiveSignal(hoverInstance.MouseMoved:Connect(DoHover))

    GiveSignal(hoverInstance.MouseLeave:Connect(function()
        if Library.CurrentHoverInstance ~= hoverInstance then
            return
        end
        TooltipTable.Hovering = false
        Library.TooltipLabel.Visible = false
        Library.CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if Library.CurrentHoverInstance == hoverInstance then
            if Library.TooltipLabel then
                Library.TooltipLabel.Visible = false
            end
            Library.CurrentHoverInstance = nil
        end
    end

    return TooltipTable
end

colorWheelHandler.__index = function(_, i) return rawget(colorWheelHandler, i) or rawget(elementHandler, i) end
elementHandler.__index = elementHandler
windowHandler.__index = function(_, i) return rawget(windowHandler, i) or rawget(elementHandler, i) end
tabHandler.__index = function(_, i ) return rawget(tabHandler, i) or rawget(elementHandler, i) end
sectionHandler.__index = function(_, i) return rawget(sectionHandler, i) or rawget(elementHandler, i) end
titleHandler.__index = function(_, i) return rawget(titleHandler, i) or rawget(elementHandler, i) end
labelHandler.__index = function(_, i) return rawget(labelHandler, i) or rawget(elementHandler, i) end
toggleHandler.__index = function(_, i) return rawget(toggleHandler, i) or rawget(elementHandler, i) end
buttonHandler.__index = function(_, i) return rawget(buttonHandler, i) or rawget(elementHandler, i) end
dropdownHandler.__index = function(_, i) return rawget(dropdownHandler, i) or rawget(elementHandler, i) end
sliderHandler.__index = function(_, i) return rawget(sliderHandler, i) or rawget(elementHandler, i) end
searchBarHandler.__index = function(_, i) return rawget(searchBarHandler, i) or rawget(elementHandler, i) end
keybindHandler.__index = function(_, i) return rawget(keybindHandler, i) or rawget(elementHandler, i) end
textBoxHandler.__index = function(_, i) return rawget(textBoxHandler, i) or rawget(elementHandler, i) end

-- Compatibility Layer for Linoria/Fluent style managers
function tabHandler:AddRightGroupbox(name) return self:Section(name) end
function tabHandler:AddLeftGroupbox(name) return self:Section(name) end
function tabHandler:AddSection(name) return self:Section(name) end

function elementHandler:AddLabel(text) return self:Label(text) end
function elementHandler:AddButton(name, cb)
    if typeof(name) == "table" then
        return self:Button(name.Title or name.Text or "Button", name.Callback)
    end
    return self:Button(name, cb)
end

function elementHandler:AddKeybind(idx, info)
    local default = info.Default or info.Standard or "F"
    local kb = self:Keybind(info.Text or idx, info.Callback or info.OnChanged, default)
    kb.OnChanged = function(s, f) kb.Callback = f end
    kb.GetValue = function(s) return tostring(kb.Value or default) end
    kb.SetValue = function(s, v)
        if typeof(v) == "string" then
            kb.Value = Enum.KeyCode[v]
        else
            kb.Value = v
        end
        kb.Instance.BoxBackground.InnerBox.KeyText.Text = kb.Value.Name
    end
    if Library.RegisterOption then Library:RegisterOption(kb, idx, "Keybind", default) end
    return kb
end

function elementHandler:AddToggle(idx, info)
    local default = info.Default or false
    local cb = info.Callback or info.OnChanged or function() end
    local t = self:Toggle(info.Text or idx, default, cb)
    t.OnChanged = function(s, f) t.Callback = f end
    t.GetValue = function(s) return t.Enabled end
    t.SetValue = function(s, v) t:Set(v) end
    if Library.RegisterToggle then Library:RegisterToggle(t, idx, default) end
    return t
end

function elementHandler:AddSlider(idx, info)
    local min = info.Min or 0
    local max = info.Max or 100
    local default = info.Default or min
    local s = self:Slider(info.Text or idx, info.Callback or info.OnChanged, max, min)
    s:Set(default)
    s.OnChanged = function(self_s, f) s.Callback = f end
    s.GetValue = function(s) return s.Value end
    s.SetValue = function(s, v) s:Set(v) end
    if Library.RegisterOption then Library:RegisterOption(s, idx, "Slider", default) end
    return s
end

function elementHandler:AddDropdown(idx, info)
    local list = info.Values or info.List or {}
    local default = info.Default or list[1]
    local d = self:Dropdown(info.Text or idx, list, default, info.Callback or info.OnChanged)
    d.OnChanged = function(s, f) d.Callback = f end
    d.GetValue = function(s) return d.SelectedValue end
    d.SetValue = function(s, v) d:Select(v) end
    if Library.RegisterOption then Library:RegisterOption(d, idx, "Dropdown", default) end
    return d
end

function elementHandler:AddColorPicker(idx, info)
    local default = info.Default or Color3.new(1, 1, 1)
    local cp = self:ColorWheel(info.Text or idx, default, info.Callback or info.OnChanged)
    cp.OnChanged = function(s, f) cp.Callback = f end
    cp.GetValue = function(s) return cp.Instance.WheelHolder.ValueHolder.ColorSample.BackgroundColor3 end -- Crude but works
    cp.SetValue = function(s, v) cp:Set(v) end
    cp.SetValueRGB = function(s, v) cp:Set(v) end
    if Library.RegisterOption then Library:RegisterOption(cp, idx, "ColorPicker", default) end
    return cp
end

function elementHandler:AddInput(idx, info)
    local default = info.Default or ""
    local tb = self:TextBox(info.Text or idx, info.Callback or info.OnChanged)
    tb.OnChanged = function(s, f) tb.Callback = f end
    tb.GetValue = function(s) return tb.Instance.BoxBackground.InnerBox.TextBoxText.Text end
    tb.SetValue = function(s, v) tb.Instance.BoxBackground.InnerBox.TextBoxText.Text = v end
    if Library.RegisterOption then Library:RegisterOption(tb, idx, "Input", default) end
    return tb
end

local function deepCopy(tbl)
	if typeof(tbl) ~= "table" then
		return tbl
	end

	local result = {}
	for key, value in pairs(tbl) do
		result[key] = deepCopy(value)
	end
	return result
end

local function setByPath(root, path, value)
	local current = root
	for i = 1, #path - 1 do
		local key = path[i]
		if typeof(current[key]) ~= "table" then
			current[key] = {}
		end
		current = current[key]
	end
	current[path[#path]] = value
end

local function getByPath(root, path)
	local current = root
	for i = 1, #path - 1 do
		current = current[path[i]]
		if current == nil then
			return nil
		end
	end
	return current[path[#path]]
end

local function trimString(text)
	if typeof(text) ~= "string" then
		return ""
	end
	return (text:match("^%s*(.-)%s*$") or "")
end



local exploitEnv = getfenv and getfenv() or _G

--! Enhanced Config Manager with Advanced Features

-- ConfigManager removed in favor of SaveManager


local function animateText(textInstance: Instance, animationSpeed: number, text: string, placeholderText: string?, fillPlaceHolder: boolean?, emptyPlaceHolderText: boolean?): nil
	if emptyPlaceHolderText then
		for i = #textInstance.PlaceholderText, 0, -1 do
			textInstance.PlaceholderText = textInstance.PlaceholderText:sub(1,i)
			task.wait(animationSpeed)
		end
	else
		for i = #textInstance.Text, 0, -1 do
			textInstance.Text = textInstance.Text:sub(1,i)
			task.wait(animationSpeed)
		end
	end
	
	if fillPlaceHolder then
		for i = 1, #placeholderText do
			textInstance.PlaceholderText = placeholderText:sub(1, i)
			task.wait(animationSpeed)
		end
	else
		for i = 1, #text do
			textInstance.Text = text:sub(1, i)
			task.wait(animationSpeed)
		end
	end
end

local function toPolar(vector)
	return vector.Magnitude, math.atan2(vector.Y, vector.X)
end

local function toCartesian(radius, theta)
	return math.cos(theta) * radius, math.sin(theta) * radius
end

local function startSnowEffect(effectFrame: Instance, snowflakeImageId: string?)
	if not effectFrame or not effectFrame:IsA("Frame") then
		return
	end

	if effectFrame:GetAttribute("SnowEffectRunning") then
		return
	end

	effectFrame:SetAttribute("SnowEffectRunning", true)
	effectFrame:SetAttribute("SnowflakeImageId", snowflakeImageId or "")
	effectFrame.ClipsDescendants = true

	local rng = Random.new()
	local running = true
	local activeSnowflakes = 0

	local function spawnSnowflake()
		if not running or not effectFrame.Parent then
			return
		end

		if activeSnowflakes >= 45 then
			return
		end

		local assetId = effectFrame:GetAttribute("SnowflakeImageId")
		local snowflake

		if typeof(assetId) == "string" and assetId ~= "" then
			local image = Instance.new("ImageLabel")
			image.BackgroundTransparency = 1
			image.BorderSizePixel = 0
			image.Image = assetId
			image.ImageColor3 = Color3.fromRGB(218, 234, 255)
			image.ImageTransparency = rng:NextNumber(.2, .45)
			snowflake = image
		else
			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = Color3.fromRGB(218, 234, 255)
			frame.BorderSizePixel = 0
			frame.BackgroundTransparency = rng:NextNumber(.15, .35)
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = frame
			snowflake = frame
		end

		snowflake.Name = "Snowflake"
		snowflake.ZIndex = 0

		local size = rng:NextInteger(6, 14)
		snowflake.Size = UDim2.fromOffset(size, size)
		snowflake.Position = UDim2.new(rng:NextNumber(), -size / 2, -0.1, 0)
		snowflake.Parent = effectFrame

		activeSnowflakes += 1

		local drift = rng:NextNumber(-0.12, 0.12)
		local duration = rng:NextNumber(4.5, 7.5)
		local goalProps = {
			Position = UDim2.new(math.clamp(snowflake.Position.X.Scale + drift, 0, 1), snowflake.Position.X.Offset, 1.1, 0)
		}

		if snowflake:IsA("ImageLabel") then
			goalProps.ImageTransparency = 1
		else
			goalProps.BackgroundTransparency = 1
		end

		local released = false
		local function release()
			if released then
				return
			end

			released = true
			activeSnowflakes = math.max(0, activeSnowflakes - 1)
		end

		snowflake.Destroying:Connect(release)

		local tween = TweenService:Create(snowflake, TweenInfo.new(duration, Enum.EasingStyle.Linear), goalProps)
		tween.Completed:Connect(function()
			release()
			if snowflake.Parent then
				snowflake:Destroy()
			end
		end)
		tween:Play()
	end

	task.spawn(function()
		while running and effectFrame.Parent do
			spawnSnowflake()
			task.wait(rng:NextNumber(.05, .25))
		end
	end)

	local function stop()
		running = false
		effectFrame:SetAttribute("SnowEffectRunning", false)
	end

	effectFrame.AncestryChanged:Connect(function()
		if not effectFrame.Parent then
			stop()
		end
	end)

	effectFrame.Destroying:Connect(stop)
end


local function getSequenceColor(sequence)
	if typeof(sequence) == "ColorSequence" then
		local keypoints = sequence.Keypoints
		if keypoints and keypoints[1] then
			return keypoints[1].Value
		end
	end
	return Color3.fromRGB(255, 255, 255)
end




local function createOriginalElements()
	local function createWindow()
		local screenGui = Instance.new("ScreenGui")
		local background = Instance.new("Frame")
		local backgroundAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		local pagesFolder = Instance.new("Folder")
		local heading = Instance.new("TextButton")
		local headingUICorner = Instance.new("UICorner")
		local buttonHolder = Instance.new("Frame")
		local buttonHolderList = Instance.new("UIListLayout")
		local buttonHolderPadding = Instance.new("UIPadding")
		local plus = Instance.new("ImageButton")
		local plusAspect = Instance.new("UIAspectRatioConstraint")
		local minus = Instance.new("ImageButton")
		local minusAspect = Instance.new("UIAspectRatioConstraint")
		local close = Instance.new("ImageButton")
		local closeAspect = Instance.new("UIAspectRatioConstraint")
		local headingCornerHiding = Instance.new("Frame")
		local headingSeperator = Instance.new("Frame")
		local title = Instance.new("TextLabel")
		local titleUIPadding = Instance.new("UIPadding")
		local holder = Instance.new("Frame")
		local backgroundUICorner = Instance.new("UICorner")
		local tabs = Instance.new("ScrollingFrame")
		local tabsUIListLayout = Instance.new("UIListLayout")
		local snowEffect = Instance.new("Frame")
		
		screenGui.Name = "KeyForge"
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.IgnoreGuiInset = true
		
		background.Name = "Background"
		background.Parent = screenGui
		background.AnchorPoint = Vector2.new(0.5, 0.5)
		Library:AddToRegistry(background, "BackgroundColor3", "BackgroundColor")
		background.BorderSizePixel = 0
		background.ClipsDescendants = true
		background.Position = UDim2.new(0.5, 0, 0.5, 0)
		background.Size = UDim2.new(0, 650, 0, 450)

		backgroundAspectRatioConstraint.Name = "BackgroundUIAspectRatioConstraint"
		backgroundAspectRatioConstraint.Parent = background
		backgroundAspectRatioConstraint.AspectRatio = 1.444444
		
		backgroundUICorner.Name = "BackgroundUICorner"
		backgroundUICorner.Parent = background
		
		pagesFolder.Name = "Pages"
		pagesFolder.Parent = background
		
		heading.Name = "Heading"
		heading.Parent = background
		Library:AddToRegistry(heading, "BackgroundColor3", "MainColor")
		heading.BorderSizePixel = 0
		heading.Size = UDim2.new(1, 0, 0.0500000007, 0)
		heading.AutoButtonColor = false
		heading.Font = Enum.Font.SourceSans
		heading.Text = ""
		heading.TextColor3 = Color3.fromRGB(0, 0, 0)
		heading.TextSize = 14.000

		headingUICorner.Name = "HeadingUICorner"
		headingUICorner.Parent = heading

		buttonHolder.Name = "ButtonHolder"
		buttonHolder.Parent = heading
		buttonHolder.AnchorPoint = Vector2.new(1, 0)
		buttonHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		buttonHolder.BackgroundTransparency = 1.000
		buttonHolder.BorderSizePixel = 0
		buttonHolder.Position = UDim2.new(1, 0, 0, 0)
		buttonHolder.Size = UDim2.new(0.300000012, 0, 1, 0)

		buttonHolderList.Name = "ButtonHolderList"
		buttonHolderList.Parent = buttonHolder
		buttonHolderList.FillDirection = Enum.FillDirection.Horizontal
		buttonHolderList.HorizontalAlignment = Enum.HorizontalAlignment.Right
		buttonHolderList.SortOrder = Enum.SortOrder.LayoutOrder
		buttonHolderList.VerticalAlignment = Enum.VerticalAlignment.Center
		buttonHolderList.Padding = UDim.new(0, 6)

		buttonHolderPadding.Name = "ButtonHolderPadding"
		buttonHolderPadding.Parent = buttonHolder
		buttonHolderPadding.PaddingRight = UDim.new(0, 6)

		plus.Name = "Plus"
		plus.Parent = buttonHolder
		plus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		plus.BackgroundTransparency = 1.000
		plus.BorderSizePixel = 0
		plus.Size = UDim2.new(1, 0, 0.5, 0)
		plus.AutoButtonColor = false
		plus.Rotation = 180
		plus.Image = "http://www.roblox.com/asset/?id=11520007725"
		plus.ImageColor3 = Color3.fromRGB(180, 180, 180)
		plus.Visible = false
		plus.ImageTransparency = 1.000

		plusAspect.Name = "PlusAspect"
		plusAspect.Parent = plus

		minus.Name = "Minus"
		minus.Parent = buttonHolder
		minus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		minus.BackgroundTransparency = 1.000
		minus.BorderSizePixel = 0
		minus.Size = UDim2.new(1, 0, .5, 0)
		minus.AutoButtonColor = false
		minus.Image = "rbxassetid://11520996670"
		minus.ImageColor3 = Color3.fromRGB(250, 250, 250)
		
		minusAspect.Name = "MinusAspect"
		minusAspect.Parent = minus
		
		close.Name = "Close"
		close.Parent = buttonHolder
		close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		close.BackgroundTransparency = 1.000
		close.BorderSizePixel = 0
		close.Size = UDim2.new(1, 0, 0.5, 0)
		close.AutoButtonColor = false
		close.Image = "rbxassetid://11520882762"
		close.ImageRectOffset = Vector2.new(48, 0)
		close.ImageRectSize = Vector2.new(20, 20)

		closeAspect.Name = "CloseAspect"
		closeAspect.Parent = close

		headingCornerHiding.Name = "HeadingCornerHiding"
		headingCornerHiding.Parent = heading
		headingCornerHiding.AnchorPoint = Vector2.new(0, 1)
		Library:AddToRegistry(headingCornerHiding, "BackgroundColor3", "MainColor")
		headingCornerHiding.BorderSizePixel = 0
		headingCornerHiding.Position = UDim2.new(0, 0, 1, 0)
		headingCornerHiding.Size = UDim2.new(1, 0, 0.25, 0)

		headingSeperator.Name = "HeadingSeperator"
		headingSeperator.Parent = heading
		headingSeperator.AnchorPoint = Vector2.new(0, 1)
		Library:AddToRegistry(headingSeperator, "BackgroundColor3", "AccentColor")
		headingSeperator.BorderSizePixel = 0
		headingSeperator.Position = UDim2.new(0, 0, 1, 0)
		headingSeperator.Size = UDim2.new(1, 0, 0.100000001, 0)

		title.Name = "Title"
		title.Parent = heading
		title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		title.BackgroundTransparency = 1.000
		title.Size = UDim2.new(0.25, 0, 0.899999976, 0)
		title.Font = Enum.Font.GothamBold
		title.LineHeight = 0.800
		title.Text = "KeyForge"
		Library:AddToRegistry(title, "TextColor3", "FontColor")
		title.TextSize = 14.000
		title.TextXAlignment = Enum.TextXAlignment.Left

		titleUIPadding.Name = "TitleUIPadding"
		titleUIPadding.Parent = title
		titleUIPadding.PaddingLeft = UDim.new(0, 5)

		holder.Name = "Holder"
		holder.Parent = background
		holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		holder.BackgroundTransparency = 1.000
		holder.BorderSizePixel = 0
		holder.Position = UDim2.new(0, 0, 0.0500000007, 0)
		holder.Size = UDim2.new(1, 0, 0.949999988, 0)
		
		tabs.Name = "Tabs"
		tabs.Parent = holder
		tabs.Active = true
		tabs.AnchorPoint = Vector2.new(0, 1)
		Library:AddToRegistry(tabs, "BackgroundColor3", "MainColor")
		tabs.BorderSizePixel = 0
		tabs.Position = UDim2.new(0, 5, 1, -5)
		tabs.Size = UDim2.new(0.225, 0, 1, -15)
		tabs.ScrollBarThickness = 0

		tabsUIListLayout.Name = "TabsUIListLayout"
		tabsUIListLayout.Parent = tabs
		tabsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabsUIListLayout.Padding = UDim.new(0, 5)
		
		snowEffect.Name = "SnowEffect"
		snowEffect.AnchorPoint = Vector2.new(1, 1)
		snowEffect.BackgroundTransparency = 1.000
		snowEffect.BorderSizePixel = 0
		snowEffect.Position = UDim2.new(1, -10, 1, -5)
		snowEffect.Size = UDim2.new(0.774999976, -25, 1, -15)
		snowEffect.ZIndex = 0
		snowEffect.Parent = holder

		return screenGui
	end
	
	local function createTab()
		local tab = Instance.new("TextButton")
		local tabText = Instance.new("TextLabel")
		local tabTextUIPadding = Instance.new("UIPadding")
		local tabImage = Instance.new("ImageLabel")
		local tabAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		local tabSeperator = Instance.new("Frame")
		local tabSeperatorUICorner = Instance.new("UICorner")

		tab.Name = "Tab"
		tab.BackgroundColor3 = Color3.fromRGB(37, 37, 51)
		tab.BackgroundTransparency = 1.000
		tab.BorderSizePixel = 0
		tab.Size = UDim2.new(1, 0, 0, 27.5)
		tab.AutoButtonColor = false
		tab.Font = Enum.Font.SourceSans
		tab.Text = ""
		tab.TextColor3 = Color3.fromRGB(109, 110, 119)
		tab.TextSize = 18.000
		tab.TextXAlignment = Enum.TextXAlignment.Left

		tabText.Name = "TabText"
		tabText.Parent = tab
		tabText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabText.BackgroundTransparency = 1.000
		tabText.Position = UDim2.new(0.0350000001, 30, 0, 0)
		tabText.Size = UDim2.new(0.964999974, -30, 1, 0)
		tabText.Font = Enum.Font.SourceSans
		tabText.Text = "N/A"
		Library:AddToRegistry(tabText, "TextColor3", "FontColor")
		tabText.TextSize = 18.000
		tabText.TextXAlignment = Enum.TextXAlignment.Left
		tabText.ClipsDescendants = true

		tabTextUIPadding.Parent = tabText
		tabTextUIPadding.PaddingLeft = UDim.new(0, 3)

		tabImage.Name = "TabImage"
		tabImage.Parent = tab
		tabImage.AnchorPoint = Vector2.new(0, 0.5)
		tabImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabImage.BackgroundTransparency = 1.000
		tabImage.BorderSizePixel = 0
		tabImage.Position = UDim2.new(0.0350000001, 5, 0.5, 0)
		tabImage.Size = UDim2.new(0.800000012, 0, 0.800000012, 0)
		tabImage.Image = "rbxassetid://10746039695"

		tabAspectRatioConstraint.Parent = tabImage

		tabSeperator.Name = "TabSeperator"
		tabSeperator.Parent = tab
		Library:AddToRegistry(tabSeperator, "BackgroundColor3", "AccentColor")
		tabSeperator.BackgroundTransparency = 0
		tabSeperator.BorderColor3 = Color3.fromRGB(27, 42, 53)
		tabSeperator.BorderSizePixel = 0
		tabSeperator.Size = UDim2.new(0, 0, 1, 0)

		tabSeperatorUICorner.CornerRadius = UDim.new(0, 2)
		tabSeperatorUICorner.Name = "TabSeperatorUICorner"
		tabSeperatorUICorner.Parent = tabSeperator
		
		return tab
	end
	
	local function createPage()
		local page = Instance.new("Frame")
		local leftScrollingFrame = Instance.new("ScrollingFrame")
		local leftScrollingFrameList = Instance.new("UIListLayout")
		local rightScrollingFrame = Instance.new("ScrollingFrame")
		local rightScrollingFrameList = Instance.new("UIListLayout")

		page.Name = "Page"
		page.AnchorPoint = Vector2.new(1, 1)
		Library:AddToRegistry(page, "BackgroundColor3", "MainColor")
		page.BackgroundTransparency = 1.000
		page.BorderSizePixel = 0
		page.Position = UDim2.new(1, -10, 1, -5)
		page.Visible = false
		page.Size = UDim2.new(.775,-25,0,0)

		leftScrollingFrame.Name = "LeftScrollingFrame"
		leftScrollingFrame.Active = true
		Library:AddToRegistry(leftScrollingFrame, "BackgroundColor3", "MainColor")
		leftScrollingFrame.BackgroundTransparency = 1.000
		leftScrollingFrame.Size = UDim2.new(0.5, -5, 1, 0)
		leftScrollingFrame.ScrollBarThickness = 0
		leftScrollingFrame.CanvasSize = UDim2.fromScale(0,0)
		leftScrollingFrame.Parent = page
		
		leftScrollingFrameList.Name = "LeftScrollingFrameList"
		leftScrollingFrameList.Padding = UDim.new(0,7)
		leftScrollingFrameList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		leftScrollingFrameList.Parent = leftScrollingFrame
		
		rightScrollingFrame.Name = "RightScrollingFrame"
		rightScrollingFrame.Active = true
		rightScrollingFrame.AnchorPoint = Vector2.new(1, 0)
		Library:AddToRegistry(rightScrollingFrame, "BackgroundColor3", "MainColor")
		rightScrollingFrame.BackgroundTransparency = 1.000
		rightScrollingFrame.Position = UDim2.new(1, 0, 0, 0)
		rightScrollingFrame.Size = UDim2.new(0.5, -5, 1, 0)
		rightScrollingFrame.CanvasSize = UDim2.fromScale(0,0)
		rightScrollingFrame.ScrollBarThickness = 0
		rightScrollingFrame.Parent = page
		
		rightScrollingFrameList.Name = "RightScrollingFrameList"
		rightScrollingFrameList.Padding = UDim.new(0,7)
		rightScrollingFrameList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		rightScrollingFrameList.Parent = rightScrollingFrame
		
		return page
	end
	
	local function createSection()
		local section = Instance.new("Frame")
		local heading = Instance.new("Frame")
		local headingSeperator = Instance.new("Frame")
		local title = Instance.new("TextLabel")
		local titleUIPadding = Instance.new("UIPadding")
		local resizeButton = Instance.new("ImageButton")
		local resizeButtonAspect = Instance.new("UIAspectRatioConstraint")
		local elementHolder = Instance.new("Frame")
		local elementHolderList = Instance.new("UIListLayout")
		local elementHolderPadding = Instance.new("UIPadding")

		section.Name = "Section"
		Library:AddToRegistry(section, "BackgroundColor3", "MainColor")
		section.BorderSizePixel = 0
		section.Size = UDim2.new(1, 0, 0, 200)
		section.ClipsDescendants = true

		heading.Name = "Heading"
		heading.Parent = section
		Library:AddToRegistry(heading, "BackgroundColor3", "MainColor")
		heading.BorderSizePixel = 0
		heading.Size = UDim2.new(1, 0, 0, 22)

		headingSeperator.Name = "HeadingSeperator"
		headingSeperator.Parent = heading
		headingSeperator.AnchorPoint = Vector2.new(0, 1)
		Library:AddToRegistry(headingSeperator, "BackgroundColor3", "AccentColor")
		headingSeperator.BorderSizePixel = 0
		headingSeperator.Position = UDim2.new(0, 0, 1, 0)
		headingSeperator.Size = UDim2.new(1, 0, 0, 2)

		title.Name = "Title"
		title.Parent = heading
		title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		title.BackgroundTransparency = 1.000
		title.Size = UDim2.new(1, -20, 0, 20)
		title.Font = Enum.Font.GothamMedium
		title.Text = "N/A"
		Library:AddToRegistry(title, "TextColor3", "FontColor")
		title.TextSize = 14.000
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ClipsDescendants = true

		titleUIPadding.Name = "TitleUIPadding"
		titleUIPadding.Parent = title
		titleUIPadding.PaddingLeft = UDim.new(0, 5)

		resizeButton.Name = "ResizeButton"
		resizeButton.Parent = heading
		resizeButton.AnchorPoint = Vector2.new(1, 0.5)
		resizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		resizeButton.BackgroundTransparency = 1.000
		resizeButton.BorderSizePixel = 0
		resizeButton.Position = UDim2.new(1, -5, 0.5, 0)
		resizeButton.Size = UDim2.fromScale(.75, .75)
		resizeButton.Image = "rbxassetid://11269835227"
		
		resizeButtonAspect.Parent = resizeButton

		elementHolder.Name = "ElementHolder"
		elementHolder.Parent = section
		elementHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		elementHolder.BackgroundTransparency = 1.000
		elementHolder.BorderSizePixel = 0
		elementHolder.Position = UDim2.new(0, 0, 0, 22)
		elementHolder.Size = UDim2.new(1, 0, 0, 178)
		elementHolder.ClipsDescendants = true

		elementHolderList.Name = "ElementHolderList"
		elementHolderList.Parent = elementHolder
		elementHolderList.SortOrder = Enum.SortOrder.LayoutOrder
		elementHolderList.Padding = UDim.new(0, 5)

		elementHolderPadding.Name = "ElementHolderPadding"
		elementHolderPadding.Parent = elementHolder
		elementHolderPadding.PaddingBottom = UDim.new(0, 4)
		elementHolderPadding.PaddingLeft = UDim.new(0, 5)
		elementHolderPadding.PaddingRight = UDim.new(0, 5)
		elementHolderPadding.PaddingTop = UDim.new(0, 4)	
		
		return section
	end
	
	local function createTitle()
		local title = Instance.new("Frame")
		local titleText = Instance.new("TextLabel")
		local design = Instance.new("Frame")
		local designGradient = Instance.new("UIGradient")

		title.Name = "Title"
		title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		title.BackgroundTransparency = 1.000
		title.BorderSizePixel = 0
		title.Size = UDim2.new(1, 0, 0, 14)

		titleText.Name = "TitleText"
		titleText.Parent = title
		titleText.AnchorPoint = Vector2.new(0.5, 0)
		Library:AddToRegistry(titleText, "BackgroundColor3", "MainColor")
		titleText.BorderSizePixel = 0
		titleText.Position = UDim2.new(0.5, 0, 0, 0)
		titleText.Size = UDim2.new(0.200000003, 0, 1, 0)
		titleText.ZIndex = 2
		titleText.Font = Enum.Font.GothamMedium
		Library:AddToRegistry(titleText, "TextColor3", "FontColor")
		titleText.Text = "N/A"
		titleText.TextSize = 14.000

		design.Name = "Design"
		design.Parent = title
		design.AnchorPoint = Vector2.new(0, 0.5)
		design.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		design.BorderSizePixel = 0
		design.Position = UDim2.new(0, 0, 0.5, 0)
		design.Size = UDim2.new(1, 0, 0.25, 0)

		designGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(31, 31, 43)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(163, 33, 38)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 43))}
		designGradient.Name = "DesignGradient"
		designGradient.Parent = design

		return title
	end
	
	local function createLabel()
		local label = Instance.new("Frame")
		local labelPadding = Instance.new("UIPadding")
		local labelBackground = Instance.new("Frame")
		local labelText = Instance.new("TextLabel")
		local labelTextPadding = Instance.new("UIPadding")
		local labelBackgroundPadding = Instance.new("UIPadding")

		label.Name = "Label"
		Library:AddToRegistry(label, "BackgroundColor3", "OutlineColor")
		label.BorderSizePixel = 0
		label.Size = UDim2.new(1, 0, 0, 18)

		labelPadding.Name = "LabelPadding"
		labelPadding.Parent = label
		labelPadding.PaddingBottom = UDim.new(0, 1)
		labelPadding.PaddingLeft = UDim.new(0, 1)
		labelPadding.PaddingRight = UDim.new(0, 1)
		labelPadding.PaddingTop = UDim.new(0, 1)

		labelBackground.Name = "LabelBackground"
		labelBackground.Parent = label
		labelBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		labelBackground.BorderSizePixel = 0
		labelBackground.Size = UDim2.new(1, 0, 1, 0)

		labelText.Name = "LabelText"
		labelText.Parent = labelBackground
		labelText.AnchorPoint = Vector2.new(0.5, 0)
		Library:AddToRegistry(labelText, "BackgroundColor3", "MainColor")
		labelText.BorderSizePixel = 0
		labelText.Position = UDim2.new(0.5, 0, 0, 0)
		labelText.Size = UDim2.new(1, 0, 1, 0)
		labelText.ZIndex = 2
		labelText.Font = Enum.Font.GothamMedium
		Library:AddToRegistry(labelText, "TextColor3", "FontColor")
		labelText.TextSize = 14.000
		labelText.TextWrapped = true
		labelText.TextXAlignment = Enum.TextXAlignment.Left
		labelText.TextYAlignment = Enum.TextYAlignment.Top

		labelTextPadding.Name = "LabelTextPadding"
		labelTextPadding.Parent = labelText
		labelTextPadding.PaddingLeft = UDim.new(0, 4)
		labelTextPadding.PaddingRight = UDim.new(0, 4)
		labelTextPadding.PaddingBottom = UDim.new(0, 2)
		labelTextPadding.PaddingTop = UDim.new(0, 2)

		labelBackgroundPadding.Name = "LabelBackgroundPadding"
		labelBackgroundPadding.Parent = labelBackground
		labelBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		labelBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		labelBackgroundPadding.PaddingRight = UDim.new(0, 1)
		labelBackgroundPadding.PaddingTop = UDim.new(0, 1)
		
		return label
	end
	
	local function createToggle()
		local toggle = Instance.new("TextButton")
		local toggleText = Instance.new("TextLabel")
		local boxBackground = Instance.new("Frame")
		local boxAspect = Instance.new("UIAspectRatioConstraint")
		local boxPadding = Instance.new("UIPadding")
		local innerBox = Instance.new("Frame")
		local innerBoxPadding = Instance.new("UIPadding")
		local centerBox = Instance.new("Frame")
		local toggleImage = Instance.new("ImageLabel")
		local toggleImageCorner = Instance.new("UICorner")
		
		toggle.Name = "ToggleElement"
		toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggle.BackgroundTransparency = 1.000
		toggle.BorderSizePixel = 0
		toggle.Size = UDim2.new(1, 0, 0, 14)
		toggle.AutoButtonColor = false
		toggle.Font = Enum.Font.SourceSans
		toggle.Text = ""
		toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
		toggle.TextSize = 14.000
		
		toggleText.Name = "ToggleText"
		toggleText.Parent = toggle
		toggleText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleText.BackgroundTransparency = 1.000
		toggleText.Position = UDim2.new(0, 18, 0, 0)
		toggleText.Size = UDim2.new(1, -18, 1, 0)
		toggleText.Font = Enum.Font.Gotham
		toggleText.Text = "N/A"
		Library:AddToRegistry(toggleText, "TextColor3", "FontColor")
		toggleText.TextSize = 14.000
		toggleText.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = toggle
		Library:AddToRegistry(boxBackground, "BackgroundColor3", "OutlineColor")
		boxBackground.BorderSizePixel = 0
		boxBackground.Size = UDim2.new(1, 0, 1, 0)

		boxAspect.Name = "BoxAspect"
		boxAspect.Parent = boxBackground

		boxPadding.Name = "BoxPadding"
		boxPadding.Parent = boxBackground
		boxPadding.PaddingBottom = UDim.new(0, 1)
		boxPadding.PaddingLeft = UDim.new(0, 1)
		boxPadding.PaddingRight = UDim.new(0, 1)
		boxPadding.PaddingTop = UDim.new(0, 1)
		
		innerBox.Name = "InnerBox"
		innerBox.Parent = boxBackground
		innerBox.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox.BorderSizePixel = 0
		innerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox.Size = UDim2.new(1, 0, 1, 0)

		innerBoxPadding.Name = "InnerBoxPadding"
		innerBoxPadding.Parent = innerBox
		innerBoxPadding.PaddingBottom = UDim.new(0, 1)
		innerBoxPadding.PaddingLeft = UDim.new(0, 1)
		innerBoxPadding.PaddingRight = UDim.new(0, 1)
		innerBoxPadding.PaddingTop = UDim.new(0, 1)

		centerBox.Name = "CenterBox"
		centerBox.Parent = innerBox
		centerBox.AnchorPoint = Vector2.new(0.5, 0.5)
		Library:AddToRegistry(centerBox, "BackgroundColor3", "MainColor")
		centerBox.BorderSizePixel = 0
		centerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		centerBox.Size = UDim2.new(1, 0, 1, 0)

		toggleImage.Name = "ToggleImage"
		toggleImage.Parent = centerBox
		toggleImage.AnchorPoint = Vector2.new(0.5, 0.5)
		Library:AddToRegistry(toggleImage, "BackgroundColor3", "AccentColor")
		toggleImage.BackgroundTransparency = 0
		toggleImage.BorderSizePixel = 0
		toggleImage.Position = UDim2.new(0.5, 0, 0.5, 0)
		toggleImage.Image = "rbxassetid://11444348176"
		Library:AddToRegistry(toggleImage, "ImageColor3", "MainColor")
		
		toggleImageCorner.Name = "ToggleImageCorner"
		toggleImageCorner.CornerRadius = UDim.new(.5,0)
		toggleImageCorner.Parent = toggleImage
		
		return toggle
	end
	
	local function createButton()
		local button = Instance.new("TextButton")
		local buttonText = Instance.new("TextLabel")
		local circleBackground = Instance.new("Frame")
		local circleAspect = Instance.new("UIAspectRatioConstraint")
		local circlePadding = Instance.new("UIPadding")
		local circleCorner = Instance.new("UICorner")
		local innerCircle = Instance.new("Frame")
		local innerCircleCorner = Instance.new("UICorner")
		local innerCirclePadding = Instance.new("UIPadding")
		local centerCircle = Instance.new("Frame")
		local centerCircleCorner = Instance.new("UICorner")
		local centerCirclePadding = Instance.new("UIPadding")
		local buttonCircle = Instance.new("Frame")
		local buttonCircleCorner = Instance.new("UICorner")
		
		button.Name = "Button"
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		button.BackgroundTransparency = 1.000
		button.BorderSizePixel = 0
		button.Size = UDim2.new(1, 0, 0, 14)
		button.AutoButtonColor = false
		button.Font = Enum.Font.SourceSans
		button.Text = ""
		button.TextColor3 = Color3.fromRGB(0, 0, 0)
		button.TextSize = 14.000

		buttonText.Name = "ButtonText"
		buttonText.Parent = button
		buttonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		buttonText.BackgroundTransparency = 1.000
		buttonText.Position = UDim2.new(0, 18, 0, 0)
		buttonText.Size = UDim2.new(1, -18, 1, 0)
		buttonText.Font = Enum.Font.Gotham
		buttonText.Text = "Button"
		Library:AddToRegistry(buttonText, "TextColor3", "FontColor")
		buttonText.TextSize = 14.000
		buttonText.TextXAlignment = Enum.TextXAlignment.Left

		circleBackground.Name = "CircleBackground"
		circleBackground.Parent = button
		Library:AddToRegistry(circleBackground, "BackgroundColor3", "OutlineColor")
		circleBackground.BorderSizePixel = 0
		circleBackground.Size = UDim2.new(1, 0, 1, 0)

		circleAspect.Name = "CircleAspect"
		circleAspect.Parent = circleBackground

		circlePadding.Name = "CirclePadding"
		circlePadding.Parent = circleBackground
		circlePadding.PaddingBottom = UDim.new(0, 1)
		circlePadding.PaddingLeft = UDim.new(0, 1)
		circlePadding.PaddingRight = UDim.new(0, 1)
		circlePadding.PaddingTop = UDim.new(0, 1)
		
		circleCorner.CornerRadius = UDim.new(0.5, 0)
		circleCorner.Name = "CircleCorner"
		circleCorner.Parent = circleBackground
		
		innerCircle.Name = "InnerCircle"
		innerCircle.Parent = circleBackground
		innerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		innerCircle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerCircle.BorderSizePixel = 0
		innerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerCircle.Size = UDim2.new(1, 0, 1, 0)

		innerCircleCorner.CornerRadius = UDim.new(0.5, 0)
		innerCircleCorner.Name = "InnerCircleCorner"
		innerCircleCorner.Parent = innerCircle

		innerCirclePadding.Name = "InnerCirclePadding"
		innerCirclePadding.Parent = innerCircle
		innerCirclePadding.PaddingBottom = UDim.new(0, 1)
		innerCirclePadding.PaddingLeft = UDim.new(0, 1)
		innerCirclePadding.PaddingRight = UDim.new(0, 1)
		innerCirclePadding.PaddingTop = UDim.new(0, 1)

		centerCircle.Name = "CenterCircle"
		centerCircle.Parent = innerCircle
		centerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		Library:AddToRegistry(centerCircle, "BackgroundColor3", "MainColor")
		centerCircle.BorderSizePixel = 0
		centerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
		centerCircle.Size = UDim2.new(1, 0, 1, 0)
		
		centerCircleCorner.CornerRadius = UDim.new(0.5, 0)
		centerCircleCorner.Name = "CenterCircleCorner"
		centerCircleCorner.Parent = centerCircle
		
		centerCirclePadding.Name = "CenterCirclePadding"
		centerCirclePadding.Parent = innerCircle
		centerCirclePadding.PaddingBottom = UDim.new(0, 1)
		centerCirclePadding.PaddingLeft = UDim.new(0, 1)
		centerCirclePadding.PaddingRight = UDim.new(0, 1)
		centerCirclePadding.PaddingTop = UDim.new(0, 1)
		
		buttonCircle.Name = "ButtonCircle"
		buttonCircle.Parent = centerCircle
		buttonCircle.AnchorPoint = Vector2.new(.5,.5)
		buttonCircle.BorderSizePixel = 0
		Library:AddToRegistry(buttonCircle, "BackgroundColor3", "AccentColor")
		buttonCircle.Size = UDim2.new(0, 0, 0, 0)
		buttonCircle.Position = UDim2.fromScale(.5,.5)

		buttonCircleCorner.CornerRadius = UDim.new(0.5, 0)
		buttonCircleCorner.Name = "ButtonCircleCorner"
		buttonCircleCorner.Parent = buttonCircle
		
		return button
	end
	
	local function createDropdown()
		local dropdown = Instance.new("Frame")
		local dropdownButton = Instance.new("TextButton")
		local buttonBackground = Instance.new("Frame")
		local dropdownText = Instance.new("TextLabel")
		local dropdownTextPadding = Instance.new("UIPadding")
		local buttonBackgroundPadding = Instance.new("UIPadding")
		local dropdownImage = Instance.new("ImageLabel")
		local imageAspect = Instance.new("UIAspectRatioConstraint")
		local buttonInnerBackground = Instance.new("Frame")
		local dropdownButtonPadding = Instance.new("UIPadding")
		local elementHolder = Instance.new("ScrollingFrame")
		local elementHolderBackground = Instance.new("Frame")
		local elementHolderInnerBackground = Instance.new("Frame")
		local elementHolderInnerBackgroundList = Instance.new("UIListLayout")
		local elementHolderInnerBackgroundPadding = Instance.new("UIPadding")
		local elementHolderBackgroundPadding = Instance.new("UIPadding")
		local elementHolderPadding = Instance.new("UIPadding")

		dropdown.Name = "Dropdown"
		dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdown.BackgroundTransparency = 1.000
		dropdown.BorderSizePixel = 0
		dropdown.ClipsDescendants = true
		dropdown.Size = UDim2.new(1, 0, 0, 18)

		dropdownButton.Name = "DropdownButton"
		dropdownButton.Parent = dropdown
		Library:AddToRegistry(dropdownButton, "BackgroundColor3", "OutlineColor")
		dropdownButton.BorderSizePixel = 0
		dropdownButton.Size = UDim2.new(1, 0, 0, 18)
		dropdownButton.AutoButtonColor = false
		dropdownButton.Font = Enum.Font.SourceSans
		dropdownButton.Text = ""
		dropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		dropdownButton.TextSize = 14.000

		buttonBackground.Name = "ButtonBackground"
		buttonBackground.Parent = dropdownButton
		buttonBackground.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		buttonBackground.BorderSizePixel = 0
		buttonBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
		buttonBackground.Size = UDim2.new(1, 0, 1, 0)

		dropdownText.Name = "DropdownText"
		dropdownText.Parent = buttonBackground
		dropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdownText.BackgroundTransparency = 1.000
		dropdownText.BorderSizePixel = 0
		dropdownText.ClipsDescendants = true
		dropdownText.Size = UDim2.new(1, -17, 1, 0)
		dropdownText.Font = Enum.Font.Gotham
		dropdownText.Text = "N/A"
		Library:AddToRegistry(dropdownText, "TextColor3", "FontColor")
		dropdownText.TextScaled = false
		dropdownText.TextSize = 14.000
		dropdownText.TextWrapped = true
		dropdownText.TextXAlignment = Enum.TextXAlignment.Left

		dropdownTextPadding.Name = "DropdownTextPadding"
		dropdownTextPadding.Parent = dropdownText
		dropdownTextPadding.PaddingLeft = UDim.new(0, 4)

		buttonBackgroundPadding.Name = "ButtonBackgroundPadding"
		buttonBackgroundPadding.Parent = buttonBackground
		buttonBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		buttonBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		buttonBackgroundPadding.PaddingRight = UDim.new(0, 1)
		buttonBackgroundPadding.PaddingTop = UDim.new(0, 1)

		dropdownImage.Name = "DropdownImage"
		dropdownImage.Parent = buttonBackground
		dropdownImage.AnchorPoint = Vector2.new(1, 0)
		dropdownImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdownImage.BackgroundTransparency = 1.000
		dropdownImage.BorderSizePixel = 0
		dropdownImage.Position = UDim2.new(1, -3, 0, 0)
		dropdownImage.Rotation = 180.000
		dropdownImage.Size = UDim2.new(1, 0, 1, 0)
		dropdownImage.Image = "rbxassetid://11269835227"

		imageAspect.Name = "ImageAspect"
		imageAspect.Parent = dropdownImage

		buttonInnerBackground.Name = "ButtonInnerBackground"
		buttonInnerBackground.Parent = buttonBackground
		Library:AddToRegistry(buttonInnerBackground, "BackgroundColor3", "MainColor")
		buttonInnerBackground.BorderSizePixel = 0
		buttonInnerBackground.Size = UDim2.new(1, 0, 1, 0)
		buttonInnerBackground.ZIndex = 0

		dropdownButtonPadding.Name = "DropdownButtonPadding"
		dropdownButtonPadding.Parent = dropdownButton
		dropdownButtonPadding.PaddingBottom = UDim.new(0, 1)
		dropdownButtonPadding.PaddingLeft = UDim.new(0, 1)
		dropdownButtonPadding.PaddingRight = UDim.new(0, 1)
		dropdownButtonPadding.PaddingTop = UDim.new(0, 1)

		elementHolder.Name = "ElementHolder"
		elementHolder.Parent = dropdown
		elementHolder.Active = true
		Library:AddToRegistry(elementHolder, "BackgroundColor3", "OutlineColor")
		elementHolder.BorderSizePixel = 0
		elementHolder.Position = UDim2.new(0, 0, 0, 18)
		elementHolder.Size = UDim2.new(0.925000012, 0, 0, 0)
		elementHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
		elementHolder.ScrollBarThickness = 0

		elementHolderBackground.Name = "ElementHolderBackground"
		elementHolderBackground.Parent = elementHolder
		elementHolderBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		elementHolderBackground.BorderSizePixel = 0
		elementHolderBackground.Size = UDim2.new(1, 0, 1, 0)

		elementHolderInnerBackground.Name = "ElementHolderInnerBackground"
		elementHolderInnerBackground.Parent = elementHolderBackground
		Library:AddToRegistry(elementHolderInnerBackground, "BackgroundColor3", "MainColor")
		elementHolderInnerBackground.BorderSizePixel = 0
		elementHolderInnerBackground.Size = UDim2.new(1, 0, 1, 0)

		elementHolderInnerBackgroundList.Name = "ElementHolderInnerBackgroundList"
		elementHolderInnerBackgroundList.Parent = elementHolderInnerBackground
		elementHolderInnerBackgroundList.SortOrder = Enum.SortOrder.LayoutOrder
		elementHolderInnerBackgroundList.Padding = UDim.new(0, 5)

		elementHolderInnerBackgroundPadding.Name = "ElementHolderInnerBackgroundPadding"
		elementHolderInnerBackgroundPadding.Parent = elementHolderInnerBackground
		elementHolderInnerBackgroundPadding.PaddingBottom = UDim.new(0, 4)
		elementHolderInnerBackgroundPadding.PaddingLeft = UDim.new(0, 5)
		elementHolderInnerBackgroundPadding.PaddingRight = UDim.new(0, 5)
		elementHolderInnerBackgroundPadding.PaddingTop = UDim.new(0, 4)

		elementHolderBackgroundPadding.Name = "ElementHolderBackgroundPadding"
		elementHolderBackgroundPadding.Parent = elementHolderBackground
		elementHolderBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingRight = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingTop = UDim.new(0, 1)

		elementHolderPadding.Name = "ElementHolderPadding"
		elementHolderPadding.Parent = elementHolder
		elementHolderPadding.PaddingBottom = UDim.new(0, 1)
		elementHolderPadding.PaddingLeft = UDim.new(0, 1)
		elementHolderPadding.PaddingRight = UDim.new(0, 1)
		
		return dropdown
	end
	
	local function createSlider()
		local sliderElement = Instance.new("Frame")
		local textGrouping = Instance.new("Frame")
		local numberText = Instance.new("TextBox")
		local sliderText = Instance.new("TextLabel")
		local sliderElementList = Instance.new("UIListLayout")
		local sliderBackground = Instance.new("TextButton")
		local sliderInnerBackground = Instance.new("Frame")
		local sliderInnerBackgroundPadding = Instance.new("UIPadding")
		local emptySliderBackground = Instance.new("Frame")
		local slider = Instance.new("Frame")
		local sliderBackgroundPadding = Instance.new("UIPadding")

		sliderElement.Name = "Slider"
		sliderElement.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sliderElement.BackgroundTransparency = 1.000
		sliderElement.BorderSizePixel = 0
		sliderElement.Size = UDim2.new(1, 0, 0, 32)

		textGrouping.Name = "TextGrouping"
		textGrouping.Parent = sliderElement
		textGrouping.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textGrouping.BackgroundTransparency = 1.000
		textGrouping.BorderSizePixel = 0
		textGrouping.Size = UDim2.new(1, 0, 0, 14)

		numberText.Name = "NumberText"
		numberText.Parent = textGrouping
		numberText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		numberText.BackgroundTransparency = 1.000
		numberText.BorderSizePixel = 0
		numberText.AnchorPoint = Vector2.new(1,0)
		numberText.Position = UDim2.new(1, 0, 0, 0)
		numberText.Size = UDim2.new(0.5, 0, 1, 0)
		numberText.Font = Enum.Font.Gotham
		numberText.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		numberText.PlaceholderText = ""
		numberText.Text = "0"
		numberText.TextColor3 = Color3.fromRGB(139, 141, 147)
		numberText.TextSize = 14.000
		numberText.TextXAlignment = Enum.TextXAlignment.Right
		numberText.ClipsDescendants = true
		
		sliderText.Name = "SliderText"
		sliderText.Parent = textGrouping
		sliderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sliderText.BackgroundTransparency = 1.000
		sliderText.Size = UDim2.new(0.5, 0, 1, 0)
		sliderText.BorderSizePixel = 0
		sliderText.Font = Enum.Font.Gotham
		sliderText.Text = "N/A"
		Library:AddToRegistry(sliderText, "TextColor3", "FontColor")
		sliderText.TextSize = 14.000
		sliderText.ClipsDescendants = true
		sliderText.TextXAlignment = Enum.TextXAlignment.Left

		sliderElementList.Name = "SliderElementList"
		sliderElementList.Parent = sliderElement
		sliderElementList.SortOrder = Enum.SortOrder.LayoutOrder
		sliderElementList.Padding = UDim.new(0, 4)

		sliderBackground.Name = "SliderBackground"
		sliderBackground.Parent = sliderElement
		sliderBackground.AnchorPoint = Vector2.new(0, 1)
		Library:AddToRegistry(sliderBackground, "BackgroundColor3", "OutlineColor")
		sliderBackground.BorderSizePixel = 0
		sliderBackground.Position = UDim2.new(0, 0, 1, 0)
		sliderBackground.Size = UDim2.new(1, 0, 0.5, -2)
		sliderBackground.AutoButtonColor = false
		sliderBackground.Font = Enum.Font.SourceSans
		sliderBackground.Text = ""
		sliderBackground.TextColor3 = Color3.fromRGB(0, 0, 0)
		sliderBackground.TextSize = 14.000

		sliderInnerBackground.Name = "SliderInnerBackground"
		sliderInnerBackground.Parent = sliderBackground
		sliderInnerBackground.AnchorPoint = Vector2.new(0.5, 0.5)
		sliderInnerBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		sliderInnerBackground.BorderSizePixel = 0
		sliderInnerBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
		sliderInnerBackground.Size = UDim2.new(1, 0, 1, 0)

		sliderInnerBackgroundPadding.Name = "SliderInnerBackgroundPadding"
		sliderInnerBackgroundPadding.Parent = sliderInnerBackground
		sliderInnerBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		sliderInnerBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		sliderInnerBackgroundPadding.PaddingRight = UDim.new(0, 1)
		sliderInnerBackgroundPadding.PaddingTop = UDim.new(0, 1)

		emptySliderBackground.Name = "EmptySliderBackground"
		emptySliderBackground.Parent = sliderInnerBackground
		Library:AddToRegistry(emptySliderBackground, "BackgroundColor3", "MainColor")
		emptySliderBackground.BorderSizePixel = 0
		emptySliderBackground.Size = UDim2.new(1, 0, 1, 0)
		emptySliderBackground.ZIndex = 0

		slider.Name = "Slider"
		slider.Parent = sliderInnerBackground
		Library:AddToRegistry(slider, "BackgroundColor3", "AccentColor")
		slider.BorderSizePixel = 0
		slider.Size = UDim2.new(0, 2, 1, 0)

		sliderBackgroundPadding.Name = "SliderBackgroundPadding"
		sliderBackgroundPadding.Parent = sliderBackground
		sliderBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		sliderBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		sliderBackgroundPadding.PaddingRight = UDim.new(0, 1)
		sliderBackgroundPadding.PaddingTop = UDim.new(0, 1)
		
		return sliderElement
	end
	
	local function createSearchBar()
		local searchBar = Instance.new("Frame")
		local searchBarFrame = Instance.new("Frame")
		local buttonBackgroundPadding = Instance.new("Frame")
		local buttonBackgroundPadding_2 = Instance.new("UIPadding")
		local searchBox = Instance.new("TextBox")
		local searchBoxPadding = Instance.new("UIPadding")
		local searchBoxBackground = Instance.new("Frame")
		local searchImage = Instance.new("ImageLabel")
		local searchImageAspect = Instance.new("UIAspectRatioConstraint")
		local searchButtonPadding = Instance.new("UIPadding")
		local elementHolder = Instance.new("ScrollingFrame")
		local elementHolderBackground = Instance.new("Frame")
		local elementHolderInnerBackground = Instance.new("Frame")
		local elementHolderInnerBackgroundList = Instance.new("UIListLayout")
		local elementHolderInnerBackgroundPadding = Instance.new("UIPadding")
		local elementHolderBackgroundPadding = Instance.new("UIPadding")
		local elementHolderPadding = Instance.new("UIPadding")

		searchBar.Name = "SearchBar"
		searchBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		searchBar.BackgroundTransparency = 1.000
		searchBar.BorderSizePixel = 0
		searchBar.ClipsDescendants = true
		searchBar.Size = UDim2.new(1, 0, 0, 18)

		searchBarFrame.Name = "SearchBarFrame"
		searchBarFrame.Parent = searchBar
		Library:AddToRegistry(searchBarFrame, "BackgroundColor3", "OutlineColor")
		searchBarFrame.BorderSizePixel = 0
		searchBarFrame.Size = UDim2.new(1, 0, 0, 18)

		buttonBackgroundPadding.Name = "ButtonBackgroundPadding"
		buttonBackgroundPadding.Parent = searchBarFrame
		buttonBackgroundPadding.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonBackgroundPadding.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		buttonBackgroundPadding.BorderSizePixel = 0
		buttonBackgroundPadding.Position = UDim2.new(0.5, 0, 0.5, 0)
		buttonBackgroundPadding.Size = UDim2.new(1, 0, 1, 0)

		buttonBackgroundPadding_2.Name = "ButtonBackgroundPadding"
		buttonBackgroundPadding_2.Parent = buttonBackgroundPadding
		buttonBackgroundPadding_2.PaddingBottom = UDim.new(0, 1)
		buttonBackgroundPadding_2.PaddingLeft = UDim.new(0, 1)
		buttonBackgroundPadding_2.PaddingRight = UDim.new(0, 1)
		buttonBackgroundPadding_2.PaddingTop = UDim.new(0, 1)

		searchBox.Name = "SearchBox"
		searchBox.Parent = buttonBackgroundPadding
		searchBox.Active = false
		Library:AddToRegistry(searchBox, "BackgroundColor3", "MainColor")
		searchBox.BackgroundTransparency = 1
		searchBox.BorderSizePixel = 0
		searchBox.Size = UDim2.new(1, 0, 1, 0)
		searchBox.Font = Enum.Font.Gotham
		searchBox.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		searchBox.PlaceholderText = "N/A"
		searchBox.Text = ""
		Library:AddToRegistry(searchBox, "TextColor3", "FontColor")
		searchBox.TextSize = 14.000
		searchBox.TextXAlignment = Enum.TextXAlignment.Left

		searchBoxPadding.Name = "SearchBoxPadding"
		searchBoxPadding.Parent = searchBox
		searchBoxPadding.PaddingLeft = UDim.new(0, 4)
		
		searchBoxBackground.Name = "SearchBoxBackground"
		searchBoxBackground.Parent = buttonBackgroundPadding
		Library:AddToRegistry(searchBoxBackground, "BackgroundColor3", "MainColor")
		searchBoxBackground.BorderSizePixel = 0
		searchBoxBackground.Size = UDim2.new(1, 0, 1, 0)
		searchBoxBackground.ZIndex = 0
		
		searchImage.Name = "SearchImage"
		searchImage.Parent = buttonBackgroundPadding
		searchImage.AnchorPoint = Vector2.new(1, 0.5)
		Library:AddToRegistry(searchImage, "BackgroundColor3", "MainColor")
		searchImage.BackgroundTransparency = 1
		searchImage.BorderSizePixel = 0
		searchImage.Position = UDim2.new(1, 0, 0.5, 0)
		searchImage.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
		searchImage.Image = "rbxassetid://11454041890"

		searchImageAspect.Name = "SearchImageAspect"
		searchImageAspect.Parent = searchImage

		searchButtonPadding.Name = "SearchButtonPadding"
		searchButtonPadding.Parent = searchBarFrame
		searchButtonPadding.PaddingBottom = UDim.new(0, 1)
		searchButtonPadding.PaddingLeft = UDim.new(0, 1)
		searchButtonPadding.PaddingRight = UDim.new(0, 1)
		searchButtonPadding.PaddingTop = UDim.new(0, 1)

		elementHolder.Name = "ElementHolder"
		elementHolder.Parent = searchBar
		elementHolder.Active = true
		Library:AddToRegistry(elementHolder, "BackgroundColor3", "OutlineColor")
		elementHolder.BorderSizePixel = 0
		elementHolder.Position = UDim2.new(0, 0, 0, 18)
		elementHolder.Size = UDim2.new(0.925000012, 0, 0, 0)
		elementHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
		elementHolder.ScrollBarThickness = 0

		elementHolderBackground.Name = "ElementHolderBackground"
		elementHolderBackground.Parent = elementHolder
		elementHolderBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		elementHolderBackground.BorderSizePixel = 0
		elementHolderBackground.Size = UDim2.new(1, 0, 1, 0)

		elementHolderInnerBackground.Name = "ElementHolderInnerBackground"
		elementHolderInnerBackground.Parent = elementHolderBackground
		Library:AddToRegistry(elementHolderInnerBackground, "BackgroundColor3", "MainColor")
		elementHolderInnerBackground.BorderSizePixel = 0
		elementHolderInnerBackground.Visible = false
		elementHolderInnerBackground.Size = UDim2.new(1, 0, 1, 0)

		elementHolderInnerBackgroundList.Name = "ElementHolderInnerBackgroundList"
		elementHolderInnerBackgroundList.Parent = elementHolderInnerBackground
		elementHolderInnerBackgroundList.SortOrder = Enum.SortOrder.LayoutOrder
		elementHolderInnerBackgroundList.Padding = UDim.new(0, 5)

		elementHolderInnerBackgroundPadding.Name = "ElementHolderInnerBackgroundPadding"
		elementHolderInnerBackgroundPadding.Parent = elementHolderInnerBackground
		elementHolderInnerBackgroundPadding.PaddingBottom = UDim.new(0, 4)
		elementHolderInnerBackgroundPadding.PaddingLeft = UDim.new(0, 5)
		elementHolderInnerBackgroundPadding.PaddingRight = UDim.new(0, 5)
		elementHolderInnerBackgroundPadding.PaddingTop = UDim.new(0, 4)

		elementHolderBackgroundPadding.Name = "ElementHolderBackgroundPadding"
		elementHolderBackgroundPadding.Parent = elementHolderBackground
		elementHolderBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingRight = UDim.new(0, 1)
		elementHolderBackgroundPadding.PaddingTop = UDim.new(0, 1)

		elementHolderPadding.Name = "ElementHolderPadding"
		elementHolderPadding.Parent = elementHolder
		elementHolderPadding.PaddingBottom = UDim.new(0, 1)
		elementHolderPadding.PaddingLeft = UDim.new(0, 1)
		elementHolderPadding.PaddingRight = UDim.new(0, 1)
		
		return searchBar
	end
	
	local function createKeybind()
		local keybind = Instance.new("TextButton")
		local keybindText = Instance.new("TextLabel")
		local boxBackground = Instance.new("Frame")
		local boxAspect = Instance.new("UIAspectRatioConstraint")
		local boxPadding = Instance.new("UIPadding")
		local innerBox = Instance.new("Frame")
		local boxPadding_2 = Instance.new("UIPadding")
		local keyText = Instance.new("TextLabel")

		keybind.Name = "Keybind"
		keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybind.BackgroundTransparency = 1.000
		keybind.BorderSizePixel = 0
		keybind.Size = UDim2.new(1, 0, 0, 18)
		keybind.AutoButtonColor = false
		keybind.Font = Enum.Font.SourceSans
		keybind.Text = ""
		keybind.TextColor3 = Color3.fromRGB(0, 0, 0)
		keybind.TextSize = 14.000

		keybindText.Name = "KeybindText"
		keybindText.Parent = keybind
		keybindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindText.BackgroundTransparency = 1.000
		keybindText.Size = UDim2.new(1, -18, 1, 0)
		keybindText.Font = Enum.Font.Gotham
		keybindText.Text = "N/A"
		Library:AddToRegistry(keybindText, "TextColor3", "FontColor")
		keybindText.TextSize = 14.000
		keybindText.ClipsDescendants = true
		keybindText.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = keybind
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		Library:AddToRegistry(boxBackground, "BackgroundColor3", "OutlineColor")
		boxBackground.BorderSizePixel = 0
		boxBackground.Position = UDim2.new(1, 0, 0, 0)
		boxBackground.Size = UDim2.new(1, 0, 1, 0)

		boxAspect.Name = "BoxAspect"
		boxAspect.Parent = boxBackground

		boxPadding.Name = "BoxPadding"
		boxPadding.Parent = boxBackground
		boxPadding.PaddingBottom = UDim.new(0, 1)
		boxPadding.PaddingLeft = UDim.new(0, 1)
		boxPadding.PaddingRight = UDim.new(0, 1)
		boxPadding.PaddingTop = UDim.new(0, 1)

		innerBox.Name = "InnerBox"
		innerBox.Parent = boxBackground
		innerBox.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox.BorderSizePixel = 0
		innerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_2.Name = "BoxPadding"
		boxPadding_2.Parent = innerBox
		boxPadding_2.PaddingBottom = UDim.new(0, 1)
		boxPadding_2.PaddingLeft = UDim.new(0, 1)
		boxPadding_2.PaddingRight = UDim.new(0, 1)
		boxPadding_2.PaddingTop = UDim.new(0, 1)

		keyText.Parent = innerBox
		keyText.Name = "KeyText"
		Library:AddToRegistry(keyText, "BackgroundColor3", "MainColor")
		keyText.BorderSizePixel = 0
		keyText.Size = UDim2.new(1, 0, 1, 0)
		keyText.Font = Enum.Font.Gotham
		keyText.Text = "N/A"
		Library:AddToRegistry(keyText, "TextColor3", "FontColor")
		keyText.TextSize = 14.000
		
		return keybind
	end
	
	local function createTextBox()
		local textBox = Instance.new("TextButton")
		local textBoxNameText = Instance.new("TextLabel")
		local boxBackground = Instance.new("Frame")
		local boxPadding = Instance.new("UIPadding")
		local innerBox = Instance.new("Frame")
		local boxPadding_2 = Instance.new("UIPadding")
		local textBoxText = Instance.new("TextBox")
		
		textBox.Name = "TextBox"
		textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textBox.BackgroundTransparency = 1.000
		textBox.BorderSizePixel = 0
		textBox.Size = UDim2.new(1, 0, 0, 18)
		textBox.AutoButtonColor = false
		textBox.Font = Enum.Font.SourceSans
		textBox.Text = ""
		textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
		textBox.TextSize = 14.000

		textBoxNameText.Name = "TextBoxNameText"
		textBoxNameText.Parent = textBox
		textBoxNameText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textBoxNameText.BackgroundTransparency = 1.000
		textBoxNameText.Size = UDim2.new(1, -18, 1, 0)
		textBoxNameText.Font = Enum.Font.Gotham
		textBoxNameText.Text = "Textbox"
		textBoxNameText.ClipsDescendants = true
		Library:AddToRegistry(textBoxNameText, "TextColor3", "FontColor")
		textBoxNameText.TextSize = 14.000
		textBoxNameText.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = textBox
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		Library:AddToRegistry(boxBackground, "BackgroundColor3", "OutlineColor")
		boxBackground.BorderSizePixel = 0
		boxBackground.Position = UDim2.new(1, 0, 0, 0)
		boxBackground.Size = UDim2.new(0.400000006, 0, 1, 0)

		boxPadding.Name = "BoxPadding"
		boxPadding.Parent = boxBackground
		boxPadding.PaddingBottom = UDim.new(0, 1)
		boxPadding.PaddingLeft = UDim.new(0, 1)
		boxPadding.PaddingRight = UDim.new(0, 1)
		boxPadding.PaddingTop = UDim.new(0, 1)

		innerBox.Name = "InnerBox"
		innerBox.Parent = boxBackground
		innerBox.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox.BorderSizePixel = 0
		innerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_2.Name = "BoxPadding"
		boxPadding_2.Parent = innerBox
		boxPadding_2.PaddingBottom = UDim.new(0, 1)
		boxPadding_2.PaddingLeft = UDim.new(0, 1)
		boxPadding_2.PaddingRight = UDim.new(0, 1)
		boxPadding_2.PaddingTop = UDim.new(0, 1)

		textBoxText.Name = "TextBoxText"
		textBoxText.Parent = innerBox
		Library:AddToRegistry(textBoxText, "BackgroundColor3", "MainColor")
		textBoxText.BorderSizePixel = 0
		textBoxText.ClipsDescendants = true
		textBoxText.Size = UDim2.new(1, 0, 1, 0)
		textBoxText.Font = Enum.Font.Gotham
		textBoxText.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		textBoxText.PlaceholderText = "Type here..."
		textBoxText.Text = ""
		textBoxText.TextXAlignment = Enum.TextXAlignment.Left
		Library:AddToRegistry(textBoxText, "TextColor3", "FontColor")
		textBoxText.TextSize = 14.000
		
		return textBox
	end
	
	local function createColorWheel()
		local colorWheel = Instance.new("Frame")
		local heading = Instance.new("TextButton")
		local colorWheelName = Instance.new("TextLabel")
		local boxBackground = Instance.new("Frame")
		local boxBackgroundPadding = Instance.new("UIPadding")
		local innerBox = Instance.new("Frame")
		local innerBoxPadding = Instance.new("UIPadding")
		local innerBoxCorner = Instance.new("UICorner")
		local centerBox = Instance.new("Frame")
		local centerBoxPadding = Instance.new("UIPadding")
		local centerBoxCorner = Instance.new("UICorner")
		local wheelImage = Instance.new("ImageLabel")
		local wheelImageAspect = Instance.new("UIAspectRatioConstraint")
		local dropdownImage = Instance.new("ImageLabel")
		local dropdownButtonAspect = Instance.new("UIAspectRatioConstraint")
		local boxBackgroundCorner = Instance.new("UICorner")
		local wheelHolder = Instance.new("Frame")
		local valueHolder = Instance.new("Frame")
		local colorInputHolder = Instance.new("Frame")
		local colorInputHolderList = Instance.new("UIListLayout")
		local red = Instance.new("Frame")
		local colorText = Instance.new("TextLabel")
		local boxBackground_2 = Instance.new("Frame")
		local boxPadding = Instance.new("UIPadding")
		local innerBox_2 = Instance.new("Frame")
		local boxPadding_2 = Instance.new("UIPadding")
		local colorValue = Instance.new("TextBox")
		local green = Instance.new("Frame")
		local colorText_2 = Instance.new("TextLabel")
		local boxBackground_3 = Instance.new("Frame")
		local boxPadding_3 = Instance.new("UIPadding")
		local innerBox_3 = Instance.new("Frame")
		local boxPadding_4 = Instance.new("UIPadding")
		local colorValue_2 = Instance.new("TextBox")
		local blue = Instance.new("Frame")
		local colorText_3 = Instance.new("TextLabel")
		local boxBackground_4 = Instance.new("Frame")
		local boxPadding_5 = Instance.new("UIPadding")
		local innerBox_4 = Instance.new("Frame")
		local boxPadding_6 = Instance.new("UIPadding")
		local colorValue_3 = Instance.new("TextBox")
		local colorSample = Instance.new("Frame")
		local colorSampleCorner = Instance.new("UICorner")
		local valueSlider = Instance.new("TextButton")
		local valueSliderCorner = Instance.new("UICorner")
		local valueSliderGradient = Instance.new("UIGradient")
		local sliderBar = Instance.new("Frame")
		local sliderBarCorner = Instance.new("UICorner")
		local wheel = Instance.new("ImageButton")
		local wheelAspect = Instance.new("UIAspectRatioConstraint")
		local selector = Instance.new("ImageLabel")
		local selectorAspect = Instance.new("UIAspectRatioConstraint")

		colorWheel.Name = "ColorWheel"
		colorWheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorWheel.BackgroundTransparency = 1.000
		colorWheel.BorderSizePixel = 0
		colorWheel.ClipsDescendants = true
		colorWheel.Size = UDim2.new(1, 0, 0, 18)

		heading.Name = "Heading"
		heading.Parent = colorWheel
		heading.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		heading.BackgroundTransparency = 1.000
		heading.BorderSizePixel = 0
		heading.Size = UDim2.new(1, 0, 0, 18)
		heading.Font = Enum.Font.SourceSans
		heading.Text = ""
		heading.TextColor3 = Color3.fromRGB(0, 0, 0)
		heading.TextSize = 14.000

		colorWheelName.Name = "ColorWheelName"
		colorWheelName.Parent = heading
		colorWheelName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorWheelName.BackgroundTransparency = 1.000
		colorWheelName.BorderSizePixel = 0
		colorWheelName.Size = UDim2.new(1, 0, 1, 0)
		colorWheelName.Font = Enum.Font.Gotham
		colorWheelName.Text = "ColorWheel"
		colorWheelName.ClipsDescendants = true
		Library:AddToRegistry(colorWheelName, "TextColor3", "FontColor")
		colorWheelName.TextSize = 14.000
		colorWheelName.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = heading
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		Library:AddToRegistry(boxBackground, "BackgroundColor3", "OutlineColor")
		boxBackground.BorderSizePixel = 0
		boxBackground.Position = UDim2.new(1, 0, 0, 0)
		boxBackground.Size = UDim2.new(0.174999997, 0, 1, 0)

		boxBackgroundPadding.Name = "BoxBackgroundPadding"
		boxBackgroundPadding.Parent = boxBackground
		boxBackgroundPadding.PaddingBottom = UDim.new(0, 1)
		boxBackgroundPadding.PaddingLeft = UDim.new(0, 1)
		boxBackgroundPadding.PaddingRight = UDim.new(0, 1)
		boxBackgroundPadding.PaddingTop = UDim.new(0, 1)

		innerBox.Name = "InnerBox"
		innerBox.Parent = boxBackground
		innerBox.AnchorPoint = Vector2.new(1, 0)
		innerBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox.BorderSizePixel = 0
		innerBox.Position = UDim2.new(1, 0, 0, 0)
		innerBox.Size = UDim2.new(1, 0, 1, 0)

		innerBoxPadding.Name = "InnerBoxPadding"
		innerBoxPadding.Parent = innerBox
		innerBoxPadding.PaddingBottom = UDim.new(0, 1)
		innerBoxPadding.PaddingLeft = UDim.new(0, 1)
		innerBoxPadding.PaddingRight = UDim.new(0, 1)
		innerBoxPadding.PaddingTop = UDim.new(0, 1)

		innerBoxCorner.Name = "InnerBoxCorner"
		innerBoxCorner.Parent = innerBox

		centerBox.Name = "CenterBox"
		centerBox.Parent = innerBox
		centerBox.AnchorPoint = Vector2.new(1, 0)
		Library:AddToRegistry(centerBox, "BackgroundColor3", "MainColor")
		centerBox.BorderSizePixel = 0
		centerBox.Position = UDim2.new(1, 0, 0, 0)
		centerBox.Size = UDim2.new(1, 0, 1, 0)

		centerBoxPadding.Name = "CenterBoxPadding"
		centerBoxPadding.Parent = centerBox
		centerBoxPadding.PaddingBottom = UDim.new(0, 1)
		centerBoxPadding.PaddingLeft = UDim.new(0, 3)
		centerBoxPadding.PaddingRight = UDim.new(0, 1)
		centerBoxPadding.PaddingTop = UDim.new(0, 1)

		centerBoxCorner.Name = "CenterBoxCorner"
		centerBoxCorner.Parent = centerBox

		wheelImage.Name = "WheelImage"
		wheelImage.Parent = centerBox
		wheelImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		wheelImage.BackgroundTransparency = 1.000
		wheelImage.Size = UDim2.new(1, 0, 1, 0)
		wheelImage.Image = "rbxassetid://11515288750"

		wheelImageAspect.Name = "WheelImageAspect"
		wheelImageAspect.Parent = wheelImage

		dropdownImage.Name = "DropdownImage"
		dropdownImage.Parent = centerBox
		dropdownImage.AnchorPoint = Vector2.new(1, 0)
		dropdownImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdownImage.BackgroundTransparency = 1.000
		dropdownImage.BorderSizePixel = 0
		dropdownImage.Rotation = 180
		dropdownImage.Position = UDim2.new(1, 0, 0, 0)
		dropdownImage.Size = UDim2.new(1, 0, 1, 0)
		dropdownImage.Image = "rbxassetid://11269835227"

		dropdownButtonAspect.Name = "DropdownButtonAspect"
		dropdownButtonAspect.Parent = dropdownImage

		boxBackgroundCorner.Name = "BoxBackgroundCorner"
		boxBackgroundCorner.Parent = boxBackground

		wheelHolder.Name = "WheelHolder"
		wheelHolder.Parent = colorWheel
		Library:AddToRegistry(wheelHolder, "BackgroundColor3", "MainColor")
		wheelHolder.BackgroundTransparency = 1.000
		wheelHolder.BorderSizePixel = 0
		wheelHolder.Position = UDim2.new(0, 0, 0, 22)
		wheelHolder.Size = UDim2.new(1, 0, 0, 98)

		valueHolder.Name = "ValueHolder"
		valueHolder.Parent = wheelHolder
		valueHolder.AnchorPoint = Vector2.new(1, 0)
		valueHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		valueHolder.BackgroundTransparency = 1.000
		valueHolder.BorderSizePixel = 0
		valueHolder.Position = UDim2.new(1, 0, 0, 0)
		valueHolder.Size = UDim2.new(0.899999976, -102, 1, 0)

		colorInputHolder.Name = "ColorInputHolder"
		colorInputHolder.Parent = valueHolder
		colorInputHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorInputHolder.BackgroundTransparency = 1.000
		colorInputHolder.BorderSizePixel = 0
		colorInputHolder.Size = UDim2.new(1, 0, 1, -36)

		colorInputHolderList.Name = "ColorInputHolderList"
		colorInputHolderList.Parent = colorInputHolder
		colorInputHolderList.SortOrder = Enum.SortOrder.LayoutOrder
		colorInputHolderList.Padding = UDim.new(0, 4)

		red.Name = "Red"
		red.Parent = colorInputHolder
		red.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		red.BackgroundTransparency = 1.000
		red.BorderSizePixel = 0
		red.ClipsDescendants = true
		red.Size = UDim2.new(1, 0, 0, 18)

		colorText.Name = "ColorText"
		colorText.Parent = red
		colorText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorText.BackgroundTransparency = 1.000
		colorText.BorderSizePixel = 0
		colorText.Size = UDim2.new(0.670000017, 0, 1, 0)
		colorText.Font = Enum.Font.Gotham
		colorText.Text = "Red:"
		colorText.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorText.TextSize = 14.000
		colorText.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_2.Name = "BoxBackground"
		boxBackground_2.Parent = red
		boxBackground_2.AnchorPoint = Vector2.new(1, 0)
		boxBackground_2.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground_2.BorderSizePixel = 0
		boxBackground_2.Position = UDim2.new(1, 0, 0, 0)
		boxBackground_2.Size = UDim2.new(0.300000012, 0, 1, 0)

		boxPadding.Name = "BoxPadding"
		boxPadding.Parent = boxBackground_2
		boxPadding.PaddingBottom = UDim.new(0, 1)
		boxPadding.PaddingLeft = UDim.new(0, 1)
		boxPadding.PaddingRight = UDim.new(0, 1)
		boxPadding.PaddingTop = UDim.new(0, 1)

		innerBox_2.Name = "InnerBox"
		innerBox_2.Parent = boxBackground_2
		innerBox_2.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox_2.BorderSizePixel = 0
		innerBox_2.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox_2.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_2.Name = "BoxPadding"
		boxPadding_2.Parent = innerBox_2
		boxPadding_2.PaddingBottom = UDim.new(0, 1)
		boxPadding_2.PaddingLeft = UDim.new(0, 1)
		boxPadding_2.PaddingRight = UDim.new(0, 1)
		boxPadding_2.PaddingTop = UDim.new(0, 1)

		colorValue.Name = "ColorValue"
		colorValue.Parent = innerBox_2
		colorValue.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		colorValue.BorderSizePixel = 0
		colorValue.ClipsDescendants = true
		colorValue.Size = UDim2.new(1, 0, 1, 0)
		colorValue.Font = Enum.Font.Gotham
		colorValue.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		colorValue.Text = "255"
		colorValue.TextColor3 = Color3.fromRGB(139, 141, 147)
		colorValue.TextSize = 14.000

		green.Name = "Green"
		green.Parent = colorInputHolder
		green.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		green.BackgroundTransparency = 1.000
		green.BorderSizePixel = 0
		green.Size = UDim2.new(1, 0, 0, 18)

		colorText_2.Name = "ColorText"
		colorText_2.Parent = green
		colorText_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorText_2.BackgroundTransparency = 1.000
		colorText_2.BorderSizePixel = 0
		colorText_2.Size = UDim2.new(0.699999988, 0, 1, 0)
		colorText_2.Font = Enum.Font.Gotham
		colorText_2.Text = "Green:"
		green.ClipsDescendants = true
		colorText_2.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorText_2.TextSize = 14.000
		colorText_2.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_3.Name = "BoxBackground"
		boxBackground_3.Parent = green
		boxBackground_3.AnchorPoint = Vector2.new(1, 0)
		boxBackground_3.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground_3.BorderSizePixel = 0
		boxBackground_3.Position = UDim2.new(1, 0, 0, 0)
		boxBackground_3.Size = UDim2.new(0.300000012, 0, 1, 0)

		boxPadding_3.Name = "BoxPadding"
		boxPadding_3.Parent = boxBackground_3
		boxPadding_3.PaddingBottom = UDim.new(0, 1)
		boxPadding_3.PaddingLeft = UDim.new(0, 1)
		boxPadding_3.PaddingRight = UDim.new(0, 1)
		boxPadding_3.PaddingTop = UDim.new(0, 1)

		innerBox_3.Name = "InnerBox"
		innerBox_3.Parent = boxBackground_3
		innerBox_3.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox_3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox_3.BorderSizePixel = 0
		innerBox_3.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox_3.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_4.Name = "BoxPadding"
		boxPadding_4.Parent = innerBox_3
		boxPadding_4.PaddingBottom = UDim.new(0, 1)
		boxPadding_4.PaddingLeft = UDim.new(0, 1)
		boxPadding_4.PaddingRight = UDim.new(0, 1)
		boxPadding_4.PaddingTop = UDim.new(0, 1)

		colorValue_2.Name = "ColorValue"
		colorValue_2.Parent = innerBox_3
		colorValue_2.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		colorValue_2.BorderSizePixel = 0
		colorValue_2.ClipsDescendants = true
		colorValue_2.Size = UDim2.new(1, 0, 1, 0)
		colorValue_2.Font = Enum.Font.Gotham
		colorValue_2.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		colorValue_2.Text = "255"
		colorValue_2.TextColor3 = Color3.fromRGB(139, 141, 147)
		colorValue_2.TextSize = 14.000

		blue.Name = "Blue"
		blue.Parent = colorInputHolder
		blue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		blue.BackgroundTransparency = 1.000
		blue.ClipsDescendants = true
		blue.BorderSizePixel = 0
		blue.Size = UDim2.new(1, 0, 0, 18)

		colorText_3.Name = "ColorText"
		colorText_3.Parent = blue
		colorText_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorText_3.BackgroundTransparency = 1.000
		colorText_3.BorderSizePixel = 0
		colorText_3.Size = UDim2.new(0.670000017, 0, 1, 0)
		colorText_3.Font = Enum.Font.Gotham
		colorText_3.Text = "Blue:"
		colorText_3.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorText_3.TextSize = 14.000
		colorText_3.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_4.Name = "BoxBackground"
		boxBackground_4.Parent = blue
		boxBackground_4.AnchorPoint = Vector2.new(1, 0)
		boxBackground_4.BackgroundColor3 = Color3.fromRGB(59, 59, 71)
		boxBackground_4.BorderSizePixel = 0
		boxBackground_4.Position = UDim2.new(1, 0, 0, 0)
		boxBackground_4.Size = UDim2.new(0.300000012, 0, 1, 0)

		boxPadding_5.Name = "BoxPadding"
		boxPadding_5.Parent = boxBackground_4
		boxPadding_5.PaddingBottom = UDim.new(0, 1)
		boxPadding_5.PaddingLeft = UDim.new(0, 1)
		boxPadding_5.PaddingRight = UDim.new(0, 1)
		boxPadding_5.PaddingTop = UDim.new(0, 1)

		innerBox_4.Name = "InnerBox"
		innerBox_4.Parent = boxBackground_4
		innerBox_4.AnchorPoint = Vector2.new(0.5, 0.5)
		innerBox_4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		innerBox_4.BorderSizePixel = 0
		innerBox_4.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerBox_4.Size = UDim2.new(1, 0, 1, 0)

		boxPadding_6.Name = "BoxPadding"
		boxPadding_6.Parent = innerBox_4
		boxPadding_6.PaddingBottom = UDim.new(0, 1)
		boxPadding_6.PaddingLeft = UDim.new(0, 1)
		boxPadding_6.PaddingRight = UDim.new(0, 1)
		boxPadding_6.PaddingTop = UDim.new(0, 1)

		colorValue_3.Name = "ColorValue"
		colorValue_3.Parent = innerBox_4
		colorValue_3.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		colorValue_3.BorderSizePixel = 0
		colorValue_3.ClipsDescendants = true
		colorValue_3.Size = UDim2.new(1, 0, 1, 0)
		colorValue_3.Font = Enum.Font.Gotham
		colorValue_3.PlaceholderColor3 = Color3.fromRGB(139, 141, 147)
		colorValue_3.Text = "255"
		colorValue_3.TextColor3 = Color3.fromRGB(139, 141, 147)
		colorValue_3.TextSize = 14.000

		colorSample.Name = "ColorSample"
		colorSample.Parent = valueHolder
		colorSample.AnchorPoint = Vector2.new(0, 1)
		colorSample.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorSample.BorderSizePixel = 0
		colorSample.Position = UDim2.new(0, 0, 1, -18)
		colorSample.Size = UDim2.new(1, 0, 0, 14)

		colorSampleCorner.CornerRadius = UDim.new(0.25, 0)
		colorSampleCorner.Name = "ColorSampleCorner"
		colorSampleCorner.Parent = colorSample

		valueSlider.Name = "ValueSlider"
		valueSlider.Parent = valueHolder
		valueSlider.AnchorPoint = Vector2.new(0, 1)
		valueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		valueSlider.BorderSizePixel = 0
		valueSlider.Position = UDim2.new(0, 0, 1, 0)
		valueSlider.Size = UDim2.new(1, 0, 0, 14)
		valueSlider.AutoButtonColor = false
		valueSlider.Font = Enum.Font.SourceSans
		valueSlider.Text = ""
		valueSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
		valueSlider.TextSize = 14.000

		valueSliderCorner.CornerRadius = UDim.new(0.25, 0)
		valueSliderCorner.Name = "ValueSliderCorner"
		valueSliderCorner.Parent = valueSlider

		valueSliderGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
		valueSliderGradient.Name = "ValueSliderGradient"
		valueSliderGradient.Parent = valueSlider

		sliderBar.Name = "SliderBar"
		sliderBar.Parent = valueSlider
		sliderBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		sliderBar.BorderSizePixel = 0
		sliderBar.Size = UDim2.new(0, 3, 1, 0)

		sliderBarCorner.CornerRadius = UDim.new(0.25, 0)
		sliderBarCorner.Name = "SliderBarCorner"
		sliderBarCorner.Parent = sliderBar

		wheel.Name = "Wheel"
		wheel.Parent = wheelHolder
		wheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		wheel.BackgroundTransparency = 1.000
		wheel.BorderSizePixel = 0
		wheel.Size = UDim2.new(1, 0, 1, 0)
		wheel.AutoButtonColor = false
		wheel.Image = "rbxassetid://11515288750"

		wheelAspect.Name = "WheelAspect"
		wheelAspect.Parent = wheel

		selector.Name = "Selector"
		selector.Parent = wheel
		selector.AnchorPoint = Vector2.new(0.5, 0.5)
		selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		selector.BackgroundTransparency = 1.000
		selector.BorderSizePixel = 0
		selector.Position = UDim2.new(0.5, 0, 0.5, 0)
		selector.Size = UDim2.new(0.125, 0, 0.125, 0)
		selector.Image = "rbxassetid://11515686713"

		selectorAspect.Name = "SelectorAspect"
		selectorAspect.Parent = selector
		
		return colorWheel
	end
	
	originalElements.Window = createWindow()
	originalElements.Tab = createTab()
	originalElements.Page = createPage()
	originalElements.Section = createSection()
	originalElements.Title = createTitle()
	originalElements.Label = createLabel()
	originalElements.Toggle = createToggle()
	originalElements.Button = createButton()
	originalElements.Dropdown = createDropdown()
	originalElements.Slider = createSlider()
	originalElements.SearchBar = createSearchBar()
	originalElements.Keybind = createKeybind()
	originalElements.TextBox = createTextBox()
	originalElements.ColorWheel = createColorWheel()
	
	-- Apply KeyForge theme remapping
	local function remapColors(root)
	local function eq(c, r, g, b)
	return math.floor(c.R*255+0.5)==r and math.floor(c.G*255+0.5)==g and math.floor(c.B*255+0.5)==b
	end
	for _, inst in ipairs(root:GetDescendants()) do
	if inst:IsA("TextLabel") or inst:IsA("TextButton") then
	-- Text colors to KeyForge gray
	if eq(inst.TextColor3,255,255,255) then
	inst.TextColor3 = Color3.fromRGB(168,168,168)
	end
	end
	if inst:IsA("TextBox") then
	if eq(inst.TextColor3,255,255,255) then
	inst.TextColor3 = Color3.fromRGB(168,168,168)
	end
	if eq(inst.PlaceholderColor3,139,141,147) then
	inst.PlaceholderColor3 = Color3.fromRGB(100,100,100)
	end
	end
	if inst:IsA("Frame") or inst:IsA("ScrollingFrame") or inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
	local c = inst.BackgroundColor3
	if c then
	-- Background remaps
	if eq(c,24,25,32) then inst.BackgroundColor3 = Color3.fromRGB(12,12,12) end
	if eq(c,31,31,43) then inst.BackgroundColor3 = Color3.fromRGB(21,21,21) end
	if eq(c,40,41,52) then inst.BackgroundColor3 = Color3.fromRGB(31,31,31) end
	if eq(c,59,59,71) then inst.BackgroundColor3 = Color3.fromRGB(31,31,31) end
	if eq(c,255,0,0) then inst.BackgroundColor3 = Color3.fromRGB(0,170,255) end
	if eq(c,255,6,4) or eq(c,163,33,38) or eq(c,131,39,45) then
	inst.BackgroundColor3 = Color3.fromRGB(38,81,103)
	end
	end
	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
	local ic = inst.ImageColor3
	if ic then
	if eq(ic,255,0,0) then inst.ImageColor3 = Color3.fromRGB(0,170,255) end
	if eq(ic,31,31,43) then inst.ImageColor3 = Color3.fromRGB(21,21,21) end
	if eq(ic,109,110,119) then inst.ImageColor3 = Color3.fromRGB(133,133,133) end
	if eq(ic,180,180,180) then inst.ImageColor3 = Color3.fromRGB(168,168,168) end
	if eq(ic,250,250,250) then inst.ImageColor3 = Color3.fromRGB(168,168,168) end
	end
	end
	end
	end
	end
	
	for _, proto in pairs(originalElements) do
	remapColors(proto)
	end
	
	-- Update branding
	originalElements.Window.Name = "KeyForge"
	do
	local bg = originalElements.Window:FindFirstChild("Background")
	if bg then
	local hd = bg:FindFirstChild("Heading")
	if hd and hd:FindFirstChild("Title") then
	hd.Title.Text = "KeyForge"
	hd.Title.TextColor3 = Color3.fromRGB(168,168,168)
	end
	if hd and hd:FindFirstChild("HeadingSeperator") then
	hd.HeadingSeperator.BackgroundColor3 = Color3.fromRGB(38,81,103)
	end
	end
	end
	end

function elementHandler:Remove()
	self.GuiToRemove:Destroy()
end

--Add zindex var to determine which window goes over which
--Add var to only have one window open at a time allowed
function Library.new(windowName: string, constrainToScreen: boolean?, width: number?, height: number?, visibilityKeybind: string?, backgroundImageId: string?): table
	local window = setmetatable({}, windowHandler) -- remove elementhandler from window hanlers index?
	local windowInstance = originalElements.Window:Clone()
	local startDragMousePos
	local startDragWindowPos
	local originialWindowSize
	local minimizedLongBarOriginialSize
	local minimizedShortBarOriginialSize

	local background = windowInstance.Background
	local heading = background.Heading
	local buttonHolder = heading.ButtonHolder
	local holder = background.Holder
	local snowEffect = holder:FindFirstChild("SnowEffect")

	local function getMatchingKeyCodeFromName(name)
		if type(name) ~= "string" then return end
		local nameLower = name:lower()
		for _, keycode in ipairs(Enum.KeyCode:GetEnumItems()) do
			if keycode.Name:lower() == nameLower then
				return keycode
			end
		end
	end

	local function updateWindowPos()
		local deltaPos = Vector2.new(mouse.X, mouse.Y) - startDragMousePos
		local windowPos = background.Position

		if window.isConstraintedToScreenBoundaries then
			local backgroundAbsPos = background.AbsolutePosition
			local backgroundAbsSize = background.AbsoluteSize
			
			background.Position = UDim2.new(0,math.clamp(startDragWindowPos.X + deltaPos.X, 0 + backgroundAbsSize.X / 2, viewPortSize.X - backgroundAbsSize.X / 2), windowPos.Y.Scale, math.clamp(startDragWindowPos.Y + deltaPos.Y, 0 + backgroundAbsSize.Y / 2,viewPortSize.Y - backgroundAbsSize.Y / 2))
		else
			background.Position = UDim2.new(0, startDragWindowPos.X + deltaPos.X, 0, startDragWindowPos.Y + deltaPos.Y)	
		end
	end

	local function onHeadingMouseDown()
		local mouseMovedConnection = mouse.Move:Connect(updateWindowPos)
		local inputEndedConnection

		startDragMousePos = Vector2.new(mouse.X, mouse.Y)
		startDragWindowPos = Vector2.new(background.Position.X.Offset, background.Position.Y.Offset)
		updateWindowPos()

		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				mouseMovedConnection:Disconnect()
				inputEndedConnection:Disconnect()
			end
		end)
	end

	local function closeWindow()
        local closeWindowTween = TweenService:Create(windowInstance.Background, TweenInfo.new(.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        closeWindowTween.Completed:Connect(function()
            task.wait()
			if Library.Window == window then
				Library.Window = nil
			end
			windowInstance:Destroy()
            window = nil
        end)
        closeWindowTween:Play()
	end

	local function minimizeWindow()
		window.IsMinimized = true
		local backgroundAbsPos = background.AbsolutePosition
		local backgroundAbsSize = background.AbsoluteSize
		local minimizeWindowUpTween = TweenService:Create(background, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0,minimizedLongBarOriginialSize.X,0, minimizedLongBarOriginialSize.Y), Position = UDim2.new(0,backgroundAbsPos.X + minimizedLongBarOriginialSize.X / 2,0, backgroundAbsPos.Y + minimizedLongBarOriginialSize.Y / 2 + 36)})
		local minimizeMinusImageTween = TweenService:Create(buttonHolder.Minus, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Rotation = 180, ImageTransparency = 1})
		local minimizePlusImageTween = TweenService:Create(buttonHolder.Plus, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Rotation = 0, ImageTransparency = 0})
		
		minimizeWindowUpTween.Completed:Connect(function()
			task.wait(.1)
			if minimizeWindowUpTween.PlaybackState == Enum.PlaybackState.Completed then
				local minimizeWindowLeftTween = TweenService:Create(background, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0, minimizedShortBarOriginialSize.X,0,minimizedShortBarOriginialSize.Y), Position = UDim2.new(0,background.AbsolutePosition.X + minimizedShortBarOriginialSize.X / 2,0, background.AbsolutePosition.Y + minimizedShortBarOriginialSize.Y / 2 + 36)})
				minimizeWindowLeftTween:Play()
			end
		end)
		
		minimizeMinusImageTween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed then
				buttonHolder.Minus.Visible = false
				buttonHolder.Plus.Visible = true
				minimizePlusImageTween:Play()
			end
		end)
		
		minimizeWindowUpTween:Play()
		minimizeMinusImageTween:Play()
	end

	local function maximizeWindow()
		window.IsMinimized = false
		local backgroundAbsPos = background.AbsolutePosition
		local backgroundAbsSize = background.AbsoluteSize
		local maximizeWindowRightTween = TweenService:Create(background, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0,minimizedLongBarOriginialSize.X,0,minimizedLongBarOriginialSize.Y), Position = UDim2.new(0, backgroundAbsPos.X + minimizedLongBarOriginialSize.X / 2,0,backgroundAbsPos.Y + minimizedLongBarOriginialSize.Y / 2 + 36)})
		local maximizePlusImageTween = TweenService:Create(buttonHolder.Plus, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Rotation = 180, ImageTransparency = 1})
		local maximizeMinusImageTween = TweenService:Create(buttonHolder.Minus, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Rotation = 0, ImageTransparency = 0})
		
		maximizeWindowRightTween.Completed:Connect(function()
			task.wait(.1)
			if maximizeWindowRightTween.PlaybackState == Enum.PlaybackState.Completed then
				local maximizeWindowDownTween = TweenService:Create(background, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0, originialWindowSize.X, 0, originialWindowSize.Y), Position = UDim2.new(0,backgroundAbsPos.X + originialWindowSize.X / 2,0,backgroundAbsPos.Y + originialWindowSize.Y / 2 + 36)})
				buttonHolder.Plus.Visible = false
				buttonHolder.Minus.Visible = true
				maximizeWindowDownTween:Play()
				maximizeMinusImageTween:Play()
			end
		end)
		
		maximizeWindowRightTween:Play()
		maximizePlusImageTween:Play()
	end

	if constrainToScreen == nil then
		constrainToScreen = true
	end

	visibilityKeybind = getMatchingKeyCodeFromName(visibilityKeybind) or Enum.KeyCode.RightControl

	local appliedWidth = width
	local appliedHeight = height
	if not appliedWidth then
		if isMobileClient then
			appliedWidth = math.clamp(math.floor(viewPortSize.X - 32), 360, 580)
		else
			appliedWidth = background.AbsoluteSize.X
		end
	end
	if not appliedHeight then
		if isMobileClient then
			appliedHeight = math.clamp(math.floor(viewPortSize.Y - 140), 320, 420)
		else
			appliedHeight = background.AbsoluteSize.Y
		end
	end

	window.Type = "Window"
	window.Instance = windowInstance
	window.Background = background
	window.GuiToRemove = windowInstance
	window.isConstraintedToScreenBoundaries = constrainToScreen
	Library.Window = window
	window.IsMinimized = false
	window.IsHidden = false
	window.TabInfo = {}

	heading.MouseButton1Down:Connect(onHeadingMouseDown)
	buttonHolder.Close.MouseButton1Click:Connect(closeWindow)
	buttonHolder.Plus.MouseButton1Click:Connect(maximizeWindow)
	buttonHolder.Minus.MouseButton1Click:Connect(minimizeWindow)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == visibilityKeybind then
				background.Visible = not background.Visible
			end
		end
	end)

	holder.Tabs.TabsUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		holder.Tabs.CanvasSize = UDim2.fromOffset(0,holder.Tabs.TabsUIListLayout.AbsoluteContentSize.Y + holder.Tabs.TabsUIListLayout.Padding.Offset)
	end)

	heading.Title.Text = windowName or "KeyForge"
	windowInstance.Parent = game:GetService("CoreGui") -- Change to core later on and add detection bypass
	local targetWidth = appliedWidth
	local targetHeight = appliedHeight
	if isMobileClient then
		targetWidth = math.clamp(targetWidth, 340, math.max(320, viewPortSize.X - 20))
		targetHeight = math.clamp(targetHeight, 300, math.max(300, viewPortSize.Y - 20))
	end
	background.Size = UDim2.fromOffset(targetWidth, targetHeight)

	if snowEffect then
		startSnowEffect(snowEffect, backgroundImageId)
	end
	background.Position = UDim2.new(0, background.AbsolutePosition.X + background.AbsoluteSize.X / 2, 0, background.AbsolutePosition.Y + background.AbsoluteSize.Y / 2 + 36)
	background.BackgroundUIAspectRatioConstraint:Destroy()
	holder.Size = UDim2.new(0,holder.AbsoluteSize.X,0,holder.AbsoluteSize.Y)
	holder.Position = UDim2.new(0,0,0,heading.AbsoluteSize.Y)
	heading.Size = UDim2.new(1,0,0,heading.AbsoluteSize.Y)
	buttonHolder.Size = UDim2.new(0,buttonHolder.ButtonHolderList.AbsoluteContentSize.X + buttonHolder.ButtonHolderPadding.PaddingRight.Offset,.9,0)
	heading.Title.Size = UDim2.new(1,-(buttonHolder.ButtonHolderList.AbsoluteContentSize.X + buttonHolder.ButtonHolderPadding.PaddingRight.Offset + 4),.9,0)
	
	if isMobileClient then
		holder.Tabs.Size = UDim2.new(0.3, 0, 1, -20)
		holder.Tabs.ScrollBarThickness = 4
		heading.Title.TextSize = 13
	end

	minimizedLongBarOriginialSize = Vector2.new(heading.AbsoluteSize.X, heading.AbsoluteSize.Y)
	minimizedShortBarOriginialSize = Vector2.new(heading.AbsoluteSize.X / 6 * 2, heading.AbsoluteSize.Y)
	originialWindowSize = background.AbsoluteSize
	
	-- Mobile Toggle Button
	if isMobileClient then
		local MobileToggle = Instance.new("TextButton")
		local MobileToggleCorner = Instance.new("UICorner")
		local MobileToggleStroke = Instance.new("UIStroke")
		
		MobileToggle.Name = "MobileToggle"
		MobileToggle.Parent = windowInstance
		MobileToggle.BackgroundColor3 = Library.Scheme.MainColor
		MobileToggle.Position = UDim2.new(0.5, -25, 0, 10)
		MobileToggle.Size = UDim2.new(0, 50, 0, 50)
		MobileToggle.Text = "KF"
		MobileToggle.TextColor3 = Library.Scheme.AccentColor
		MobileToggle.Font = Enum.Font.GothamBold
		MobileToggle.TextSize = 18
		MobileToggle.ZIndex = 1000
		
		MobileToggleCorner.CornerRadius = UDim.new(1, 0)
		MobileToggleCorner.Parent = MobileToggle
		
		MobileToggleStroke.Color = Library.Scheme.AccentColor
		MobileToggleStroke.Thickness = 2
		MobileToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		MobileToggleStroke.Parent = MobileToggle
		
		Library:AddToRegistry(MobileToggle, "BackgroundColor3", "MainColor")
		Library:AddToRegistry(MobileToggle, "TextColor3", "AccentColor")
		Library:AddToRegistry(MobileToggleStroke, "Color", "AccentColor")
		
		-- Draggable Logic for Mobile Toggle
		local dragging = false
		local dragInput, dragStart, startPos
		
		MobileToggle.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				dragging = true
				dragStart = input.Position
				startPos = MobileToggle.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		
		MobileToggle.InputChanged:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				dragInput = input
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				MobileToggle.Position = UDim2.new(
					startPos.X.Scale, 
					startPos.X.Offset + delta.X, 
					startPos.Y.Scale, 
					startPos.Y.Offset + delta.Y
				)
			end
		end)
		
		MobileToggle.MouseButton1Click:Connect(function()
			background.Visible = not background.Visible
		end)
	end
	
	return window
end

function windowHandler:LockScreenBoundaries(constrainWindowToScreenBoundaries)
	self.isConstraintedToScreenBoundaries = constrainWindowToScreenBoundaries
end

function windowHandler:Tab(tabName: string, tabImage: string): table
	local tab = setmetatable({}, tabHandler)
	local tabInstance = originalElements.Tab:Clone()
	local pageInstance = originalElements.Page:Clone()
	
	local tabOpenTween = TweenService:Create(tabInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {BackgroundTransparency = .25})
	local tabCloseTween = TweenService:Create(tabInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 1})
	local tabSeperatorOpenTween = TweenService:Create(tabInstance.TabSeperator, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(.035,1)})
	local tabSeperatorCloseTween = TweenService:Create(tabInstance.TabSeperator, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,1)})
	local pageOpenTween = TweenService:Create(pageInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0.774999976, -25, 1, -15)})
	local pageCloseTween = TweenService:Create(pageInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(.775,-25,0,0)})
	
	local function isTabFirstTab()
		local amountOfTabs = 0
		for _, foundTab in ipairs(self.Instance.Background.Holder.Tabs:GetChildren()) do
			if foundTab:IsA("TextButton") then
				amountOfTabs += 1
			end
		end

		if amountOfTabs == 1 then
			return true
		end
		
		return false
	end
	
	local function onMouseEnter()
		if not pageInstance.Visible then
			tabOpenTween:Play()
		end
	end
	
	local function onMouseLeave()
		if not pageInstance.Visible then
			tabCloseTween:Play()
		end
	end
	
	local function onMouseClick()
		local selfInfo = self.TabInfo[tabInstance]
		
		local function openTab()
			local isATabOpen = false
			
			for foundTabInstance, tabInfo in pairs(self.TabInfo) do
				if foundTabInstance ~= tabInstance then
					if tabInfo.isOpen then
						local foundPageCloseTween = TweenService:Create(tabInfo.Page, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(.775,-25,0,0)})
						local foundTabCloseTween = TweenService:Create(foundTabInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 1})
						local foundTabSeperatorCloseTween = TweenService:Create(foundTabInstance.TabSeperator, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,1)})

						isATabOpen = true
						tabInfo.isOpen = false

						foundPageCloseTween.Completed:Connect(function()
							task.wait(.15)
							if selfInfo.isQueued and foundPageCloseTween.PlaybackState == Enum.PlaybackState.Completed then
								selfInfo.isOpen = true
								pageInstance.Visible = true
								tabInfo.Page.Visible = false
								tabOpenTween:Play()
								tabSeperatorOpenTween:Play()	
								pageOpenTween:Play()
							end
						end)
						
						selfInfo.isQueued = true
						foundPageCloseTween:Play()
						foundTabCloseTween:Play()
						foundTabSeperatorCloseTween:Play()
					elseif tabInfo.isQueued then
						tabInfo.isQueued = false
					end
				end
			end
			
			if not isATabOpen then
				selfInfo.isOpen = true
				pageInstance.Visible = true
				pageOpenTween:Play()
				tabOpenTween:Play()
				tabSeperatorOpenTween:Play()
			end
		end

		local function closeTab()
			selfInfo.isOpen = false
			tabCloseTween:Play()
			tabSeperatorCloseTween:Play()
			pageCloseTween:Play()
		end
		
		if selfInfo.isOpen then
			closeTab()
		else
			openTab()
		end
	end	
	
	tab.Type = "Tab"
	tab.IdentifierText = tabName or "N/A"
	tab.TabToRemove = tabInstance
	tab.PageToRemove = pageInstance
	tab.ElementToParentChildren = pageInstance
	
	tabInstance.TabText.Text = tabName or "N/A"
	tabInstance.TabImage.Image = tabImage or "rbxassetid://11436779516" -- Add n/a found image here later on

	tabInstance.MouseEnter:Connect(onMouseEnter)
	tabInstance.MouseLeave:Connect(onMouseLeave)
	tabInstance.MouseButton1Click:Connect(onMouseClick)
	
	self.TabInfo[tabInstance] = {Page = pageInstance, isOpen = false, isQueued = false}
	tabInstance.Parent = self.Instance.Background.Holder.Tabs
	tabInstance.TabText.Position = UDim2.new(0.035, 8 + tabInstance.TabImage.AbsoluteSize.X, 0, 0)
	tabInstance.TabText.Size = UDim2.new(0.965, -(8 + tabInstance.TabImage.AbsoluteSize.X + 8), 1, 0)
	pageInstance.Parent = self.Instance.Background.Holder
	
	if isTabFirstTab() then
		tabInstance.TabSeperator.Size = UDim2.fromScale(.035,1)
		tabInstance.BackgroundTransparency = .25
		pageInstance.Visible = true
		pageInstance.Size = UDim2.new(0.774999976, -25, 1, -15)
		self.TabInfo[tabInstance].isOpen = true
	end
	
	pageCloseTween.Completed:Connect(function()
		if pageCloseTween.PlaybackState == Enum.PlaybackState.Completed then
			pageInstance.Visible = false	
		end
	end)
	
	for _, scrollingFrame in ipairs(pageInstance:GetChildren()) do
		local list = scrollingFrame:FindFirstChildWhichIsA("UIListLayout")
		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scrollingFrame.CanvasSize = UDim2.fromOffset(0,list.AbsoluteContentSize.Y + list.Padding.Offset)
		end)
	end
	
	return tab
end

function tabHandler:Remove()
	self.TabToRemove:Destroy()
	self.PageToRemove:Destroy()
end

function tabHandler:Section(sectionTitle: string) -- Add option to make on left or right after
	local section = setmetatable({}, sectionHandler)
	local sectionInstance = originalElements.Section:Clone()
	local isMaximized = true
	local resizeButtonMinimizeTween = TweenService:Create(sectionInstance.Heading.ResizeButton, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Rotation = 180})
	local resizeButtonMaximizeTween = TweenService:Create(sectionInstance.Heading.ResizeButton, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Rotation = 0})
	local sectionInstanceMinimizeTween = TweenService:Create(sectionInstance, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,sectionInstance.Heading.Size.Y.Offset)})
	
	local function getSectionNeededYOffsetSize()
		local minimumSize = 200
		return math.max(minimumSize, sectionInstance.Heading.Size.Y.Offset + sectionInstance.ElementHolder.ElementHolderList.AbsoluteContentSize.Y + sectionInstance.ElementHolder.ElementHolderPadding.PaddingBottom.Offset + sectionInstance.ElementHolder.ElementHolderPadding.PaddingTop.Offset)
	end
	
	local function getShorterScrollingFrame()
		local pageScrollingFrame
		local pageScrollingFrameContentSizeY = math.huge
		
		for _, scrollingFrame in ipairs(self.ElementToParentChildren:GetChildren()) do
			local list = scrollingFrame:FindFirstChildWhichIsA("UIListLayout")
			if pageScrollingFrameContentSizeY > list.AbsoluteContentSize.Y then
				pageScrollingFrame = scrollingFrame
				pageScrollingFrameContentSizeY = list.AbsoluteContentSize.Y
			end
		end
		
		return pageScrollingFrame
	end
	
	local function onResizeClick()
		if isMaximized then
			isMaximized = false
			resizeButtonMinimizeTween:Play()
			sectionInstanceMinimizeTween:Play()
		else
			isMaximized = true
			local sectionInstanceMaximizeTween = TweenService:Create(sectionInstance, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,getSectionNeededYOffsetSize())})
			resizeButtonMaximizeTween:Play()
			sectionInstanceMaximizeTween:Play()
			sectionInstanceMaximizeTween:Play()
		end
	end
	
	section.Type = "Section"
	section.IdentiferText = sectionTitle or "N/A"
	section.Instance = sectionInstance
	section.GuiToRemove = sectionInstance
	section.ElementToParentChildren = sectionInstance.ElementHolder
	
	sectionInstance.Heading.ResizeButton.MouseButton1Click:Connect(onResizeClick)
	
	sectionInstance.ElementHolder.ElementHolderList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sectionInstance.Size = UDim2.new(1, 0, 0, getSectionNeededYOffsetSize())
		sectionInstance.ElementHolder.Size = UDim2.new(1,0,0, math.max(200 - sectionInstance.Heading.Size.Y.Offset, sectionInstance.ElementHolder.ElementHolderList.AbsoluteContentSize.Y + sectionInstance.ElementHolder.ElementHolderPadding.PaddingBottom.Offset + sectionInstance.ElementHolder.ElementHolderPadding.PaddingTop.Offset))
	end)
	
	sectionInstance.Heading.Title.Text = sectionTitle or "N/A"
	sectionInstance.Parent = getShorterScrollingFrame()
	sectionInstance.Heading.Title.Size = UDim2.new(1,-(sectionInstance.Heading.ResizeButton.AbsoluteSize.X + 5 + 3),0,20)
	
	return section
end

function elementHandler:Title(titleName: string)
	local title = setmetatable({}, titleHandler)
	local titleInstance = originalElements.Title:Clone()

	local textSpaceOffset = Vector2.new(10,0)
	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = titleName or "N/A"
	textParams.Font = titleInstance.TitleText.FontFace
	textParams.Size = 14
	textParams.Width = 10000

	local requiredTextSpace = TextService:GetTextBoundsAsync(textParams) + textSpaceOffset

	title.Type = "Title"
	title.IdentifierText = titleName or "N/A"
	title.Instance = titleInstance
	title.GuiToRemove = titleInstance
	
	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[titleInstance] = title
	end

	titleInstance.TitleText.Text = titleName or "N/A"
	titleInstance.TitleText.Size = UDim2.new(0, requiredTextSpace.X, 1, 0)

	titleInstance.Parent = self.ElementToParentChildren

	return title
end

function titleHandler:ChangeText(newText: string): nil
	local textSpaceOffset = Vector2.new(10,0)
	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = newText or "N/A"
	textParams.Font = self.Instance.TitleText.FontFace
	textParams.Size = 14
	textParams.Width = 10000
	
	local requiredTextSpace = TextService:GetTextBoundsAsync(textParams) + textSpaceOffset
	
	self.Instance.TitleText.Text = newText or "N/A"
	self.Instance.TitleText.Size = UDim2.new(0, requiredTextSpace.X, 1, 0)
end

function elementHandler:Label(labelInputtedText: string, textSize: number, textColor: Color3): table
	local label = setmetatable({}, labelHandler)
	local labelInstance = originalElements.Label:Clone()
	
	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = labelInputtedText or "N/A"
	textParams.Font = labelInstance.LabelBackground.LabelText.FontFace
	textParams.Size = textSize or 13

	label.Type = "Label"
	label.IdentifierText = labelInputtedText or "N/A"
	label.Instance = labelInstance
	label.GuiToRemove = labelInstance
	label.PlayingAnimations = {}
	
	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[labelInstance] = label
	end
	
	labelInstance.LabelBackground.LabelText.Text = labelInputtedText or "N/A"
	labelInstance.LabelBackground.LabelText.TextColor3 = textColor or Color3.fromRGB(255,255,255)
	labelInstance.LabelBackground.LabelText.TextSize = textSize or 13
	
	labelInstance.Parent = self.ElementToParentChildren
	textParams.Width = labelInstance.LabelBackground.LabelText.AbsoluteSize.X - labelInstance.LabelBackground.LabelText.LabelTextPadding.PaddingLeft.Offset - labelInstance.LabelBackground.LabelText.LabelTextPadding.PaddingRight.Offset
	labelInstance.Size = UDim2.new(1,0,0,TextService:GetTextBoundsAsync(textParams).Y + labelInstance.LabelBackground.LabelText.LabelTextPadding.PaddingTop.Offset + labelInstance.LabelBackground.LabelText.LabelTextPadding.PaddingBottom.Offset + labelInstance.LabelPadding.PaddingTop.Offset + labelInstance.LabelPadding.PaddingBottom.Offset + labelInstance.LabelBackground.LabelBackgroundPadding.PaddingTop.Offset + labelInstance.LabelBackground.LabelBackgroundPadding.PaddingBottom.Offset)
	
	return label
end

function labelHandler:ChangeText(newText: string, playAnimation: boolean): nil
	local textParams = Instance.new("GetTextBoundsParams") -- Add Tween here for text
	textParams.Text = newText or "N/A"
	textParams.Font = self.Instance.LabelBackground.LabelText.FontFace
	textParams.Size = 13
	textParams.Width = self.Instance.LabelBackground.LabelText.AbsoluteSize.X
	
	playAnimation = playAnimation or false
	
	local function closeAllRunningAnimations()
		for i, foundAnimation in pairs(self.PlayingAnimations) do
			coroutine.close(foundAnimation)
			table.remove(self.PlayingAnimations, i)
		end
	end
	
	if playAnimation then
		closeAllRunningAnimations()
		
		local animationCoroutine = coroutine.create(function()
			for i = 1, #newText do
				self.Instance.LabelBackground.LabelText.Text = string.sub(newText or "N/A", 1, i)
				task.wait(.01)	
			end
		end)
		
		table.insert(self.PlayingAnimations, animationCoroutine)
		coroutine.resume(animationCoroutine)
	else
		closeAllRunningAnimations()
		self.Instance.LabelBackground.LabelText.Text = newText or "N/A"
	end
end

function elementHandler:Toggle(toggleName: string, defaultState, callback): table
	local toggle = setmetatable({}, toggleHandler)
	local toggleInstance = originalElements.Toggle:Clone()
	local textOffset = 4

	local tweenTime = .275
	local cornerOnTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage.ToggleImageCorner, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {CornerRadius = UDim.new(0, 0)})
	local cornerOffTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage.ToggleImageCorner, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CornerRadius = UDim.new(.5, 0)})
	local imageRotationOnTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Rotation = 360})
	local imageRotationOffTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Rotation = 0})
	local imageSizeOnTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(1,1)});
	local imageSizeOffTween = TweenService:Create(toggleInstance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,0)});
	
	if typeof(defaultState) == "function" then
		callback = defaultState
		defaultState = nil
	end

	local initialState = typeof(defaultState) == "boolean" and defaultState or false
	callback = typeof(callback) == "function" and callback or function() end

	toggle.Type = "Toggle"
	toggle.IdentifierText = toggleName or "N/A"
	toggle.Instance = toggleInstance
	toggle.GuiToRemove = toggleInstance
	toggle.Enabled = false

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[toggleInstance] = toggle
	end
	
	local function onToggleClick()
		if toggle.Enabled then
			cornerOffTween:Play()
			imageRotationOffTween:Play()
			imageSizeOffTween:Play()
		else
			cornerOnTween:Play()
			imageRotationOnTween:Play()
			imageSizeOnTween:Play()
		end
		
		toggle.Enabled = not toggle.Enabled
		
		callback(toggle.Enabled)
	end

	toggleInstance.MouseButton1Click:Connect(onToggleClick)

	toggleInstance.ToggleText.Text = toggleName or "N/A"

	toggleInstance.Parent = self.ElementToParentChildren
	toggleInstance.ToggleText.Size = UDim2.new(1,-(toggleInstance.BoxBackground.AbsoluteSize.X + textOffset),1,0)
	toggleInstance.Position = UDim2.fromOffset(toggleInstance.BoxBackground.AbsoluteSize.X + textOffset,0)

	toggle:Set(initialState, callback)

	return toggle
end
 -- SET IDENTIFIER IN SELF AND ADD TOGGLES TO EACH IDENTIFIER RADIO GROUP
function toggleHandler:Set(bool: boolean, callback): nil -- Add Callback to self?
	local tweenTime = .275
	local cornerOnTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage.ToggleImageCorner, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {CornerRadius = UDim.new(0, 0)})
	local cornerOffTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage.ToggleImageCorner, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CornerRadius = UDim.new(.5, 0)})
	local imageRotationOnTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Rotation = 360})
	local imageRotationOffTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Rotation = 0})
	local imageSizeOnTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(1,1)});
	local imageSizeOffTween = TweenService:Create(self.Instance.BoxBackground.InnerBox.CenterBox.ToggleImage, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,0)});
	
	if typeof(bool) ~= "boolean" then error("First argument must be a boolean.") end
	
	callback = callback or function() end
	self.Enabled = bool

	if self.Enabled then
		cornerOnTween:Play()
		imageRotationOnTween:Play()
		imageSizeOnTween:Play()
	else
		cornerOffTween:Play()
		imageRotationOffTween:Play()
		imageSizeOffTween:Play()
	end

	callback(bool)
end

function elementHandler:Button(buttonName: string, callback): table -- Add Callback to self?
	local button = setmetatable({}, buttonHandler)
	local buttonInstance = originalElements.Button:Clone()
	local textOffset = 4
	
	local tweenTime = .25
	local buttonExpandTween = TweenService:Create(buttonInstance.CircleBackground.InnerCircle.CenterCircle.ButtonCircle, TweenInfo.new(tweenTime / 2, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(1,1)})
	local buttonCondenseTween = TweenService:Create(buttonInstance.CircleBackground.InnerCircle.CenterCircle.ButtonCircle, TweenInfo.new(tweenTime / 2, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,0)})
	
	buttonName = buttonName or "N/A"
	callback = callback or function() end
	
	buttonExpandTween.Completed:Connect(function(playbackState)
		task.wait(.1)
		if playbackState == Enum.PlaybackState.Completed then
			buttonCondenseTween:Play()
		end
	end)
	
	local function onButtonClick()
		buttonExpandTween:Play()
		callback()
	end
	
	button.Type = "Button"
	button.IdentifierText = buttonName or "N/A"
	button.Instance = buttonInstance
	button.GuiToRemove = buttonInstance
	
	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[buttonInstance] = button
	end
	
	buttonInstance.MouseButton1Click:Connect(onButtonClick)
	
	buttonInstance.ButtonText.Text = buttonName

	buttonInstance.Parent = self.ElementToParentChildren
	buttonInstance.ButtonText.Size = UDim2.new(1,-(buttonInstance.CircleBackground.AbsoluteSize.X + textOffset),1,0)
	buttonInstance.ButtonText.Position = UDim2.fromOffset(buttonInstance.CircleBackground.AbsoluteSize.X + textOffset,0)
end

function elementHandler:Dropdown(dropdownName: string, optionList, param3, param4): table
	local dropdown = setmetatable({}, dropdownHandler)
	local dropdownInstance = originalElements.Dropdown:Clone()
	local elementHolderInnerBackground = dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderInnerBackground
	local elementHolderInnerBackgroundPaddings = dropdownInstance.ElementHolder.ElementHolderPadding.PaddingBottom.Offset + dropdownInstance.ElementHolder.ElementHolderPadding.PaddingTop.Offset + dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderBackgroundPadding.PaddingBottom.Offset + dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderBackgroundPadding.PaddingTop.Offset + elementHolderInnerBackground.ElementHolderInnerBackgroundPadding.PaddingBottom.Offset + elementHolderInnerBackground.ElementHolderInnerBackgroundPadding.PaddingTop.Offset

	local imageRotationOpenTween = TweenService:Create(dropdownInstance.DropdownButton.ButtonBackground.DropdownImage, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Rotation = 0})
	local imageRotationCloseTween = TweenService:Create(dropdownInstance.DropdownButton.ButtonBackground.DropdownImage, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Rotation = 180})
	local dropdownInstanceCloseTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,dropdownInstance.DropdownButton.Size.Y.Offset)})
	local dropdownInstanceOpenTween
	
	local function onDropdownClicked()
		if dropdown.IsExpanded then
			dropdown.IsExpanded = false
			imageRotationCloseTween:Play()
			dropdownInstanceCloseTween:Play()
		else
			dropdown.IsExpanded = true
			imageRotationOpenTween:Play()
			dropdownInstanceOpenTween:Play()
		end
	end

	local defaultSelection
	if typeof(param3) == "function" then
		dropdown.Callback = param3
		defaultSelection = param4
	else
		defaultSelection = param3
		if typeof(param4) == "function" then
			dropdown.Callback = param4
		end
	end

	dropdown.Type = "Dropdown"
	dropdown.IdentifierText = dropdownName or "N/A"
	dropdown.Instance = dropdownInstance
	dropdown.GuiToRemove = dropdownInstance
	dropdown.ElementToParentChildren = dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderInnerBackground
	dropdown.IsExpanded = false
	dropdown.Options = {}
	dropdown.SelectedValue = nil

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[dropdownInstance] = dropdown
	end

	dropdownInstance.DropdownButton.MouseButton1Click:Connect(onDropdownClicked)
	
	elementHolderInnerBackground.ElementHolderInnerBackgroundList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if dropdown.IsExpanded then
			if elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y == 0 then
				dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0, dropdownInstance.DropdownButton.AbsoluteSize.Y)})
			else
				local elementHolderTween = TweenService:Create(dropdownInstance.ElementHolder, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(.925,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings)})
				dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings + dropdownInstance.DropdownButton.Size.Y.Offset)})
				
				elementHolderTween:Play()
			end
			dropdownInstanceOpenTween:Play()	
		else
			dropdownInstance.ElementHolder.Size = UDim2.new(.925,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings)
			if elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y == 0 then
				dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0, dropdownInstance.DropdownButton.AbsoluteSize.Y)})
			else
				dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings + dropdownInstance.DropdownButton.Size.Y.Offset)})
			end
		end
	end)

	dropdownInstance.DropdownButton.ButtonBackground.DropdownText.Text = dropdownName or "N/A"

	dropdownInstance.Parent = self.ElementToParentChildren
	dropdownInstanceOpenTween = TweenService:Create(dropdownInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0, dropdownInstance.DropdownButton.AbsoluteSize.Y + dropdownInstance.ElementHolder.AbsoluteSize.Y)})

	local function styleOptionButton(button)
		local hoverIn = TweenService:Create(button, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(48, 48, 65)})
		local hoverOut = TweenService:Create(button, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(37, 37, 51)})
		button.MouseEnter:Connect(function()
			hoverOut:Cancel()
			hoverIn:Play()
		end)
		button.MouseLeave:Connect(function()
			hoverIn:Cancel()
			if dropdown.SelectedValue then
				local isSelected = button:GetAttribute("OptionValue") == dropdown.SelectedValue
				if not isSelected then
					hoverOut:Play()
				end
			else
				hoverOut:Play()
			end
		end)
	end

	function dropdown:ClearOptions()
		for _, option in ipairs(self.Options) do
			if option.Button then
				option.Button:Destroy()
			end
		end
		table.clear(self.Options)
		self.SelectedValue = nil
		self.Instance.DropdownButton.ButtonBackground.DropdownText.Text = dropdownName or "N/A"
	end

	function dropdown:AddOption(label, value)
		label = label or "Option"
		if value == nil then
			value = label
		end

		local button = Instance.new("TextButton")
		button.Name = "DropdownOption"
		button.AutoButtonColor = false
		button.BackgroundColor3 = Color3.fromRGB(37, 37, 51)
		button.BorderSizePixel = 0
		button.Size = UDim2.new(1, 0, 0, 22)
		button.Font = Enum.Font.Gotham
		button.Text = tostring(label)
		button.TextColor3 = Color3.fromRGB(168, 168, 168)
		button.TextSize = 14
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Parent = self.ElementToParentChildren
		button:SetAttribute("OptionValue", value)

		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = UDim.new(0, 6)
		padding.Parent = button

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = button

		styleOptionButton(button)

		button.MouseButton1Click:Connect(function()
			dropdown:Select(value)
		end)

		local info = {Label = label, Value = value, Button = button}
		table.insert(self.Options, info)
		return info
	end

	function dropdown:Select(value)
		local foundOption
		for _, option in ipairs(self.Options) do
			local isSelected = option.Value == value or option.Label == value
			if isSelected then
				foundOption = option
				self.SelectedValue = option.Value
			end
			if option.Button then
				option.Button.TextColor3 = isSelected and Color3.fromRGB(0, 255, 106) or Color3.fromRGB(168, 168, 168)
				option.Button.BackgroundColor3 = isSelected and Color3.fromRGB(48, 48, 65) or Color3.fromRGB(37, 37, 51)
			end
		end

		if not foundOption and self.Options[1] then
			return self:Select(self.Options[1].Value)
		end

		if foundOption then
			self.Instance.DropdownButton.ButtonBackground.DropdownText.Text = string.format("%s: %s", dropdownName or "N/A", foundOption.Label)
			if self.Callback then
				local ok, err = pcall(self.Callback, foundOption.Value, foundOption.Label)
				if not ok then
					warn("Dropdown callback error:", err)
				end
			end
			if self.IsExpanded then
				self.IsExpanded = false
				imageRotationCloseTween:Play()
				dropdownInstanceCloseTween:Play()
			end
		end
	end

	function dropdown:SetOptions(optionsList, preferredValue, cb)
		self:ClearOptions()
		if typeof(cb) == "function" then
			self.Callback = cb
		end

		if typeof(optionsList) == "table" then
			for _, entry in ipairs(optionsList) do
				local label
				local value
				if typeof(entry) == "table" then
					label = entry.label or entry.Name or entry[1]
					value = entry.value or entry.Value or entry[2] or label
				else
					label = tostring(entry)
					value = entry
				end
				self:AddOption(label, value)
			end
		end

		if preferredValue ~= nil then
			self:Select(preferredValue)
		elseif self.Options[1] then
			self:Select(self.Options[1].Value)
		end
	end

	if typeof(optionList) == "table" then
		dropdown:SetOptions(optionList, defaultSelection, dropdown.Callback)
	elseif defaultSelection ~= nil and dropdown.Callback then
		dropdown:SetOptions({}, defaultSelection, dropdown.Callback)
	end

	return dropdown
end

function dropdownHandler:ChangeText(newText: string)
	newText = newText or "N/A"
	self.Instance.DropdownButton.ButtonBackground.DropdownText.Text = newText
	self.IdentifierText = newText
end

function elementHandler:Slider(sliderName: string, callback, maximumValue: number, minimumValue: number): table
	local slider = setmetatable({}, sliderHandler) -- MAKE RIGHT CLICK AND BAR GOES TO MID
	local sliderInstance = originalElements.Slider:Clone()
	local sliderBar = sliderInstance.SliderBackground.SliderInnerBackground.Slider
	local minimumClosePixelsLeft = 2
	local textPixelOffset = 2

	minimumValue = minimumValue or 0
	maximumValue = maximumValue or 100

	assert(maximumValue > minimumValue, "Maximum must be greater than minimum.")

	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = tostring(maximumValue) or "N/A"
	textParams.Font = sliderInstance.TextGrouping.NumberText.FontFace
	textParams.Size = 14
	textParams.Width = 10000

	local requiredNumberTextSpace = TextService:GetTextBoundsAsync(textParams)
	textParams.Text = "ERR"
	local requiredErrorTextSpace = TextService:GetTextBoundsAsync(textParams)

	local maxMinRange = math.abs(minimumValue - maximumValue)
	local sliderValue = minimumValue
	callback = callback or function() end

	slider.Type = "Slider"
	slider.IdentifierText = sliderName or "N/A"
	slider.Instance = sliderInstance
	slider.GuiToRemove = sliderInstance
	slider.MinimumValue = minimumValue
	slider.MaximumValue = maximumValue
	slider.Value = sliderValue
	slider.Callback = callback

	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[sliderInstance] = slider
	end

	local function fire(newValue, fireCallback)
		local emptyWidth = sliderBar.Parent.EmptySliderBackground.AbsoluteSize.X
		local clampedValue = math.clamp(newValue, slider.MinimumValue, slider.MaximumValue)
		sliderValue = clampedValue
		slider.Value = sliderValue
		local percent = (sliderValue - slider.MinimumValue) / maxMinRange
		sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
		if emptyWidth <= 0 then
			sliderBar.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
		else
			local newSize = math.max(minimumClosePixelsLeft, emptyWidth * percent)
			sliderBar.Size = UDim2.new(0, newSize, 1, 0)
		end
		if fireCallback ~= false and slider.Callback then
			slider.Callback(sliderValue)
		end
	end

	local function onMouseDown()
		local function onMouseMoved()
			local background = sliderBar.Parent.EmptySliderBackground
			local absPos = background.AbsolutePosition
			local absSize = background.AbsoluteSize
			local mouseOffset = math.clamp(mouse.X - absPos.X, 0, math.max(absSize.X, 1))
			local percent = mouseOffset / math.max(absSize.X, 1)
			local value = minimumValue + (maxMinRange * percent)
			fire(value)
		end

		local moveConn = mouse.Move:Connect(onMouseMoved)
		local endInputConnection
		onMouseMoved()
		endInputConnection = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				moveConn:Disconnect()
				endInputConnection:Disconnect()
			end
		end)
	end

	local function onFocusLost(enterPressed)
		if enterPressed then
			local enteredNum = tonumber(sliderInstance.TextGrouping.NumberText.Text)
			if typeof(enteredNum) == "number" and enteredNum >= minimumValue and enteredNum <= maximumValue then
				fire(enteredNum)
			else
				sliderInstance.TextGrouping.NumberText.Text = "ERR"
				task.wait(.5)
				if sliderInstance.TextGrouping.NumberText.Text == "ERR" then
					sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
				end
			end
		else
			sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
		end
	end

	sliderInstance.SliderBackground.MouseButton1Down:Connect(onMouseDown)
	sliderInstance.TextGrouping.NumberText.FocusLost:Connect(onFocusLost)

	sliderInstance.TextGrouping.SliderText.Text = sliderName or "N/A"
	sliderInstance.TextGrouping.NumberText.Text = minimumValue
	sliderInstance.TextGrouping.NumberText.Size = UDim2.new(0,math.max(requiredErrorTextSpace.X, requiredNumberTextSpace.X) + textPixelOffset,1,0)

	sliderInstance.Parent = self.ElementToParentChildren
	sliderInstance.TextGrouping.SliderText.Size = UDim2.new(0, sliderInstance.TextGrouping.AbsoluteSize.X - textPixelOffset - requiredNumberTextSpace.X, 1, 0)

	function slider:Set(value, skipCallback)
		if typeof(value) ~= "number" then
			return
		end
		fire(value, skipCallback ~= true)
	end

	return slider
end


function elementHandler:SearchBar(placeholderText: string): table
	local searchBar = setmetatable({}, searchBarHandler)
	local searchBarInstance = originalElements.SearchBar:Clone()
	local searchBox = searchBarInstance.SearchBarFrame.ButtonBackgroundPadding.SearchBox
	local elementHolder = searchBarInstance.ElementHolder
    local elementHolderBackground = elementHolder.ElementHolderBackground
	local elementHolderInnerBackground = elementHolderBackground.ElementHolderInnerBackground
	local elementHolderInnerBackgroundPaddings = elementHolder.ElementHolderPadding.PaddingBottom.Offset + elementHolder.ElementHolderPadding.PaddingTop.Offset + elementHolderBackground.ElementHolderBackgroundPadding.PaddingBottom.Offset + elementHolderBackground.ElementHolderBackgroundPadding.PaddingTop.Offset + elementHolderInnerBackground.ElementHolderInnerBackgroundPadding.PaddingBottom.Offset + elementHolderInnerBackground.ElementHolderInnerBackgroundPadding.PaddingTop.Offset
	local searchBarInstanceCloseTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,searchBarInstance.SearchBarFrame.Size.Y.Offset)})
	local searchBarInstanceOpenTween
	local isMouseHoveringOver = false
	local mouseEnterConnection
	local mouseLeftConnection
	local uisFocusLost
	local playingAnimation
	local searchingText
	
	placeholderText = placeholderText or "N/A"

	local function onTextChanged()
		if searchBar.IsExpanded then
			if searchingText then coroutine.close(searchingText) end
			searchingText = coroutine.create(function()
				for _, foundElement in ipairs(elementHolderInnerBackground:GetChildren()) do
					local foundElementInfo = searchBar.ChildedElementsInfo[foundElement]
					if foundElementInfo ~= nil then
						if foundElementInfo.IdentifierText:lower():find(searchBox.Text:lower(), 1, true) then
							foundElement.Visible = true
						else
							foundElement.Visible = false
						end
					end
				end
				searchingText = nil
			end)
			coroutine.resume(searchingText)
		end
	end
	
	local function onFocused()
		elementHolderInnerBackground.Visible = true
		searchBar.IsExpanded = true
		onTextChanged()
		isMouseHoveringOver = true
		searchBarInstanceOpenTween:Play()
		
		if playingAnimation then
			coroutine.close(playingAnimation) 
			searchBox.PlaceholderText = placeholderText
			searchBox.Text = ""
		end
		
		mouseLeftConnection = searchBarInstance.MouseLeave:Connect(function()
			isMouseHoveringOver = false
			
			if not searchBox:IsFocused() then
				searchBar.IsExpanded = false
				searchBarInstanceCloseTween:Play()
				mouseLeftConnection:Disconnect()
				mouseEnterConnection:Disconnect()
				uisFocusLost:Disconnect()
				
				searchBarInstanceCloseTween.Completed:Connect(function(playbackState)
					if playbackState == Enum.PlaybackState.Completed then
						elementHolderInnerBackground.Visible = false
					end
				end)

				if playingAnimation then coroutine.close(playingAnimation) end
				playingAnimation = coroutine.create(function()
					searchBox.PlaceholderText = ""
					animateText(searchBox, .025, nil, placeholderText, true)
					playingAnimation = nil
				end)
				coroutine.resume(playingAnimation)
			end
		end)
		
		mouseEnterConnection = searchBarInstance.MouseEnter:Connect(function()
			isMouseHoveringOver = true
		end)
		
		uisFocusLost = UserInputService.TextBoxFocusReleased:Connect(function(textBoxReleased)
			if textBoxReleased == searchBox then
				if not isMouseHoveringOver then
					searchBar.IsExpanded = false
					searchBarInstanceCloseTween:Play()
					mouseLeftConnection:Disconnect()
					mouseEnterConnection:Disconnect()
					uisFocusLost:Disconnect()

					searchBarInstanceCloseTween.Completed:Connect(function(playbackState)
						if playbackState == Enum.PlaybackState.Completed then
							elementHolderInnerBackground.Visible = false
						end
					end)

					if playingAnimation then coroutine.close(playingAnimation) end
					playingAnimation = coroutine.create(function()
						searchBox.PlaceholderText = ""
						animateText(searchBox, .025, nil, placeholderText, true)
						playingAnimation = nil
					end)
					coroutine.resume(playingAnimation)
				end
			end
		end)
	end
	
	searchBar.Type = "SearchBar"
	searchBar.IdentifierText = placeholderText or "N/A"
	searchBar.Instance = searchBarInstance
	searchBar.GuiToRemove = searchBarInstance
	searchBar.ElementToParentChildren = elementHolderInnerBackground
	searchBar.ChildedElementsInfo = {}
	searchBar.IsExpanded = false
	
	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[searchBarInstance] = searchBar
	end
	
	searchBox:GetPropertyChangedSignal("Text"):Connect(onTextChanged)
	searchBox.Focused:Connect(onFocused)
	
	elementHolderInnerBackground.ElementHolderInnerBackgroundList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if searchBar.IsExpanded then
			if elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y == 0 then
				searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,searchBarInstance.SearchBarFrame.Size.Y.Offset)})
			else
				local elementHolderOpenTween = TweenService:Create(elementHolder, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(.925,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings)})
				searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings + searchBarInstance.SearchBarFrame.Size.Y.Offset)})	
				elementHolderOpenTween:Play()		
			end
			
			searchBarInstanceOpenTween:Play()
		else
			elementHolder.Size = UDim2.new(.925,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings)
			if elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y == 0 then
				searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,searchBarInstance.SearchBarFrame.Size.Y.Offset)})
			else
				searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,elementHolderInnerBackground.ElementHolderInnerBackgroundList.AbsoluteContentSize.Y + elementHolderInnerBackgroundPaddings + searchBarInstance.SearchBarFrame.Size.Y.Offset)})
			end	
		end
	end)
	
	searchBox.PlaceholderText = placeholderText or "N/A"
	
	searchBarInstance.Parent = self.ElementToParentChildren
	searchBox.Size = UDim2.new(1,-(searchBox.Parent.SearchImage.AbsoluteSize.X + searchBox.Parent.ButtonBackgroundPadding.PaddingRight.Offset),1,0)
	searchBarInstanceOpenTween = TweenService:Create(searchBarInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,searchBarInstance.SearchBarFrame.Size.Y.Offset)})	
	
	return searchBar
end

--REWORK KEYBIND COMPLETLEY INEFFICENT !!!
-- ADD RIGHT CLICK TO REMOVE CURRENT KEYBIND TO NOTHING
function elementHandler:Keybind(keybindName: string, callback, defaultKey: string): table
	local keybind = setmetatable({}, keybindHandler)
	local keybindInstance = originalElements.Keybind:Clone()
	local sideClosedTextPaddingPixels = 1
	local keybindTextPadding = 4
	local isOverriding = false
	local inputBeingProcessed
	local originialOffsetSize
	local textAnimationSpeed = .025
	local textAnimation
	
	local pressKeyMsg = "Press a key..."
	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = pressKeyMsg
	textParams.Width = 10000
	textParams.Font = keybindInstance.BoxBackground.InnerBox.KeyText.FontFace
	textParams.Size = 14
	
	local requiredInputKeyTextSize = TextService:GetTextBoundsAsync(textParams)
	local requiredInputKeyTextTween = TweenService:Create(keybindInstance.BoxBackground, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0,requiredInputKeyTextSize.X + keybindInstance.BoxBackground.BoxPadding.PaddingLeft.Offset + keybindInstance.BoxBackground.BoxPadding.PaddingRight.Offset + keybindInstance.BoxBackground.InnerBox.BoxPadding.PaddingLeft.Offset + keybindInstance.BoxBackground.InnerBox.BoxPadding.PaddingRight.Offset,1,0)})
	
	callback = callback or function() end
	keybindName = keybindName or "N/A"
	defaultKey = defaultKey or "F"
	
	local function getMatchingKeyCodeFromName(name)
		if type(name) ~= "string" then return end
		local nameLower = name:lower()
		for _, keycode in ipairs(Enum.KeyCode:GetEnumItems()) do
			if keycode.Name:lower() == nameLower then
				return keycode
			end
		end
	end
	
	local function onKeybindClick()
		local recognizedKey = false
		local input
		
		requiredInputKeyTextTween:Play()
		
		repeat
			local gameProcessedEvent
			input, gameProcessedEvent = UserInputService.InputBegan:Wait()
			if input.KeyCode.Name ~= "Unknown" then
				recognizedKey = true
			end
		until recognizedKey
		
		isOverriding = true
		if textAnimation then
			coroutine.close(textAnimation)	
		end
		
		textAnimation = coroutine.create(function()
			animateText(keybindInstance.BoxBackground.InnerBox.KeyText, textAnimationSpeed, input.KeyCode.Name)
			
			textParams.Text = input.KeyCode.Name
			local requiredNewTextSpace = TextService:GetTextBoundsAsync(textParams)
			local closeTween = TweenService:Create(keybindInstance.BoxBackground, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0,math.max(originialOffsetSize.X, requiredNewTextSpace.X + keybindInstance.BoxBackground.BoxPadding.PaddingLeft.Offset + keybindInstance.BoxBackground.BoxPadding.PaddingRight.Offset + keybindInstance.BoxBackground.InnerBox.BoxPadding.PaddingLeft.Offset + keybindInstance.BoxBackground.InnerBox.BoxPadding.PaddingRight.Offset + sideClosedTextPaddingPixels),1,0)})
			closeTween:Play()
			isOverriding = false
		end)
		
		coroutine.resume(textAnimation)

		repeat task.wait() until not inputBeingProcessed
		defaultKey = input.KeyCode
		keybind.Value = input.KeyCode
	end
	
	local function onInputBegan(input, gameProcessedEvent)
		inputBeingProcessed = true
		if gameProcessedEvent then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == defaultKey then
				callback()
			end
		end
		inputBeingProcessed = false	
	end
	-- for toggle radio buttons do a fn to loop all and toggles in table given and setttoggle fn to false  by checking if self.IsToggled
	requiredInputKeyTextTween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed and not isOverriding then -- Animation runs after other override starts due to tween completed after override starts
			if textAnimation then
				coroutine.close(textAnimation)
			end
			
			textAnimation = coroutine.create(function()
				animateText(keybindInstance.BoxBackground.InnerBox.KeyText, textAnimationSpeed, pressKeyMsg)
			end)
			
			coroutine.resume(textAnimation)
		end
	end)
	
	keybind.Type = "Keybind"
	keybind.IdentifierText = keybindName
	keybind.Instance = keybindInstance
	keybind.GuiToRemove = keybindInstance
	
	UserInputService.InputBegan:Connect(onInputBegan)
	keybindInstance.MouseButton1Click:Connect(onKeybindClick)
	
	keybindInstance.KeybindText.Text = keybindName
	keybindInstance.BoxBackground.InnerBox.KeyText.Text = defaultKey
	
	defaultKey = getMatchingKeyCodeFromName(defaultKey)
	
	keybind.Value = defaultKey
	keybindInstance.Parent = self.ElementToParentChildren
	originialOffsetSize = keybindInstance.BoxBackground.AbsoluteSize
	keybindInstance.BoxBackground.Size = UDim2.fromOffset(originialOffsetSize.X,originialOffsetSize.Y)
	keybindInstance.BoxBackground.BoxAspect:Destroy()
	keybindInstance.KeybindText.Size = UDim2.new(1,-(originialOffsetSize.X + keybindTextPadding),1,0)
end

function elementHandler:TextBox(textBoxName:string, callback): table
	local textBox = setmetatable({}, textBoxHandler)
	local textBoxInstance = originalElements.TextBox:Clone()
	local placeholderText = "Type here..."
	local sidePlaceholderTextPadding = 2
	local textAnimation
	
	local boxBackground = textBoxInstance.BoxBackground
	local innerBox = boxBackground.InnerBox
	local textBoxText = innerBox.TextBoxText
	
	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = placeholderText
	textParams.Width = 10000
	textParams.Font = textBoxText.FontFace
	textParams.Size = 14
	
	local requiredPlaceholderTextSpace = TextService:GetTextBoundsAsync(textParams)
	
	local function onInstanceClicked(): nil
		textBoxText:CaptureFocus()
	end
	
	local function onFocusLost(enterPressed: boolean): nil
		if enterPressed then callback(textBoxText.Text) end
		if textAnimation then coroutine.close(textAnimation) end
		textAnimation = coroutine.create(function()
			textBoxText.PlaceholderText = ""
			animateText(textBoxText, .025, _, placeholderText, true)
			textAnimation = nil
		end)
		coroutine.resume(textAnimation)
	end
	
	local function onFocused()
		if textAnimation then 
			coroutine.close(textAnimation) 
			textBoxText.PlaceholderText = placeholderText
			textBoxText.Text = ""
		end
	end
	
	local function onTextChanged()
		local boxBackgroundPaddingNeededSize = (sidePlaceholderTextPadding * 2) + boxBackground.BoxPadding.PaddingLeft.Offset + boxBackground.BoxPadding.PaddingRight.Offset + innerBox.BoxPadding.PaddingLeft.Offset + innerBox.BoxPadding.PaddingRight.Offset
		textParams.Text = textBoxText.Text
		local requiredTextSize = TextService:GetTextBoundsAsync(textParams)
		local textChangedTween = TweenService:Create(boxBackground, TweenInfo.new(.1, Enum.EasingStyle.Linear), {Size = UDim2.new(0,math.clamp(boxBackgroundPaddingNeededSize + requiredTextSize.X, boxBackgroundPaddingNeededSize + requiredPlaceholderTextSpace.X, textBoxInstance.AbsoluteSize.X / 8 * 5),1,0)})
		textChangedTween:Play()	
	end
	
	textBoxName = textBoxName or "N/A"
	callback = callback or function() end
	
	textBox.Type = "TextBox"
	textBox.IdentifierText = textBoxName
	textBox.Instance = textBoxInstance
	textBox.GuiToRemove = textBoxInstance
	
	textBoxInstance.MouseButton1Click:Connect(onInstanceClicked)
	textBoxText.FocusLost:Connect(onFocusLost)
	textBoxText.Focused:Connect(onFocused)
	textBoxText:GetPropertyChangedSignal("Text"):Connect(onTextChanged)
	
	textBoxText.PlaceholderText = placeholderText
	textBoxInstance.TextBoxNameText.Text = textBoxName
	
	textBoxInstance.Parent = self.ElementToParentChildren
	boxBackground.Size = UDim2.new(0,requiredPlaceholderTextSpace.X + (sidePlaceholderTextPadding * 2) + boxBackground.BoxPadding.PaddingLeft.Offset + boxBackground.BoxPadding.PaddingRight.Offset + innerBox.BoxPadding.PaddingLeft.Offset + innerBox.BoxPadding.PaddingRight.Offset,1,0)
	textBoxInstance.TextBoxNameText.Size = UDim2.new(1,-(boxBackground.AbsoluteSize.X + 4),1,0)
	
	return textBox
end

--Fix toggle img it's imported as orange make it white
function elementHandler:ColorWheel(colorWheelName: string, defaultColor, callback): table
	local colorWheel = setmetatable({}, colorWheelHandler)
	local colorWheelInstance = originalElements.ColorWheel:Clone()

	local heading = colorWheelInstance.Heading
	local wheelHolder = colorWheelInstance.WheelHolder
	local valueHolder =wheelHolder.ValueHolder
	local colorInputHolder = valueHolder.ColorInputHolder
	local wheel = wheelHolder.Wheel
	local selector = wheel.Selector
	local slider = valueHolder.ValueSlider
	local sliderBar = slider.SliderBar
	local sliderAbsSize
	local sliderAbsPos
	local wheelRadius = 0

	local dropdownOpenTween = TweenService:Create(colorWheelInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, heading.AbsoluteSize.Y + wheelHolder.AbsoluteSize.Y + 4)})
	local dropdownCloseTween = TweenService:Create(colorWheelInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, heading.AbsoluteSize.Y)})
	local dropdownImageOpenTween = TweenService:Create(heading.BoxBackground.InnerBox.CenterBox.DropdownImage, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Rotation = 0})
	local dropdownImageCloseTween = TweenService:Create(heading.BoxBackground.InnerBox.CenterBox.DropdownImage, TweenInfo.new(.25, Enum.EasingStyle.Linear), {Rotation = 180})

	local textParams = Instance.new("GetTextBoundsParams")
	textParams.Text = "255"
	textParams.Font = heading.ColorWheelName.FontFace
	textParams.Size = 14
	textParams.Width = 10000

	local requiredRgbTextSize = TextService:GetTextBoundsAsync(textParams)

	if typeof(defaultColor) == "function" then
		callback = defaultColor
		defaultColor = nil
	end

	local hue, saturation, value = 0, 0, 1
	callback = callback or function() end

	local function updateVisuals(fireCallback)
		local color = Color3.fromHSV(hue, saturation, value)
		valueHolder.ColorSample.BackgroundColor3 = color
		colorInputHolder.Red.BoxBackground.InnerBox.ColorValue.Text = math.round(color.R * 255)
		colorInputHolder.Green.BoxBackground.InnerBox.ColorValue.Text = math.round(color.G * 255)
		colorInputHolder.Blue.BoxBackground.InnerBox.ColorValue.Text = math.round(color.B * 255)
		if fireCallback ~= false then
			callback(color)
		end
	end

	local function setColorFromInput(newColor, fireCallback)
		if typeof(newColor) ~= "Color3" then
			return
		end
		hue, saturation, value = newColor:ToHSV()
		local sliderWidth = math.max(slider.AbsoluteSize.X - sliderBar.AbsoluteSize.X, 1)
		local sliderPosition = math.clamp(value, 0, 1) * sliderWidth
		sliderBar.Position = UDim2.new(0, sliderPosition, 0, 0)
		local angle = math.rad(hue * 360 - 180)
		local radius = saturation * math.max(wheelRadius, 1)
		local polarX = math.cos(angle) * radius
		local polarY = math.sin(angle) * radius
		selector.Position = UDim2.new(.5, polarX, .5, -polarY)
		updateVisuals(fireCallback)
	end

	local function updateSlider()
		sliderAbsPos = slider.AbsolutePosition
		sliderAbsSize = slider.AbsoluteSize

		local clampedMousePos = math.clamp(mouse.X - sliderAbsPos.X, 0, sliderAbsSize.X - sliderBar.AbsoluteSize.X)
		sliderBar.Position = UDim2.new(0, clampedMousePos, 0, 0)
		value = clampedMousePos / math.max(sliderAbsSize.X - sliderBar.AbsoluteSize.X, 1)
		updateVisuals()
	end

	local function updateRing()
		local relativeVector = Vector2.new(mouse.X, mouse.Y) - wheel.AbsolutePosition - wheel.AbsoluteSize / 2
		local radius, angle = toPolar(relativeVector * Vector2.new(1,-1))

		if radius > wheelRadius then
			relativeVector = relativeVector.Unit * wheelRadius
			radius = wheelRadius
		end

		selector.Position = UDim2.new(.5, relativeVector.X, .5, relativeVector.Y)

		hue, saturation = (math.deg(angle) + 180) / 360 , radius / math.max(wheelRadius, 1)

		updateVisuals()
	end

	local function onDropdownClicked()
		if colorWheel.IsExpanded then
			colorWheel.IsExpanded = false
			dropdownCloseTween:Play()
			dropdownImageCloseTween:Play()
		else
			colorWheel.IsExpanded = true
			dropdownOpenTween:Play()
			dropdownImageOpenTween:Play()
		end
	end

	local function onSliderMouseDown()
		local inputEndedConnection

		updateSlider()

		local mouseMovedConnection = mouse.Move:Connect(function()
			updateSlider()
		end)

		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				inputEndedConnection:Disconnect()
				mouseMovedConnection:Disconnect()
			end
		end)
	end

	local function onWheelMouseDown()
		local inputEndedConnection

		updateRing()

		local mouseMovedConnection = mouse.Move:Connect(function()
			updateRing()
		end)

		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				inputEndedConnection:Disconnect()
				mouseMovedConnection:Disconnect()
			end
		end)
	end

	local function onColorInputTextChanged(textBox: TextBox): nil
		local colorValue = tonumber(textBox.Text)
		if textBox.Text:match("%D") or #textBox.Text > 3 then
			textBox.Text = textBox.Text:sub(1, #textBox.Text - 1)
		elseif colorValue and colorValue > 255 then
			textBox.Text = 255
		end
	end

	local function onColorInputTextLostFocus(textBox: TextBox, textBoxColorAssociated): nil	
		local currentColor = Color3.fromHSV(hue, saturation, value)
		local colorTable = {
			Red = {Tag = "R", Color3Value = Color3.fromRGB(tonumber(textBox.Text), currentColor.G * 255, currentColor.B * 255)},
			Green = {Tag = "G", Color3Value = Color3.fromRGB(currentColor.R * 255, tonumber(textBox.Text), currentColor.B * 255)},
			Blue = {Tag = "B", Color3Value = Color3.fromRGB(currentColor.R * 255, currentColor.G * 255, tonumber(textBox.Text))}
		}

		if #textBox.Text == 0 then
			textBox.Text = math.round(currentColor[colorTable[textBoxColorAssociated].Tag] * 255)
		else
			hue, saturation, value = colorTable[textBoxColorAssociated].Color3Value:ToHSV()
			local angle = math.rad(hue * 360 - 180)
			local radial = saturation * math.max(wheelRadius, 1)
			local x, y = math.cos(angle) * radial, math.sin(angle) * radial
			selector.Position = UDim2.new(.5, x, .5, -y)
			local sliderWidth = math.max(slider.AbsoluteSize.X - sliderBar.AbsoluteSize.X, 1)
			sliderBar.Position = UDim2.new(0, math.clamp(value, 0, 1) * sliderWidth, 0, 0)
			updateVisuals()
		end

	end

	colorWheelName = colorWheelName or "N/A"
	colorWheel.Callback = callback
	colorWheel.Type = "ColorWheel"
	colorWheel.IdentifierText = colorWheelName
	colorWheel.IsExpanded = false
	colorWheel.Instance = colorWheelInstance
	colorWheel.GuiToRemove = colorWheelInstance

	heading.MouseButton1Click:Connect(onDropdownClicked)
	slider.MouseButton1Down:Connect(onSliderMouseDown)
	wheel.MouseButton1Down:Connect(onWheelMouseDown)

	heading.ColorWheelName.Text = colorWheelName

	colorWheelInstance.Parent = self.ElementToParentChildren
	heading.ColorWheelName.Size = UDim2.new(1, -(heading.BoxBackground.AbsoluteSize.X + 4),1,0)
	valueHolder.Size = UDim2.new(.9,-(wheel.AbsoluteSize.X + 4),1,0)
	sliderBar.Position = UDim2.new(1,-sliderBar.AbsoluteSize.X,0,0)

	for _, rgbFrame in ipairs(valueHolder.ColorInputHolder:GetChildren()) do
		if rgbFrame:IsA("Frame") then
			local requiredBoxBackgroundXSize = rgbFrame.BoxBackground.BoxPadding.PaddingLeft.Offset + rgbFrame.BoxBackground.BoxPadding.PaddingRight.Offset + rgbFrame.BoxBackground.InnerBox.BoxPadding.PaddingLeft.Offset + rgbFrame.BoxBackground.InnerBox.BoxPadding.PaddingRight.Offset + requiredRgbTextSize.X + 4
			rgbFrame.BoxBackground.Size = UDim2.new(0,requiredBoxBackgroundXSize,1,0)	
			rgbFrame.ColorText.Size = UDim2.new(1,-(requiredBoxBackgroundXSize + 2),1,0)
			rgbFrame.BoxBackground.InnerBox.ColorValue:GetPropertyChangedSignal("Text"):Connect(function() onColorInputTextChanged(rgbFrame.BoxBackground.InnerBox.ColorValue) end)
			rgbFrame.BoxBackground.InnerBox.ColorValue.FocusLost:Connect(function() onColorInputTextLostFocus(rgbFrame.BoxBackground.InnerBox.ColorValue, rgbFrame.Name) end)
		end
	end

	wheel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		wheelRadius = wheel.AbsoluteSize.X / 2
	end)

	wheelRadius = wheel.AbsoluteSize.X / 2

	function colorWheel:Set(newColor, skipCallback)
		setColorFromInput(newColor, skipCallback ~= true)
	end

	local initialColor = defaultColor or Color3.fromRGB(255, 255, 255)
	task.defer(function()
		setColorFromInput(initialColor, false)
	end)

	return colorWheel
end

createOriginalElements()

-- Theme and Config Integration
local ThemeManager = {} do
    local ThemeFields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
    ThemeManager.Folder = "KeyForgeSettings"
    ThemeManager.SubFolder = ""
    ThemeManager.Library = Library

    ThemeManager.BuiltInThemes = {
        ["Default"] = {
            1,
            { FontColor = "a8a8a8", MainColor = "1f1f1f", AccentColor = "00aaff", BackgroundColor = "151515", OutlineColor = "252533" },
        },
        ["Light"] = {
            2,
            { FontColor = "000000", MainColor = "ffffff", AccentColor = "ffaa00", BackgroundColor = "f5f5f5", OutlineColor = "cccccc" },
        },
        ["Dark"] = {
            3,
            { FontColor = "ffffff", MainColor = "000000", AccentColor = "ff0000", BackgroundColor = "1a1a1a", OutlineColor = "333333" },
        }
    }

    function ThemeManager:BuildFolderTree()
        local paths = { self.Folder .. "/themes" }
        for _, path in paths do
            if not exploitEnv.isfolder(path) then
                exploitEnv.makefolder(path)
            end
        end
    end

    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function ThemeManager:ApplyTheme(theme)
        local customThemeData = self:GetCustomTheme(theme)
        local data = customThemeData or self.BuiltInThemes[theme]

        if not data then
            return
        end

        local scheme = data[2]
        for idx, val in pairs(customThemeData or scheme) do
            if idx == "VideoLink" then
                continue
            elseif idx == "FontFace" then
                self.Library:SetFont(Enum.Font[val])

                if self.Library.Options[idx] then
                    self.Library.Options[idx]:SetValue(val)
                end
            else
                self.Library.Scheme[idx] = Color3.fromHex(val)

                if self.Library.Options[idx] then
                    self.Library.Options[idx]:SetValueRGB(Color3.fromHex(val))
                end
            end
        end

        self:ThemeUpdate()
    end

    function ThemeManager:ThemeUpdate()
        self.Library:UpdateColorsUsingRegistry()
    end

    function ThemeManager:GetCustomTheme(file)
        local path = self.Folder .. "/themes/" .. file .. ".json"
        if not exploitEnv.isfile(path) then
            return nil
        end

        local data = exploitEnv.readfile(path)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)

        if not success then
            return nil
        end

        return decoded
    end

    ThemeManager:BuildFolderTree()
end

local SaveManager = {} do
    SaveManager.Folder = "KeyForgeSettings"
    SaveManager.Ignore = {}
    SaveManager.Options = Library.Options
    SaveManager.Library = Library

    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object) 
                return { type = "Toggle", idx = idx, value = object.Value or object.Enabled } 
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = "Slider", idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValue(tonumber(data.value) or data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = "Dropdown", idx = idx, value = object.Value or object.SelectedValue, multi = object.Multi }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                local color = object.Value or (object.Instance and object.Instance.WheelHolder.ValueHolder.ColorSample.BackgroundColor3) or Color3.new(1,1,1)
                return { type = "ColorPicker", idx = idx, value = color:ToHex(), transparency = object.Transparency or 0 }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    if SaveManager.Options[idx].SetValueRGB then
                        SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                    else
                        SaveManager.Options[idx]:Set(Color3.fromHex(data.value))
                    end
                end
            end,
        },
        Keybind = {
            Save = function(idx, object)
                return { type = "Keybind", idx = idx, mode = object.Mode or "Always", key = object.Value or (object.Instance and object.Instance.BoxBackground.InnerBox.KeyText.Text) }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValue(data.key, data.mode)
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = "Input", idx = idx, text = object.Value or (object.Instance and object.Instance.BoxBackground.InnerBox.TextBoxText.Text) }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] and type(data.text) == "string" then
                    SaveManager.Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in next, list do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function SaveManager:Save(name)
        if (not name) then
            return false, "no config file is selected"
        end

        local fullPath = self.Folder .. "/settings/" .. name .. ".json"

        local data = {
            objects = {}
        }

        for idx, option in next, SaveManager.Options do
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end

            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end	

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return false, "failed to encode data"
        end

        exploitEnv.writefile(fullPath, encoded)
        return true
    end

    function SaveManager:Load(name)
        if (not name) then
            return false, "no config file is selected"
        end
        
        local file = self.Folder .. "/settings/" .. name .. ".json"
        if not exploitEnv.isfile(file) then return false, "invalid file" end

        local success, decoded = pcall(HttpService.JSONDecode, HttpService, exploitEnv.readfile(file))
        if not success then return false, "decode error" end

        for _, option in next, decoded.objects do
            if self.Parser[option.type] then
                task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
            end
        end

        return true
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({ 
            "InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind"
        })
    end

    function SaveManager:BuildFolderTree()
        local paths = {
            self.Folder,
            self.Folder .. "/settings"
        }

        for i = 1, #paths do
            local str = paths[i]
            if not exploitEnv.isfolder(str) then
                exploitEnv.makefolder(str)
            end
        end
    end

    function SaveManager:RefreshConfigList()
        if not exploitEnv.isfolder(self.Folder .. "/settings") then return {} end
        local list = exploitEnv.listfiles(self.Folder .. "/settings")

        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == ".json" then
                local pos = file:find(".json", 1, true)
                local start = pos

                local char = file:sub(pos, pos)
                while char ~= "/" and char ~= "\\" and char ~= "" do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end

                if char == "/" or char == "\\" then
                    local name = file:sub(pos + 1, start - 1)
                    if name ~= "options" then
                        table.insert(out, name)
                    end
                end
            end
        end
        
        return out
    end

    function SaveManager:SetLibrary(library)
        self.Library = library
        self.Options = library.Options
    end

    function SaveManager:LoadAutoloadConfig()
        if exploitEnv.isfile(self.Folder .. "/settings/autoload.txt") then
            local name = exploitEnv.readfile(self.Folder .. "/settings/autoload.txt")

            local success, err = self:Load(name)
            if not success then
                return self.Library:Notify({
                    Title = "Interface",
                    Content = "Config loader",
                    Description = "Failed to load autoload config: " .. err,
                    Duration = 7
                })
            end

            self.Library:Notify({
                Title = "Interface",
                Content = "Config loader",
                Description = string.format("Auto loaded config %q", name),
                Duration = 7
            })
        end
    end

    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, "Must set SaveManager.Library")

        local section = tab:AddSection("Configuration")

        section:AddInput("SaveManager_ConfigName",    { Title = "Config name" })
        section:AddDropdown("SaveManager_ConfigList", { Title = "Config list", Values = self:RefreshConfigList(), AllowNull = true })

        section:AddButton({
            Title = "Create config",
            Callback = function()
                local name = SaveManager.Options.SaveManager_ConfigName.Value

                if name:gsub(" ", "") == "" then 
                    return self.Library:Notify({
                        Title = "Interface",
                        Content = "Config loader",
                        Description = "Invalid config name (empty)",
                        Duration = 7
                    })
                end

                local success, err = self:Save(name)
                if not success then
                    return self.Library:Notify({
                        Title = "Interface",
                        Content = "Config loader",
                        Description = "Failed to save config: " .. err,
                        Duration = 7
                    })
                end

                self.Library:Notify({
                    Title = "Interface",
                    Content = "Config loader",
                    Description = string.format("Created config %q", name),
                    Duration = 7
                })

                SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
                SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
            end
        })

        section:AddButton({Title = "Load config", Callback = function()
            local name = SaveManager.Options.SaveManager_ConfigList.Value

            local success, err = self:Load(name)
            if not success then
                return self.Library:Notify({
                    Title = "Interface",
                    Content = "Config loader",
                    Description = "Failed to load config: " .. err,
                    Duration = 7
                })
            end

            self.Library:Notify({
                Title = "Interface",
                Content = "Config loader",
                Description = string.format("Loaded config %q", name),
                Duration = 7
            })
        end})

        section:AddButton({Title = "Overwrite config", Callback = function()
            local name = SaveManager.Options.SaveManager_ConfigList.Value

            local success, err = self:Save(name)
            if not success then
                return self.Library:Notify({
                    Title = "Interface",
                    Content = "Config loader",
                    Description = "Failed to overwrite config: " .. err,
                    Duration = 7
                })
            end

            self.Library:Notify({
                Title = "Interface",
                Content = "Config loader",
                Description = string.format("Overwrote config %q", name),
                Duration = 7
            })
        end})

        section:AddButton({Title = "Refresh list", Callback = function()
            SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
        end})

        local AutoloadButton
        AutoloadButton = section:AddButton({Title = "Set as autoload", Description = "Current autoload config: none", Callback = function()
            local name = SaveManager.Options.SaveManager_ConfigList.Value
            exploitEnv.writefile(self.Folder .. "/settings/autoload.txt", name)
            AutoloadButton:SetDesc("Current autoload config: " .. name)
            self.Library:Notify({
                Title = "Interface",
                Content = "Config loader",
                Description = string.format("Set %q to auto load", name),
                Duration = 7
            })
        end})

        if exploitEnv.isfile(self.Folder .. "/settings/autoload.txt") then
            local name = exploitEnv.readfile(self.Folder .. "/settings/autoload.txt")
            AutoloadButton:SetDesc("Current autoload config: " .. name)
        end

        SaveManager:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
    end

    SaveManager:BuildFolderTree()
    Library.SaveManager = SaveManager
end

local InterfaceManager = {} do
    InterfaceManager.Folder = "KeyForgeSettings"
    InterfaceManager.Settings = {
        Theme = "Default",
        Acrylic = false,
        Transparency = false,
        MenuKeybind = "RightControl"
    }
    InterfaceManager.Library = Library

    function InterfaceManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function InterfaceManager:SetLibrary(library)
        self.Library = library
    end

    function InterfaceManager:BuildFolderTree()
        if not exploitEnv.isfolder(self.Folder) then exploitEnv.makefolder(self.Folder) end
    end

    function InterfaceManager:SaveSettings()
        exploitEnv.writefile(self.Folder .. "/options.json", HttpService:JSONEncode(self.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if exploitEnv.isfile(path) then
            local data = exploitEnv.readfile(path)
            local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)
            if success then
                for i, v in next, decoded do
                    self.Settings[i] = v
                end
            end
        end
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")
        local Library = self.Library
        local Settings = self.Settings

        self:LoadSettings()

        local section = tab:AddSection("Interface")

        local themeList = {}
        for name in pairs(ThemeManager.BuiltInThemes) do themeList[#themeList+1] = name end

        local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
            Title = "Theme",
            Description = "Changes the interface theme.",
            Values = themeList,
            Default = Settings.Theme,
            Callback = function(Value)
                ThemeManager:ApplyTheme(Value)
                Settings.Theme = Value
                self:SaveSettings()
            end
        })

        InterfaceTheme:SetValue(Settings.Theme)
    
        section:AddToggle("TransparentToggle", {
            Title = "Transparency",
            Description = "Makes the interface transparent.",
            Default = Settings.Transparency,
            Callback = function(Value)
                if Library.Window then
                    TweenService:Create(Library.Window.Background, TweenInfo.new(0.5), {BackgroundTransparency = Value and 0.5 or 0}):Play()
                end
                Settings.Transparency = Value
                self:SaveSettings()
            end
        })
    
        local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
        MenuKeybind:OnChanged(function()
            Settings.MenuKeybind = MenuKeybind.Value
            self:SaveSettings()
        end)
        Library.MinimizeKeybind = MenuKeybind
    end
    
    Library.InterfaceManager = InterfaceManager
end

function Library:ApplySaveManager(tab)
    SaveManager:BuildConfigSection(tab)
end

function Library:ApplyInterfaceManager(tab)
    InterfaceManager:BuildInterfaceSection(tab)
end

function Library:ApplyThemeManager(tab)
    InterfaceManager:BuildInterfaceSection(tab)
end


-- Update existing elements to track in Options/Toggles (minimal integration due to existing structure)
-- Note: Full integration would require modifying all element creation to register with Library.Options/Toggles

-- Warning Box System
function elementHandler:WarningBox(titleText: string, descriptionText: string, warningType: string?): table
    local warningBox = setmetatable({}, labelHandler)
    local warningInstance = originalElements.Label:Clone()
    warningInstance.Name = "WarningBox"

    -- Set warning colors based on type
    local warningColors = {
        Warning = Color3.fromRGB(255, 193, 7),  -- Yellow for warnings
        Error = Color3.fromRGB(220, 53, 69),    -- Red for errors
        Info = Library.Scheme.AccentColor,      -- Accent for info
        Success = Color3.fromRGB(25, 135, 84)   -- Green for success
    }

    local backgroundColor = warningColors[warningType or "Info"] or Library.Scheme.AccentColor
    warningInstance.LabelBackground.BackgroundColor3 = backgroundColor

    -- Create title text element
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "WarningTitle"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = titleText or "Warning"
    Library:AddToRegistry(titleLabel, "TextColor3", "FontColor")
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(1, 0, 0, 18)
    titleLabel.Parent = warningInstance.LabelBackground

    -- Create description text element
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "WarningDescription"
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = descriptionText or "Please check your settings."
    Library:AddToRegistry(descLabel, "TextColor3", "FontColor")
    descLabel.TextSize = 13
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Position = UDim2.new(0, 4, 0, 20)
    descLabel.Size = UDim2.new(1, -8, 0, 0)
    descLabel.Parent = warningInstance.LabelBackground

    -- Calculate required height
    local textParams = Instance.new("GetTextBoundsParams")
    textParams.Text = descLabel.Text
    textParams.Font = descLabel.FontFace
    textParams.Size = 13
    textParams.Width = descLabel.AbsoluteSize.X - 8
    local textBounds = TextService:GetTextBoundsAsync(textParams)

    descLabel.Size = UDim2.new(1, -8, 0, math.max(textBounds.Y, 16))
    warningInstance.Size = UDim2.new(1, 0, 0, descLabel.Position.Y.Offset + descLabel.Size.Y.Offset + warningInstance.LabelPadding.PaddingTop.Offset + warningInstance.LabelPadding.PaddingBottom.Offset)

    warningBox.Type = "WarningBox"
    warningBox.IdentifierText = titleText or "Warning"
    warningBox.Instance = warningInstance
    warningBox.GuiToRemove = warningInstance

    if self.Type == "SearchBar" then
        self.ChildedElementsInfo[warningInstance] = warningBox
    end

    warningInstance.Parent = self.ElementToParentChildren

    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.TextColor3 = Library.Scheme.FontColor
    closeButton.TextSize = 16
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 2)
    closeButton.Parent = warningInstance.LabelBackground

    closeButton.MouseButton1Click:Connect(function()
        warningInstance:Destroy()
    end)

    return warningBox
end

-- UI Library for KeyForge
-- This library provides a modular UI system for creating windows, tabs, sections, and various GUI elements in Roblox.
-- It has been refactored from the KeyForge hub script to be a reusable library, making script development easier by providing pre-built UI components.
-- Enhanced with ThemeManager and SaveManager for themes and configurations, plus enhanced features like tooltips and warning boxes.

-- Usage Example:
-- local Library = loadstring(game:HttpGet("https://path/to/library"))()  -- or require your module
-- local win = Library.new("My Script", true, 600, 400)  -- Create a window
-- local tab = win:Tab("Main", "rbxassetid://icon")  -- Add a tab
-- local sec = tab:Section("Features")  -- Add a section
-- sec:Toggle("Enable Feature", false, function(state) print("Toggle:", state) end)  -- Add elements like toggles, buttons, sliders, etc.
--
-- This abstraction allows developers to quickly build intuitive UIs without handling low-level GUI creation, promoting cleaner and more maintainable code.

return Library
