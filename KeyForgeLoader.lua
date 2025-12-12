local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Loader = {}
local Products = {}
local CurrentProduct = nil
local LeftLabel = nil
local RightLabel = nil

local loader_config = {
    LoaderName = "Keyforge Loader",
    HeaderColor = {31, 31, 31},
    AccentColor = {0, 170, 255},
    BackgroundColor = {12, 12, 12}
}

local key_config = {
    ValidateUrl = "https://www.keyforge.lol/api/validate",
    GetKeyUrl = "https://www.keyforge.lol/ad",
    DiscordUrl = "https://discord.gg/GEqUNyZ2Gv"
}

local storage_config = {
    Folder = "KeyForgeKeys",
    FileForPlace = tostring(game.PlaceId) .. ".txt"
}

local defaultIcon = "rbxassetid://6026663726"
local ScriptLibrary = {
    {
        name = "Keyforge Hub",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load =  'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsensealt/Update-Bot/refs/heads/main/KFHUB"))()'
        
    },
    {
        name = "Operation One",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Detected(Dont Use Risky)</font>',
            ["Version"] = "v1.5"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/Operation%20One"))()'
    },
    {
        name = "(ODM/PVE DEMO) Attack on Titan: Wings of Requiem",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/(ODM%20PVE%20DEMO)%20Attack%20on%20Titan%3A%20Wings%20of%20Requiem"))()'
    },
    {
        name = "Attack on Titan Revolution",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/Attack%20on%20Titan%20Revolution"))()'
    },
    {
        name = "Build A Cart",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/Build%20A%20Cart"))()'
    },
    {
        name = "Forsaken",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/Forsaken"))()'
    },
    {
        name = "Superstar Baseball",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/Superstar%20Baseball"))()'
    },
    {
        name = "Defuse Division [ALPHA]",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Detected</font>',
            ["Version"] = "v1.5"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/%5B??%5D%20Defuse%20Division%20%5BALPHA%5D"))()'
    },
    {
        name = "99 Nights in the Forest",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/%5B??%5D%2099%20Nights%20in%20the%20Forest%20??"))()'
    },
    {
        name = "Flee the Facility",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/??Flee%20the%20Facility??"))()'
    },
    {
        name = "Evade",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/??%20Evade%20??"))()'
    },
    {
        name = "Frontlines",
        icon = "rbxassetid://6026663726",
        info = {
            ["Status"] = '<font color="#00FF6A">Undetected</font>',
            ["Version"] = "v1.0"
        },
        load = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyforgeScripts/refs/heads/main/Frontlines"))()'
    }
}

local function setClipboard(text)
    local ok = false
    pcall(function()
        if setclipboard then
            setclipboard(text)
            ok = true
        end
    end)
    return ok
end

local function getExecutorRequest()
    local ok, lib = pcall(function()
        return (syn and syn.request)
    end)
    if ok and lib then
        return lib
    end
    if typeof(http_request) == "function" then
        return http_request
    end
    if typeof(request) == "function" then
        return request
    end
    local ok2, httpLib = pcall(function()
        return http and http.request
    end)
    if ok2 and httpLib then
        return httpLib
    end
    local ok3, flux = pcall(function()
        return fluxus and fluxus.request
    end)
    if ok3 and flux then
        return flux
    end
    return nil
end

local function httpPost(url, tbl)
    local body = HttpService:JSONEncode(tbl or {})
    local execReq = getExecutorRequest()
    if execReq then
        local ok, res = pcall(function()
            return execReq({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["User-Agent"] = "KeyForgeLoader/2.0"
                },
                Body = body
            })
        end)
        if ok and res and (res.Body or res.body) then
            return res.Body or res.body
        end
    end

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)
    if success and response and response.Body then
        return response.Body
    end
    return nil
end

local function canWrite()
    return type(writefile) == "function" and type(isfile) == "function" and type(makefolder) == "function"
end

local function ensureFolder(path)
    if not canWrite() then
        return false
    end
    local ok, exists = pcall(function()
        return isfolder(path)
    end)
    if ok and not exists then
        pcall(function()
            makefolder(path)
        end)
    end
    return true
end

local function getSavedKey()
    if canWrite() then
        ensureFolder(storage_config.Folder)
        local filePath = storage_config.Folder .. "/" .. storage_config.FileForPlace
        local ok, data = pcall(function()
            if isfile(filePath) then
                return readfile(filePath)
            end
            return nil
        end)
        if ok and data and data ~= "" then
            return data
        end
    end

    _G.__KF_SavedKeys = _G.__KF_SavedKeys or {}
    local cached = _G.__KF_SavedKeys[storage_config.FileForPlace]
    if cached and cached ~= "" then
        return cached
    end

    return nil
end

local function saveKey(key)
    if not key or key == "" then
        return
    end
    if canWrite() then
        ensureFolder(storage_config.Folder)
        local filePath = storage_config.Folder .. "/" .. storage_config.FileForPlace
        pcall(function()
            writefile(filePath, key)
        end)
    end
    _G.__KF_SavedKeys = _G.__KF_SavedKeys or {}
    _G.__KF_SavedKeys[storage_config.FileForPlace] = key
end

local function safeLoadScript(source)
    if typeof(source) ~= "string" then
        return false, "invalid source"
    end
    local loaderFunc
    if type(loadstring) == "function" then
        local ok, fn = pcall(loadstring, source)
        if not ok or type(fn) ~= "function" then
            return false, fn or "loadstring failed"
        end
        loaderFunc = fn
    elseif type(load) == "function" then
        local ok, fn = pcall(load, source)
        if not ok or type(fn) ~= "function" then
            return false, fn or "load failed"
        end
        loaderFunc = fn
    else
        return false, "no loadstring/load available"
    end

    local ok, err = pcall(loaderFunc)
    return ok, err
end

local function fetchUrl(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and result and result ~= "" then
        return result
    end

    local execReq = getExecutorRequest()
    if execReq then
        local ok2, res = pcall(function()
            return execReq({ Url = url, Method = "GET" })
        end)
        if ok2 and res and (res.Body or res.body) then
            return res.Body or res.body
        end
    end
    return nil
end

local function runRemote(url)
    local body = fetchUrl(url)
    if not body or body == "" then
        return false, "empty response"
    end
    return safeLoadScript(body)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Enabled = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.ClipsDescendants = true
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Name = "MainFrame"
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 372, 0, 292)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundColor3 = Color3.fromRGB(loader_config.BackgroundColor[1], loader_config.BackgroundColor[2], loader_config.BackgroundColor[3])
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 3)
FrameCorner.Parent = MainFrame

local Header = Instance.new("Frame")
Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
Header.AnchorPoint = Vector2.new(0.5, 0)
Header.Name = "Header"
Header.Position = UDim2.new(0.5, 0, 0, 0)
Header.Size = UDim2.new(0, 374, 0, 28)
Header.ZIndex = 15
Header.BorderSizePixel = 0
Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 3)
HeaderCorner.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Rotation = 90
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(loader_config.HeaderColor[1], loader_config.HeaderColor[2], loader_config.HeaderColor[3])),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 20))
}
HeaderGradient.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.AnchorPoint = Vector2.new(0, 1)
HeaderLine.Name = "Liner"
HeaderLine.Position = UDim2.new(0, 0, 1, 0)
HeaderLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
HeaderLine.Size = UDim2.new(1, 1, 0, 1)
HeaderLine.BorderSizePixel = 0
HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderLine.Parent = Header

local HeaderLineGradient = Instance.new("UIGradient")
HeaderLineGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 57, 73)),
    ColorSequenceKeypoint.new(0.495, Color3.fromRGB(38, 81, 103)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 57, 73))
}
HeaderLineGradient.Parent = HeaderLine

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.RichText = true
HeaderTitle.Name = "LoaderName"
HeaderTitle.TextColor3 = Color3.fromRGB(168, 168, 168)
HeaderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
HeaderTitle.Text = "KeyForge Hub"
HeaderTitle.Size = UDim2.new(0, 1, 0, 1)
HeaderTitle.TextStrokeTransparency = 0.5
HeaderTitle.AnchorPoint = Vector2.new(0, 0.5)
HeaderTitle.BorderSizePixel = 0
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Position = UDim2.new(0, 9, 0.5, 0)
HeaderTitle.AutomaticSize = Enum.AutomaticSize.XY
HeaderTitle.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
HeaderTitle.TextSize = 14
HeaderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.Parent = Header

local Exit_Button = Instance.new("ImageButton")
Exit_Button.ImageColor3 = Color3.fromRGB(168, 168, 168)
Exit_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
Exit_Button.Name = "Exit_Button"
Exit_Button.AnchorPoint = Vector2.new(1, 0.5)
Exit_Button.Image = "rbxassetid://79993078202649"
Exit_Button.BackgroundTransparency = 1
Exit_Button.Position = UDim2.new(1, -9, 0.5, 0)
Exit_Button.Size = UDim2.new(0, 15, 0, 15)
Exit_Button.BorderSizePixel = 0
Exit_Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Exit_Button.Parent = Header

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(37, 90, 119)
MainStroke.Parent = MainFrame

local BG_TEXTURE = Instance.new("ImageLabel")
BG_TEXTURE.ScaleType = Enum.ScaleType.Slice
BG_TEXTURE.ImageTransparency = 0.98
BG_TEXTURE.BorderColor3 = Color3.fromRGB(0, 0, 0)
BG_TEXTURE.Name = "BG_TEXTURE"
BG_TEXTURE.Image = "rbxassetid://136562337748317"
BG_TEXTURE.BackgroundTransparency = 1
BG_TEXTURE.Size = UDim2.new(1, 1, 1, 1)
BG_TEXTURE.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BG_TEXTURE.BorderSizePixel = 0
BG_TEXTURE.SliceCenter = Rect.new(Vector2.new(1000, 0), Vector2.new(1000, 267))
BG_TEXTURE.Parent = MainFrame
BG_TEXTURE.ZIndex = -5

local ProductHolder = Instance.new("Frame")
ProductHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
ProductHolder.AnchorPoint = Vector2.new(0, 1)
ProductHolder.BackgroundTransparency = 1
ProductHolder.Position = UDim2.new(0, 9, 1, -49)
ProductHolder.Name = "ProductHolder"
ProductHolder.Size = UDim2.new(0, 115, 0, 205)
ProductHolder.BorderSizePixel = 0
ProductHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProductHolder.Parent = MainFrame

local Container = Instance.new("ScrollingFrame")
Container.ScrollBarImageColor3 = Color3.fromRGB(loader_config.AccentColor[1], loader_config.AccentColor[2], loader_config.AccentColor[3])
Container.Active = true
Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
Container.ScrollBarThickness = 0
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(-0.0782608687877655, 0, 0, 0)
Container.Name = "Container"
Container.Size = UDim2.new(0, 124, 0, 205)
Container.BorderSizePixel = 0
Container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Container.Parent = ProductHolder

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y + UIListLayout.Padding.Offset)
end)

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 9)
UIPadding.PaddingLeft = UDim.new(0, 9)
UIPadding.Parent = Container

local SelectedProductInfo = Instance.new("Frame")
SelectedProductInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
SelectedProductInfo.AnchorPoint = Vector2.new(1, 1)
SelectedProductInfo.BackgroundTransparency = 0.65
SelectedProductInfo.Position = UDim2.new(1, -9, 1, -49)
SelectedProductInfo.Name = "SelectedProductInfo"
SelectedProductInfo.Size = UDim2.new(0, 232, 0, 196)
SelectedProductInfo.BorderSizePixel = 0
SelectedProductInfo.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
SelectedProductInfo.Parent = MainFrame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 3)
UICorner3.Parent = SelectedProductInfo

local UIStroke3 = Instance.new("UIStroke")
UIStroke3.Color = Color3.fromRGB(43, 43, 43)
UIStroke3.Parent = SelectedProductInfo

local InfoHeader = Instance.new("Frame")
InfoHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
InfoHeader.AnchorPoint = Vector2.new(0.5, 0)
InfoHeader.Name = "Header"
InfoHeader.Position = UDim2.new(0.4978448152542114, 0, 0, 0)
InfoHeader.Size = UDim2.new(0, 231, 0, 28)
InfoHeader.ZIndex = 15
InfoHeader.BorderSizePixel = 0
InfoHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InfoHeader.Parent = SelectedProductInfo

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 3)
UICorner4.Parent = InfoHeader

local UIGradient2 = Instance.new("UIGradient")
UIGradient2.Rotation = 90
UIGradient2.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(loader_config.HeaderColor[1], loader_config.HeaderColor[2], loader_config.HeaderColor[3])),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 20))
}
UIGradient2.Parent = InfoHeader

local Liner2 = Instance.new("Frame")
Liner2.AnchorPoint = Vector2.new(0, 1)
Liner2.Name = "Liner"
Liner2.Position = UDim2.new(0, 0, 1, 0)
Liner2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Liner2.Size = UDim2.new(1, 1, 0, 1)
Liner2.BorderSizePixel = 0
Liner2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Liner2.Parent = InfoHeader

local UIGradientLiner2 = Instance.new("UIGradient")
UIGradientLiner2.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 57, 73)),
    ColorSequenceKeypoint.new(0.495, Color3.fromRGB(38, 81, 103)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 57, 73))
}
UIGradientLiner2.Parent = Liner2

local SelectedProduct = Instance.new("TextLabel")
SelectedProduct.RichText = true
SelectedProduct.Name = "SelectedProduct"
SelectedProduct.TextColor3 = Color3.fromRGB(168, 168, 168)
SelectedProduct.BorderColor3 = Color3.fromRGB(0, 0, 0)
SelectedProduct.Text = "Select Product"
SelectedProduct.Size = UDim2.new(0, 1, 0, 1)
SelectedProduct.TextStrokeTransparency = 0.5
SelectedProduct.AnchorPoint = Vector2.new(0, 0.5)
SelectedProduct.BorderSizePixel = 0
SelectedProduct.BackgroundTransparency = 1
SelectedProduct.Position = UDim2.new(0, 9, 0.5, 0)
SelectedProduct.AutomaticSize = Enum.AutomaticSize.XY
SelectedProduct.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
SelectedProduct.TextSize = 14
SelectedProduct.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SelectedProduct.Parent = InfoHeader

local InfoHolder = Instance.new("Frame")
InfoHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
InfoHolder.AnchorPoint = Vector2.new(0.5, 1)
InfoHolder.BackgroundTransparency = 1
InfoHolder.Position = UDim2.new(0.4978448152542114, 0, 1, 0)
InfoHolder.Name = "InfoHolder"
InfoHolder.Size = UDim2.new(0, 231, 0, 166)
InfoHolder.BorderSizePixel = 0
InfoHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InfoHolder.Parent = SelectedProductInfo

local UIListLayout2 = Instance.new("UIListLayout")
UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout2.Parent = InfoHolder

local Seperator = Instance.new("Frame")
Seperator.BackgroundTransparency = 1
Seperator.Name = "Seperator"
Seperator.BorderColor3 = Color3.fromRGB(0, 0, 0)
Seperator.Size = UDim2.new(0, 231, 0, 25)
Seperator.BorderSizePixel = 0
Seperator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Seperator.Visible = false
Seperator.Parent = InfoHolder

local Liner3 = Instance.new("Frame")
Liner3.AnchorPoint = Vector2.new(0.5, 0.5)
Liner3.Name = "Liner"
Liner3.Position = UDim2.new(0.48051944375038147, 0, 0.5, 0)
Liner3.BorderColor3 = Color3.fromRGB(0, 0, 0)
Liner3.Size = UDim2.new(0.9567098617553711, 1, 0, 1)
Liner3.BorderSizePixel = 0
Liner3.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
Liner3.Parent = Seperator

local DividerLabel = Instance.new("TextLabel")
DividerLabel.RichText = true
DividerLabel.TextColor3 = Color3.fromRGB(132, 132, 132)
DividerLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
DividerLabel.Text = "INFORMATION"
DividerLabel.BorderSizePixel = 0
DividerLabel.TextStrokeTransparency = 0.5
DividerLabel.AnchorPoint = Vector2.new(0, 0.5)
DividerLabel.Size = UDim2.new(0, 2, 0, 1)
DividerLabel.Name = "DividerLabel"
DividerLabel.Position = UDim2.new(0, 0, 0.5, 0)
DividerLabel.AutomaticSize = Enum.AutomaticSize.XY
DividerLabel.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
DividerLabel.TextSize = 14
DividerLabel.BackgroundColor3 = Color3.fromRGB(13, 13, 14)
DividerLabel.Parent = Liner3

local UIPadding3 = Instance.new("UIPadding")
UIPadding3.PaddingRight = UDim.new(0, 10)
UIPadding3.PaddingLeft = UDim.new(0, 10)
UIPadding3.Parent = DividerLabel

local LoadButton = Instance.new("Frame")
LoadButton.AnchorPoint = Vector2.new(0.5, 1)
LoadButton.Name = "LoadButton"
LoadButton.Position = UDim2.new(0.5, 0, 1, -9)
LoadButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadButton.Size = UDim2.new(0, 352, 0, 30)
LoadButton.BorderSizePixel = 0
LoadButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.Parent = MainFrame

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 3)
LoadCorner.Parent = LoadButton

local LoadGradient = Instance.new("UIGradient")
LoadGradient.Rotation = 90
LoadGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 31, 31)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 20))
}
LoadGradient.Parent = LoadButton

local LoadStroke = Instance.new("UIStroke")
LoadStroke.Color = Color3.fromRGB(43, 43, 43)
LoadStroke.Parent = LoadButton

local LoadButtonLabel = Instance.new("TextLabel")
LoadButtonLabel.RichText = true
LoadButtonLabel.Name = "LoaderName"
LoadButtonLabel.TextColor3 = Color3.fromRGB(168, 168, 168)
LoadButtonLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadButtonLabel.Text = "inject"
LoadButtonLabel.Size = UDim2.new(0, 1, 0, 1)
LoadButtonLabel.TextStrokeTransparency = 0.5
LoadButtonLabel.AnchorPoint = Vector2.new(0.5, 0.5)
LoadButtonLabel.BorderSizePixel = 0
LoadButtonLabel.BackgroundTransparency = 1
LoadButtonLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadButtonLabel.AutomaticSize = Enum.AutomaticSize.XY
LoadButtonLabel.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
LoadButtonLabel.TextSize = 14
LoadButtonLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadButtonLabel.Parent = LoadButton

local LoadButtonClickable = Instance.new("TextButton")
LoadButtonClickable.Name = "LoadButtonClickable"
LoadButtonClickable.Text = ""
LoadButtonClickable.BackgroundTransparency = 1
LoadButtonClickable.Size = UDim2.new(1, 0, 1, 0)
LoadButtonClickable.Position = UDim2.new(0, 0, 0, 0)
LoadButtonClickable.Parent = LoadButton

local KeyContainer = Instance.new("Frame")
KeyContainer.Name = "KeyContainer"
KeyContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
KeyContainer.Size = UDim2.new(1, -18, 1, -44)
KeyContainer.Position = UDim2.new(0, 9, 0, 30)
KeyContainer.BorderSizePixel = 0
KeyContainer.Parent = MainFrame

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 4)
KeyCorner.Parent = KeyContainer

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(43, 43, 43)
KeyStroke.Parent = KeyContainer

local KeyInnerGradient = Instance.new("UIGradient")
KeyInnerGradient.Rotation = 90
KeyInnerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 13, 13))
}
KeyInnerGradient.Parent = KeyContainer

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Name = "KeyTitle"
KeyTitle.Text = "KeyForge Hub"
KeyTitle.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
KeyTitle.TextSize = 16
KeyTitle.TextColor3 = Color3.fromRGB(168, 168, 168)
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
KeyTitle.BackgroundTransparency = 1
KeyTitle.Position = UDim2.new(0, 12, 0, 10)
KeyTitle.Size = UDim2.new(1, -24, 0, 20)
KeyTitle.Parent = KeyContainer

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Name = "KeyStatus"
KeyStatus.Text = "Enter your KeyForge key."
KeyStatus.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
KeyStatus.TextSize = 14
KeyStatus.TextColor3 = Color3.fromRGB(132, 132, 132)
KeyStatus.TextXAlignment = Enum.TextXAlignment.Left
KeyStatus.BackgroundTransparency = 1
KeyStatus.Position = UDim2.new(0, 12, 0, 34)
KeyStatus.Size = UDim2.new(1, -24, 0, 18)
KeyStatus.Parent = KeyContainer

local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Text = ""
KeyInput.PlaceholderText = "KF-XXXXX-XXXXX-XXXXX"
KeyInput.ClearTextOnFocus = false
KeyInput.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
KeyInput.TextSize = 15
KeyInput.TextColor3 = Color3.fromRGB(168, 168, 168)
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyInput.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
KeyInput.BorderSizePixel = 0
KeyInput.Position = UDim2.new(0, 12, 0, 64)
KeyInput.Size = UDim2.new(1, -24, 0, 32)
KeyInput.Parent = KeyContainer

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 4)
KeyInputCorner.Parent = KeyInput

local KeyInputStroke = Instance.new("UIStroke")
KeyInputStroke.Color = Color3.fromRGB(43, 43, 43)
KeyInputStroke.Parent = KeyInput

local ButtonsRow = Instance.new("Frame")
ButtonsRow.BackgroundTransparency = 1
ButtonsRow.Position = UDim2.new(0, 12, 0, 106)
ButtonsRow.Size = UDim2.new(1, -24, 0, 32)
ButtonsRow.Parent = KeyContainer

local ButtonsLayout = Instance.new("UIListLayout")
ButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
ButtonsLayout.Padding = UDim.new(0, 10)
ButtonsLayout.Parent = ButtonsRow

local function createKeyButton(text, color)
    local button = Instance.new("TextButton")
    button.Text = text
    button.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(180, 180, 180)
    button.BackgroundColor3 = color
    button.AutoButtonColor = false
    button.Size = UDim2.new(0, 95, 1, 0)
    button.Parent = ButtonsRow

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = color:Lerp(Color3.new(0, 0, 0), 0.2)
    stroke.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.1)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = color
        }):Play()
    end)

    return button
end

local KeyProgressBar = Instance.new("Frame")
KeyProgressBar.AnchorPoint = Vector2.new(0.5, 1)
KeyProgressBar.Name = "KeyProgress"
KeyProgressBar.Position = UDim2.new(0.5, 0, 1, -12)
KeyProgressBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
KeyProgressBar.Size = UDim2.new(1, -24, 0, 6)
KeyProgressBar.BorderSizePixel = 0
KeyProgressBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
KeyProgressBar.Parent = KeyContainer

local KeyProgressCorner = Instance.new("UICorner")
KeyProgressCorner.Parent = KeyProgressBar

local KeyProgressInner = Instance.new("Frame")
KeyProgressInner.Name = "KeyProgressInner"
KeyProgressInner.AnchorPoint = Vector2.new(0, 0.5)
KeyProgressInner.Position = UDim2.new(0, 0, 0.5, 0)
KeyProgressInner.Size = UDim2.new(0, 0, 0, 6)
KeyProgressInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KeyProgressInner.BorderSizePixel = 0
KeyProgressInner.Parent = KeyProgressBar

local KeyProgressCornerInner = Instance.new("UICorner")
KeyProgressCornerInner.Parent = KeyProgressInner

local KeyProgressGradient = Instance.new("UIGradient")
KeyProgressGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 57, 73)),
    ColorSequenceKeypoint.new(0.495, Color3.fromRGB(38, 81, 103)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 57, 73))
}
KeyProgressGradient.Parent = KeyProgressInner

local RedeemButton = createKeyButton("Redeem", Color3.fromRGB(31, 31, 31))
local CopyKeyButton = createKeyButton("Get Key", Color3.fromRGB(21, 21, 21))
local DiscordButton = createKeyButton("Discord", Color3.fromRGB(21, 21, 21))

local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

Exit_Button.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local function setLoaderVisible(state)
    ProductHolder.Visible = state
    SelectedProductInfo.Visible = state
    LoadButton.Visible = state
end

setLoaderVisible(false)

local function setKeyStatus(text, color)
    KeyStatus.Text = text
    if color then
        TweenService:Create(KeyStatus, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = color
        }):Play()
    end
end

local keyBusy = false
local activeKeyTween = nil

local function resetKeyProgress()
    if activeKeyTween then
        activeKeyTween:Cancel()
    end
    KeyProgressInner.Size = UDim2.new(0, 0, 0, 6)
end

local function runKeyProgress(duration)
    resetKeyProgress()
    activeKeyTween = TweenService:Create(KeyProgressInner, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(1, 0, 0, 6)
    })
    activeKeyTween:Play()
end

local function transitionToLoader()
    HeaderTitle.Text = loader_config.LoaderName
    setKeyStatus("Key accepted. Loading loader...", Color3.fromRGB(loader_config.AccentColor[1], loader_config.AccentColor[2], loader_config.AccentColor[3]))
    TweenService:Create(KeyContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.2, function()
        KeyContainer.Visible = false
        setLoaderVisible(true)
    end)
end

local function redeemKey()
    if keyBusy then
        return
    end

    local key = (KeyInput.Text or ""):gsub("%s+", "")
    if key == "" then
        setKeyStatus("Please enter a key first.", Color3.fromRGB(255, 170, 0))
        return
    end
    if not key:match("^KF%-%w+") then
        setKeyStatus("Key format should start with KF-", Color3.fromRGB(255, 90, 90))
        return
    end

    keyBusy = true
    setKeyStatus("Validating key...", Color3.fromRGB(loader_config.AccentColor[1], loader_config.AccentColor[2], loader_config.AccentColor[3]))
    runKeyProgress(1.8)

    task.spawn(function()
        local hwid = tostring(Players.LocalPlayer.UserId) .. "-" .. Players.LocalPlayer.Name
        local response = httpPost(key_config.ValidateUrl, {
            key = key,
            hwid = hwid,
            userAgent = "KeyForgeLoader/1.0",
            action = "validate"
        })

        if not response then
            setKeyStatus("Network error.", Color3.fromRGB(255, 90, 90))
            keyBusy = false
            resetKeyProgress()
            return
        end

        local ok, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if not ok or not data then
            setKeyStatus("Server error.", Color3.fromRGB(255, 90, 90))
            keyBusy = false
            resetKeyProgress()
            return
        end

        if data.success then
            _G.KeyForgeValidated = true
            _G.KeyForgeData = { key = key, validatedAt = os.time(), hwid = hwid }
            saveKey(key)
            setKeyStatus("Key validated!", Color3.fromRGB(0, 255, 106))
            TweenService:Create(KeyProgressInner, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
                Size = UDim2.new(1, 0, 0, 6)
            }):Play()
            task.delay(0.4, function()
                transitionToLoader()
            end)
        else
            setKeyStatus(data.error or "Invalid key.", Color3.fromRGB(255, 90, 90))
            resetKeyProgress()
            keyBusy = false
        end
    end)
end

RedeemButton.MouseButton1Click:Connect(redeemKey)

CopyKeyButton.MouseButton1Click:Connect(function()
    if setClipboard(key_config.GetKeyUrl) then
        setKeyStatus("Get key link copied.", Color3.fromRGB(0, 255, 106))
    else
        setKeyStatus("Clipboard unavailable.", Color3.fromRGB(255, 170, 0))
    end
end)

DiscordButton.MouseButton1Click:Connect(function()
    if setClipboard(key_config.DiscordUrl) then
        setKeyStatus("Discord copied.", Color3.fromRGB(0, 255, 106))
    else
        setKeyStatus("Clipboard unavailable.", Color3.fromRGB(255, 170, 0))
    end
end)

KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        redeemKey()
    end
end)

task.defer(function()
    local saved = getSavedKey()
    if saved and saved ~= "" then
        KeyInput.Text = saved
        setKeyStatus("Using saved key for this game.", Color3.fromRGB(0, 255, 106))
        task.wait(0.1)
        redeemKey()
    end
end)

function Loader:CreateProduct(config)
    local product = {
        Name = config.Name or "Product",
        Icon = config.Icon or defaultIcon,
        Callback = config.Callback or function() end,
        Info = config.Info or {}
    }

    local ProductFrame = Instance.new("Frame")
    ProductFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ProductFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ProductFrame.BackgroundTransparency = 1
    ProductFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ProductFrame.Name = "Product"
    ProductFrame.Size = UDim2.new(0, 110, 0, 30)
    ProductFrame.BorderSizePixel = 0
    ProductFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ProductFrame.Parent = Container

    local ProductName = Instance.new("TextLabel")
    ProductName.RichText = true
    ProductName.Name = "ProductName"
    ProductName.TextColor3 = Color3.fromRGB(167, 167, 167)
    ProductName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ProductName.Text = product.Name
    ProductName.Size = UDim2.new(0, 1, 0, 1)
    ProductName.TextStrokeTransparency = 0.5
    ProductName.AnchorPoint = Vector2.new(0, 0.5)
    ProductName.BorderSizePixel = 0
    ProductName.BackgroundTransparency = 1
    ProductName.Position = UDim2.new(0, 29, 0.5, 0)
    ProductName.AutomaticSize = Enum.AutomaticSize.XY
    ProductName.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    ProductName.TextSize = 14
    ProductName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ProductName.Parent = ProductFrame

    local ProductCorner = Instance.new("UICorner")
    ProductCorner.CornerRadius = UDim.new(0, 3)
    ProductCorner.Parent = ProductFrame

    local ProductGradient = Instance.new("UIGradient")
    ProductGradient.Rotation = 90
    ProductGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 31, 31)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 20))
    }
    ProductGradient.Parent = ProductFrame

    local Icon = Instance.new("ImageLabel")
    Icon.ImageColor3 = Color3.fromRGB(133, 133, 133)
    Icon.ImageTransparency = 0.4
    Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Icon.Name = "Icon"
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.Image = product.Icon
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 7, 0.5, 0)
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.BorderSizePixel = 0
    Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Icon.Parent = ProductFrame

    local ProductClickable = Instance.new("TextButton")
    ProductClickable.Name = "ProductClickable"
    ProductClickable.Text = ""
    ProductClickable.BackgroundTransparency = 1
    ProductClickable.Size = UDim2.new(1, 0, 1, 0)
    ProductClickable.Position = UDim2.new(0, 0, 0, 0)
    ProductClickable.Parent = ProductFrame

    ProductClickable.MouseButton1Click:Connect(function()
        for _, otherProduct in pairs(Products) do
            if otherProduct.frame then
                otherProduct.frame.BackgroundTransparency = 1
                local otherStroke = otherProduct.frame:FindFirstChild("UIStroke")
                if otherStroke then otherStroke:Destroy() end
                otherProduct.frame:FindFirstChild("Icon").ImageColor3 = Color3.fromRGB(133, 133, 133)
                otherProduct.frame:FindFirstChild("Icon").ImageTransparency = 0.4
                otherProduct.frame:FindFirstChild("ProductName").TextColor3 = Color3.fromRGB(167, 167, 167)
            end
        end

        ProductFrame.BackgroundTransparency = 0
        local newStroke = Instance.new("UIStroke")
        newStroke.Color = Color3.fromRGB(43, 43, 43)
        newStroke.Parent = ProductFrame

        Icon.ImageColor3 = Color3.fromRGB(loader_config.AccentColor[1], loader_config.AccentColor[2], loader_config.AccentColor[3])
        Icon.ImageTransparency = 0.5
        ProductName.TextColor3 = Color3.fromRGB(168, 168, 168)

        CurrentProduct = product
        SelectedProduct.Text = product.Name .. " Info"

        Seperator.Visible = true

        for _, child in pairs(InfoHolder:GetChildren()) do
            if child.Name ~= "UIListLayout" and child.Name ~= "Seperator" then
                child:Destroy()
            end
        end

        LeftLabel = nil
        RightLabel = nil

        if product.Info then
            for key, value in pairs(product.Info) do
                if key == "Separator" then
                    Loader:CreateSeparator(value)
                else
                    Loader:CreateLabel(key, value)
                end
            end
        end
    end)

    product.frame = ProductFrame
    table.insert(Products, product)
    return product
end

function Loader:CreateLabel(leftText, rightText)
    local Component_Label = Instance.new("Frame")
    Component_Label.Name = "Component_Label"
    Component_Label.BackgroundTransparency = 1
    Component_Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Component_Label.Size = UDim2.new(0, 231, 0, 25)
    Component_Label.BorderSizePixel = 0
    Component_Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Component_Label.Parent = InfoHolder

    local LeftTextLabel = Instance.new("TextLabel")
    LeftTextLabel.RichText = true
    LeftTextLabel.Name = "LeftTextLabel"
    LeftTextLabel.TextColor3 = Color3.fromRGB(132, 132, 132)
    LeftTextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LeftTextLabel.Text = leftText
    LeftTextLabel.Size = UDim2.new(0, 2, 0, 1)
    LeftTextLabel.TextStrokeTransparency = 0.5
    LeftTextLabel.AnchorPoint = Vector2.new(0, 0.5)
    LeftTextLabel.BorderSizePixel = 0
    LeftTextLabel.BackgroundTransparency = 1
    LeftTextLabel.Position = UDim2.new(0, 9, 0.5, 0)
    LeftTextLabel.AutomaticSize = Enum.AutomaticSize.XY
    LeftTextLabel.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    LeftTextLabel.TextSize = 14
    LeftTextLabel.BackgroundColor3 = Color3.fromRGB(13, 13, 14)
    LeftTextLabel.Parent = Component_Label

    local RightTextLabel = Instance.new("TextLabel")
    RightTextLabel.RichText = true
    RightTextLabel.Name = "RightTextLabel"
    RightTextLabel.TextColor3 = Color3.fromRGB(132, 132, 132)
    RightTextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    RightTextLabel.Text = rightText
    RightTextLabel.Size = UDim2.new(0, 1, 0, 1)
    RightTextLabel.TextStrokeTransparency = 0.5
    RightTextLabel.AnchorPoint = Vector2.new(1, 0.5)
    RightTextLabel.BorderSizePixel = 0
    RightTextLabel.BackgroundTransparency = 1
    RightTextLabel.Position = UDim2.new(1, -9, 0.5, 0)
    RightTextLabel.AutomaticSize = Enum.AutomaticSize.XY
    RightTextLabel.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    RightTextLabel.TextSize = 14
    RightTextLabel.BackgroundColor3 = Color3.fromRGB(13, 13, 14)
    RightTextLabel.Parent = Component_Label

    return Component_Label
end

function Loader:CreateSeparator(text)
    local SeparatorFrame = Instance.new("Frame")
    SeparatorFrame.BackgroundTransparency = 1
    SeparatorFrame.Name = "CustomSeparator"
    SeparatorFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SeparatorFrame.Size = UDim2.new(0, 231, 0, 25)
    SeparatorFrame.BorderSizePixel = 0
    SeparatorFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SeparatorFrame.Parent = InfoHolder

    local SeparatorLiner = Instance.new("Frame")
    SeparatorLiner.AnchorPoint = Vector2.new(0.5, 0.5)
    SeparatorLiner.Name = "Liner"
    SeparatorLiner.Position = UDim2.new(0.48051944375038147, 0, 0.5, 0)
    SeparatorLiner.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SeparatorLiner.Size = UDim2.new(0.9567098617553711, 1, 0, 1)
    SeparatorLiner.BorderSizePixel = 0
    SeparatorLiner.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
    SeparatorLiner.Parent = SeparatorFrame

    local SeparatorLabel = Instance.new("TextLabel")
    SeparatorLabel.RichText = true
    SeparatorLabel.TextColor3 = Color3.fromRGB(132, 132, 132)
    SeparatorLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SeparatorLabel.Text = text
    SeparatorLabel.BorderSizePixel = 0
    SeparatorLabel.TextStrokeTransparency = 0.5
    SeparatorLabel.AnchorPoint = Vector2.new(0, 0.5)
    SeparatorLabel.Size = UDim2.new(0, 2, 0, 1)
    SeparatorLabel.Name = "SeparatorLabel"
    SeparatorLabel.Position = UDim2.new(0, 0, 0.5, 0)
    SeparatorLabel.AutomaticSize = Enum.AutomaticSize.XY
    SeparatorLabel.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    SeparatorLabel.TextSize = 14
    SeparatorLabel.BackgroundColor3 = Color3.fromRGB(13, 13, 14)
    SeparatorLabel.Parent = SeparatorLiner

    local SeparatorPadding = Instance.new("UIPadding")
    SeparatorPadding.PaddingRight = UDim.new(0, 10)
    SeparatorPadding.PaddingLeft = UDim.new(0, 10)
    SeparatorPadding.Parent = SeparatorLabel

    return SeparatorFrame
end

LoadButtonClickable.MouseButton1Click:Connect(function()
    if not CurrentProduct or not CurrentProduct.Callback then
        return
    end

    ProductHolder.Visible = false
    SelectedProductInfo.Visible = false
    LoadButton.Visible = false

    local tweenInfo = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )

    local mainFrameTween = TweenService:Create(MainFrame, tweenInfo, {
        Size = UDim2.new(0, 288, 0, 188)
    })

    local headerTween = TweenService:Create(Header, tweenInfo, {
        Size = UDim2.new(0, 289, 0, 28)
    })

    mainFrameTween:Play()
    headerTween:Play()

    mainFrameTween.Completed:Connect(function()
        HeaderTitle.Text = loader_config.LoaderName

        local LoadingMessage = Instance.new("TextLabel")
        LoadingMessage.FontFace = Font.new("rbxassetid://6026663726", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        LoadingMessage.TextTransparency = 0.25
        LoadingMessage.TextStrokeTransparency = 0.5
        LoadingMessage.AnchorPoint = Vector2.new(0.5, 1)
        LoadingMessage.TextSize = 14
        LoadingMessage.Size = UDim2.new(0, 1, 0, 1)
        LoadingMessage.RichText = true
        LoadingMessage.TextColor3 = Color3.fromRGB(168, 168, 168)
        LoadingMessage.BorderColor3 = Color3.fromRGB(0, 0, 0)
        LoadingMessage.Text = "Loading " .. CurrentProduct.Name .. "..."
        LoadingMessage.BackgroundTransparency = 1
        LoadingMessage.Position = UDim2.new(0.5, 0, 1, -92)
        LoadingMessage.Name = "LoadingMessage"
        LoadingMessage.BorderSizePixel = 0
        LoadingMessage.AutomaticSize = Enum.AutomaticSize.XY
        LoadingMessage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        LoadingMessage.Parent = MainFrame

        local Progressbar = Instance.new("Frame")
        Progressbar.AnchorPoint = Vector2.new(0.5, 1)
        Progressbar.Name = "Progressbar"
        Progressbar.Position = UDim2.new(0.5, 0, 1, -74)
        Progressbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Progressbar.Size = UDim2.new(0, 173, 0, 6)
        Progressbar.BorderSizePixel = 0
        Progressbar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
        Progressbar.Parent = MainFrame

        local ProgressbarCorner = Instance.new("UICorner")
        ProgressbarCorner.Parent = Progressbar

        local Progressbar_Progress = Instance.new("Frame")
        Progressbar_Progress.AnchorPoint = Vector2.new(0, 0.5)
        Progressbar_Progress.Name = "Progressbar_Progress"
        Progressbar_Progress.Position = UDim2.new(0, 0, 0.5, 0)
        Progressbar_Progress.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Progressbar_Progress.Size = UDim2.new(0, 0, 0, 6)
        Progressbar_Progress.BorderSizePixel = 0
        Progressbar_Progress.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Progressbar_Progress.Parent = Progressbar

        local ProgressCorner = Instance.new("UICorner")
        ProgressCorner.Parent = Progressbar_Progress

        local ProgressGradient = Instance.new("UIGradient")
        ProgressGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 57, 73)),
            ColorSequenceKeypoint.new(0.495, Color3.fromRGB(38, 81, 103)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 57, 73))
        }
        ProgressGradient.Parent = Progressbar_Progress

        local progressTween = TweenService:Create(Progressbar_Progress, TweenInfo.new(2, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 173, 0, 6)
        })
        progressTween:Play()

        progressTween.Completed:Connect(function()
            CurrentProduct.Callback()

            task.wait(0.5)

            local exitTweenInfo = TweenInfo.new(
                0.4,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.In,
                0,
                false,
                0
            )

            local exitTween = TweenService:Create(ScreenGui, exitTweenInfo, {
                Enabled = false
            })

            local scaleTween = TweenService:Create(MainFrame, exitTweenInfo, {
                Size = UDim2.new(0, 0, 0, 0)
            })

            exitTween:Play()
            scaleTween:Play()

            scaleTween.Completed:Connect(function()
                ScreenGui:Destroy()
            end)
        end)
    end)
end)

for _, entry in ipairs(ScriptLibrary) do
    Loader:CreateProduct({
        Name = entry.name,
        Icon = entry.icon,
        Info = entry.info,
        Callback = function()
            local loaderDef = entry.load
            local success = false
            local lastErr

            local function runCodeChunk(chunk)
                local ran, err = safeLoadScript(chunk)
                if ran then
                    success = true
                else
                    lastErr = err
                end
            end

            if typeof(loaderDef) == "table" then
                for _, url in ipairs(loaderDef) do
                    local ran, err = runRemote(url)
                    if ran then
                        success = true
                        break
                    else
                        lastErr = err
                    end
                end
            elseif typeof(loaderDef) == "string" then
                if loaderDef:match("^https?://") then
                    local ran, err = runRemote(loaderDef)
                    success = ran
                    lastErr = err
                else
                    runCodeChunk(loaderDef)
                end
            end

            if not success then
                warn("Failed to load script:", lastErr or "unknown error")
            end
        end
    })
end

return Loader
