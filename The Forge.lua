local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera

-- Variables
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = false
local WallCheckEnabled = false
local AimbotEnabled = false
local AimbotActive = false
local TeamCheckEnabled = false
local Highlights = {}
local GuiVisible = true
local ESPKey = Enum.KeyCode.K
local AimbotKey = Enum.KeyCode.E
local AimbotSmoothness = 0.5
local Minimized = false
local Dragging = false
local DragStartPos = nil
local DragStartMousePos = nil
local CurrentTarget = nil
local SilentAimEnabled = false
local HitChance = 50 -- 0 to 100, where 100 always hits head, 0 is normal
local NoRecoilEnabled = false
local NoSpreadEnabled = false
local HitboxEnabled = false
local HitboxSize = 1.5 -- Default 1.5x, adjustable from 1 to 3
local RainbowESPEnabled = false
local FlyEnabled = false
local Speed = 16 -- Normal speed
local JumpPower = 50 -- Default jump power
local BodyVelocity = nil
local FlySpeed = 0

-- Create Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Create Feedback ScreenGui
local FeedbackGui = Instance.new("ScreenGui")
FeedbackGui.Name = "FeedbackGui"
FeedbackGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
FeedbackGui.ResetOnSpawn = false
FeedbackGui.Enabled = true
FeedbackGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Create Toggle Feedback Label
local ToggleFeedback = Instance.new("TextLabel")
ToggleFeedback.Size = UDim2.new(0, 300, 0, 50)
ToggleFeedback.Position = UDim2.new(0.5, -150, 0, 10)
ToggleFeedback.BackgroundTransparency = 1
ToggleFeedback.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleFeedback.TextSize = 18
ToggleFeedback.Text = ""
ToggleFeedback.ZIndex = 15
ToggleFeedback.Parent = FeedbackGui

-- Create Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 700, 0, 600) -- Increased height to 600 for more space
Frame.Position = UDim2.new(0.5, -350, 0.5, -300)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black base
Frame.BorderSizePixel = 0
Frame.ZIndex = 10
Frame.Parent = ScreenGui

-- Create Gradient for Frame
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)), -- Dark gray
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))    -- Black
}
UIGradient.Rotation = 45
UIGradient.Parent = Frame

-- Create UIStroke for neon glow
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(0, 255, 255) -- Neon cyan
UIStroke.Transparency = 0.3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = Frame

-- Create Sharp Corner for Frame
local UICornerFrame = Instance.new("UICorner")
UICornerFrame.CornerRadius = UDim.new(0, 8)
UICornerFrame.Parent = Frame

-- Create Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- Darker black
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Parent = Frame

-- Create Title Label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 40, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
TitleLabel.Text = "Counter Blox Hack"
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 12
TitleLabel.Parent = TitleBar

-- Create Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -50, 0, 10)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
MinimizeButton.TextSize = 16
MinimizeButton.ZIndex = 12
MinimizeButton.Parent = TitleBar
local UICornerMinimize = Instance.new("UICorner")
UICornerMinimize.CornerRadius = UDim.new(0, 4)
UICornerMinimize.Parent = MinimizeButton

-- Create Expand Button
local ExpandButton = Instance.new("TextButton")
ExpandButton.Size = UDim2.new(0, 20, 0, 20)
ExpandButton.Position = UDim2.new(1, -50, 0, 10)
ExpandButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray
ExpandButton.Text = "+"
ExpandButton.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
ExpandButton.Visible = false
ExpandButton.TextSize = 16
ExpandButton.ZIndex = 12
ExpandButton.Parent = TitleBar
local UICornerExpand = Instance.new("UICorner")
UICornerExpand.CornerRadius = UDim.new(0, 4)
UICornerExpand.Parent = ExpandButton

-- Create Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark gray
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11
Sidebar.Parent = Frame

-- Create Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -150, 1, -40)
ContentArea.Position = UDim2.new(0, 150, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 11
ContentArea.Parent = Frame

-- Sidebar: ESP Tab Button
local ESPTabButton = Instance.new("TextButton")
ESPTabButton.Size = UDim2.new(1, -20, 0, 50)
ESPTabButton.Position = UDim2.new(0, 10, 0, 10)
ESPTabButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan (active)
ESPTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPTabButton.Text = "ESP"
ESPTabButton.TextSize = 18
ESPTabButton.ZIndex = 12
ESPTabButton.Parent = Sidebar

-- Sidebar: Aimbot Tab Button
local AimbotTabButton = Instance.new("TextButton")
AimbotTabButton.Size = UDim2.new(1, -20, 0, 50)
AimbotTabButton.Position = UDim2.new(0, 10, 0, 70)
AimbotTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray (inactive)
AimbotTabButton.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
AimbotTabButton.Text = "Aimbot"
AimbotTabButton.TextSize = 18
AimbotTabButton.ZIndex = 12
AimbotTabButton.Parent = Sidebar

-- Sidebar: Experimental Tab Button
local ExperimentalTabButton = Instance.new("TextButton")
ExperimentalTabButton.Size = UDim2.new(1, -20, 0, 50)
ExperimentalTabButton.Position = UDim2.new(0, 10, 0, 130)
ExperimentalTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray (inactive)
ExperimentalTabButton.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
ExperimentalTabButton.Text = "Experimental"
ExperimentalTabButton.TextSize = 18
ExperimentalTabButton.ZIndex = 12
ExperimentalTabButton.Parent = Sidebar

-- Sidebar: Others Tab Button
local OthersTabButton = Instance.new("TextButton")
OthersTabButton.Size = UDim2.new(1, -20, 0, 50)
OthersTabButton.Position = UDim2.new(0, 10, 0, 190)
OthersTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray (inactive)
OthersTabButton.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
OthersTabButton.Text = "Others"
OthersTabButton.TextSize = 18
OthersTabButton.ZIndex = 12
OthersTabButton.Parent = Sidebar

-- Create Corners for Tab Buttons
local UICornerESPTab = Instance.new("UICorner")
UICornerESPTab.CornerRadius = UDim.new(0, 8)
UICornerESPTab.Parent = ESPTabButton
local UICornerAimbotTab = Instance.new("UICorner")
UICornerAimbotTab.CornerRadius = UDim.new(0, 8)
UICornerAimbotTab.Parent = AimbotTabButton
local UICornerExperimentalTab = Instance.new("UICorner")
UICornerExperimentalTab.CornerRadius = UDim.new(0, 8)
UICornerExperimentalTab.Parent = ExperimentalTabButton
local UICornerOthersTab = Instance.new("UICorner")
UICornerOthersTab.CornerRadius = UDim.new(0, 8)
UICornerOthersTab.Parent = OthersTabButton

-- Create ESP Tab Content
local ESPTabContent = Instance.new("Frame")
ESPTabContent.Size = UDim2.new(0.8, 0, 0.8, 0)
ESPTabContent.Position = UDim2.new(0.1, 0, 0.1, 0)
ESPTabContent.BackgroundTransparency = 1
ESPTabContent.ZIndex = 12
ESPTabContent.Parent = ContentArea
ESPTabContent.Visible = true

-- Create Aimbot Tab Content
local AimbotTabContent = Instance.new("Frame")
AimbotTabContent.Size = UDim2.new(0.8, 0, 0.8, 0)
AimbotTabContent.Position = UDim2.new(0.1, 0, 0.1, 0)
AimbotTabContent.BackgroundTransparency = 1
AimbotTabContent.ZIndex = 12
AimbotTabContent.Parent = ContentArea
AimbotTabContent.Visible = false

-- Create Experimental Tab Content
local ExperimentalTabContent = Instance.new("Frame")
ExperimentalTabContent.Size = UDim2.new(0.8, 0, 0.8, 0)
ExperimentalTabContent.Position = UDim2.new(0.1, 0, 0.1, 0)
ExperimentalTabContent.BackgroundTransparency = 1
ExperimentalTabContent.ZIndex = 12
ExperimentalTabContent.Parent = ContentArea
ExperimentalTabContent.Visible = false

-- Create Others Tab Content
local OthersTabContent = Instance.new("Frame")
OthersTabContent.Size = UDim2.new(0.8, 0, 0.8, 0)
OthersTabContent.Position = UDim2.new(0.1, 0, 0.1, 0)
OthersTabContent.BackgroundTransparency = 1
OthersTabContent.ZIndex = 12
OthersTabContent.Parent = ContentArea
OthersTabContent.Visible = false

-- ESP Tab: Toggle Button
local ESPToggleButton = Instance.new("TextButton")
ESPToggleButton.Size = UDim2.new(0, 300, 0, 50)
ESPToggleButton.Position = UDim2.new(0.5, -150, 0.1, 20) -- Increased vertical spacing
ESPToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
ESPToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggleButton.Text = "ESP: OFF"
ESPToggleButton.TextSize = 18
ESPToggleButton.ZIndex = 13
ESPToggleButton.Parent = ESPTabContent

-- ESP Tab: Keybind TextBox
local ESPKeybindBox = Instance.new("TextBox")
ESPKeybindBox.Size = UDim2.new(0, 300, 0, 40)
ESPKeybindBox.Position = UDim2.new(0.5, -150, 0.1, 80) -- Increased vertical spacing
ESPKeybindBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark gray
ESPKeybindBox.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
ESPKeybindBox.Text = ESPKey.Name
ESPKeybindBox.TextSize = 16
ESPKeybindBox.PlaceholderText = "Enter key (e.g., K, J)"
ESPKeybindBox.ZIndex = 13
ESPKeybindBox.Parent = ESPTabContent

-- ESP Tab: Rainbow ESP Toggle Button
local RainbowESPToggleButton = Instance.new("TextButton")
RainbowESPToggleButton.Size = UDim2.new(0, 300, 0, 50)
RainbowESPToggleButton.Position = UDim2.new(0.5, -150, 0.1, 140) -- Increased vertical spacing
RainbowESPToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
RainbowESPToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RainbowESPToggleButton.Text = "Rainbow ESP: OFF"
RainbowESPToggleButton.TextSize = 18
RainbowESPToggleButton.ZIndex = 13
RainbowESPToggleButton.Parent = ESPTabContent

-- Aimbot Tab: Toggle Button
local AimbotToggleButton = Instance.new("TextButton")
AimbotToggleButton.Size = UDim2.new(0, 300, 0, 50)
AimbotToggleButton.Position = UDim2.new(0.5, -150, 0.1, 20) -- Increased vertical spacing
AimbotToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
AimbotToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggleButton.Text = "Aimbot: OFF"
AimbotToggleButton.TextSize = 18
AimbotToggleButton.ZIndex = 13
AimbotToggleButton.Parent = AimbotTabContent

-- Aimbot Tab: Wall Check Toggle Button
local WallCheckToggleButton = Instance.new("TextButton")
WallCheckToggleButton.Size = UDim2.new(0, 300, 0, 50)
WallCheckToggleButton.Position = UDim2.new(0.5, -150, 0.1, 80) -- Increased vertical spacing
WallCheckToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
WallCheckToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
WallCheckToggleButton.Text = "Wall Check: OFF"
WallCheckToggleButton.TextSize = 18
WallCheckToggleButton.ZIndex = 13
WallCheckToggleButton.Parent = AimbotTabContent

-- Aimbot Tab: Keybind TextBox
local AimbotKeybindBox = Instance.new("TextBox")
AimbotKeybindBox.Size = UDim2.new(0, 300, 0, 40)
AimbotKeybindBox.Position = UDim2.new(0.5, -150, 0.1, 140) -- Increased vertical spacing
AimbotKeybindBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark gray
AimbotKeybindBox.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
AimbotKeybindBox.Text = AimbotKey.Name
AimbotKeybindBox.TextSize = 16
AimbotKeybindBox.PlaceholderText = "Enter key (e.g., E, F)"
AimbotKeybindBox.ZIndex = 13
AimbotKeybindBox.Parent = AimbotTabContent

-- Aimbot Tab: Smoothness Slider
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0, 300, 0, 40)
SliderFrame.Position = UDim2.new(0.5, -150, 0.1, 200) -- Increased vertical spacing
SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark gray
SliderFrame.ZIndex = 13
SliderFrame.Parent = AimbotTabContent
local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0, 280, 0, 10)
SliderBar.Position = UDim2.new(0, 10, 0, 15)
SliderBar.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
SliderBar.ZIndex = 14
SliderBar.Parent = SliderFrame
local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 20, 0, 20)
SliderKnob.Position = UDim2.new(AimbotSmoothness, -10, 0, 10)
SliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan glow
SliderKnob.ZIndex = 15
SliderKnob.Parent = SliderFrame
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(0, 300, 0, 20)
SliderLabel.Position = UDim2.new(0, 0, 0, -5)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
SliderLabel.Text = "Smoothness: " .. string.format("%.2f", AimbotSmoothness)
SliderLabel.TextSize = 16
SliderLabel.ZIndex = 14
SliderLabel.Parent = SliderFrame
local UICornerSlider = Instance.new("UICorner")
UICornerSlider.CornerRadius = UDim.new(0, 4)
UICornerSlider.Parent = SliderFrame

-- Experimental Tab: Team Check Toggle Button
local TeamCheckToggleButton = Instance.new("TextButton")
TeamCheckToggleButton.Size = UDim2.new(0, 300, 0, 50)
TeamCheckToggleButton.Position = UDim2.new(0.5, -150, 0.1, 20) -- Increased vertical spacing
TeamCheckToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
TeamCheckToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamCheckToggleButton.Text = "Team Check: OFF"
TeamCheckToggleButton.TextSize = 18
TeamCheckToggleButton.ZIndex = 13
TeamCheckToggleButton.Parent = ExperimentalTabContent

-- Experimental Tab: Silent Aim Toggle Button
local SilentAimToggleButton = Instance.new("TextButton")
SilentAimToggleButton.Size = UDim2.new(0, 300, 0, 50)
SilentAimToggleButton.Position = UDim2.new(0.5, -150, 0.1, 80) -- Increased vertical spacing
SilentAimToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
SilentAimToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentAimToggleButton.Text = "Silent Aim: OFF"
SilentAimToggleButton.TextSize = 18
SilentAimToggleButton.ZIndex = 13
SilentAimToggleButton.Parent = ExperimentalTabContent

-- Experimental Tab: Hit Chance Slider
local HitChanceSliderFrame = Instance.new("Frame")
HitChanceSliderFrame.Size = UDim2.new(0, 300, 0, 40)
HitChanceSliderFrame.Position = UDim2.new(0.5, -150, 0.1, 140) -- Increased vertical spacing
HitChanceSliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark gray
HitChanceSliderFrame.ZIndex = 13
HitChanceSliderFrame.Parent = ExperimentalTabContent
local HitChanceSliderBar = Instance.new("Frame")
HitChanceSliderBar.Size = UDim2.new(0, 280, 0, 10)
HitChanceSliderBar.Position = UDim2.new(0, 10, 0, 15)
HitChanceSliderBar.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
HitChanceSliderBar.ZIndex = 14
HitChanceSliderBar.Parent = HitChanceSliderFrame
local HitChanceSliderKnob = Instance.new("Frame")
HitChanceSliderKnob.Size = UDim2.new(0, 20, 0, 20)
HitChanceSliderKnob.Position = UDim2.new(HitChance / 100, -10, 0, 10)
HitChanceSliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan glow
HitChanceSliderKnob.ZIndex = 15
HitChanceSliderKnob.Parent = HitChanceSliderFrame
local HitChanceSliderLabel = Instance.new("TextLabel")
HitChanceSliderLabel.Size = UDim2.new(0, 300, 0, 20)
HitChanceSliderLabel.Position = UDim2.new(0, 0, 0, -5)
HitChanceSliderLabel.BackgroundTransparency = 1
HitChanceSliderLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
HitChanceSliderLabel.Text = "Hit Chance: " .. HitChance .. "%"
HitChanceSliderLabel.TextSize = 16
HitChanceSliderLabel.ZIndex = 14
HitChanceSliderLabel.Parent = HitChanceSliderFrame
local UICornerHitChanceSlider = Instance.new("UICorner")
UICornerHitChanceSlider.CornerRadius = UDim.new(0, 4)
UICornerHitChanceSlider.Parent = HitChanceSliderFrame

-- Experimental Tab: No Spread Toggle Button
local NoSpreadToggleButton = Instance.new("TextButton")
NoSpreadToggleButton.Size = UDim2.new(0, 300, 0, 50)
NoSpreadToggleButton.Position = UDim2.new(0.5, -150, 0.1, 200) -- Increased vertical spacing
NoSpreadToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
NoSpreadToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoSpreadToggleButton.Text = "No Spread: OFF"
NoSpreadToggleButton.TextSize = 18
NoSpreadToggleButton.ZIndex = 13
NoSpreadToggleButton.Parent = ExperimentalTabContent

-- Experimental Tab: No Recoil Toggle Button
local NoRecoilToggleButton = Instance.new("TextButton")
NoRecoilToggleButton.Size = UDim2.new(0, 300, 0, 50)
NoRecoilToggleButton.Position = UDim2.new(0.5, -150, 0.1, 260) -- Increased vertical spacing
NoRecoilToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
NoRecoilToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoRecoilToggleButton.Text = "No Recoil: OFF"
NoRecoilToggleButton.TextSize = 18
NoRecoilToggleButton.ZIndex = 13
NoRecoilToggleButton.Parent = ExperimentalTabContent

-- Experimental Tab: Hitbox Changer Toggle Button
local HitboxToggleButton = Instance.new("TextButton")
HitboxToggleButton.Size = UDim2.new(0, 300, 0, 50)
HitboxToggleButton.Position = UDim2.new(0.5, -150, 0.1, 320) -- Increased vertical spacing
HitboxToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
HitboxToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxToggleButton.Text = "Hitbox Changer: OFF"
HitboxToggleButton.TextSize = 18
HitboxToggleButton.ZIndex = 13
HitboxToggleButton.Parent = ExperimentalTabContent

-- Experimental Tab: Hitbox Size Slider
local HitboxSizeSliderFrame = Instance.new("Frame")
HitboxSizeSliderFrame.Size = UDim2.new(0, 300, 0, 40)
HitboxSizeSliderFrame.Position = UDim2.new(0.5, -150, 0.1, 380) -- Increased vertical spacing
HitboxSizeSliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark gray
HitboxSizeSliderFrame.ZIndex = 13
HitboxSizeSliderFrame.Parent = ExperimentalTabContent
local HitboxSizeSliderBar = Instance.new("Frame")
HitboxSizeSliderBar.Size = UDim2.new(0, 280, 0, 10)
HitboxSizeSliderBar.Position = UDim2.new(0, 10, 0, 15)
HitboxSizeSliderBar.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
HitboxSizeSliderBar.ZIndex = 14
HitboxSizeSliderBar.Parent = HitboxSizeSliderFrame
local HitboxSizeSliderKnob = Instance.new("Frame")
HitboxSizeSliderKnob.Size = UDim2.new(0, 20, 0, 20)
HitboxSizeSliderKnob.Position = UDim2.new((HitboxSize - 1) / 2, -10, 0, 10)
HitboxSizeSliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan glow
HitboxSizeSliderKnob.ZIndex = 15
HitboxSizeSliderKnob.Parent = HitboxSizeSliderFrame
local HitboxSizeSliderLabel = Instance.new("TextLabel")
HitboxSizeSliderLabel.Size = UDim2.new(0, 300, 0, 20)
HitboxSizeSliderLabel.Position = UDim2.new(0, 0, 0, -5)
HitboxSizeSliderLabel.BackgroundTransparency = 1
HitboxSizeSliderLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
HitboxSizeSliderLabel.Text = "Hitbox Size: " .. string.format("%.1f", HitboxSize) .. "x"
HitboxSizeSliderLabel.TextSize = 16
HitboxSizeSliderLabel.ZIndex = 14
HitboxSizeSliderLabel.Parent = HitboxSizeSliderFrame
local UICornerHitboxSizeSlider = Instance.new("UICorner")
UICornerHitboxSizeSlider.CornerRadius = UDim.new(0, 4)
UICornerHitboxSizeSlider.Parent = HitboxSizeSliderFrame

-- Others Tab: Fly Toggle Button
local FlyToggleButton = Instance.new("TextButton")
FlyToggleButton.Size = UDim2.new(0, 300, 0, 50)
FlyToggleButton.Position = UDim2.new(0.5, -150, 0.1, 20) -- Increased vertical spacing
FlyToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
FlyToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyToggleButton.Text = "Fly: OFF"
FlyToggleButton.TextSize = 18
FlyToggleButton.ZIndex = 13
FlyToggleButton.Parent = OthersTabContent

-- Others Tab: Speed Slider
local SpeedSliderFrame = Instance.new("Frame")
SpeedSliderFrame.Size = UDim2.new(0, 300, 0, 40)
SpeedSliderFrame.Position = UDim2.new(0.5, -150, 0.1, 80) -- Increased vertical spacing
SpeedSliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark gray
SpeedSliderFrame.ZIndex = 13
SpeedSliderFrame.Parent = OthersTabContent
local SpeedSliderBar = Instance.new("Frame")
SpeedSliderBar.Size = UDim2.new(0, 280, 0, 10)
SpeedSliderBar.Position = UDim2.new(0, 10, 0, 15)
SpeedSliderBar.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
SpeedSliderBar.ZIndex = 14
SpeedSliderBar.Parent = SpeedSliderFrame
local SpeedSliderKnob = Instance.new("Frame")
SpeedSliderKnob.Size = UDim2.new(0, 20, 0, 20)
SpeedSliderKnob.Position = UDim2.new(0, -10, 0, 10) -- Start at normal speed (16)
SpeedSliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan glow
SpeedSliderKnob.ZIndex = 15
SpeedSliderKnob.Parent = SpeedSliderFrame
local SpeedSliderLabel = Instance.new("TextLabel")
SpeedSliderLabel.Size = UDim2.new(0, 300, 0, 20)
SpeedSliderLabel.Position = UDim2.new(0, 0, 0, -5)
SpeedSliderLabel.BackgroundTransparency = 1
SpeedSliderLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
SpeedSliderLabel.Text = "Speed: " .. Speed
SpeedSliderLabel.TextSize = 16
SpeedSliderLabel.ZIndex = 14
SpeedSliderLabel.Parent = SpeedSliderFrame
local UICornerSpeedSlider = Instance.new("UICorner")
UICornerSpeedSlider.CornerRadius = UDim.new(0, 4)
UICornerSpeedSlider.Parent = SpeedSliderFrame

-- Others Tab: Jump Power Slider
local JumpPowerSliderFrame = Instance.new("Frame")
JumpPowerSliderFrame.Size = UDim2.new(0, 300, 0, 40)
JumpPowerSliderFrame.Position = UDim2.new(0.5, -150, 0.1, 140) -- Increased vertical spacing
JumpPowerSliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark gray
JumpPowerSliderFrame.ZIndex = 13
JumpPowerSliderFrame.Parent = OthersTabContent
local JumpPowerSliderBar = Instance.new("Frame")
JumpPowerSliderBar.Size = UDim2.new(0, 280, 0, 10)
JumpPowerSliderBar.Position = UDim2.new(0, 10, 0, 15)
JumpPowerSliderBar.BackgroundColor3 = Color3.fromRGB(0, 150, 150) -- Neon cyan
JumpPowerSliderBar.ZIndex = 14
JumpPowerSliderBar.Parent = JumpPowerSliderFrame
local JumpPowerSliderKnob = Instance.new("Frame")
JumpPowerSliderKnob.Size = UDim2.new(0, 20, 0, 20)
JumpPowerSliderKnob.Position = UDim2.new(0, -10, 0, 10) -- Start at 50
JumpPowerSliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan glow
JumpPowerSliderKnob.ZIndex = 15
JumpPowerSliderKnob.Parent = JumpPowerSliderFrame
local JumpPowerSliderLabel = Instance.new("TextLabel")
JumpPowerSliderLabel.Size = UDim2.new(0, 300, 0, 20)
JumpPowerSliderLabel.Position = UDim2.new(0, 0, 0, -5)
JumpPowerSliderLabel.BackgroundTransparency = 1
JumpPowerSliderLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
JumpPowerSliderLabel.Text = "Jump Power: " .. JumpPower
JumpPowerSliderLabel.TextSize = 16
JumpPowerSliderLabel.ZIndex = 14
JumpPowerSliderLabel.Parent = JumpPowerSliderFrame
local UICornerJumpPowerSlider = Instance.new("UICorner")
UICornerJumpPowerSlider.CornerRadius = UDim.new(0, 4)
UICornerJumpPowerSlider.Parent = JumpPowerSliderFrame

-- Create Corners for UI Elements
local UICornerESPToggle = Instance.new("UICorner")
UICornerESPToggle.CornerRadius = UDim.new(0, 8)
UICornerESPToggle.Parent = ESPToggleButton
local UICornerESPKeybind = Instance.new("UICorner")
UICornerESPKeybind.CornerRadius = UDim.new(0, 8)
UICornerESPKeybind.Parent = ESPKeybindBox
local UICornerAimbotToggle = Instance.new("UICorner")
UICornerAimbotToggle.CornerRadius = UDim.new(0, 8)
UICornerAimbotToggle.Parent = AimbotToggleButton
local UICornerWallCheckToggle = Instance.new("UICorner")
UICornerWallCheckToggle.CornerRadius = UDim.new(0, 8)
UICornerWallCheckToggle.Parent = WallCheckToggleButton
local UICornerAimbotKeybind = Instance.new("UICorner")
UICornerAimbotKeybind.CornerRadius = UDim.new(0, 8)
UICornerAimbotKeybind.Parent = AimbotKeybindBox
local UICornerTeamCheckToggle = Instance.new("UICorner")
UICornerTeamCheckToggle.CornerRadius = UDim.new(0, 8)
UICornerTeamCheckToggle.Parent = TeamCheckToggleButton
local UICornerSilentAimToggle = Instance.new("UICorner")
UICornerSilentAimToggle.CornerRadius = UDim.new(0, 8)
UICornerSilentAimToggle.Parent = SilentAimToggleButton
local UICornerNoRecoilToggle = Instance.new("UICorner")
UICornerNoRecoilToggle.CornerRadius = UDim.new(0, 8)
UICornerNoRecoilToggle.Parent = NoRecoilToggleButton
local UICornerHitboxToggle = Instance.new("UICorner")
UICornerHitboxToggle.CornerRadius = UDim.new(0, 8)
UICornerHitboxToggle.Parent = HitboxToggleButton
local UICornerRainbowESPToggle = Instance.new("UICorner")
UICornerRainbowESPToggle.CornerRadius = UDim.new(0, 8)
UICornerRainbowESPToggle.Parent = RainbowESPToggleButton
local UICornerNoSpreadToggle = Instance.new("UICorner")
UICornerNoSpreadToggle.CornerRadius = UDim.new(0, 8)
UICornerNoSpreadToggle.Parent = NoSpreadToggleButton
local UICornerFlyToggle = Instance.new("UICorner")
UICornerFlyToggle.CornerRadius = UDim.new(0, 8)
UICornerFlyToggle.Parent = FlyToggleButton

-- Minimize/Expand Logic
local function toggleMinimize()
    Minimized = not Minimized
    if Minimized then
        Frame.Size = UDim2.new(0, 700, 0, 40)
        Sidebar.Visible = false
        ContentArea.Visible = false
        MinimizeButton.Visible = false
        ExpandButton.Visible = true
        print("GUI Minimized")
    else
        Frame.Size = UDim2.new(0, 700, 0, 600)
        Sidebar.Visible = true
        ContentArea.Visible = true
        MinimizeButton.Visible = true
        ExpandButton.Visible = false
        print("GUI Expanded")
    end
end

-- Dragging Logic
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStartPos = Frame.Position
        DragStartMousePos = input.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - DragStartMousePos
        local newPos = UDim2.new(
            DragStartPos.X.Scale,
            DragStartPos.X.Offset + delta.X,
            DragStartPos.Y.Scale,
            DragStartPos.Y.Offset + delta.Y
        )
        Frame.Position = newPos
    end
end)

-- Function to show toggle feedback
local function showToggleFeedback(message)
    ToggleFeedback.Text = message
    ToggleFeedback.Visible = true
    task.delay(2, function()
        ToggleFeedback.Visible = false
    end)
end

-- Function to check if player is visible (wall check)
local function isPlayerVisible(targetPlayer)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
        return false
    end
    local origin = LocalPlayer.Character.HumanoidRootPart.Position
    local target = targetPlayer.Character.Head.Position
    local ray = Ray.new(origin, (target - origin).Unit * (target - origin).Magnitude)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, targetPlayer.Character})
    if hit then
        print("Wall check failed for " .. targetPlayer.Name .. ": Hit " .. hit.Name)
        return false
    end
    print("Wall check passed for " .. targetPlayer.Name)
    return true
end

-- Function to create ESP for a player
local function createESP(player)
    if player ~= LocalPlayer and player.Character and player.Character:WaitForChild("HumanoidRootPart", 2) and not Highlights[player] then
        local isDifferentTeam = not TeamCheckEnabled or (player.Team ~= LocalPlayer.Team) or (player.Team == nil or LocalPlayer.Team == nil)
        if isDifferentTeam then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = player.Character
            highlight.Parent = player.Character
            Highlights[player] = highlight
            print("ESP added for " .. player.Name .. " (Team: " .. tostring(player.Team) .. ", TeamCheck: " .. tostring(TeamCheckEnabled) .. ")")
        else
            print("ESP not added for " .. player.Name .. ": Same team (TeamCheck: " .. tostring(TeamCheckEnabled) .. ")")
        end
    else
        print("ESP not added for " .. player.Name .. ": Invalid conditions (No character or already highlighted)")
    end
end

-- Function to remove ESP from a player
local function removeESP(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
        print("ESP removed for " .. player.Name)
    end
end

-- Function to create or update hitbox highlight
local function updateHitbox(player)
    if HitboxEnabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and not Highlights[player .. "_Hitbox"] then
        local hitbox = Instance.new("Highlight")
        hitbox.Name = "HitboxHighlight"
        hitbox.FillColor = Color3.fromRGB(0, 255, 0)
        hitbox.OutlineColor = Color3.fromRGB(0, 255, 255)
        hitbox.FillTransparency = 0.7
        hitbox.OutlineTransparency = 0.3
        hitbox.Adornee = player.Character
        hitbox.Parent = player.Character
        Highlights[player .. "_Hitbox"] = hitbox
        print("Hitbox added for " .. player.Name)
    elseif Highlights[player .. "_Hitbox"] then
        Highlights[player .. "_Hitbox"]:Destroy()
        Highlights[player .. "_Hitbox"] = nil
        print("Hitbox removed for " .. player.Name)
    end
end

-- Function to toggle ESP
local function toggleESP()
    ESPEnabled = not ESPEnabled
    ESPToggleButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    ESPToggleButton.BackgroundColor3 = ESPEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("Toggling ESP: " .. (ESPEnabled and "ON" or "OFF"))
    if ESPEnabled then
        showToggleFeedback("ESP toggled ON")
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createESP(player)
            end
        end
    else
        showToggleFeedback("ESP toggled OFF")
        for _, player in ipairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
end

-- Function to toggle Rainbow ESP
local function toggleRainbowESP()
    RainbowESPEnabled = not RainbowESPEnabled
    RainbowESPToggleButton.Text = RainbowESPEnabled and "Rainbow ESP: ON" or "Rainbow ESP: OFF"
    RainbowESPToggleButton.BackgroundColor3 = RainbowESPEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("Toggling Rainbow ESP: " .. (RainbowESPEnabled and "ON" or "OFF"))
    showToggleFeedback("Rainbow ESP: " .. (RainbowESPEnabled and "ON" or "OFF"))
    if not ESPEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if Highlights[player] then
            Highlights[player].FillColor = RainbowESPEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 0, 0)
            Highlights[player].OutlineColor = RainbowESPEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
        end
    end
end

-- Function to toggle Wall Check
local function toggleWallCheck()
    print("toggleWallCheck called")
    WallCheckEnabled = not WallCheckEnabled
    WallCheckToggleButton.Text = WallCheckEnabled and "Wall Check: ON" or "Wall Check: OFF"
    WallCheckToggleButton.BackgroundColor3 = WallCheckEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("Wall Check: " .. (WallCheckEnabled and "Enabled" or "Disabled"))
end

-- Function to toggle Aimbot
local function toggleAimbot()
    AimbotEnabled = not AimbotEnabled
    AimbotToggleButton.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    AimbotToggleButton.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("Aimbot toggled: " .. (AimbotEnabled and "ON" or "OFF"))
    showToggleFeedback(AimbotEnabled and "Aimbot toggled" or "Aimbot untoggled")
    if not AimbotEnabled then
        CurrentTarget = nil
        AimbotActive = false
        AimbotToggleButton.Text = "Aimbot: OFF"
        AimbotToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
    end
end

-- Function to toggle Aimbot Active state
local function toggleAimbotActive()
    if AimbotEnabled then
        AimbotActive = not AimbotActive
        print("Aimbot active toggled: " .. (AimbotActive and "ON" or "OFF"))
        showToggleFeedback("Aimbot active: " .. (AimbotActive and "ON" or "OFF"))
        AimbotToggleButton.Text = "Aimbot: " .. (AimbotActive and "ON" or "OFF")
        AimbotToggleButton.BackgroundColor3 = AimbotActive and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    else
        print("Aimbot not enabled, cannot toggle active state")
    end
end

-- Function to toggle Team Check
local function toggleTeamCheck()
    TeamCheckEnabled = not TeamCheckEnabled
    TeamCheckToggleButton.Text = TeamCheckEnabled and "Team Check: ON" or "Team Check: OFF"
    TeamCheckToggleButton.BackgroundColor3 = TeamCheckEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("Team Check: " .. (TeamCheckEnabled and "Enabled" or "Disabled"))
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            removeESP(player)
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createESP(player)
            end
        end
    end
end

-- Function to toggle Silent Aim
local function toggleSilentAim()
    SilentAimEnabled = not SilentAimEnabled
    SilentAimToggleButton.Text = SilentAimEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
    SilentAimToggleButton.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("Silent Aim: " .. (SilentAimEnabled and "Enabled" or "Disabled"))
    showToggleFeedback("Silent Aim: " .. (SilentAimEnabled and "ON" or "OFF"))
end

-- Function to toggle No Spread
local function toggleNoSpread()
    NoSpreadEnabled = not NoSpreadEnabled
    NoSpreadToggleButton.Text = NoSpreadEnabled and "No Spread: ON" or "No Spread: OFF"
    NoSpreadToggleButton.BackgroundColor3 = NoSpreadEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("No Spread: " .. (NoSpreadEnabled and "Enabled" or "Disabled"))
    showToggleFeedback("No Spread: " .. (NoSpreadEnabled and "ON" or "OFF"))
end

-- Function to toggle No Recoil
local function toggleNoRecoil()
    NoRecoilEnabled = not NoRecoilEnabled
    NoRecoilToggleButton.Text = NoRecoilEnabled and "No Recoil: ON" or "No Recoil: OFF"
    NoRecoilToggleButton.BackgroundColor3 = NoRecoilEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("No Recoil: " .. (NoRecoilEnabled and "Enabled" or "Disabled"))
    showToggleFeedback("No Recoil: " .. (NoRecoilEnabled and "ON" or "OFF"))
end

-- Function to toggle Hitbox Changer
local function toggleHitbox()
    HitboxEnabled = not HitboxEnabled
    HitboxToggleButton.Text = HitboxEnabled and "Hitbox Changer: ON" or "Hitbox Changer: OFF"
    HitboxToggleButton.BackgroundColor3 = HitboxEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("Hitbox Changer: " .. (HitboxEnabled and "Enabled" or "Disabled"))
    showToggleFeedback("Hitbox Changer: " .. (HitboxEnabled and "ON" or "OFF"))
    if HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                updateHitbox(player)
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if Highlights[player .. "_Hitbox"] then
                Highlights[player .. "_Hitbox"]:Destroy()
                Highlights[player .. "_Hitbox"] = nil
            end
        end
    end
end

-- Function to toggle Fly
local function toggleFly()
    FlyEnabled = not FlyEnabled
    FlyToggleButton.Text = FlyEnabled and "Fly: ON" or "Fly: OFF"
    FlyToggleButton.BackgroundColor3 = FlyEnabled and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(0, 150, 150)
    print("Fly toggled: " .. (FlyEnabled and "ON" or "OFF"))
    showToggleFeedback("Fly: " .. (FlyEnabled and "ON" or "OFF"))
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
    elseif BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
end

-- Function to get closest player (now with viewport check)
local function getClosestPlayer()
    print("getClosestPlayer called")
    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") and CurrentTarget.Character:FindFirstChild("Humanoid") and CurrentTarget.Character.Humanoid.Health > 0 then
        local isDifferentTeam = not TeamCheckEnabled or (CurrentTarget.Team ~= LocalPlayer.Team) or (CurrentTarget.Team == nil or LocalPlayer.Team == nil)
        local headPos = CurrentTarget.Character.Head.Position
        local screenPoint = Camera:WorldToViewportPoint(headPos)
        if isDifferentTeam and screenPoint.Z > 0 and screenPoint.X > 0 and screenPoint.X < Camera.ViewportSize.X and screenPoint.Y > 0 and screenPoint.Y < Camera.ViewportSize.Y then
            if not WallCheckEnabled or isPlayerVisible(CurrentTarget) then
                print("Aimbot maintaining lock on " .. CurrentTarget.Name)
                return CurrentTarget
            end
        end
    end
    local closestPlayer = nil
    local closestDistance = math.huge
    local localPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not localPos then
        print("Aimbot: No local player position")
        return nil
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player ~= CurrentTarget and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local isDifferentTeam = not TeamCheckEnabled or (player.Team ~= LocalPlayer.Team) or (player.Team == nil or LocalPlayer.Team == nil)
            if isDifferentTeam then
                local headPos = player.Character.Head.Position
                local screenPoint = Camera:WorldToViewportPoint(headPos)
                if screenPoint.Z > 0 and screenPoint.X > 0 and screenPoint.X < Camera.ViewportSize.X and screenPoint.Y > 0 and screenPoint.Y < Camera.ViewportSize.Y then
                    if not WallCheckEnabled or isPlayerVisible(player) then
                        local worldDistance = (headPos - localPos).Magnitude
                        if worldDistance < closestDistance then
                            closestDistance = worldDistance
                            closestPlayer = player
                        end
                    else
                        print("Aimbot: " .. player.Name .. " not visible through wall")
                    end
                else
                    print("Aimbot: " .. player.Name .. " out of viewport")
                end
            else
                print("Aimbot: " .. player.Name .. " is on same team")
            end
        end
    end
    if closestPlayer then
        print("Aimbot switching to new target: " .. closestPlayer.Name)
        CurrentTarget = closestPlayer
    else
        print("Aimbot: No valid target found")
        CurrentTarget = nil
    end
    return CurrentTarget
end

-- Function to get silent aim target
local function getSilentAimTarget()
    if not SilentAimEnabled or not CurrentTarget or not CurrentTarget.Character then return nil end
    local randomValue = math.random(0, 100)
    if randomValue <= HitChance then
        if CurrentTarget.Character:FindFirstChild("Head") then
            print("Silent Aim: Hitting head of " .. CurrentTarget.Name)
            return CurrentTarget.Character.Head
        end
    end
    print("Silent Aim: Default aim for " .. CurrentTarget.Name)
    return CurrentTarget.Character:FindFirstChild("HumanoidRootPart") or nil
end

-- Rainbow color function
local function getRainbowColor(t)
    local r = math.sin(t) * 0.5 + 0.5
    local g = math.sin(t + 2) * 0.5 + 0.5
    local b = math.sin(t + 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

-- Function to modify bullet direction (No Spread)
local function modifyBulletDirection(tool)
    if NoSpreadEnabled and tool and tool:FindFirstChild("Handle") then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local mouse = UserInputService:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
            tool.Handle.CFrame = CFrame.new(tool.Handle.Position, ray.Direction * 1000)
        end
    end
end

-- Fly and Speed logic
RunService.RenderStepped:Connect(function(deltaTime)
    print("RenderStepped running, AimbotEnabled: " .. tostring(AimbotEnabled) .. ", AimbotActive: " .. tostring(AimbotActive))
    if AimbotEnabled and AimbotActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            print("Aimbot locking onto " .. target.Name)
            local aimPart = SilentAimEnabled and getSilentAimTarget() or target.Character.Head
            if aimPart then
                local headPos = aimPart.Position
                local targetCFrame = CFrame.new(Camera.CFrame.Position, headPos)
                if AimbotSmoothness == 0 then
                    Camera.CFrame = targetCFrame
                else
                    local lerpFactor = math.clamp(deltaTime * 10 * (1 - AimbotSmoothness), 0, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, lerpFactor)
                end
                if NoRecoilEnabled and LocalPlayer.Character:FindFirstChild("Tool") then
                    local camCFrame = Camera.CFrame
                    local _, pitch, _ = camCFrame:ToEulerAnglesYXZ()
                    Camera.CFrame = CFrame.new(camCFrame.Position) * CFrame.Angles(0, camCFrame:ToEulerAnglesYXZ().Y, 0)
                end
            else
                print("Aimbot: No valid aim part for " .. target.Name)
            end
        else
            print("Aimbot: No valid target to lock onto")
        end
    end
    -- Update rainbow colors
    if RainbowESPEnabled and ESPEnabled then
        local t = tick() % 10
        for _, player in ipairs(Players:GetPlayers()) do
            if Highlights[player] then
                Highlights[player].FillColor = getRainbowColor(t)
                Highlights[player].OutlineColor = getRainbowColor(t + 2)
            end
        end
    elseif ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if Highlights[player] then
                Highlights[player].FillColor = Color3.fromRGB(255, 0, 0)
                Highlights[player].OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end
    -- Fly logic
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and BodyVelocity then
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, FlySpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, FlySpeed, 0)
        end
        local forward = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + forward * FlySpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - forward * FlySpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - right * FlySpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + right * FlySpeed
        end
        BodyVelocity.Velocity = moveDirection
    end
end)

-- Periodic logic (ESP, Hitbox, Speed, Jump Power)
RunService.Heartbeat:Connect(function()
    if HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                updateHitbox(player)
            end
        end
    end
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if player.Character:FindFirstChild("HumanoidRootPart") then
                    local isDifferentTeam = not TeamCheckEnabled or (player.Team ~= LocalPlayer.Team) or (player.Team == nil or LocalPlayer.Team == nil)
                    if not Highlights[player] and isDifferentTeam then
                        createESP(player)
                    elseif Highlights[player] and not isDifferentTeam then
                        removeESP(player)
                    end
                else
                    print("ESP: No HumanoidRootPart for " .. player.Name .. ", waiting for respawn")
                    removeESP(player)
                end
            end
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
        local lastHealth = LocalPlayer.Character.Humanoid.Health
        task.wait(1)
        if LocalPlayer.Character.Humanoid.Health < lastHealth or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            print("Round reset detected, reapplying ESP")
            if ESPEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    removeESP(player)
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        createESP(player)
                    end
                end
            end
        end
        -- Apply Speed
        if LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Speed
        end
        -- Apply Jump Power
        if LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = JumpPower
        end
    end
    -- Apply No Spread
    if NoSpreadEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Tool") then
        modifyBulletDirection(LocalPlayer.Character.Tool)
    end
end)

-- Tab switching
ESPTabButton.MouseButton1Click:Connect(function()
    ESPTabContent.Visible = true
    AimbotTabContent.Visible = false
    ExperimentalTabContent.Visible = false
    OthersTabContent.Visible = false
    ESPTabButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
    AimbotTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ExperimentalTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    OthersTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)
AimbotTabButton.MouseButton1Click:Connect(function()
    ESPTabContent.Visible = false
    AimbotTabContent.Visible = true
    ExperimentalTabContent.Visible = false
    OthersTabContent.Visible = false
    ESPTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    AimbotTabButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
    ExperimentalTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    OthersTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)
ExperimentalTabButton.MouseButton1Click:Connect(function()
    ESPTabContent.Visible = false
    AimbotTabContent.Visible = false
    ExperimentalTabContent.Visible = true
    OthersTabContent.Visible = false
    ESPTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    AimbotTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ExperimentalTabButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
    OthersTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)
OthersTabButton.MouseButton1Click:Connect(function()
    ESPTabContent.Visible = false
    AimbotTabContent.Visible = false
    ExperimentalTabContent.Visible = false
    OthersTabContent.Visible = true
    ESPTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    AimbotTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ExperimentalTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    OthersTabButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
end)

-- ESP keybind handler
ESPKeybindBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local keyName = ESPKeybindBox.Text:upper()
        local success, keyCode = pcall(function()
            return Enum.KeyCode[keyName]
        end)
        if success and keyCode then
            ESPKey = keyCode
            ESPKeybindBox.Text = keyName
            print("ESP key set to " .. keyName)
        else
            ESPKeybindBox.Text = ESPKey.Name
            print("Invalid key: " .. keyName)
        end
    end
end)

-- Aimbot keybind handler
AimbotKeybindBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local keyName = AimbotKeybindBox.Text:upper()
        local success, keyCode = pcall(function()
            return Enum.KeyCode[keyName]
        end)
        if success and keyCode then
            AimbotKey = keyCode
            AimbotKeybindBox.Text = keyName
            print("Aimbot key set to " .. keyName)
        else
            AimbotKeybindBox.Text = AimbotKey.Name
            print("Invalid key: " .. keyName)
        end
    end
end)

-- Wall check toggle handler
WallCheckToggleButton.MouseButton1Click:Connect(toggleWallCheck)

-- Smoothness slider logic
local isSliderDragging = false
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isSliderDragging = true
    end
end)
SliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isSliderDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isSliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = SliderFrame.AbsolutePosition.X
        local sliderWidth = SliderFrame.AbsoluteSize.X - 20
        local relativeX = math.clamp((mouseX - sliderX - 10) / sliderWidth, 0, 1)
        SliderKnob.Position = UDim2.new(relativeX, -10, 0, 10)
        AimbotSmoothness = relativeX
        SliderLabel.Text = "Smoothness: " .. string.format("%.2f", AimbotSmoothness)
    end
end)

-- Hit Chance slider logic
local isHitChanceDragging = false
HitChanceSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isHitChanceDragging = true
    end
end)
HitChanceSliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isHitChanceDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isHitChanceDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = HitChanceSliderFrame.AbsolutePosition.X
        local sliderWidth = HitChanceSliderFrame.AbsoluteSize.X - 20
        local relativeX = math.clamp((mouseX - sliderX - 10) / sliderWidth, 0, 1)
        HitChanceSliderKnob.Position = UDim2.new(relativeX, -10, 0, 10)
        HitChance = math.floor(relativeX * 100)
        HitChanceSliderLabel.Text = "Hit Chance: " .. HitChance .. "%"
    end
end)

-- Hitbox Size slider logic
local isHitboxSizeDragging = false
HitboxSizeSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isHitboxSizeDragging = true
    end
end)
HitboxSizeSliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isHitboxSizeDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isHitboxSizeDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = HitboxSizeSliderFrame.AbsolutePosition.X
        local sliderWidth = HitboxSizeSliderFrame.AbsoluteSize.X - 20
        local relativeX = math.clamp((mouseX - sliderX - 10) / sliderWidth, 0, 1)
        HitboxSizeSliderKnob.Position = UDim2.new(relativeX, -10, 0, 10)
        HitboxSize = 1 + (relativeX * 2) -- Range 1 to 3
        HitboxSizeSliderLabel.Text = "Hitbox Size: " .. string.format("%.1f", HitboxSize) .. "x"
        if HitboxEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if Highlights[player .. "_Hitbox"] then
                    updateHitbox(player) -- Recreate to apply new size (visual only)
                end
            end
        end
    end
end)

-- Speed slider logic
local isSpeedDragging = false
SpeedSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isSpeedDragging = true
    end
end)
SpeedSliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isSpeedDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isSpeedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = SpeedSliderFrame.AbsolutePosition.X
        local sliderWidth = SpeedSliderFrame.AbsoluteSize.X - 20
        local relativeX = math.clamp((mouseX - sliderX - 10) / sliderWidth, 0, 1)
        SpeedSliderKnob.Position = UDim2.new(relativeX, -10, 0, 10)
        Speed = math.floor(16 + (relativeX * 84)) -- Range 16 to 100
        SpeedSliderLabel.Text = "Speed: " .. Speed
        FlySpeed = Speed / 2 -- Adjust fly speed based on walk speed
    end
end)

-- Jump Power slider logic
local isJumpPowerDragging = false
JumpPowerSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isJumpPowerDragging = true
    end
end)
JumpPowerSliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isJumpPowerDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isJumpPowerDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = JumpPowerSliderFrame.AbsolutePosition.X
        local sliderWidth = JumpPowerSliderFrame.AbsoluteSize.X - 20
        local relativeX = math.clamp((mouseX - sliderX - 10) / sliderWidth, 0, 1)
        JumpPowerSliderKnob.Position = UDim2.new(relativeX, -10, 0, 10)
        JumpPower = math.floor(50 + (relativeX * 150)) -- Range 50 to 200
        JumpPowerSliderLabel.Text = "Jump Power: " .. JumpPower
    end
end)

-- Connect toggle buttons
ESPToggleButton.MouseButton1Click:Connect(toggleESP)
AimbotToggleButton.MouseButton1Click:Connect(toggleAimbot)
MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
ExpandButton.MouseButton1Click:Connect(toggleMinimize)
TeamCheckToggleButton.MouseButton1Click:Connect(toggleTeamCheck)
SilentAimToggleButton.MouseButton1Click:Connect(toggleSilentAim)
NoRecoilToggleButton.MouseButton1Click:Connect(toggleNoRecoil)
HitboxToggleButton.MouseButton1Click:Connect(toggleHitbox)
RainbowESPToggleButton.MouseButton1Click:Connect(toggleRainbowESP)
NoSpreadToggleButton.MouseButton1Click:Connect(toggleNoSpread)
FlyToggleButton.MouseButton1Click:Connect(toggleFly)

-- Connect player events
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            if ESPEnabled and character:WaitForChild("HumanoidRootPart", 2) then
                createESP(player)
            end
            if HitboxEnabled and character:FindFirstChild("Head") then
                updateHitbox(player)
            end
        end)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    if Highlights[player .. "_Hitbox"] then
        Highlights[player .. "_Hitbox"]:Destroy()
        Highlights[player .. "_Hitbox"] = nil
    end
    if CurrentTarget == player then
        CurrentTarget = nil
    end
end)

-- Check existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and ESPEnabled then
            createESP(player)
        end
        if player.Character and player.Character:FindFirstChild("Head") and HitboxEnabled then
            updateHitbox(player)
        end
        player.CharacterAdded:Connect(function(character)
            if ESPEnabled and character:WaitForChild("HumanoidRootPart", 2) then
                createESP(player)
            end
            if HitboxEnabled and character:FindFirstChild("Head") then
                updateHitbox(player)
            end
        end)
    end
end

-- Keybind input
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.Keyboard and not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode.L then
            GuiVisible = not GuiVisible
            ScreenGui.Enabled = GuiVisible
            print("GUI Toggle Attempted: " .. (GuiVisible and "Shown" or "Hidden") .. " | Enabled: " .. tostring(ScreenGui.Enabled))
        elseif input.KeyCode == ESPKey then
            toggleESP()
            print("ESP Key Pressed: " .. ESPKey.Name)
        elseif input.KeyCode == AimbotKey then
            print("Aimbot Key Pressed: " .. AimbotKey.Name)
            toggleAimbotActive()
        end
    end
end)