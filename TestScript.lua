-- TestScript.lua - KeyForge UI Library Test
-- Use local file for testing (comment out and use HttpGet for production)
local Library = loadstring(readfile("KeyForgeUILibrary.lua"))()
-- local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyForge-UI-Library/master/KeyForgeUILibrary.lua"))()

-- Create main window
-- Library.new(windowName, constrainToScreen, width, height, visibilityKeybind, backgroundImageId)
local Window = Library.new("Test Script", true, 650, 450, "RightControl")

-- Create a tab
-- Window:Tab(tabName, tabImage)
local MainTab = Window:Tab("Main", "rbxassetid://10746039695")

-- Create a section
-- Tab:Section(sectionTitle)
local MainSection = MainTab:Section("Test Features")

-- Add a title
MainSection:Title("Welcome to KeyForge")

-- Add a label
MainSection:Label("This is a test label demonstrating the UI library.", 13, Color3.fromRGB(255, 255, 255))

-- Add a toggle
-- Section:Toggle(toggleName, defaultState, callback)
MainSection:Toggle("Test Toggle", false, function(state)
    print("Toggle:", state)
end)

-- Add a button
-- Section:Button(buttonName, callback)
MainSection:Button("Test Button", function()
    print("Button clicked!")
end)

-- Add a slider
-- Section:Slider(sliderName, callback, maximumValue, minimumValue)
MainSection:Slider("Test Slider", function(value)
    print("Slider:", value)
end, 100, 0)

-- Add a dropdown
-- Section:Dropdown(dropdownName, optionList, defaultSelection, callback)
MainSection:Dropdown("Test Dropdown", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected)
    print("Dropdown:", selected)
end)

-- Add a textbox
-- Section:TextBox(textBoxName, callback)
MainSection:TextBox("Test Input", function(text)
    print("Input:", text)
end)

-- Add a keybind
-- Section:Keybind(keybindName, callback, defaultKey)
MainSection:Keybind("Test Keybind", function()
    print("Keybind pressed!")
end, "E")

-- Add a color wheel
-- Section:ColorWheel(colorWheelName, defaultColor, callback)
MainSection:ColorWheel("Test Color", Color3.fromRGB(255, 0, 0), function(color)
    print("Color:", color)
end)

-- Create a second section for more elements
local ExtraSection = MainTab:Section("Extra Features")

-- Add a search bar with nested elements
local SearchBar = ExtraSection:SearchBar("Search elements...")

SearchBar:Toggle("Searchable Toggle 1", false, function(state)
    print("Searchable Toggle 1:", state)
end)

SearchBar:Toggle("Searchable Toggle 2", false, function(state)
    print("Searchable Toggle 2:", state)
end)

SearchBar:Button("Searchable Button", function()
    print("Searchable button clicked!")
end)

print("TestScript loaded successfully!")
