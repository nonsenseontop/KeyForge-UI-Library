# KeyForge UI Library

A modular UI library for Roblox scripts, designed to simplify the creation of user interfaces with pre-built components like windows, tabs, toggles, sliders, and more.

## Features

- **Easy-to-Use API**: Create complex UIs with simple method calls.
- **Modular Design**: Reusable components that promote code maintainability.
- **Animations & Themes**: Built-in animations and theming support.
- **Config Management**: Save and load UI states with integrated config system.
- **Mobile Support**: Responsive design for mobile devices.

## Installation

Load the library in your script:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/REPO_NAME/main/KFHubSource%20-%20Copy.lua"))()
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

### Manager Objects

Access config management:

```lua
local config = Library.ConfigManager
config:Save("config_name")
config:Load("config_name")
```

## Configuration

The library includes a built-in config system that can save/load UI states to/from files (if file functions are available).

## Compatibility

- Works on most Roblox exploits with GUI and mouse support.
- Includes mobile responsiveness.
- Supports both Synapse X and other executor environments.

## Contributing

Contributions are welcome! Please open issues for bugs or feature requests, and submit pull requests for improvements.

## License

MIT License - Feel free to use, modify, and distribute.
