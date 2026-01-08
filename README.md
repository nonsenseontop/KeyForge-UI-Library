# KeyForge UI Library

A comprehensive, production-ready UI library for Roblox scripts featuring deep theme and config management integration. Create professional interfaces with windows, tabs, interactive elements, and persistent user customization.

## ✨ Key Features

- **🎨 Deep Theme Integration**: Built-in ThemeManager with real-time color updates and custom theme support
- **💾 Advanced Save System**: Persistent configuration saving/loading with auto-registration
- **📢 Professional Notifications**: Rich notification system with animations, DPI scaling, and structured content
- **🔧 Automatic Manager Setup**: One-line functions to add theme/config tabs to any window
- **📱 Advanced Mobile Support**: Draggable "KF" toggle button, responsive design, and robust multi-sensor hardware detection
- **📐 Perfect Scaling**: DPI-aware elements that look crisp on any resolution

## Installation

Load the library in your script:

```lua
local Library = loadstring(game:HttpGet"https://raw.githubusercontent.com/nonsenseontop/KeyForge-UI-Library/master/KeyForgeUILibrary.lua"))()
```

Or require it as a module:

```lua
local Library = require(path.to.library)
```

## Quick Start

```lua
-- Create a window
local win = Library.new("My Script", true, 600, 400, "RightControl")

-- Add a tab
local tab = win:Tab("Main", "rbxassetid://iconId")

-- Add a section
local section = tab:Section("Features")

-- Add UI elements
section:Toggle("Enable Feature", false, function(state)
    print("Feature enabled:", state)
end)

section:Slider("Volume", 50, function(value)
    print("Volume:", value)
end)

section:Button("Click Me", function()
    print("Button clicked!")
end)
```

## Advanced Usage - Theme & Save Managers

### 🎨 Theme Manager Integration

Automatically add a full theme customization interface:

```lua
local tab = win:Tab("Settings")

-- Adds color pickers for all theme colors, font selector, and theme presets
Library:ApplyThemeManager(tab, "Appearance")

-- Manual theme control
ThemeManager:ApplyTheme("Dark")  -- Apply built-in theme
ThemeManager:ApplyTheme("MyCustomTheme")  -- Apply custom theme
```

Available theme options:
- **BackgroundColor**: Main window background
- **MainColor**: Section and tab backgrounds
- **AccentColor**: Buttons, sliders, and highlights
- **OutlineColor**: Borders and frames
- **FontColor**: Text color

### 💾 Save Manager Integration

Automatically add save/load configuration:

```lua
local tab = win:Tab("Settings")

-- Adds config input and save/load buttons
Library:ApplySaveManager(tab, "Configuration")

-- Manual config control
SaveManager:Save("myConfig")  -- Save current settings
SaveManager:Load("myConfig")  -- Load saved settings
```

### 📢 Notifications System

Display professional notifications:

```lua
-- Simple notification
Library:Notify("Feature enabled successfully!")

-- Rich notification with title and description
Library:Notify({
    Title = "Important Update",
    Description = "Please restart your script for best performance",
    Time = 5  -- Display duration in seconds
})
```

### ⚠️ Warning Boxes

Show color-coded alerts in your interface:

```lua
-- Different severity levels with distinct colors
section:WarningBox("Beta Feature", "This feature is in beta and may change.", "Warning")
section:WarningBox("Connection Error", "Unable to connect to server.", "Error")
section:WarningBox("Success!", "Settings saved successfully.", "Success")
section:WarningBox("Tip", "You can customize themes in the Settings tab.", "Info")
```

## Available UI Elements

- **Window**: Main UI container
- **Tab**: Organize sections within windows
- **Section**: Group related elements
- **Toggle**: Boolean on/off switch
- **Button**: Clickable action trigger
- **Dropdown**: Selection from multiple options
- **Slider**: Numeric value selector
- **SearchBar**: Filterable list container
- **Keybind**: Hotkey assignment
- **TextBox**: Text input field
- **ColorWheel**: HSV color picker
- **Label**: Display text with optional color
- **Title**: Decorative heading

## API Reference

Full documentation of all methods and their parameters.

### Window Methods

- `new(windowName, constrainToScreen, width, height, visibilityKeybind, backgroundImageId)`
- `LockScreenBoundaries(constrain)`

### Element Methods

- `Tab(tabName, tabImage)` - Creates a new tab
- `Section(sectionTitle)` - Creates a new section within a tab

### Section Methods (inherited by other elements)

Most UI elements can be added to any section or container:

- `Toggle(name, defaultState, callback)`
- `Button(name, callback)`
- `Dropdown(name, optionList, defaultIndex, callback)`
- `Slider(name, defaultValue, callback, max, min)`
- `SearchBar(placeholderText)`
- `Keybind(name, callback, defaultKey)`
- `TextBox(name, callback)`
- `ColorWheel(name, defaultColor, callback)`
- `Label(text, textSize, textColor)`
- `Title(text)`

## Utility Functions

### Theme & Save Management

- `Library:ApplyThemeManager(tab, groupboxName)` - Add complete theme customization UI to specified tab
- `Library:ApplySaveManager(tab, groupboxName)` - Add save/load configuration UI to specified tab

### Element Registration

- `Library:RegisterElementType(elementType, updateFunction)` - Register custom element types for theme updates
- `Library:RegisterOption(element, identifier, elementType, defaultValue)` - Register elements for configuration saving
- `Library:RegisterToggle(element, identifier, defaultValue)` - Register toggle elements for saving/loading

### Visual Helpers

- `Library:MakeOutline(frame, cornerRadius)` - Create consistent outline borders for UI elements
- `Library:AddTooltip(infoStr, disabledInfoStr, hoverInstance)` - Add hover tooltips to elements
- `Library:Notify(message)` or `Library:Notify({Title, Description, Time})` - Display notifications

### DPI & Scaling

- `Library:GetTextBounds(text, font, size, width)` - Get precise text dimensions for layout
- `Library:UpdateDPI(instance, properties)` - Apply DPI scaling to UI elements

## Theme Manager API

### Built-in Themes
- "Default", "Light", "Dark"

### Methods
- `ThemeManager:ApplyTheme(themeName)` - Switch to specified theme instantly
- `ThemeManager:SetFolder(folder)` - Set theme save location
- `ThemeManager:ThemeUpdate()` - Force refresh all element colors

## Save Manager API

### Methods
- `SaveManager:Save(configName)` - Save current UI state
- `SaveManager:Load(configName)` - Load saved configuration
- `SaveManager:SetFolder(folder)` - Set config save location
- `SaveManager:IsReady()` - Check if file system is available
- `SaveManager:GetConfigs()` - Get list of saved configurations

### Supported Element Types
- Toggle, Slider, Dropdown, ColorPicker, Input

## Warning Box Types

- **"Info"** - Blue accent color for general information
- **"Warning"** - Yellow for caution messages
- **"Error"** - Red for error conditions
- **"Success"** - Green for positive confirmations

## Recent Updates

### v2.x - Major Enhancement Update
- **🎨 Deep Theme Integration**: Complete theme manager with real-time color updates
- **💾 Advanced Save System**: Persistent configuration with auto-registration
- **📢 Professional Notifications**: Rich notification system with DPI scaling and animations
- **⚠️ Warning Box System**: Color-coded alerts (Info, Warning, Error, Success)
- **🔧 Automatic Manager Setup**: One-line functions to add theme/config tabs
- **📐 DPI Scaling Support**: Perfect scaling across all resolutions
- **🛠️ Helper Utilities**: MakeOutline for consistent borders, enhanced tooltips
- **📐 DPI Scaling Support**: Perfect scaling across all resolutions
- **📱 Advanced Mobile Support**: Draggable "KF" toggle button and refined multi-sensor hardware detection to distinguish mobile devices from touch laptops

## Configuration

The library includes an advanced configuration system with:

- **Persistent Settings**: Save/load UI states automatically
- **Element Auto-Registration**: New elements automatically register for saving
- **File System Integration**: Save to custom folders with backup support
- **Theme Persistence**: Color schemes and font preferences are preserved

### Configuration Files
- Themes: `KeyForgeSettings/themes/`
- Configs: `KeyForgeSettings/settings/`

## Compatibility

- Works on most Roblox exploits with GUI and mouse support.
- Includes mobile responsiveness with touch controls.
- Supports both Synapse X and other executor environments.
- File system functions required for save/load features.

## Troubleshooting

### Theme/Save Manager Not Working
- Ensure file system functions are available in your executor
- Check that `KeyForgeSettings` folder can be created
- Verify no conflicts with other scripts

### DPI Scaling Issues
- Force reload the script after changing resolutions
- Check that DPI scaling is set to 1.0 if experiencing issues

- **Mobile Toggle**: A dedicated draggable button (branded "KF") allows mobile users to easily toggle UI visibility.
- **Advanced Detection**: Uses accelerometer and input device checks to ensure the mobile interface only appears on true mobile/tablet hardware, not touch-screen laptops.
- **Responsive Layout**: On mobile devices, the interface automatically adjusts its size and organization.

## Contributing

Contributions are welcome! Please open issues for bugs or feature requests, and submit pull requests for improvements.

### Development Notes
- The library is designed to be modular and extensible
- New UI elements should follow the established registration pattern
- Theme compatibility is maintained through the Scheme system

## License

MIT License - Feel free to use, modify, and distribute.
