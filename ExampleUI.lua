-- ExampleUI.lua
-- This script demonstrates EVERY feature of the KeyForge UI Library.

-- Load the library from the GitHub repository
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyForge-UI-Library/master/KeyForgeUILibrary.lua"))()

-- Create a new window
local Window = Library.new("KeyForge Feature Showreel", true, 600, 450, "RightControl")

-- 1. MAIN TAB: Basic Elements
local MainTab = Window:Tab("Main Elements", "rbxassetid://11436779516")
local MainSection = MainTab:Section("Interactive Gadgets")

MainSection:Title("Standard Controls")

MainSection:Toggle("Feature Toggle", false, function(state)
    Library:Notify("Toggle changed to: " .. tostring(state))
end)

MainSection:Button("Action Button", function()
    Library:Notify({
        Title = "Action Executed",
        Description = "You clicked the main action button!",
        Time = 3
    })
end)

local PowerSlider = MainSection:Slider("Power Level", function(value)
    print("Slider value:", value)
end, 100, 0)
PowerSlider:Set(50)

MainSection:Dropdown("Select Mode", {"Standard", "Advanced", "Elite", "Legendary"}, "Standard", function(value)
    Library:Notify("Mode set to: " .. value)
end)

MainSection:TextBox("User Label", function(text)
    Library:Notify("Text entered: " .. text)
end)

MainSection:Keybind("Quick Action", function()
    Library:Notify("Keybind pressed!")
end, "F")

MainSection:ColorWheel("Accent Color", Color3.fromRGB(0, 170, 255), function(color)
    print("Color selected:", color)
end)

-- 2. UTILITY TAB: Labels, Titles, and Search
local UtilityTab = Window:Tab("Utilities", "rbxassetid://11436779516")
local LabelSection = UtilityTab:Section("Visual Elements")

LabelSection:Title("Text Decorations")
LabelSection:Label("This is a standard informational label.")
LabelSection:Label("This is a colored label.", 14, Color3.fromRGB(0, 255, 127))

local SearchSection = UtilityTab:Section("Search & Filter")
local SearchBar = SearchSection:SearchBar("Search elements...")
SearchBar:Button("Hidden Gem 1", function() end)
SearchBar:Button("Hidden Gem 2", function() end)
SearchBar:Toggle("Searchable Toggle", false, function() end)
SearchBar:Label("Found result")

-- 3. FEEDBACK TAB: Warning Boxes
local FeedbackTab = Window:Tab("Feedback", "rbxassetid://11436779516")
local WarningSection = FeedbackTab:Section("Warning Boxes")

WarningSection:WarningBox("Information", "This is an informative message.", "Info")
WarningSection:WarningBox("Caution", "This action might have unexpected results.", "Warning")
WarningSection:WarningBox("Critical Error", "The operation failed significantly.", "Error")
WarningSection:WarningBox("Success", "Task completed successfully!", "Success")

-- 4. SETTINGS TAB: Theme & Save Managers
local SettingsTab = Window:Tab("Settings", "rbxassetid://11436779516")

-- One-line integration for Theme and Save Managers
Library:ApplyInterfaceManager(SettingsTab)
Library:ApplySaveManager(SettingsTab)

-- 5. INITIAL NOTIFICATION
Library:Notify({
    Title = "Welcome to KeyForge",
    Description = "Tap the 'KF' button on mobile or use RightControl to toggle the UI.",
    Time = 10
})
