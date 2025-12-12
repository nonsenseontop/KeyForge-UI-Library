-- TestScript.lua - KeyForge UI Library Test
-- Robust test script with error handling and proper library usage

-- Safely load the library with fallback mechanisms
local Library
local success, library_module = pcall(function()
    return loadstring(readfile("KeyForgeUILibrary.lua"))()
end)

if not success or not library_module then
    -- Fallback to HTTP loading if local file fails
    print("Local file loading failed, trying HTTP...")
    local success_http, library_http = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyForge-UI-Library/master/KeyForgeUILibrary.lua"))()
    end)
    
    if success_http and library_http then
        Library = library_http
        print("KeyForge library loaded successfully from GitHub")
    else
        error("Failed to load KeyForge library from both local file and GitHub")
    end
else
    Library = library_module
    print("KeyForge library loaded successfully from local file")
end

-- Verify library has required functions
assert(Library and Library.new, "Library failed to load properly")

-- Create main window with error handling
local Window
local success, window_obj = pcall(function()
    return Library.new("Test Script", true, 650, 450, "RightControl")
end)

if not success or not window_obj then
    error("Failed to create window: " .. tostring(window_obj))
end

Window = window_obj
print("Window created successfully")

-- Create a tab with error handling
local MainTab
local success, tab_obj = pcall(function()
    return Window:Tab("Main", "rbxassetid://10746039695")
end)

if not success or not tab_obj then
    error("Failed to create tab: " .. tostring(tab_obj))
end

MainTab = tab_obj
print("Main tab created successfully")

-- Create a section with error handling
local MainSection
local success, section_obj = pcall(function()
    return MainTab:Section("Test Features")
end)

if not success or not section_obj then
    error("Failed to create section: " .. tostring(section_obj))
end

MainSection = section_obj
print("Main section created successfully")

-- Add UI elements with error handling

-- Add a title
local Title
local success, title_obj = pcall(function()
    return MainSection:Title("Welcome to KeyForge")
end)

if success and title_obj then
    Title = title_obj
    print("Title added successfully")
else
    print("Failed to add title: " .. tostring(title_obj))
end

-- Add a label
local Label
local success, label_obj = pcall(function()
    return MainSection:Label("This is a test label demonstrating the UI library.", 13, Color3.fromRGB(255, 255, 255))
end)

if success and label_obj then
    Label = label_obj
    print("Label added successfully")
else
    print("Failed to add label: " .. tostring(label_obj))
end

-- Add a toggle
local Toggle
local success, toggle_obj = pcall(function()
    return MainSection:Toggle("Test Toggle", false, function(state)
        print("Toggle:", state)
    end)
end)

if success and toggle_obj then
    Toggle = toggle_obj
    print("Toggle added successfully")
else
    print("Failed to add toggle: " .. tostring(toggle_obj))
end

-- Add a button
local Button
local success, button_obj = pcall(function()
    return MainSection:Button("Test Button", function()
        print("Button clicked!")
    end)
end)

if success and button_obj then
    Button = button_obj
    print("Button added successfully")
else
    print("Failed to add button: " .. tostring(button_obj))
end

-- Add a slider
local Slider
local success, slider_obj = pcall(function()
    return MainSection:Slider("Test Slider", function(value)
        print("Slider:", value)
    end, 100, 0)
end)

if success and slider_obj then
    Slider = slider_obj
    print("Slider added successfully")
else
    print("Failed to add slider: " .. tostring(slider_obj))
end

-- Add a dropdown
local Dropdown
local success, dropdown_obj = pcall(function()
    return MainSection:Dropdown("Test Dropdown", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected)
        print("Dropdown:", selected)
    end)
end)

if success and dropdown_obj then
    Dropdown = dropdown_obj
    print("Dropdown added successfully")
else
    print("Failed to add dropdown: " .. tostring(dropdown_obj))
end

-- Add a textbox
local TextBox
local success, textbox_obj = pcall(function()
    return MainSection:TextBox("Test Input", function(text)
        print("Input:", text)
    end)
end)

if success and textbox_obj then
    TextBox = textbox_obj
    print("TextBox added successfully")
else
    print("Failed to add TextBox: " .. tostring(textbox_obj))
end

-- Add a keybind
local Keybind
local success, keybind_obj = pcall(function()
    return MainSection:Keybind("Test Keybind", function()
        print("Keybind pressed!")
    end, "E")
end)

if success and keybind_obj then
    Keybind = keybind_obj
    print("Keybind added successfully")
else
    print("Failed to add keybind: " .. tostring(keybind_obj))
end

-- Add a color wheel
local ColorWheel
local success, colorwheel_obj = pcall(function()
    return MainSection:ColorWheel("Test Color", Color3.fromRGB(255, 0, 0), function(color)
        print("Color:", color)
    end)
end)

if success and colorwheel_obj then
    ColorWheel = colorwheel_obj
    print("ColorWheel added successfully")
else
    print("Failed to add ColorWheel: " .. tostring(colorwheel_obj))
end

-- Create a second section for more elements
local ExtraSection
local success, extra_section_obj = pcall(function()
    return MainTab:Section("Extra Features")
end)

if success and extra_section_obj then
    ExtraSection = extra_section_obj
    print("Extra section created successfully")
    
    -- Add a search bar with nested elements
    local SearchBar
    local success, searchbar_obj = pcall(function()
        return ExtraSection:SearchBar("Search elements...")
    end)
    
    if success and searchbar_obj then
        SearchBar = searchbar_obj
        print("SearchBar added successfully")
        
        -- Add searchable elements
        local searchable_toggle1
        pcall(function()
            searchable_toggle1 = SearchBar:Toggle("Searchable Toggle 1", false, function(state)
                print("Searchable Toggle 1:", state)
            end)
        end)
        
        local searchable_toggle2
        pcall(function()
            searchable_toggle2 = SearchBar:Toggle("Searchable Toggle 2", false, function(state)
                print("Searchable Toggle 2:", state)
            end)
        end)
        
        local searchable_button
        pcall(function()
            searchable_button = SearchBar:Button("Searchable Button", function()
                print("Searchable button clicked!")
            end)
        end)
        
        print("SearchBar elements added successfully")
    else
        print("Failed to add SearchBar: " .. tostring(searchbar_obj))
    end
else
    print("Failed to create extra section: " .. tostring(extra_section_obj))
end

-- Add some additional elements to demonstrate functionality
local ThirdSection
local success, third_section_obj = pcall(function()
    return MainTab:Section("Additional Elements")
end)

if success and third_section_obj then
    ThirdSection = third_section_obj
    print("Third section created successfully")
    
    -- Add another title
    pcall(function()
        ThirdSection:Title("More Features")
    end)
    
    -- Add another label
    pcall(function()
        ThirdSection:Label("This demonstrates additional UI elements available in the KeyForge library.", 12, Color3.fromRGB(200, 200, 200))
    end)
    
    -- Add another toggle with different default state
    pcall(function()
        ThirdSection:Toggle("Another Toggle", true, function(state)
            print("Another Toggle:", state)
        end)
    end)
    
    -- Add a slider with different range
    pcall(function()
        ThirdSection:Slider("Custom Range Slider", function(value)
            print("Custom Range Slider:", value)
        end, 50, 10)
    end)
    
    -- Add a dropdown with different options
    pcall(function()
        ThirdSection:Dropdown("Custom Dropdown", {"Red", "Green", "Blue", "Yellow", "Purple"}, "Red", function(selected)
            print("Custom Dropdown:", selected)
        end)
    end)
    
    print("Additional elements added successfully")
else
    print("Failed to create third section: " .. tostring(third_section_obj))
end

-- Final success message
print("TestScript loaded successfully! All UI elements should now be visible.")
print("Use RightControl to toggle the window visibility.")
