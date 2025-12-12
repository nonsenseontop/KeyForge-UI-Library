_G.JxereasExistingHooks = _G.JxereasExistingHooks or {}
if not _G.JxereasExistingHooks.GuiDetectionBypass then
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
    old = hookfunc(ContentProvider.PreloadAsync, function(self, tbl, cb)
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
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

for _, connection in pairs(getconnections(player.Idled)) do
	if connection.Enabled then
    	connection:Disable()
    end
end


local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local sharedKeyForgeEnv = getgenv and getgenv() or _G

local forcedMobilePreference = rawget(sharedKeyForgeEnv, "__KF_FORCE_MOBILE")
local mouse = player:GetMouse()
local viewPortSize = workspace.CurrentCamera.ViewportSize
local isMobileClient = forcedMobilePreference
if isMobileClient == nil then
	local touchOnly = UserInputService.TouchEnabled
	isMobileClient = touchOnly and not GuiService:IsTenFootInterface()
end

local LocalPlayer = player
local Mouse = mouse

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
colorWheelHandler.__index = function(_, i) return rawget(colorWheelHandler, i) or rawget(elementHandler, i) end

local loader_config = {
    LoaderName = "KeyForge Hub",
    HeaderColor = {31, 31, 31},
    AccentColor = {0, 170, 255},
    BackgroundColor = {12, 12, 12}
}

local function rgb(values)
    return Color3.fromRGB(values[1], values[2], values[3])
end

local theme = {
    background = rgb(loader_config.BackgroundColor),
    header = rgb(loader_config.HeaderColor),
    accent = rgb(loader_config.AccentColor),
    accentGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 57, 73)),
        ColorSequenceKeypoint.new(0.495, Color3.fromRGB(38, 81, 103)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 57, 73))
    },
    panel = Color3.fromRGB(15, 15, 17),
    panelInset = Color3.fromRGB(21, 21, 21),
    stroke = Color3.fromRGB(43, 43, 43),
    text = Color3.fromRGB(168, 168, 168),
    mutedText = Color3.fromRGB(132, 132, 132),
    placeholder = Color3.fromRGB(100, 100, 100),
    icon = Color3.fromRGB(133, 133, 133)
}

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

local function createOriginialElements()


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
		local pageLogo = Instance.new("ImageLabel")
		
		screenGui.Name = "KeyForge"
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.IgnoreGuiInset = true
		
		background.Name = "Background"
		background.Parent = screenGui
		background.AnchorPoint = Vector2.new(0.5, 0.5)
		background.BackgroundColor3 = theme.background
		background.BorderSizePixel = 0
		background.ClipsDescendants = true
		background.Position = UDim2.new(0.5, 0, 0.5, 0)
		background.Size = UDim2.new(0.5, 0, 0.600000024, 0)

		backgroundAspectRatioConstraint.Name = "BackgroundUIAspectRatioConstraint"
		backgroundAspectRatioConstraint.Parent = background
		backgroundAspectRatioConstraint.AspectRatio = 1.531
		
		backgroundUICorner.Name = "BackgroundUICorner"
		backgroundUICorner.Parent = background
		
		pagesFolder.Name = "Pages"
		pagesFolder.Parent = background
		
		heading.Name = "Heading"
		heading.Parent = background
		heading.BackgroundColor3 = theme.header
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
		plus.ImageColor3 = theme.text
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
		minus.Image = "rbxassetid://12187365364"
		minus.ImageColor3 = theme.text
		
		minusAspect.Name = "MinusAspect"
		minusAspect.Parent = minus
		
		close.Name = "Close"
		close.Parent = buttonHolder
		close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		close.BackgroundTransparency = 1.000
		close.BorderSizePixel = 0
		close.Size = UDim2.new(1, 0, 0.5, 0)
		close.AutoButtonColor = false
		close.Image = "rbxassetid://12187365364"
		close.ImageRectOffset = Vector2.new(48, 0)
		close.ImageRectSize = Vector2.new(20, 20)
		close.ImageColor3 = theme.text

		closeAspect.Name = "CloseAspect"
		closeAspect.Parent = close

		headingCornerHiding.Name = "HeadingCornerHiding"
		headingCornerHiding.Parent = heading
		headingCornerHiding.AnchorPoint = Vector2.new(0, 1)
		headingCornerHiding.BackgroundColor3 = theme.header
		headingCornerHiding.BorderSizePixel = 0
		headingCornerHiding.Position = UDim2.new(0, 0, 1, 0)
		headingCornerHiding.Size = UDim2.new(1, 0, 0.25, 0)

		headingSeperator.Name = "HeadingSeperator"
		headingSeperator.Parent = heading
		headingSeperator.AnchorPoint = Vector2.new(0, 1)
		headingSeperator.BackgroundColor3 = theme.accent
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
		title.TextColor3 = theme.text
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
		tabs.BackgroundColor3 = theme.header
		tabs.BorderSizePixel = 0
		tabs.Position = UDim2.new(0, 5, 1, -5)
		tabs.Size = UDim2.new(0.225, 0, 1, -15)
		tabs.ScrollBarThickness = 0

		tabsUIListLayout.Name = "TabsUIListLayout"
		tabsUIListLayout.Parent = tabs
		tabsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabsUIListLayout.Padding = UDim.new(0, 5)
		
		pageLogo.Name = "PageLogo"
		pageLogo.AnchorPoint = Vector2.new(1, 1)
		pageLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		pageLogo.BackgroundTransparency = 1.000
		pageLogo.BorderSizePixel = 0
		pageLogo.Position = UDim2.new(1, -10, 1, -5)
		pageLogo.Size = UDim2.new(0.774999976, -25, 1, -15)
		pageLogo.ZIndex = 0
		pageLogo.Image = "rbxassetid://12187365364"
		pageLogo.ImageColor3 = theme.icon
		pageLogo.ImageTransparency = 1
		pageLogo.Parent = holder

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
		tab.BackgroundColor3 = theme.panelInset
		tab.BackgroundTransparency = 1.000
		tab.BorderSizePixel = 0
		tab.Size = UDim2.new(1, 0, 0, 27.5)
		tab.AutoButtonColor = false
		tab.Font = Enum.Font.SourceSans
		tab.Text = ""
		tab.TextColor3 = theme.mutedText
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
		tabText.TextColor3 = theme.mutedText
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
		tabImage.Image = "rbxassetid://12187365364"
		tabImage.ImageColor3 = theme.icon

		tabAspectRatioConstraint.Parent = tabImage

		tabSeperator.Name = "TabSeperator"
		tabSeperator.Parent = tab
		tabSeperator.BackgroundColor3 = theme.accent
		tabSeperator.BackgroundTransparency = 0
		tabSeperator.BorderColor3 = theme.stroke
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
		page.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
		page.BackgroundTransparency = 1.000
		page.BorderSizePixel = 0
		page.Position = UDim2.new(1, -10, 1, -5)
		page.Visible = false
		page.Size = UDim2.new(.775,-25,0,0)

		leftScrollingFrame.Name = "LeftScrollingFrame"
		leftScrollingFrame.Active = true
		leftScrollingFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
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
		rightScrollingFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 43)
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
		section.BackgroundColor3 = theme.panel
		section.BorderSizePixel = 0
		section.Size = UDim2.new(1, 0, 0, 200)
		section.ClipsDescendants = true

		heading.Name = "Heading"
		heading.Parent = section
		heading.BackgroundColor3 = theme.panelInset
		heading.BorderSizePixel = 0
		heading.Size = UDim2.new(1, 0, 0, 22)

		headingSeperator.Name = "HeadingSeperator"
		headingSeperator.Parent = heading
		headingSeperator.AnchorPoint = Vector2.new(0, 1)
		headingSeperator.BackgroundColor3 = theme.accent
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
		title.TextColor3 = theme.text
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
		resizeButton.Image = "rbxassetid://12187365364"
		resizeButton.ImageColor3 = theme.text
		
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
		titleText.BackgroundColor3 = theme.panel
		titleText.BorderSizePixel = 0
		titleText.Position = UDim2.new(0.5, 0, 0, 0)
		titleText.Size = UDim2.new(0.200000003, 0, 1, 0)
		titleText.ZIndex = 2
		titleText.Font = Enum.Font.GothamMedium
		titleText.TextColor3 = theme.text
		titleText.Text = "N/A"
		titleText.TextSize = 14.000

		design.Name = "Design"
		design.Parent = title
		design.AnchorPoint = Vector2.new(0, 0.5)
		design.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		design.BorderSizePixel = 0
		design.Position = UDim2.new(0, 0, 0.5, 0)
		design.Size = UDim2.new(1, 0, 0.25, 0)

		designGradient.Color = theme.accentGradient
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
		label.BackgroundColor3 = theme.panelInset
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
		labelBackground.BackgroundColor3 = theme.stroke
		labelBackground.BorderSizePixel = 0
		labelBackground.Size = UDim2.new(1, 0, 1, 0)

		labelText.Name = "LabelText"
		labelText.Parent = labelBackground
		labelText.AnchorPoint = Vector2.new(0.5, 0)
		labelText.BackgroundColor3 = theme.panel
		labelText.BorderSizePixel = 0
		labelText.Position = UDim2.new(0.5, 0, 0, 0)
		labelText.Size = UDim2.new(1, 0, 1, 0)
		labelText.ZIndex = 2
		labelText.Font = Enum.Font.GothamMedium
		labelText.TextColor3 = theme.text
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
		toggleText.TextColor3 = theme.text
		toggleText.TextSize = 14.000
		toggleText.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = toggle
		boxBackground.BackgroundColor3 = theme.stroke
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
		innerBox.BackgroundColor3 = theme.panel
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
		centerBox.BackgroundColor3 = theme.panelInset
		centerBox.BorderSizePixel = 0
		centerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
		centerBox.Size = UDim2.new(1, 0, 1, 0)

		toggleImage.Name = "ToggleImage"
		toggleImage.Parent = centerBox
		toggleImage.AnchorPoint = Vector2.new(0.5, 0.5)
		toggleImage.BackgroundColor3 = theme.accent
		toggleImage.BackgroundTransparency = 0
		toggleImage.BorderSizePixel = 0
		toggleImage.Position = UDim2.new(0.5, 0, 0.5, 0)
		toggleImage.Image = "rbxassetid://12187365364"
		toggleImage.ImageColor3 = theme.panel
		
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
		buttonText.TextColor3 = theme.text
		buttonText.TextSize = 14.000
		buttonText.TextXAlignment = Enum.TextXAlignment.Left

		circleBackground.Name = "CircleBackground"
		circleBackground.Parent = button
		circleBackground.BackgroundColor3 = theme.stroke
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
		innerCircle.BackgroundColor3 = theme.panel
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
		centerCircle.BackgroundColor3 = theme.panelInset
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
		buttonCircle.BackgroundColor3 = theme.accent
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
		dropdownButton.BackgroundColor3 = theme.stroke
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
		buttonBackground.BackgroundColor3 = theme.panel
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
		dropdownText.TextColor3 = theme.text
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
		dropdownImage.Image = "rbxassetid://12187365364"
		dropdownImage.ImageColor3 = theme.text

		imageAspect.Name = "ImageAspect"
		imageAspect.Parent = dropdownImage

		buttonInnerBackground.Name = "ButtonInnerBackground"
		buttonInnerBackground.Parent = buttonBackground
		buttonInnerBackground.BackgroundColor3 = theme.panelInset
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
		elementHolder.BackgroundColor3 = theme.stroke
		elementHolder.BorderSizePixel = 0
		elementHolder.Position = UDim2.new(0, 0, 0, 18)
		elementHolder.Size = UDim2.new(0.925000012, 0, 0, 0)
		elementHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
		elementHolder.ScrollBarThickness = 0

		elementHolderBackground.Name = "ElementHolderBackground"
		elementHolderBackground.Parent = elementHolder
		elementHolderBackground.BackgroundColor3 = theme.panel
		elementHolderBackground.BorderSizePixel = 0
		elementHolderBackground.Size = UDim2.new(1, 0, 1, 0)

		elementHolderInnerBackground.Name = "ElementHolderInnerBackground"
		elementHolderInnerBackground.Parent = elementHolderBackground
		elementHolderInnerBackground.BackgroundColor3 = theme.panelInset
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
		numberText.PlaceholderColor3 = theme.placeholder
		numberText.PlaceholderText = ""
		numberText.Text = "0"
		numberText.TextColor3 = theme.text
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
		sliderText.TextColor3 = theme.text
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
		sliderBackground.BackgroundColor3 = theme.stroke
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
		sliderInnerBackground.BackgroundColor3 = theme.panel
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
		emptySliderBackground.BackgroundColor3 = theme.panelInset
		emptySliderBackground.BorderSizePixel = 0
		emptySliderBackground.Size = UDim2.new(1, 0, 1, 0)
		emptySliderBackground.ZIndex = 0

		slider.Name = "Slider"
		slider.Parent = sliderInnerBackground
		slider.BackgroundColor3 = theme.accent
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
		searchBarFrame.BackgroundColor3 = theme.stroke
		searchBarFrame.BorderSizePixel = 0
		searchBarFrame.Size = UDim2.new(1, 0, 0, 18)

		buttonBackgroundPadding.Name = "ButtonBackgroundPadding"
		buttonBackgroundPadding.Parent = searchBarFrame
		buttonBackgroundPadding.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonBackgroundPadding.BackgroundColor3 = theme.panel
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
		searchBox.BackgroundColor3 = theme.panelInset
		searchBox.BackgroundTransparency = 1
		searchBox.BorderSizePixel = 0
		searchBox.Size = UDim2.new(1, 0, 1, 0)
		searchBox.Font = Enum.Font.Gotham
		searchBox.PlaceholderColor3 = theme.placeholder
		searchBox.PlaceholderText = "N/A"
		searchBox.Text = ""
		searchBox.TextColor3 = theme.text
		searchBox.TextSize = 14.000
		searchBox.TextXAlignment = Enum.TextXAlignment.Left

		searchBoxPadding.Name = "SearchBoxPadding"
		searchBoxPadding.Parent = searchBox
		searchBoxPadding.PaddingLeft = UDim.new(0, 4)
		
		searchBoxBackground.Name = "SearchBoxBackground"
		searchBoxBackground.Parent = buttonBackgroundPadding
		searchBoxBackground.BackgroundColor3 = theme.panelInset
		searchBoxBackground.BorderSizePixel = 0
		searchBoxBackground.Size = UDim2.new(1, 0, 1, 0)
		searchBoxBackground.ZIndex = 0
		
		searchImage.Name = "SearchImage"
		searchImage.Parent = buttonBackgroundPadding
		searchImage.AnchorPoint = Vector2.new(1, 0.5)
		searchImage.BackgroundColor3 = theme.panelInset
		searchImage.BackgroundTransparency = 1
		searchImage.BorderSizePixel = 0
		searchImage.Position = UDim2.new(1, 0, 0.5, 0)
		searchImage.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
		searchImage.Image = "rbxassetid://12187365364"
		searchImage.ImageColor3 = theme.text

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
		elementHolder.BackgroundColor3 = theme.stroke
		elementHolder.BorderSizePixel = 0
		elementHolder.Position = UDim2.new(0, 0, 0, 18)
		elementHolder.Size = UDim2.new(0.925000012, 0, 0, 0)
		elementHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
		elementHolder.ScrollBarThickness = 0

		elementHolderBackground.Name = "ElementHolderBackground"
		elementHolderBackground.Parent = elementHolder
		elementHolderBackground.BackgroundColor3 = theme.panel
		elementHolderBackground.BorderSizePixel = 0
		elementHolderBackground.Size = UDim2.new(1, 0, 1, 0)

		elementHolderInnerBackground.Name = "ElementHolderInnerBackground"
		elementHolderInnerBackground.Parent = elementHolderBackground
		elementHolderInnerBackground.BackgroundColor3 = theme.panelInset
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
		keybindText.TextColor3 = theme.text
		keybindText.TextSize = 14.000
		keybindText.ClipsDescendants = true
		keybindText.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = keybind
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		boxBackground.BackgroundColor3 = theme.stroke
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
		innerBox.BackgroundColor3 = theme.panel
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
		keyText.BackgroundColor3 = theme.panelInset
		keyText.BorderSizePixel = 0
		keyText.Size = UDim2.new(1, 0, 1, 0)
		keyText.Font = Enum.Font.Gotham
		keyText.Text = "N/A"
		keyText.TextColor3 = theme.text
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
		textBoxNameText.TextColor3 = theme.text
		textBoxNameText.TextSize = 14.000
		textBoxNameText.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = textBox
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		boxBackground.BackgroundColor3 = theme.stroke
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
		innerBox.BackgroundColor3 = theme.panel
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
		textBoxText.BackgroundColor3 = theme.panelInset
		textBoxText.BorderSizePixel = 0
		textBoxText.ClipsDescendants = true
		textBoxText.Size = UDim2.new(1, 0, 1, 0)
		textBoxText.Font = Enum.Font.Gotham
		textBoxText.PlaceholderColor3 = theme.placeholder
		textBoxText.PlaceholderText = "Type here..."
		textBoxText.Text = ""
		textBoxText.TextXAlignment = Enum.TextXAlignment.Left
		textBoxText.TextColor3 = theme.text
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
		colorWheelName.TextColor3 = theme.text
		colorWheelName.TextSize = 14.000
		colorWheelName.TextXAlignment = Enum.TextXAlignment.Left

		boxBackground.Name = "BoxBackground"
		boxBackground.Parent = heading
		boxBackground.AnchorPoint = Vector2.new(1, 0)
		boxBackground.BackgroundColor3 = theme.stroke
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
		innerBox.BackgroundColor3 = theme.panel
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
		centerBox.BackgroundColor3 = theme.panelInset
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
		wheelImage.Image = "rbxassetid://12187365364"

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
		dropdownImage.Image = "rbxassetid://12187365364"
		dropdownImage.ImageColor3 = theme.text

		dropdownButtonAspect.Name = "DropdownButtonAspect"
		dropdownButtonAspect.Parent = dropdownImage

		boxBackgroundCorner.Name = "BoxBackgroundCorner"
		boxBackgroundCorner.Parent = boxBackground

		wheelHolder.Name = "WheelHolder"
		wheelHolder.Parent = colorWheel
		wheelHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
		colorText.TextColor3 = theme.text
		colorText.TextSize = 14.000
		colorText.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_2.Name = "BoxBackground"
		boxBackground_2.Parent = red
		boxBackground_2.AnchorPoint = Vector2.new(1, 0)
		boxBackground_2.BackgroundColor3 = theme.stroke
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
		innerBox_2.BackgroundColor3 = theme.panel
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
		colorValue.BackgroundColor3 = theme.panelInset
		colorValue.BorderSizePixel = 0
		colorValue.ClipsDescendants = true
		colorValue.Size = UDim2.new(1, 0, 1, 0)
		colorValue.Font = Enum.Font.Gotham
		colorValue.PlaceholderColor3 = theme.placeholder
		colorValue.Text = "255"
		colorValue.TextColor3 = theme.text
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
		colorText_2.TextColor3 = theme.text
		colorText_2.TextSize = 14.000
		colorText_2.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_3.Name = "BoxBackground"
		boxBackground_3.Parent = green
		boxBackground_3.AnchorPoint = Vector2.new(1, 0)
		boxBackground_3.BackgroundColor3 = theme.stroke
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
		innerBox_3.BackgroundColor3 = theme.panel
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
		colorValue_2.BackgroundColor3 = theme.panelInset
		colorValue_2.BorderSizePixel = 0
		colorValue_2.ClipsDescendants = true
		colorValue_2.Size = UDim2.new(1, 0, 1, 0)
		colorValue_2.Font = Enum.Font.Gotham
		colorValue_2.PlaceholderColor3 = theme.placeholder
		colorValue_2.Text = "255"
		colorValue_2.TextColor3 = theme.text
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
		colorText_3.TextColor3 = theme.text
		colorText_3.TextSize = 14.000
		colorText_3.TextXAlignment = Enum.TextXAlignment.Right

		boxBackground_4.Name = "BoxBackground"
		boxBackground_4.Parent = blue
		boxBackground_4.AnchorPoint = Vector2.new(1, 0)
		boxBackground_4.BackgroundColor3 = theme.stroke
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
		innerBox_4.BackgroundColor3 = theme.panel
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
		colorValue_3.BackgroundColor3 = theme.panelInset
		colorValue_3.BorderSizePixel = 0
		colorValue_3.ClipsDescendants = true
		colorValue_3.Size = UDim2.new(1, 0, 1, 0)
		colorValue_3.Font = Enum.Font.Gotham
		colorValue_3.PlaceholderColor3 = theme.placeholder
		colorValue_3.Text = "255"
		colorValue_3.TextColor3 = theme.text
		colorValue_3.TextSize = 14.000

		colorSample.Name = "ColorSample"
		colorSample.Parent = valueHolder
		colorSample.AnchorPoint = Vector2.new(0, 1)
		colorSample.BackgroundColor3 = theme.panel
		colorSample.BorderSizePixel = 0
		colorSample.Position = UDim2.new(0, 0, 1, -18)
		colorSample.Size = UDim2.new(1, 0, 0, 14)

		colorSampleCorner.CornerRadius = UDim.new(0.25, 0)
		colorSampleCorner.Name = "ColorSampleCorner"
		colorSampleCorner.Parent = colorSample

		valueSlider.Name = "ValueSlider"
		valueSlider.Parent = valueHolder
		valueSlider.AnchorPoint = Vector2.new(0, 1)
		valueSlider.BackgroundColor3 = theme.panel
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
		sliderBar.BackgroundColor3 = theme.accent
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
		wheel.Image = "rbxassetid://12187365364"

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
		selector.Image = "rbxassetid://12187365364"

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

	local function getMatchingKeyCodeFromName(name: string)
		if not name then return end
		for i, keycode in pairs(Enum.KeyCode:GetEnumItems()) do
			if keycode.Name:lower() == name:lower() then
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
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				mouseMovedConnection:Disconnect()
				inputEndedConnection:Disconnect()
			end
		end)
	end

	local function closeWindow()
        local closeWindowTween = TweenService:Create(windowInstance.Background, TweenInfo.new(.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        closeWindowTween.Completed:Connect(function()
            task.wait()
			windowInstance:Destroy() -- add cool tween cause cool
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

	window.Type = "Window"
	window.Instance = windowInstance
	window.GuiToRemove = windowInstance
	window.isConstraintedToScreenBoundaries = constrainToScreen
	window.IsMinimized = false
	window.IsHidden = false
	window.TabInfo = {}
	window.VisibilityKeybind = visibilityKeybind

	heading.MouseButton1Down:Connect(onHeadingMouseDown)
	buttonHolder.Close.MouseButton1Click:Connect(closeWindow)
	buttonHolder.Plus.MouseButton1Click:Connect(maximizeWindow)
	buttonHolder.Minus.MouseButton1Click:Connect(minimizeWindow)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == window.VisibilityKeybind then
				background.Visible = not background.Visible
			end
		end
	end)

	holder.Tabs.TabsUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		holder.Tabs.CanvasSize = UDim2.fromOffset(0,holder.Tabs.TabsUIListLayout.AbsoluteContentSize.Y + holder.Tabs.TabsUIListLayout.Padding.Offset)
	end)

	heading.Title.Text = windowName or "KeyForge"
	windowInstance.Parent = game:GetService("CoreGui") -- Change to core later on and add detection bypass
	background.Size = UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y)
	
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

	local targetWidth = appliedWidth
	local targetHeight = appliedHeight
	if isMobileClient then
		targetWidth = math.clamp(targetWidth, 340, math.max(320, viewPortSize.X - 20))
		targetHeight = math.clamp(targetHeight, 300, math.max(300, viewPortSize.Y - 20))
	end
	background.Size = UDim2.fromOffset(targetWidth, targetHeight)

	holder.PageLogo.Image = backgroundImageId or "rbxassetid://12187365364"
	background.Position = UDim2.new(0, background.AbsolutePosition.X + background.AbsoluteSize.X / 2, 0, background.AbsolutePosition.Y + background.AbsoluteSize.Y / 2 + 36)
	background.BackgroundUIAspectRatioConstraint:Destroy()
	holder.Size = UDim2.new(0,holder.AbsoluteSize.X,0,holder.AbsoluteSize.Y)
	holder.Position = UDim2.new(0,0,0,heading.AbsoluteSize.Y)
	heading.Size = UDim2.new(1,0,0,heading.AbsoluteSize.Y)
	buttonHolder.Size = UDim2.new(0,buttonHolder.ButtonHolderList.AbsoluteContentSize.X + buttonHolder.ButtonHolderPadding.PaddingRight.Offset,.9,0)
	heading.Title.Size = UDim2.new(1,-(buttonHolder.ButtonHolderList.AbsoluteContentSize.X + buttonHolder.ButtonHolderPadding.PaddingRight.Offset + 4),.9,0)
	minimizedLongBarOriginialSize = Vector2.new(heading.AbsoluteSize.X, heading.AbsoluteSize.Y)
	minimizedShortBarOriginialSize = Vector2.new(heading.AbsoluteSize.X / 6 * 2, heading.AbsoluteSize.Y)
	originialWindowSize = background.AbsoluteSize
	
	if isMobileClient then
		holder.Tabs.Size = UDim2.new(0.3, 0, 1, -20)
		holder.Tabs.ScrollBarThickness = 4
		heading.Title.TextSize = 13
	end
	
	return window
end

function windowHandler:LockScreenBoundaries(constrainWindowToScreenBoundaries)
	self.isConstraintedToScreenBoundaries = constrainWindowToScreenBoundaries
end

function windowHandler:SetVisibilityKeybind(newKeyCode)
	if typeof(newKeyCode) == "EnumItem" and newKeyCode.EnumType == Enum.KeyCode then
		self.VisibilityKeybind = newKeyCode
	end
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
	local logoShowTween = TweenService:Create(self.Instance.Background.Holder.PageLogo, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = .65})
	local logoHideTween = TweenService:Create(self.Instance.Background.Holder.PageLogo, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1})
	
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

                        pageOpenTween.Completed:Connect(function()
                            if pageOpenTween.PlaybackState == Enum.PlaybackState.Completed then
                                logoHideTween:Play()
                            end
                        end)

                        selfInfo.isQueued = true
                        foundPageCloseTween:Play()
                        foundTabCloseTween:Play()
                        foundTabSeperatorCloseTween:Play()
                        logoShowTween:Play()
                    elseif tabInfo.isQueued then
                        tabInfo.isQueued = false
                    end
                end
            end

            if not State then State = { CurrentTab = nil, Unloaded = false, LastCache = 0, Aiming = false, AimTarget = nil, RainbowHue = 0, ColorPickerOpen = false, RadarPos = nil, RadarDragging = false, RadarDragOffset = Vector2.zero } end
            State.CurrentTab = tabName

            if not isATabOpen then
                selfInfo.isOpen = true
                pageInstance.Visible = true
                pageOpenTween:Play()
                tabOpenTween:Play()
                tabSeperatorOpenTween:Play()
                logoHideTween:Play()
            end
        end

        local function closeTab()
            if not State then State = { CurrentTab = nil, Unloaded = false, LastCache = 0, Aiming = false, AimTarget = nil, RainbowHue = 0, ColorPickerOpen = false, RadarPos = nil, RadarDragging = false, RadarDragOffset = Vector2.zero } end
            selfInfo.isOpen = false
            State.CurrentTab = nil
            tabCloseTween:Play()
            tabSeperatorCloseTween:Play()
            pageCloseTween:Play()
            logoShowTween:Play()
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
	tabInstance.TabImage.Image = tabImage or "rbxassetid://12187365364" -- Add n/a found image here later on

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
	labelInstance.LabelBackground.LabelText.TextColor3 = textColor or theme.text
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

function elementHandler:Toggle(toggleName: string, callback): table
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
	
	toggle.Type = "Toggle"
	toggle.IdentifierText = toggleName or "N/A"
	toggle.Instance = toggleInstance
	toggle.GuiToRemove = toggleInstance
	toggle.Enabled = false
	
	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[toggleInstance] = toggle
	end
	
	callback = callback or function() end
	
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

function elementHandler:Dropdown(dropdownName: string): table
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
	
	dropdown.Type = "Dropdown"
	dropdown.IdentifierText = dropdownName or "N/A"
	dropdown.Instance = dropdownInstance
	dropdown.GuiToRemove = dropdownInstance
	dropdown.ElementToParentChildren = dropdownInstance.ElementHolder.ElementHolderBackground.ElementHolderInnerBackground
	dropdown.IsExpanded = false
	
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
	local isMouseDown = false
	local sliderBar = sliderInstance.SliderBackground.SliderInnerBackground.Slider
	local minimumClosePixelsLeft = 2
	local textPixelOffset = 2
	local absPos
	local absSize

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
	
	local sliderConnection
	local endInputConnection

	callback = callback or function() end
	
	local function onMouseDown()
		local function onMouseMoved()
			local absPos = sliderBar.AbsolutePosition
			local absSize = sliderBar.Parent.EmptySliderBackground.AbsoluteSize

			if mouse.X < absPos.X then
				sliderBar.Size = UDim2.new(0,minimumClosePixelsLeft,1,0)
				sliderValue = minimumValue
			elseif mouse.X > absPos.X + absSize.X then
				sliderBar.Size = UDim2.new(1,0,1,0)
				sliderValue = maximumValue
			else
				local percentOfBarFilled = (mouse.X - absPos.X) / absSize.X
				sliderBar.Size = UDim2.new(0,math.max(minimumClosePixelsLeft, mouse.X - absPos.X),1,0)
				sliderValue = minimumValue + (maxMinRange * percentOfBarFilled)
			end
			
			sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
			callback(sliderValue)
		end
		
		onMouseMoved()
		sliderConnection = mouse.Move:Connect(onMouseMoved)
		
		endInputConnection = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				sliderConnection:Disconnect()
				endInputConnection:Disconnect()
			end
		end)
	end
	
	local function onFocusLost(enterPressed)
		if enterPressed then
			local enteredNum = tonumber(sliderInstance.TextGrouping.NumberText.Text)
			if typeof(enteredNum) == "number" and enteredNum >= minimumValue and enteredNum <= maximumValue then
				local absPos = sliderBar.AbsolutePosition
				local absSize = sliderBar.Parent.EmptySliderBackground.AbsoluteSize
				local percentOfBarFilled = enteredNum / absSize.X
				sliderValue = enteredNum
				sliderInstance.TextGrouping.NumberText.Text = math.round(sliderValue)
				sliderBar.Size = UDim2.new((sliderValue - minimumValue) / maxMinRange,0,1,0)
				callback(sliderValue)
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
	
	slider.Type = "Slider"
	slider.IdentifierText = sliderName or "N/A"
	slider.Instance = sliderInstance
	slider.GuiToRemove = sliderInstance
	
	if self.Type == "SearchBar" then
		self.ChildedElementsInfo[sliderInstance] = slider
	end
	
	sliderInstance.SliderBackground.MouseButton1Down:Connect(onMouseDown)
	sliderInstance.TextGrouping.NumberText.FocusLost:Connect(onFocusLost)
	
	sliderInstance.TextGrouping.SliderText.Text = sliderName or "N/A"
	sliderInstance.TextGrouping.NumberText.Text = minimumValue
	sliderInstance.TextGrouping.NumberText.Size = UDim2.new(0,math.max(requiredErrorTextSpace.X, requiredNumberTextSpace.X) + textPixelOffset,1,0)
	
	sliderInstance.Parent = self.ElementToParentChildren
	sliderInstance.TextGrouping.SliderText.Size = UDim2.new(0, sliderInstance.TextGrouping.AbsoluteSize.X - textPixelOffset - requiredNumberTextSpace.X, 1, 0)
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
	
	local function getMatchingKeyCodeFromName(name: string)
		if not name then return end
		for i, keycode in pairs(Enum.KeyCode:GetEnumItems()) do
			if keycode.Name:lower() == name:lower() then
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
function elementHandler:ColorWheel(colorWheelName: string, callback): table
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
	local wheelRadius
	
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
	
	local hue, saturation, value = 0, 0, 1
	
	local function updateVisuals()
		local color = Color3.fromHSV(hue, saturation, value)
		
		valueHolder.ColorSample.BackgroundColor3 = color
		colorInputHolder.Red.BoxBackground.InnerBox.ColorValue.Text = math.round(color.R * 255)
		colorInputHolder.Green.BoxBackground.InnerBox.ColorValue.Text = math.round(color.G * 255)
		colorInputHolder.Blue.BoxBackground.InnerBox.ColorValue.Text = math.round(color.B * 255)
		callback(color)
	end
	
	local function updateSlider()
		local sliderAbsPos = slider.AbsolutePosition
		local sliderAbsSize = slider.AbsoluteSize

		if mouse.X - sliderAbsPos.X <= 0 then
			sliderBar.Position = UDim2.new(0,0,0,0)
		elseif mouse.X - sliderAbsPos.X >= sliderAbsSize.X - sliderBar.AbsoluteSize.X then
			sliderBar.Position = UDim2.new(1,-(sliderBar.AbsoluteSize.X),0,0)
		else
			sliderBar.Position = UDim2.new(0,mouse.X - sliderAbsPos.X,0,0)
		end
		
		local clampedMousePos = math.clamp(mouse.X - sliderAbsPos.X, 0, sliderAbsSize.X - sliderBar.AbsoluteSize.X)
		value = clampedMousePos / (sliderAbsSize.X - sliderBar.AbsoluteSize.X)

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

		hue, saturation = (math.deg(angle) + 180) / 360 , radius / wheelRadius

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
			
			local x, y = toCartesian(saturation, math.rad(hue * 360))
			
			selector.Position = UDim2.new(.5, -x * wheelRadius, .5, y * wheelRadius)
			
			updateVisuals()
		end
		
	end
	
	colorWheelName = colorWheelName or "N/A"
	callback = callback or function() end
	
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
	
	wheelRadius = wheel.AbsoluteSize.X / 2
	
	return colorWheel
end

createOriginialElements()
-- Frontlines core systems
local Config = {
    ESP_Enabled = true,
    ESP_Box = true,
    ESP_BoxStyle = "Full",
    ESP_BoxFill = false,
    ESP_Name = true,
    ESP_Distance = true,
    ESP_Tracer = false,
    ESP_TracerOrigin = "Bottom",
    ESP_Snapline = false,
    ESP_LookDirection = false,
    ESP_Velocity = false,
    ESP_Offscreen = true,
    ESP_DeadCheck = true,
    ESP_MaxDist = 1500,
    ESP_Chams = false,
    ESP_ChamsStyle = "Solid",
    ESP_Heatmap = false,
    ESP_TeamCheck = true,
    ESP_Rainbow = false,
    ESP_CustomColor = Color3.fromRGB(220, 60, 60),  
    
    AIM_Enabled = false,
    AIM_Key = Enum.UserInputType.MouseButton2,
    AIM_FOV = 250,
    AIM_Smooth = 0.12,
    AIM_ShowFOV = true,
    AIM_TargetPart = "Auto",
    AIM_TeamCheck = true,
    AIM_ProximityPriority = 0.3,
    AIM_StickyFactor = 1.2,  
    
    MISC_NoRecoil = false,
    MISC_NoSway = false,
    MISC_NoSpread = false,
    MISC_NoCamShake = false,
    MISC_MenuColor = Color3.fromRGB(220, 60, 60),
    MISC_FullBright = false,
    
    MENU_Open = true,
    MENU_Tab = 1,
    KEY_Menu = Enum.KeyCode.Insert,
    KEY_Panic = Enum.KeyCode.Home
}

local Tuning = {
    CacheRate = 1.5,
    
    BoxRatio = 0.55,
    NameOffset = 16,
    DistOffset = 4,
    CornerLen = 8,
    
    OffscreenEdge = 45,
    OffscreenSize = 10,
    
    RadarDotSize = 4,
    RadarArrowSize = 7,
    
    HeatmapNear = 20,
    HeatmapFar = 100,
    
    PreviewBoxW = 90,
    PreviewBoxH = 150
}

local Palette = {
    Enemy = Color3.fromRGB(220, 60, 60),
    Dead = Color3.fromRGB(90, 90, 95),
    Friendly = Color3.fromRGB(100, 160, 255),
    Tracer = Color3.fromRGB(255, 120, 80),
    Snapline = Color3.fromRGB(180, 180, 220),
    LookDirection = Color3.fromRGB(255, 220, 80),
    Velocity = Color3.fromRGB(0, 220, 255),
    Offscreen = Color3.fromRGB(255, 200, 80),
    HeatNear = Color3.fromRGB(255, 40, 40),
    HeatFar = Color3.fromRGB(40, 40, 255),

    RadarBg = Color3.fromRGB(15, 15, 18),
    RadarBorder = Color3.fromRGB(220, 60, 60),
    RadarGrid = Color3.fromRGB(35, 35, 40),
    RadarYou = Color3.fromRGB(80, 255, 120),

    MenuBg = Color3.fromRGB(14, 14, 18),
    MenuPanel = Color3.fromRGB(20, 20, 26),
    MenuBorder = Color3.fromRGB(40, 40, 50),
    MenuAccent = Color3.fromRGB(220, 60, 60),
    MenuAccentDim = Color3.fromRGB(160, 45, 45),
    MenuText = Color3.fromRGB(220, 220, 225),
    MenuTextDim = Color3.fromRGB(110, 110, 120),
    MenuOn = Color3.fromRGB(80, 220, 100),
    MenuOff = Color3.fromRGB(55, 55, 65),
    MenuTab = Color3.fromRGB(18, 18, 22),
    MenuTabActive = Color3.fromRGB(220, 60, 60),
    MenuScrollbar = Color3.fromRGB(220, 60, 60),

    PreviewBg = theme.panel,
    PreviewBorder = theme.stroke
}

State = State or {
    Unloaded = false,
    LastCache = 0,
    Aiming = false,
    AimTarget = nil,
    RainbowHue = 0,
    ColorPickerOpen = false,
    RadarPos = nil,
    RadarDragging = false,
    RadarDragOffset = Vector2.zero,
    CurrentTab = nil
}

local Cache = {
    Soldiers = {},
    Chams = {}
}


local DeathTracker = {
    -- [model] = { lastPos, lastMoveTime, wasActive, peakY, isDead, frozenTime, knownWeapons }
}


local WeaponPatterns = {
    "upper_receiver", "lower_receiver", "receiver", "barrel", 
    "magazine", "handguard", "stock", "slide", "pump", "grip",
    "mp5", "m4", "glock", "awm", "vector", "asval", "ebr", "m500", "pp2000", "fix"
}


local function IsWeaponModel(obj)
    if not obj:IsA("Model") then return false, nil end
    if obj.Name == "soldier_model" then return false, nil end
    if obj.Name:find("friendly_marker") then return false, nil end
    
    local weaponPos = nil
    local isWeapon = false
    
    local objNameLower = obj.Name:lower()
    for _, pattern in ipairs(WeaponPatterns) do
        if objNameLower:find(pattern, 1, true) then
            isWeapon = true
            break
        end
    end
    
    
    if not isWeapon then
        for _, child in ipairs(obj:GetChildren()) do
            local childNameLower = child.Name:lower()
            for _, pattern in ipairs(WeaponPatterns) do
                if childNameLower:find(pattern, 1, true) then
                    isWeapon = true
                    if child:IsA("BasePart") then
                        weaponPos = child.Position
                    elseif child:IsA("Model") then
                        local part = child:FindFirstChildWhichIsA("BasePart", true)
                        if part then weaponPos = part.Position end
                    end
                    break
                end
            end
            if isWeapon then break end
        end
    end
    
    
    if isWeapon and not weaponPos then
        if obj.PrimaryPart then
            weaponPos = obj.PrimaryPart.Position
        else
            local part = obj:FindFirstChildWhichIsA("BasePart", true)
            if part then weaponPos = part.Position end
        end
    end
    
    return isWeapon, weaponPos
end


local function GetWeaponsNearby(position, radius)
    local weapons = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        local isWeapon, weaponPos = IsWeaponModel(obj)
        if isWeapon and weaponPos then
            local dist = (weaponPos - position).Magnitude
            if dist < radius then
                weapons[obj] = true
            end
        end
    end
    return weapons
end


local function HasNewWeaponNearby(position, knownWeapons, radius)
    for _, obj in ipairs(Workspace:GetChildren()) do
        local isWeapon, weaponPos = IsWeaponModel(obj)
        if isWeapon and weaponPos then
            local dist = (weaponPos - position).Magnitude
            if dist < radius and not knownWeapons[obj] then
                return true  
            end
        end
    end
    return false
end

local function IsModelDead(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local pos = root.Position
    local now = tick()
    
    if not DeathTracker[model] then
        DeathTracker[model] = {
            lastPos = pos,
            lastMoveTime = now,
            wasActive = false,
            isDead = false,
            frozenTime = 0,
            knownWeapons = GetWeaponsNearby(pos, 10),
            lastWeaponCheck = now
        }
        return false
    end
    
    local data = DeathTracker[model]
    local delta = (pos - data.lastPos)
    local horizontalDelta = Vector3.new(delta.X, 0, delta.Z).Magnitude
    local verticalDelta = math.abs(delta.Y)
    
    local isMoving = horizontalDelta > 0.08 or verticalDelta > 0.15
    
    if isMoving then
        data.lastMoveTime = now
        data.wasActive = true
        data.frozenTime = 0
        data.knownWeapons = GetWeaponsNearby(pos, 10)
        data.lastWeaponCheck = now
        
        if data.isDead then
            data.isDead = false
        end
    else
        data.frozenTime = now - data.lastMoveTime
    end
    
    if not data.isDead and data.wasActive then
        if data.frozenTime > 0.1 and data.frozenTime < 3.0 then
            if now - data.lastWeaponCheck > 0.05 then
                data.lastWeaponCheck = now
                if HasNewWeaponNearby(pos, data.knownWeapons, 6) then
                    data.isDead = true
                end
            end
        end
    end
    
    data.lastPos = pos
    
    return data.isDead
end

local function CleanupDeathTracker()
    for model, _ in pairs(DeathTracker) do
        if not model or not model.Parent then
            DeathTracker[model] = nil
        end
    end
end

local OriginalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    FogEnd = Lighting.FogEnd
}

local Connections = {}

local function IsFriendly(model)
    return model:FindFirstChild("friendly_marker") ~= nil
end

local function IsLocalPlayer(model)
    
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    
   
    if model == myChar then return true end
    
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local modelRoot = model:FindFirstChild("HumanoidRootPart")
    if myRoot and modelRoot then
        local dist = (myRoot.Position - modelRoot.Position).Magnitude
        if dist < 1 then return true end
    end
    
    return false
end

local function IsEnemy(model)
    if not model:IsA("Model") then return false end
    if model.Name ~= "soldier_model" then return false end
    if IsLocalPlayer(model) then return false end  
    if Config.ESP_TeamCheck and IsFriendly(model) then return false end
    return true
end

local function GetRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
end

local function GetHead(model)
    return model:FindFirstChild("TPVBodyVanillaHead") or model:FindFirstChild("Head")
end

local function GetDistance(pos)
    local char = LocalPlayer.Character
    if not char then return math.huge end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    return (pos - root.Position).Magnitude
end

local function WorldToScreen(pos)
    local cam = Workspace.CurrentCamera
    if not cam then return Vector2.zero, false, 0 end
    local vp, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(vp.X, vp.Y), onScreen and vp.Z > 0, vp.Z
end

local function LerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local function GetHeatmapColor(dist)
    local t = math.clamp((dist - Tuning.HeatmapNear) / (Tuning.HeatmapFar - Tuning.HeatmapNear), 0, 1)
    return LerpColor(Palette.HeatNear, Palette.HeatFar, t)
end


local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    return Color3.new(r, g, b)
end


local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    s = max == 0 and 0 or d / max
    if max ~= min then
        if max == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end


local function GetEspColor()
    if Config.ESP_Rainbow then
        return HSVtoRGB(State.RainbowHue, 1, 1)
    end
    return Config.ESP_CustomColor
end

local ESP = {
    cache = {},
    lastCleanup = 0,
    posCache = {},
    lastPosUpdate = 0,
    velocityData = {}
}

function ESP.Create()
    local box = {}
    for i = 1, 4 do
        box[i] = Drawing.new("Line")
        box[i].Thickness = 1
        box[i].Visible = false
    end
    
    local corners = {}
    for i = 1, 8 do
        corners[i] = Drawing.new("Line")
        corners[i].Thickness = 1
        corners[i].Visible = false
    end
    
    
    local deadX = {}
    for i = 1, 2 do
        deadX[i] = Drawing.new("Line")
        deadX[i].Thickness = 2
        deadX[i].Color = Color3.fromRGB(90, 90, 95)
        deadX[i].Visible = false
    end
    
    local boxFill = Drawing.new("Square")
    boxFill.Filled = true
    boxFill.Visible = false
    boxFill.Transparency = 0.15
    
    local snapline = Drawing.new("Line")
    snapline.Thickness = 1
    snapline.Visible = false
    
    local lookLine = Drawing.new("Line")
    lookLine.Thickness = 2
    lookLine.Visible = false
    
    return {
        Box = box,
        BoxFill = boxFill,
        Corners = corners,
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Snapline = snapline,
        LookLine = lookLine,
        Offscreen = Drawing.new("Triangle"),
        DeadX = deadX,
        VelLine = Drawing.new("Line"),
        VelArrow = Drawing.new("Triangle")
    }
end

function ESP.Setup(esp)
    esp.Name.Size = 13
    esp.Name.Font = Drawing.Fonts.Monospace
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false
    
    esp.Dist.Size = 11
    esp.Dist.Font = Drawing.Fonts.Monospace
    esp.Dist.Center = true
    esp.Dist.Outline = true
    esp.Dist.Color = Color3.fromRGB(170, 170, 170)
    esp.Dist.Visible = false
    
    esp.Tracer.Thickness = 1
    esp.Tracer.Visible = false
    
    esp.BoxFill.Filled = true
    esp.BoxFill.Transparency = 0.15
    esp.BoxFill.Visible = false
    
    esp.Snapline.Thickness = 1
    esp.Snapline.Color = Palette.Snapline
    esp.Snapline.Transparency = 0.5
    esp.Snapline.Visible = false
    
    esp.LookLine.Thickness = 2
    esp.LookLine.Color = Palette.LookDirection
    esp.LookLine.Visible = false
    
    esp.Offscreen.Filled = true
    esp.Offscreen.Visible = false
    
    esp.VelLine.Thickness = 2
    esp.VelLine.Color = Palette.Velocity
    esp.VelLine.Visible = false
    
    esp.VelArrow.Filled = true
    esp.VelArrow.Color = Palette.Velocity
    esp.VelArrow.Visible = false
end

function ESP.Hide(esp)
    if not esp then return end
    for _, l in ipairs(esp.Box) do l.Visible = false end
    if esp.BoxFill then esp.BoxFill.Visible = false end
    for _, l in ipairs(esp.Corners) do l.Visible = false end
    esp.Name.Visible = false
    esp.Dist.Visible = false
    esp.Tracer.Visible = false
    if esp.Snapline then esp.Snapline.Visible = false end
    if esp.LookLine then esp.LookLine.Visible = false end
    esp.Offscreen.Visible = false
    if esp.DeadX then
        for _, l in ipairs(esp.DeadX) do l.Visible = false end
    end
    if esp.VelLine then esp.VelLine.Visible = false end
    if esp.VelArrow then esp.VelArrow.Visible = false end
end

function ESP.Destroy(esp)
    if not esp then return end
    pcall(function()
        for _, l in ipairs(esp.Box) do l:Remove() end
        if esp.BoxFill then esp.BoxFill:Remove() end
        for _, l in ipairs(esp.Corners) do l:Remove() end
        esp.Name:Remove()
        esp.Dist:Remove()
        esp.Tracer:Remove()
        if esp.Snapline then esp.Snapline:Remove() end
        if esp.LookLine then esp.LookLine:Remove() end
        esp.Offscreen:Remove()
        if esp.DeadX then
            for _, l in ipairs(esp.DeadX) do l:Remove() end
        end
        if esp.VelLine then esp.VelLine:Remove() end
        if esp.VelArrow then esp.VelArrow:Remove() end
    end)
end

function ESP.Render(esp, model, cam, screenSize, screenCenter)
    if not esp or not model then return end
    if not cam then return end
    
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root or not root.Parent then
        ESP.Hide(esp)
        return
    end
    
    local isDead = Config.ESP_DeadCheck and IsModelDead(model) or false
    
 
    local rootPos = root.Position
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local dist = myRoot and (rootPos - myRoot.Position).Magnitude or 0
    
    if dist > Config.ESP_MaxDist then
        ESP.Hide(esp)
        return
    end
    
    
    local rs = cam:WorldToViewportPoint(rootPos)
    
   
    if esp.DeadX then
        for _, l in ipairs(esp.DeadX) do l.Visible = false end
    end
    
    if rs.Z <= 0 then
        ESP.Hide(esp)
        if Config.ESP_Offscreen and not isDead then
            local dx = rs.X - screenCenter.X
            local dy = rs.Y - screenCenter.Y
            local angle = math.atan2(dy, dx)
            local edge = Tuning.OffscreenEdge
            local cosA, sinA = math.cos(angle), math.sin(angle)
            local ax = math.clamp(screenCenter.X + cosA * (screenSize.X/2 - edge), edge, screenSize.X - edge)
            local ay = math.clamp(screenCenter.Y + sinA * (screenSize.Y/2 - edge), edge, screenSize.Y - edge)
            local pos = Vector2.new(ax, ay)
            local sz = Tuning.OffscreenSize
            esp.Offscreen.PointA = pos + Vector2.new(cosA * sz, sinA * sz)
            esp.Offscreen.PointB = pos + Vector2.new(-cosA * sz/2 + sinA * sz/2, -sinA * sz/2 - cosA * sz/2)
            esp.Offscreen.PointC = pos + Vector2.new(-cosA * sz/2 - sinA * sz/2, -sinA * sz/2 + cosA * sz/2)
            esp.Offscreen.Color = Palette.Offscreen
            esp.Offscreen.Visible = true
        end
        return
    end
    
    local onScreen = rs.X > -100 and rs.X < screenSize.X + 100 and rs.Y > -100 and rs.Y < screenSize.Y + 100
    
    if not onScreen then
        ESP.Hide(esp)
        return
    end
    
   
    local baseSize = 1200 / math.max(rs.Z, 1)
    local boxHeight = math.clamp(baseSize, 25, screenSize.Y * 0.8)
    local boxWidth = boxHeight * Tuning.BoxRatio
    boxWidth = math.clamp(boxWidth, 15, screenSize.X * 0.5)
    
    local cx = rs.X
    local cy = rs.Y
    local boxTop = cy - boxHeight * 0.55
    local boxBottom = cy + boxHeight * 0.45
    
   
    local baseCol = isDead and Palette.Dead or (Config.ESP_Heatmap and GetHeatmapColor(dist) or GetEspColor())
    
    esp.Offscreen.Visible = false
    
   
    if isDead then
        
        for _, l in ipairs(esp.Box) do l.Visible = false end
        for _, l in ipairs(esp.Corners) do l.Visible = false end
        
        
        if esp.DeadX then
            local xSize = math.min(boxWidth, boxHeight) * 0.4
            local xcx, xcy = cx, cy
            
            esp.DeadX[1].From = Vector2.new(xcx - xSize, xcy - xSize)
            esp.DeadX[1].To = Vector2.new(xcx + xSize, xcy + xSize)
            esp.DeadX[1].Color = Palette.Dead
            esp.DeadX[1].Visible = true
            
            esp.DeadX[2].From = Vector2.new(xcx + xSize, xcy - xSize)
            esp.DeadX[2].To = Vector2.new(xcx - xSize, xcy + xSize)
            esp.DeadX[2].Color = Palette.Dead
            esp.DeadX[2].Visible = true
        end
        
        
        esp.Name.Text = "DEAD"
        esp.Name.Position = Vector2.new(cx, cy - boxHeight * 0.3 - 14)
        esp.Name.Color = Palette.Dead
        esp.Name.Visible = true
        
        
        esp.Dist.Visible = false
        esp.Tracer.Visible = false
        return
    end
    
   
    if Config.ESP_Box then
        if Config.ESP_BoxStyle == "Full" then
            for _, l in ipairs(esp.Corners) do l.Visible = false end
            esp.Box[1].From = Vector2.new(cx - boxWidth/2, boxTop)
            esp.Box[1].To = Vector2.new(cx + boxWidth/2, boxTop)
            esp.Box[2].From = Vector2.new(cx + boxWidth/2, boxTop)
            esp.Box[2].To = Vector2.new(cx + boxWidth/2, boxBottom)
            esp.Box[3].From = Vector2.new(cx + boxWidth/2, boxBottom)
            esp.Box[3].To = Vector2.new(cx - boxWidth/2, boxBottom)
            esp.Box[4].From = Vector2.new(cx - boxWidth/2, boxBottom)
            esp.Box[4].To = Vector2.new(cx - boxWidth/2, boxTop)
            for _, l in ipairs(esp.Box) do
                l.Color = baseCol
                l.Visible = true
            end
        else
            for _, l in ipairs(esp.Box) do l.Visible = false end
            local x1, y1 = cx - boxWidth/2, boxTop
            local x2, y2 = cx + boxWidth/2, boxBottom
            local cl = Tuning.CornerLen
            
            esp.Corners[1].From = Vector2.new(x1, y1)
            esp.Corners[1].To = Vector2.new(x1 + cl, y1)
            esp.Corners[2].From = Vector2.new(x1, y1)
            esp.Corners[2].To = Vector2.new(x1, y1 + cl)
            esp.Corners[3].From = Vector2.new(x2, y1)
            esp.Corners[3].To = Vector2.new(x2 - cl, y1)
            esp.Corners[4].From = Vector2.new(x2, y1)
            esp.Corners[4].To = Vector2.new(x2, y1 + cl)
            esp.Corners[5].From = Vector2.new(x1, y2)
            esp.Corners[5].To = Vector2.new(x1 + cl, y2)
            esp.Corners[6].From = Vector2.new(x1, y2)
            esp.Corners[6].To = Vector2.new(x1, y2 - cl)
            esp.Corners[7].From = Vector2.new(x2, y2)
            esp.Corners[7].To = Vector2.new(x2 - cl, y2)
            esp.Corners[8].From = Vector2.new(x2, y2)
            esp.Corners[8].To = Vector2.new(x2, y2 - cl)
            
            for _, l in ipairs(esp.Corners) do
                l.Color = baseCol
                l.Visible = true
            end
        end
    else
        for _, l in ipairs(esp.Box) do l.Visible = false end
        for _, l in ipairs(esp.Corners) do l.Visible = false end
    end
    
    if Config.ESP_Name then
        esp.Name.Text = "ENEMY"
        esp.Name.Position = Vector2.new(cx, boxTop - Tuning.NameOffset)
        esp.Name.Color = baseCol
        esp.Name.Visible = true
    else
        esp.Name.Visible = false
    end
    
    if Config.ESP_Distance then
        esp.Dist.Text = math.floor(dist) .. "m"
        esp.Dist.Position = Vector2.new(cx, boxBottom + Tuning.DistOffset)
        esp.Dist.Visible = true
    else
        esp.Dist.Visible = false
    end
    
    if Config.ESP_Tracer then
        local origin
        if Config.ESP_TracerOrigin == "Bottom" then
            origin = Vector2.new(screenCenter.X, screenSize.Y)
        elseif Config.ESP_TracerOrigin == "Top" then
            origin = Vector2.new(screenCenter.X, 0)
        else
            origin = screenCenter
        end
        esp.Tracer.From = origin
        esp.Tracer.To = Vector2.new(cx, boxBottom)
        esp.Tracer.Color = Palette.Tracer
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end
    
    if Config.ESP_Snapline and esp.Snapline then
        esp.Snapline.From = Vector2.new(screenCenter.X, screenSize.Y)
        esp.Snapline.To = Vector2.new(cx, boxBottom)
        esp.Snapline.Color = Palette.Snapline
        esp.Snapline.Transparency = 0.5
        esp.Snapline.Visible = true
    else
        if esp.Snapline then esp.Snapline.Visible = false end
    end
    
    if Config.ESP_LookDirection and esp.LookLine then
        local torso = model:FindFirstChild("TPVBodyVanillaTorsoFront")
        if torso then
            local lookDir = torso.CFrame.LookVector
            local lookEndPos = rootPos + lookDir * 10
            local lookScreen, lookOn = cam:WorldToViewportPoint(lookEndPos)
            if lookOn and lookScreen.Z > 0 then
                esp.LookLine.From = Vector2.new(cx, cy)
                esp.LookLine.To = Vector2.new(lookScreen.X, lookScreen.Y)
                esp.LookLine.Color = Palette.LookDirection
                esp.LookLine.Visible = true
            else
                esp.LookLine.Visible = false
            end
        else
            esp.LookLine.Visible = false
        end
    else
        if esp.LookLine then esp.LookLine.Visible = false end
    end
    
    if Config.ESP_BoxFill and esp.BoxFill then
        esp.BoxFill.Position = Vector2.new(cx - boxWidth/2, boxTop)
        esp.BoxFill.Size = Vector2.new(boxWidth, boxBottom - boxTop)
        esp.BoxFill.Color = baseCol
        esp.BoxFill.Transparency = 0.15
        esp.BoxFill.Visible = true
    else
        if esp.BoxFill then esp.BoxFill.Visible = false end
    end
    
    local vd = ESP.velocityData[model]
    if not vd then
        vd = {pos = rootPos, vel = Vector3.zero, time = tick()}
        ESP.velocityData[model] = vd
    end
    local now = tick()
    local dt = now - vd.time
    if dt > 0.03 then
        local rawVel = (rootPos - vd.pos) / dt
        vd.vel = vd.vel * 0.7 + rawVel * 0.3
        vd.pos = rootPos
        vd.time = now
    end
    
    if Config.ESP_Velocity and esp.VelLine and esp.VelArrow then
        local velFlat = Vector3.new(vd.vel.X, 0, vd.vel.Z)
        local velMag = velFlat.Magnitude
        if velMag > 2 then
            local futurePos = rootPos + velFlat.Unit * math.clamp(velMag * 0.4, 5, 20)
            local futureScreen, futureOn = cam:WorldToViewportPoint(futurePos)
            if futureOn and futureScreen.Z > 0 then
                esp.VelLine.From = Vector2.new(rs.X, rs.Y)
                esp.VelLine.To = Vector2.new(futureScreen.X, futureScreen.Y)
                esp.VelLine.Visible = true
                local dx, dy = futureScreen.X - rs.X, futureScreen.Y - rs.Y
                local len = math.sqrt(dx*dx + dy*dy)
                if len > 5 then
                    local fx, fy = dx/len, dy/len
                    esp.VelArrow.PointA = Vector2.new(futureScreen.X, futureScreen.Y)
                    esp.VelArrow.PointB = Vector2.new(futureScreen.X - fx*10 + fy*5, futureScreen.Y - fy*10 - fx*5)
                    esp.VelArrow.PointC = Vector2.new(futureScreen.X - fx*10 - fy*5, futureScreen.Y - fy*10 + fx*5)
                    esp.VelArrow.Visible = true
                else
                    esp.VelArrow.Visible = false
                end
            else
                esp.VelLine.Visible = false
                esp.VelArrow.Visible = false
            end
        else
            esp.VelLine.Visible = false
            esp.VelArrow.Visible = false
        end
    else
        if esp.VelLine then esp.VelLine.Visible = false end
        if esp.VelArrow then esp.VelArrow.Visible = false end
    end
end

function ESP.Cleanup()
    local toRemove = {}
    for model, esp in pairs(ESP.cache) do
        if not model or not model.Parent or not model:FindFirstChild("HumanoidRootPart") then
            ESP.Hide(esp)
            ESP.Destroy(esp)
            toRemove[#toRemove + 1] = model
        end
    end
    for _, model in ipairs(toRemove) do
        ESP.cache[model] = nil
        ESP.posCache[model] = nil
        ESP.velocityData[model] = nil
        DeathTracker[model] = nil  
    end
    
    
    CleanupDeathTracker()
end

function ESP.HideAll()
    for _, esp in pairs(ESP.cache) do
        ESP.Hide(esp)
    end
end

function ESP.CachePositions()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position or Vector3.zero
    
    ESP.posCache = {}
    
    local models = Workspace:GetChildren()
    for i = 1, #models do
        local model = models[i]
        if model and model:IsA("Model") and model.Name == "soldier_model" then
            
            if IsLocalPlayer(model) then continue end
            
            local root = model:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                local dist = (pos - myPos).Magnitude
                ESP.posCache[model] = {
                    pos = pos,
                    dist = dist
                }
            end
        end
    end
end

function ESP.Step(cam, screenSize, screenCenter)
    if State.Unloaded then return end
    
    if not Config.ESP_Enabled then
        ESP.HideAll()
        return
    end
    
    local now = tick()
    
    if now - ESP.lastCleanup > 0.5 then
        ESP.lastCleanup = now
        ESP.Cleanup()
    end
    
    if now - ESP.lastPosUpdate > 0.033 then
        ESP.lastPosUpdate = now
        ESP.CachePositions()
    end
    
    local validModels = {}
    
    for model, posData in pairs(ESP.posCache) do
        if model and model.Parent then
            local root = model:FindFirstChild("HumanoidRootPart")
            if root then
                if Config.ESP_TeamCheck and model:FindFirstChild("friendly_marker") then
                    if ESP.cache[model] then
                        ESP.Hide(ESP.cache[model])
                    end
                else
                    validModels[model] = true
                    
                    if not ESP.cache[model] then
                        ESP.cache[model] = ESP.Create()
                        ESP.Setup(ESP.cache[model])
                    end
                    
                    ESP.Render(ESP.cache[model], model, cam, screenSize, screenCenter)
                end
            end
        end
    end
    
    for model, esp in pairs(ESP.cache) do
        if not validModels[model] then
            ESP.Hide(esp)
        end
    end
end

local Chams = {
    objects = {}
}

function Chams.Create(model)
    if Chams.objects[model] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "_FrontlinesChams"
    highlight.Adornee = model
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
    
    Chams.objects[model] = highlight
end

function Chams.Update(model, dist)
    local highlight = Chams.objects[model]
    if not highlight then return end
    
   
    local isDead = Config.ESP_DeadCheck and IsModelDead(model) or false
    
    if isDead then
        highlight.FillColor = Palette.Dead
        highlight.OutlineColor = Palette.Dead
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.5
    elseif Config.ESP_ChamsStyle == "Outline" then
        highlight.FillColor = GetEspColor()
        highlight.OutlineColor = GetEspColor()
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
    elseif Config.ESP_ChamsStyle == "Heatmap" or Config.ESP_Heatmap then
        local col = GetHeatmapColor(dist)
        highlight.FillColor = col
        highlight.OutlineColor = col
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0.2
    else
        highlight.FillColor = GetEspColor()
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.6
        highlight.OutlineTransparency = 0
    end
    highlight.Enabled = true
end

function Chams.Remove(model)
    local highlight = Chams.objects[model]
    if highlight then
        highlight:Destroy()
        Chams.objects[model] = nil
    end
    
    local existing = model:FindFirstChild("_FrontlinesChams")
    if existing then existing:Destroy() end
end

function Chams.ClearAll()
    for model, _ in pairs(Chams.objects) do
        Chams.Remove(model)
    end
    Chams.objects = {}
end

function Chams.Step()
    if State.Unloaded or not Config.ESP_Enabled or not Config.ESP_Chams then
        Chams.ClearAll()
        return
    end
    
    local validModels = {}
    
    for model, posData in pairs(ESP.posCache) do
        if model and model.Parent then
            if Config.ESP_TeamCheck and model:FindFirstChild("friendly_marker") then
                if Chams.objects[model] then
                    Chams.Remove(model)
                end
            else
                validModels[model] = true
                
                if not Chams.objects[model] then
                    Chams.Create(model)
                end
                Chams.Update(model, posData.dist)
            end
        end
    end
    
    for model, _ in pairs(Chams.objects) do
        if not validModels[model] then
            Chams.Remove(model)
        end
    end
end



local Aimbot = {
    fov = Drawing.new("Circle")
}

Aimbot.fov.Thickness = 1
Aimbot.fov.NumSides = 60
Aimbot.fov.Filled = false
Aimbot.fov.Transparency = 0.7


Aimbot.currentTargetModel = nil
Aimbot.lastTargetTime = 0
Aimbot.lastTargetDist = 100

function Aimbot.GetTarget(cam)
    local bestTarget = nil
    local bestScore = math.huge
    local bestModel = nil
    local bestDist = 100
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position or cam.CFrame.Position
    
    local models = Workspace:GetChildren()
    for i = 1, #models do
        local model = models[i]
        if model:IsA("Model") and model.Name == "soldier_model" then
         
            if IsLocalPlayer(model) then continue end
            if Config.AIM_TeamCheck and model:FindFirstChild("friendly_marker") then continue end
            if Config.ESP_DeadCheck and IsModelDead(model) then continue end  
            
            local hrp = model:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local worldDist = (hrp.Position - myPos).Magnitude
            
            local partsToCheck = {}
            local distanceOffset = Vector3.new(0, 0, 0)
            
            if Config.AIM_TargetPart == "Auto" then
                partsToCheck = {
                    {part = model:FindFirstChild("HumanoidRootPart"), offset = Vector3.new(0, 2.5, 0)},
                    {part = model:FindFirstChild("TPVBodyVanillaHead"), offset = Vector3.new(0, 0, 0)},
                    {part = model:FindFirstChild("TPVAccessoryJaw"), offset = Vector3.new(0, 0, 0)},
                    {part = model:FindFirstChild("TPVBodyVanillaTorsoBack"), offset = Vector3.new(0, 0, 0)},
                    {part = model:FindFirstChild("TPVBodyVanillaTorsoFront"), offset = Vector3.new(0, 0, 0)}
                }
            elseif Config.AIM_TargetPart == "Head" then
                if worldDist < 5 then
                    distanceOffset = Vector3.new(0, -3.5, 0)
                elseif worldDist < 8 then
                    distanceOffset = Vector3.new(0, -2.8, 0)
                elseif worldDist < 12 then
                    distanceOffset = Vector3.new(0, -2.0, 0)
                elseif worldDist < 18 then
                    distanceOffset = Vector3.new(0, -1.2, 0)
                elseif worldDist < 25 then
                    distanceOffset = Vector3.new(0, -0.6, 0)
                elseif worldDist < 40 then
                    distanceOffset = Vector3.new(0, -0.2, 0)
                else
                    distanceOffset = Vector3.new(0, 0.1, 0)
                end
                partsToCheck = {
                    {part = model:FindFirstChild("TPVBodyVanillaHead"), offset = distanceOffset},
                    {part = model:FindFirstChild("TPVAccessoryJaw"), offset = distanceOffset},
                    {part = model:FindFirstChild("Head"), offset = distanceOffset}
                }
            elseif Config.AIM_TargetPart == "Torso" then
                if worldDist < 8 then
                    distanceOffset = Vector3.new(0, -1.5, 0)
                elseif worldDist < 15 then
                    distanceOffset = Vector3.new(0, -0.8, 0)
                elseif worldDist < 25 then
                    distanceOffset = Vector3.new(0, -0.3, 0)
                end
                partsToCheck = {
                    {part = model:FindFirstChild("TPVBodyVanillaTorsoFront"), offset = distanceOffset},
                    {part = model:FindFirstChild("TPVBodyVanillaTorsoBack"), offset = distanceOffset},
                    {part = model:FindFirstChild("UpperTorso"), offset = distanceOffset}
                }
            else
                if worldDist < 10 then
                    distanceOffset = Vector3.new(0, 1.5, 0)
                else
                    distanceOffset = Vector3.new(0, 2.5, 0)
                end
                partsToCheck = {
                    {part = model:FindFirstChild("HumanoidRootPart"), offset = distanceOffset}
                }
            end
            
            for _, info in ipairs(partsToCheck) do
                local part = info.part
                if part then
                    local offset = info.offset or Vector3.zero
                    local targetPos = part.Position + offset
                    local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
                    
                    if onScreen and screenPos.Z > 0 then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if screenDist <= Config.AIM_FOV then
                            local score
                            
                            if Config.AIM_TargetPart == "Auto" then
                                local normalizedScreen = screenDist / Config.AIM_FOV
                                local normalizedWorld = math.clamp(worldDist / 200, 0, 1)
                                local proxWeight = Config.AIM_ProximityPriority * 0.5
                                score = (1 - proxWeight) * normalizedScreen + proxWeight * normalizedWorld
                                
                                if model == Aimbot.currentTargetModel then
                                    local stickyBonus = (Config.AIM_StickyFactor - 1) * 0.5 + 1
                                    score = score / stickyBonus
                                end
                            else
                                local normalizedScreen = screenDist / Config.AIM_FOV
                                local normalizedWorld = math.clamp(worldDist / 150, 0, 1)
                                local proxWeight = Config.AIM_ProximityPriority
                                score = (1 - proxWeight) * normalizedScreen + proxWeight * normalizedWorld
                                
                                if model == Aimbot.currentTargetModel then
                                    score = score / Config.AIM_StickyFactor
                                end
                            end
                            
                            if score < bestScore then
                                bestScore = score
                                bestTarget = targetPos
                                bestModel = model
                                bestDist = worldDist
                            end
                        end
                    end
                    
                    if Config.AIM_TargetPart ~= "Auto" then
                        break
                    end
                end
            end
        end
    end
    
    if bestModel then
        Aimbot.currentTargetModel = bestModel
        Aimbot.lastTargetTime = tick()
        Aimbot.lastTargetDist = bestDist
    elseif tick() - Aimbot.lastTargetTime > 0.5 then
        Aimbot.currentTargetModel = nil
        Aimbot.lastTargetDist = 100
    end
    
    return bestTarget
end

function Aimbot.Step(cam, screenCenter)
    if State.Unloaded then
        if Aimbot.fov then Aimbot.fov.Visible = false end
        return
    end
    
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    local isAiming = State.Aiming
    if Config.AIM_Key == Enum.UserInputType.MouseButton2 then
        pcall(function()
            isAiming = isAiming or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        end)
    elseif Config.AIM_Key == Enum.UserInputType.MouseButton1 then
        pcall(function()
            isAiming = isAiming or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        end)
    elseif Config.AIM_Key == Enum.UserInputType.MouseButton3 then
        pcall(function()
            isAiming = isAiming or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
        end)
    end
    
    if Config.AIM_Enabled and Config.AIM_ShowFOV then
        Aimbot.fov.Position = screenCenter
        Aimbot.fov.Radius = Config.AIM_FOV
        Aimbot.fov.Color = isAiming and Palette.MenuOn or Color3.fromRGB(255, 255, 255)
        Aimbot.fov.Visible = true
    else
        Aimbot.fov.Visible = false
    end
    
    if not Config.AIM_Enabled or not isAiming then return end
    
    local targetPos = Aimbot.GetTarget(cam)
    if not targetPos then return end
    
    local screenPos = cam:WorldToViewportPoint(targetPos)
    local delta = Vector2.new(screenPos.X - mousePos.X, screenPos.Y - mousePos.Y)
    local deltaMag = delta.Magnitude
    
    if Config.AIM_TargetPart == "Auto" then
        if deltaMag < 2 then return end
        pcall(function()
            if mousemoverel then
                mousemoverel(delta.X * Config.AIM_Smooth, delta.Y * Config.AIM_Smooth)
            end
        end)
    else
        local deadzone = 3
        if Aimbot.lastTargetDist < 15 then
            deadzone = 8  
        elseif Aimbot.lastTargetDist < 30 then
            deadzone = 5
        end
        
        if deltaMag < deadzone then return end
        
        local smooth = Config.AIM_Smooth
        
        if Aimbot.lastTargetDist < 8 then
            smooth = smooth * 0.3  
        elseif Aimbot.lastTargetDist < 15 then
            smooth = smooth * 0.5  
        elseif Aimbot.lastTargetDist < 25 then
            smooth = smooth * 0.7  
        end
        
        smooth = math.clamp(smooth, 0.02, 0.5)
        
        local adjustedDelta = deltaMag - deadzone
        if adjustedDelta > 0 then
            local normalizedDelta = delta / deltaMag
            local moveX = normalizedDelta.X * adjustedDelta * smooth
            local moveY = normalizedDelta.Y * adjustedDelta * smooth
            
            if Aimbot.lastTargetDist < 10 then
                moveX = math.clamp(moveX, -15, 15)
                moveY = math.clamp(moveY, -15, 15)
            end
            
            pcall(function()
                if mousemoverel then
                    mousemoverel(moveX, moveY)
                end
            end)
        end
    end
end

local Tabs = {
    {name = "ESP"},
    {name = "AIM"},
    {name = "MISC"}
}

local MenuItems = {
    {tab = 1, name = "VISUALS", type = "label"},
    {tab = 1, name = "Enable ESP", key = "ESP_Enabled", type = "toggle"},
    {tab = 1, name = "Box ESP", key = "ESP_Box", type = "toggle"},
    {tab = 1, name = "Box Style", key = "ESP_BoxStyle", type = "dropdown", options = {"Full", "Corner"}},
    {tab = 1, name = "Box Fill", key = "ESP_BoxFill", type = "toggle"},
    {tab = 1, name = "Name", key = "ESP_Name", type = "toggle"},
    {tab = 1, name = "Distance", key = "ESP_Distance", type = "toggle"},
    {tab = 1, name = "Tracer", key = "ESP_Tracer", type = "toggle"},
    {tab = 1, name = "Tracer Origin", key = "ESP_TracerOrigin", type = "dropdown", options = {"Bottom", "Center", "Top"}},
    {tab = 1, name = "Snapline", key = "ESP_Snapline", type = "toggle"},
    {tab = 1, name = "Look Direction", key = "ESP_LookDirection", type = "toggle"},
    {tab = 1, name = "Velocity", key = "ESP_Velocity", type = "toggle"},
    {tab = 1, name = "Dead Check", key = "ESP_DeadCheck", type = "toggle"},
    {tab = 1, name = "Offscreen", key = "ESP_Offscreen", type = "toggle"},
    {tab = 1, name = "Max Distance", key = "ESP_MaxDist", type = "slider", min = 500, max = 3000, step = 100},
    {tab = 1, name = "CHAMS", type = "label"},
    {tab = 1, name = "Enable Chams", key = "ESP_Chams", type = "toggle"},
    {tab = 1, name = "Chams Style", key = "ESP_ChamsStyle", type = "dropdown", options = {"Solid", "Outline", "Heatmap"}},
    {tab = 1, name = "Heatmap Mode", key = "ESP_Heatmap", type = "toggle"},
    {tab = 1, name = "COLORS", type = "label"},
    {tab = 1, name = "Rainbow Mode", key = "ESP_Rainbow", type = "toggle"},
    {tab = 1, name = "ESP Color", key = "ESP_CustomColor", type = "color"},
    {tab = 1, name = "Team Check", key = "ESP_TeamCheck", type = "toggle"},
    {tab = 1, name = "RADAR", type = "label"},
    {tab = 1, name = "Enable Radar", key = "RADAR_Enabled", type = "toggle"},
    {tab = 1, name = "Radar Size", key = "RADAR_Size", type = "slider", min = 80, max = 180, step = 10},
    {tab = 1, name = "Radar Range", key = "RADAR_Range", type = "slider", min = 100, max = 400, step = 25},
    {tab = 1, name = "Move Radar", key = "RADAR_Edit", type = "toggle"},
    
    {tab = 2, name = "AIMBOT", type = "label"},
    {tab = 2, name = "Enable Aimbot", key = "AIM_Enabled", type = "toggle"},
    {tab = 2, name = "Show FOV", key = "AIM_ShowFOV", type = "toggle"},
    {tab = 2, name = "FOV Size", key = "AIM_FOV", type = "slider", min = 50, max = 500, step = 25},
    {tab = 2, name = "Smoothness", key = "AIM_Smooth", type = "slider", min = 0.05, max = 0.5, step = 0.01},
    {tab = 2, name = "Target Part", key = "AIM_TargetPart", type = "dropdown", options = {"Auto", "Head", "Torso", "Root"}},
    {tab = 2, name = "Team Check", key = "AIM_TeamCheck", type = "toggle"},
    {tab = 2, name = "TARGETING", type = "label"},
    {tab = 2, name = "Proximity Priority", key = "AIM_ProximityPriority", type = "slider", min = 0, max = 1, step = 0.1},
    {tab = 2, name = "Target Stickiness", key = "AIM_StickyFactor", type = "slider", min = 1, max = 2, step = 0.1},
    
    {tab = 3, name = "GUN MODS", type = "label"},
    {tab = 3, name = "No Recoil", key = "MISC_NoRecoil", type = "toggle"},
    {tab = 3, name = "No Sway", key = "MISC_NoSway", type = "toggle"},
    {tab = 3, name = "No Spread", key = "MISC_NoSpread", type = "toggle"},
    {tab = 3, name = "No Cam Shake", key = "MISC_NoCamShake", type = "toggle"},
    {tab = 3, name = "VISUAL", type = "label"},
    {tab = 3, name = "Menu Color", key = "MISC_MenuColor", type = "color"},
    {tab = 3, name = "Full Bright", key = "MISC_FullBright", type = "toggle"},
    {tab = 3, name = "HOTKEYS", type = "label"},
    {tab = 3, name = "Menu Key", key = "KEY_Menu", type = "keybind"},
    {tab = 3, name = "Panic Key", key = "KEY_Panic", type = "keybind"}
}



local Preview = {
    Initialized = false,
    Position = Config.UI_PreviewPosition or Vector2.new(60, 260),
    Size = Vector2.new(170, 210),
    Dragging = false,
    DragOffset = Vector2.zero
}

function Preview:Init()
    if self.Initialized then return end

    self.Bg = Drawing.new("Square")
    self.Bg.Filled = true
    self.Bg.Color = Palette.PreviewBg
    self.Bg.Transparency = 0.92

    self.Border = Drawing.new("Square")
    self.Border.Filled = false
    self.Border.Color = Palette.PreviewBorder
    self.Border.Thickness = 1

    self.Title = Drawing.new("Text")
    self.Title.Size = 12
    self.Title.Font = Drawing.Fonts.UI
    self.Title.Color = Palette.MenuTextDim
    self.Title.Center = true
    self.Title.Outline = true
    self.Title.Text = "ESP PREVIEW"

    self.Box = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        self.Box[i] = line
    end

    self.Corners = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        self.Corners[i] = line
    end

    self.BoxFill = Drawing.new("Square")
    self.BoxFill.Filled = true
    self.BoxFill.Transparency = 0.15
    self.BoxFill.Visible = false

    self.Name = Drawing.new("Text")
    self.Name.Size = 13
    self.Name.Font = Drawing.Fonts.Monospace
    self.Name.Center = true
    self.Name.Outline = true
    self.Name.Text = "ENEMY"
    self.Name.Visible = false

    self.Dist = Drawing.new("Text")
    self.Dist.Size = 11
    self.Dist.Font = Drawing.Fonts.Monospace
    self.Dist.Center = true
    self.Dist.Outline = true
    self.Dist.Color = Color3.fromRGB(170, 170, 170)
    self.Dist.Visible = false

    self.Tracer = Drawing.new("Line")
    self.Tracer.Thickness = 1
    self.Tracer.Color = Palette.Tracer
    self.Tracer.Visible = false

    self.Snapline = Drawing.new("Line")
    self.Snapline.Thickness = 1
    self.Snapline.Color = Palette.Snapline
    self.Snapline.Transparency = 0.5
    self.Snapline.Visible = false

    self.LookLine = Drawing.new("Line")
    self.LookLine.Thickness = 2
    self.LookLine.Color = Palette.LookDirection
    self.LookLine.Visible = false

    self.VelLine = Drawing.new("Line")
    self.VelLine.Thickness = 2
    self.VelLine.Color = Palette.Velocity
    self.VelLine.Visible = false

    self.VelArrow = Drawing.new("Triangle")
    self.VelArrow.Filled = true
    self.VelArrow.Color = Palette.Velocity
    self.VelArrow.Visible = false

    self.Figure = {
        Head = Drawing.new("Circle"),
        Torso = Drawing.new("Square"),
        ArmL = Drawing.new("Square"),
        ArmR = Drawing.new("Square"),
        LegL = Drawing.new("Square"),
        LegR = Drawing.new("Square")
    }

    self.Figure.Head.Filled = true
    self.Figure.Head.NumSides = 20
    self.Figure.Torso.Filled = true
    self.Figure.ArmL.Filled = true
    self.Figure.ArmR.Filled = true
    self.Figure.LegL.Filled = true
    self.Figure.LegR.Filled = true

    self.Initialized = true
end

function Preview:Hide()
    if not self.Initialized then return end
    self.Bg.Visible = false
    self.Border.Visible = false
    self.Title.Visible = false
    for _, line in ipairs(self.Box) do line.Visible = false end
    for _, line in ipairs(self.Corners) do line.Visible = false end
    if self.BoxFill then self.BoxFill.Visible = false end
    if self.Name then self.Name.Visible = false end
    if self.Dist then self.Dist.Visible = false end
    if self.Tracer then self.Tracer.Visible = false end
    if self.Snapline then self.Snapline.Visible = false end
    if self.LookLine then self.LookLine.Visible = false end
    if self.VelLine then self.VelLine.Visible = false end
    if self.VelArrow then self.VelArrow.Visible = false end
    if self.Figure then
        for _, part in pairs(self.Figure) do
            part.Visible = false
        end
    end
end

local function renderPreviewSample(x, y, w, h)
    Preview:Init()
    local pw, ph = Tuning.PreviewBoxW, Tuning.PreviewBoxH
    local cx = x + w/2
    local cy = y + h/2 + 8
    local boxTop = cy - ph/2
    local boxBottom = cy + ph/2
    local boxLeft = cx - pw/2
    local boxRight = cx + pw/2

    local animCycle = tick() % 3
    local animDist
    if animCycle < 1.5 then
        animDist = 20 + (animCycle / 1.5) * 80
    else
        animDist = 100 - ((animCycle - 1.5) / 1.5) * 80
    end
    animDist = math.floor(animDist)

    local espColor
    local figFillColor
    local figOutlineColor
    local useHeatmap = Config.ESP_Heatmap or (Config.ESP_Chams and Config.ESP_ChamsStyle == "Heatmap")
    local useOutline = Config.ESP_Chams and Config.ESP_ChamsStyle == "Outline"

    if useHeatmap then
        espColor = GetHeatmapColor(animDist)
        figFillColor = espColor
        figOutlineColor = Color3.fromRGB(
            math.min(255, espColor.R * 255 + 40),
            math.min(255, espColor.G * 255 + 40),
            math.min(255, espColor.B * 255 + 40)
        )
    elseif useOutline then
        espColor = GetEspColor()
        figFillColor = Color3.fromRGB(60, 60, 65)
        figOutlineColor = GetEspColor()
    elseif Config.ESP_Chams then
        espColor = GetEspColor()
        figFillColor = GetEspColor()
        figOutlineColor = Color3.fromRGB(255, 120, 120)
    else
        espColor = GetEspColor()
        figFillColor = Color3.fromRGB(60, 60, 65)
        figOutlineColor = Color3.fromRGB(80, 80, 85)
    end

    local fig = Preview.Figure
    local headRadius = 10
    local headY = cy - ph * 0.32

    fig.Head.Position = Vector2.new(cx, headY)
    fig.Head.Radius = headRadius
    fig.Head.Color = Config.ESP_Chams and (useOutline and figOutlineColor or figFillColor) or Color3.fromRGB(60, 60, 65)
    fig.Head.Filled = not useOutline
    fig.Head.Thickness = useOutline and 2 or 1
    fig.Head.Visible = true

    local torsoW, torsoH = 24, 40
    local torsoTop = headY + headRadius + 2
    fig.Torso.Position = Vector2.new(cx - torsoW/2, torsoTop)
    fig.Torso.Size = Vector2.new(torsoW, torsoH)
    fig.Torso.Color = Config.ESP_Chams and (useOutline and figOutlineColor or figFillColor) or Color3.fromRGB(50, 50, 55)
    fig.Torso.Filled = not useOutline
    fig.Torso.Thickness = useOutline and 2 or 1
    fig.Torso.Visible = true

    local armW, armH = 8, 38
    fig.ArmL.Position = Vector2.new(cx - torsoW/2 - armW - 2, torsoTop + 2)
    fig.ArmL.Size = Vector2.new(armW, armH)
    fig.ArmL.Color = Config.ESP_Chams and (useOutline and figOutlineColor or figFillColor) or Color3.fromRGB(50, 50, 55)
    fig.ArmL.Filled = not useOutline
    fig.ArmL.Thickness = useOutline and 2 or 1
    fig.ArmL.Visible = true

    fig.ArmR.Position = Vector2.new(cx + torsoW/2 + 2, torsoTop + 2)
    fig.ArmR.Size = Vector2.new(armW, armH)
    fig.ArmR.Color = Config.ESP_Chams and (useOutline and figOutlineColor or figFillColor) or Color3.fromRGB(50, 50, 55)
    fig.ArmR.Filled = not useOutline
    fig.ArmR.Thickness = useOutline and 2 or 1
    fig.ArmR.Visible = true

    local legW, legH = 10, 45
    local legTop = torsoTop + torsoH + 2
    fig.LegL.Position = Vector2.new(cx - legW - 2, legTop)
    fig.LegL.Size = Vector2.new(legW, legH)
    fig.LegL.Color = Config.ESP_Chams and (useOutline and figOutlineColor or figFillColor) or Color3.fromRGB(45, 45, 50)
    fig.LegL.Filled = not useOutline
    fig.LegL.Thickness = useOutline and 2 or 1
    fig.LegL.Visible = true

    fig.LegR.Position = Vector2.new(cx + 2, legTop)
    fig.LegR.Size = Vector2.new(legW, legH)
    fig.LegR.Color = Config.ESP_Chams and (useOutline and figOutlineColor or figFillColor) or Color3.fromRGB(45, 45, 50)
    fig.LegR.Filled = not useOutline
    fig.LegR.Thickness = useOutline and 2 or 1
    fig.LegR.Visible = true

    if Config.ESP_Box then
        if Config.ESP_BoxStyle == "Full" then
            for _, l in ipairs(Preview.Corners) do l.Visible = false end
            Preview.Box[1].From = Vector2.new(boxLeft, boxTop)
            Preview.Box[1].To = Vector2.new(boxRight, boxTop)
            Preview.Box[2].From = Vector2.new(boxRight, boxTop)
            Preview.Box[2].To = Vector2.new(boxRight, boxBottom)
            Preview.Box[3].From = Vector2.new(boxRight, boxBottom)
            Preview.Box[3].To = Vector2.new(boxLeft, boxBottom)
            Preview.Box[4].From = Vector2.new(boxLeft, boxBottom)
            Preview.Box[4].To = Vector2.new(boxLeft, boxTop)
            for _, l in ipairs(Preview.Box) do
                l.Color = espColor
                l.Visible = true
            end
        else
            for _, l in ipairs(Preview.Box) do l.Visible = false end
            local cl = 12
            Preview.Corners[1].From = Vector2.new(boxLeft, boxTop)
            Preview.Corners[1].To = Vector2.new(boxLeft + cl, boxTop)
            Preview.Corners[2].From = Vector2.new(boxLeft, boxTop)
            Preview.Corners[2].To = Vector2.new(boxLeft, boxTop + cl)
            Preview.Corners[3].From = Vector2.new(boxRight, boxTop)
            Preview.Corners[3].To = Vector2.new(boxRight - cl, boxTop)
            Preview.Corners[4].From = Vector2.new(boxRight, boxTop)
            Preview.Corners[4].To = Vector2.new(boxRight, boxTop + cl)
            Preview.Corners[5].From = Vector2.new(boxLeft, boxBottom)
            Preview.Corners[5].To = Vector2.new(boxLeft + cl, boxBottom)
            Preview.Corners[6].From = Vector2.new(boxLeft, boxBottom)
            Preview.Corners[6].To = Vector2.new(boxLeft, boxBottom - cl)
            Preview.Corners[7].From = Vector2.new(boxRight, boxBottom)
            Preview.Corners[7].To = Vector2.new(boxRight - cl, boxBottom)
            Preview.Corners[8].From = Vector2.new(boxRight, boxBottom)
            Preview.Corners[8].To = Vector2.new(boxRight, boxBottom - cl)
            for _, l in ipairs(Preview.Corners) do
                l.Color = espColor
                l.Visible = true
            end
        end
    else
        for _, l in ipairs(Preview.Box) do l.Visible = false end
        for _, l in ipairs(Preview.Corners) do l.Visible = false end
    end

    if Config.ESP_BoxFill then
        Preview.BoxFill.Position = Vector2.new(boxLeft, boxTop)
        Preview.BoxFill.Size = Vector2.new(pw, ph)
        Preview.BoxFill.Color = espColor
        Preview.BoxFill.Visible = true
    else
        Preview.BoxFill.Visible = false
    end

    if Config.ESP_Name then
        Preview.Name.Position = Vector2.new(cx, boxTop - 16)
        Preview.Name.Color = espColor
        Preview.Name.Visible = true
    else
        Preview.Name.Visible = false
    end

    if Config.ESP_Distance then
        Preview.Dist.Position = Vector2.new(cx, boxBottom + 4)
        Preview.Dist.Text = animDist .. "m"
        Preview.Dist.Visible = true
    else
        Preview.Dist.Visible = false
    end

    if Config.ESP_Tracer then
        local fromY
        if Config.ESP_TracerOrigin == "Bottom" then
            fromY = y + h - 5
        elseif Config.ESP_TracerOrigin == "Top" then
            fromY = y + 5
        else
            fromY = y + h/2
        end
        Preview.Tracer.From = Vector2.new(cx, fromY)
        Preview.Tracer.To = Vector2.new(cx, boxBottom)
        Preview.Tracer.Color = Palette.Tracer
        Preview.Tracer.Visible = true
    else
        Preview.Tracer.Visible = false
    end

    if Config.ESP_Snapline then
        Preview.Snapline.From = Vector2.new(cx, y + h - 5)
        Preview.Snapline.To = Vector2.new(cx, boxBottom)
        Preview.Snapline.Color = Palette.Snapline
        Preview.Snapline.Transparency = 0.5
        Preview.Snapline.Visible = true
    else
        Preview.Snapline.Visible = false
    end

    if Config.ESP_LookDirection then
        Preview.LookLine.From = Vector2.new(cx, cy)
        Preview.LookLine.To = Vector2.new(cx + 35, cy - 5)
        Preview.LookLine.Color = Palette.LookDirection
        Preview.LookLine.Visible = true
    else
        Preview.LookLine.Visible = false
    end

    if Config.ESP_Velocity then
        local velStartX = cx + pw/2 - 15
        local velStartY = cy
        local velEndX = velStartX + 28
        local velEndY = cy - 10
        Preview.VelLine.From = Vector2.new(velStartX, velStartY)
        Preview.VelLine.To = Vector2.new(velEndX, velEndY)
        Preview.VelLine.Color = Palette.Velocity
        Preview.VelLine.Visible = true

        local dx = velEndX - velStartX
        local dy = velEndY - velStartY
        local len = math.max(1, math.sqrt(dx*dx + dy*dy))
        local fx, fy = dx/len, dy/len
        local arrowSize = 12
        Preview.VelArrow.PointA = Vector2.new(velEndX + fx*2, velEndY + fy*2)
        Preview.VelArrow.PointB = Vector2.new(velEndX - fx*arrowSize + fy*arrowSize/2, velEndY - fy*arrowSize - fx*arrowSize/2)
        Preview.VelArrow.PointC = Vector2.new(velEndX - fx*arrowSize - fy*arrowSize/2, velEndY - fy*arrowSize + fx*arrowSize/2)
        Preview.VelArrow.Color = Palette.Velocity
        Preview.VelArrow.Visible = true
    else
        Preview.VelLine.Visible = false
        Preview.VelArrow.Visible = false
    end
end

function Preview:Render()
    if State.Unloaded or State.CurrentTab ~= "ESP/" or not Config.UI_ShowPreview then
        self:Hide()
        return
    end

    local cam = Workspace.CurrentCamera
    if not cam then
        self:Hide()
        return
    end

    self:Init()

    local windowInstance = window.Instance.Background
    local windowPos = windowInstance.AbsolutePosition
    local windowSize = windowInstance.AbsoluteSize
    local screenSize = cam.ViewportSize
    local spacing = 20

    self.Position = Vector2.new(
        math.clamp(windowPos.X + windowSize.X + spacing, 0, screenSize.X - self.Size.X),
        math.clamp(windowPos.Y, 0, screenSize.Y - self.Size.Y)
    )

    if not Config.UI_PreviewLock then
        local mousePos = UserInputService:GetMouseLocation()
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            if not self.Dragging then
                if mousePos.X >= self.Position.X and mousePos.X <= self.Position.X + self.Size.X and
                   mousePos.Y >= self.Position.Y and mousePos.Y <= self.Position.Y + self.Size.Y then
                    self.Dragging = true
                    self.DragOffset = mousePos - self.Position
                end
            else
                self.Position = mousePos - self.DragOffset
                Config.UI_PreviewPosition = self.Position
            end
        else
            self.Dragging = false
        end
    else
        self.Dragging = false
    end

    local x, y = self.Position.X, self.Position.Y
    local w, h = self.Size.X, self.Size.Y

    self.Bg.Position = Vector2.new(x, y)
    self.Bg.Size = Vector2.new(w, h)
    self.Bg.Visible = true

    self.Border.Position = Vector2.new(x, y)
    self.Border.Size = Vector2.new(w, h)
    self.Border.Visible = true

    self.Title.Position = Vector2.new(x + w/2, y + 10)
    self.Title.Visible = true

    renderPreviewSample(x, y + 24, w, h - 30)
end


local GunModConnection = nil

local function ApplyGunModsFrame()
    if Config.MISC_NoRecoil or Config.MISC_NoSway or Config.MISC_NoSpread or Config.MISC_NoCamShake then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if Config.MISC_NoRecoil and rawget(v, "recoil") then v.recoil = 0 end
                if Config.MISC_NoSway and rawget(v, "sway") then v.sway = 0 end
                if Config.MISC_NoSpread and rawget(v, "spread") then v.spread = 0 end
                if Config.MISC_NoCamShake and rawget(v, "shake") then v.shake = 0 end
            end
        end
    end
end

local function ToggleGunMods()
    local anyEnabled = Config.MISC_NoRecoil or Config.MISC_NoSway or Config.MISC_NoSpread or Config.MISC_NoCamShake
    if anyEnabled then
        if not GunModConnection then
            GunModConnection = RunService.RenderStepped:Connect(ApplyGunModsFrame)
        end
    else
        if GunModConnection then
            GunModConnection:Disconnect()
            GunModConnection = nil
        end
    end
end

local function ApplyMiscSettings()
    if Config.MISC_FullBright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.Ambient = OriginalLighting.Ambient
    end
end

local function MainLoop()
    if State.Unloaded then
        if Connections.Render then
            Connections.Render:Disconnect()
            Connections.Render = nil
        end
        return
    end

    if Config.ESP_Rainbow then
        State.RainbowHue = (State.RainbowHue + 0.002) % 1
    end

    local cam = Workspace.CurrentCamera
    if not cam then return end

    local screenSize = cam.ViewportSize
    local screenCenter = Vector2.new(screenSize.X/2, screenSize.Y/2)

    pcall(ApplyMiscSettings)
    pcall(function() ESP.Step(cam, screenSize, screenCenter) end)
    pcall(function() Chams.Step() end)
    pcall(function() Aimbot.Step(cam, screenCenter) end)
end

Unload = function()
    if State.Unloaded then return end
    State.Unloaded = true

    if GunModConnection then
        GunModConnection:Disconnect()
        GunModConnection = nil
    end

    for name, conn in pairs(Connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
        Connections[name] = nil
    end

    for model, esp in pairs(ESP.cache) do
        pcall(function() ESP.Hide(esp) end)
        pcall(function() ESP.Destroy(esp) end)
    end
    ESP.cache = {}
    pcall(function() Chams.ClearAll() end)

    if Radar.bg then
        Radar.HideAll()
    end

    if Aimbot.fov then
        Aimbot.fov.Visible = false
    end

    Preview:Hide()
    if Preview.Initialized then
        local cleanup = {Preview.Bg, Preview.Border, Preview.Title, Preview.BoxFill, Preview.Name, Preview.Dist,
            Preview.Tracer, Preview.Snapline, Preview.LookLine, Preview.VelLine, Preview.VelArrow}
        for _, obj in ipairs(cleanup) do
            if obj and obj.Remove then obj:Remove() end
        end
        if Preview.Box then
            for _, obj in ipairs(Preview.Box) do if obj.Remove then obj:Remove() end end
        end
        if Preview.Corners then
            for _, obj in ipairs(Preview.Corners) do if obj.Remove then obj:Remove() end end
        end
        if Preview.Figure then
            for _, part in pairs(Preview.Figure) do if part.Remove then part:Remove() end end
        end
        Preview.Initialized = false
    end

    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.Ambient = OriginalLighting.Ambient
    Lighting.FogEnd = OriginalLighting.FogEnd
end

local function OnInputBegan(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Config.KEY_Panic then
            Unload()
            return
        end
    end

    if input.UserInputType == Config.AIM_Key then
        State.Aiming = true
    end
end

local function OnInputEnded(input)
    if input.UserInputType == Config.AIM_Key then
        State.Aiming = false
    end
end

local window
local espTab
local aimTab
local miscTab

local function InitUI()
    window = Library.new("NewKeyforgeHub", false, 650, 450)

    espTab = window:Tab("ESP/")
    local visualSection = espTab:Section("Visuals")
    visualSection:Toggle("Enable ESP", function(enabled)
        Config.ESP_Enabled = enabled
    end, Config.ESP_Enabled)

    visualSection:Toggle("Box ESP", function(enabled)
        Config.ESP_Box = enabled
    end, Config.ESP_Box)

    visualSection:Dropdown("Box Style", {"Full", "Corner"}, function(value)
        Config.ESP_BoxStyle = value
    end, Config.ESP_BoxStyle)

    visualSection:Toggle("Box Fill", function(enabled)
        Config.ESP_BoxFill = enabled
    end, Config.ESP_BoxFill)

    visualSection:Toggle("Name", function(enabled)
        Config.ESP_Name = enabled
    end, Config.ESP_Name)

    visualSection:Toggle("Distance", function(enabled)
        Config.ESP_Distance = enabled
    end, Config.ESP_Distance)

    visualSection:Toggle("Tracer", function(enabled)
        Config.ESP_Tracer = enabled
    end, Config.ESP_Tracer)

    visualSection:Dropdown("Tracer Origin", {"Bottom", "Center", "Top"}, function(value)
        Config.ESP_TracerOrigin = value
    end, Config.ESP_TracerOrigin)

    visualSection:Toggle("Snapline", function(enabled)
        Config.ESP_Snapline = enabled
    end, Config.ESP_Snapline)

    visualSection:Toggle("Look Direction", function(enabled)
        Config.ESP_LookDirection = enabled
    end, Config.ESP_LookDirection)

    visualSection:Toggle("Velocity", function(enabled)
        Config.ESP_Velocity = enabled
    end, Config.ESP_Velocity)

    visualSection:Toggle("Dead Check", function(enabled)
        Config.ESP_DeadCheck = enabled
    end, Config.ESP_DeadCheck)

    visualSection:Toggle("Offscreen", function(enabled)
        Config.ESP_Offscreen = enabled
    end, Config.ESP_Offscreen)

    visualSection:Slider("Max Distance", 500, 3000, 100, function(value)
        Config.ESP_MaxDist = value
    end, Config.ESP_MaxDist)

    local chamsSection = espTab:Section("Chams")
    chamsSection:Toggle("Enable Chams", function(enabled)
        Config.ESP_Chams = enabled
    end, Config.ESP_Chams)

    chamsSection:Dropdown("Chams Style", {"Solid", "Outline", "Heatmap"}, function(value)
        Config.ESP_ChamsStyle = value
    end, Config.ESP_ChamsStyle)

    chamsSection:Toggle("Heatmap Mode", function(enabled)
        Config.ESP_Heatmap = enabled
    end, Config.ESP_Heatmap)

    local colorsSection = espTab:Section("Colors")
    colorsSection:Toggle("Rainbow Mode", function(enabled)
        Config.ESP_Rainbow = enabled
    end, Config.ESP_Rainbow)

    colorsSection:ColorWheel("ESP Color", function(color)
        Config.ESP_CustomColor = color
    end, Config.ESP_CustomColor)

    colorsSection:Toggle("Team Check", function(enabled)
        Config.ESP_TeamCheck = enabled
    end, Config.ESP_TeamCheck)

    aimTab = window:Tab("AIM/")
    local aimbotSection = aimTab:Section("Aimbot")
    aimbotSection:Toggle("Enable Aimbot", function(enabled)
        Config.AIM_Enabled = enabled
    end, Config.AIM_Enabled)

    aimbotSection:Toggle("Show FOV", function(enabled)
        Config.AIM_ShowFOV = enabled
    end, Config.AIM_ShowFOV)

    aimbotSection:Slider("FOV Size", 50, 500, 25, function(value)
        Config.AIM_FOV = value
    end, Config.AIM_FOV)

    aimbotSection:Slider("Smoothness", 0.05, 0.5, 0.01, function(value)
        Config.AIM_Smooth = value
    end, Config.AIM_Smooth)

    aimbotSection:Dropdown("Target Part", {"Auto", "Head", "Torso", "Root"}, function(value)
        Config.AIM_TargetPart = value
    end, Config.AIM_TargetPart)

    aimbotSection:Toggle("Team Check", function(enabled)
        Config.AIM_TeamCheck = enabled
    end, Config.AIM_TeamCheck)

    local targetingSection = aimTab:Section("Targeting")
    targetingSection:Slider("Proximity Priority", 0, 1, 0.1, function(value)
        Config.AIM_ProximityPriority = value
    end, Config.AIM_ProximityPriority)

    targetingSection:Slider("Target Stickiness", 1, 2, 0.1, function(value)
        Config.AIM_StickyFactor = value
    end, Config.AIM_StickyFactor)

    miscTab = window:Tab("MISC/")
    local gunSection = miscTab:Section("Gun Mods")
    gunSection:Toggle("No Recoil", function(enabled)
        Config.MISC_NoRecoil = enabled
        ToggleGunMods()
    end, Config.MISC_NoRecoil)

    gunSection:Toggle("No Sway", function(enabled)
        Config.MISC_NoSway = enabled
        ToggleGunMods()
    end, Config.MISC_NoSway)

    gunSection:Toggle("No Spread", function(enabled)
        Config.MISC_NoSpread = enabled
        ToggleGunMods()
    end, Config.MISC_NoSpread)

    gunSection:Toggle("No Cam Shake", function(enabled)
        Config.MISC_NoCamShake = enabled
        ToggleGunMods()
    end, Config.MISC_NoCamShake)

    local visualSection = miscTab:Section("Visual")
    visualSection:ColorWheel("Menu Color", function(color)
        Config.MISC_MenuColor = color
        Palette.Velocity = color
        Palette.MenuAccent = color
        Palette.RadarBorder = color
        Palette.PreviewBorder = color
        Palette.MenuScrollbar = color
        Palette.MenuTabActive = color
        if window then
            -- Update library theme or something, but since library is created, perhaps respawn or update
            -- For now, just set colors
        end
    end, Config.MISC_MenuColor)

    visualSection:Toggle("Full Bright", function(enabled)
        Config.MISC_FullBright = enabled
    end, Config.MISC_FullBright)
end

local function Init()
    InitUI()
    Connections.Input = UserInputService.InputBegan:Connect(OnInputBegan)
    Connections.InputEnd = UserInputService.InputEnded:Connect(OnInputEnded)
    Connections.Render = RunService.RenderStepped:Connect(MainLoop)
end

Init()
