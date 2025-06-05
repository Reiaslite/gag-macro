# Roblox AutoHotkey v2.0 Macro

A customizable macro for Roblox using AutoHotkey v2.0's ImageSearch functionality.

## Requirements

- Windows OS
- AutoHotkey v2.0 installed
- Roblox game client

## Installation

1. Install AutoHotkey v2.0 from https://www.autohotkey.com/
2. Clone or download this project
3. Add your target images to the `images` folder

## Usage

1. Capture screenshots of UI elements you want to automate:
   - Use Win+Shift+S to capture specific buttons/elements
   - Save as PNG files in the `images` folder
   - Use descriptive names (e.g., "play_button.png")

2. Edit `RobloxMacro.ahk` to add your image searches:
   ```ahk
   if (SearchAndClick("images/your_button.png")) {
       Sleep(config.clickDelay)
   }
   ```

3. Run the macro:
   - Double-click `RobloxMacro.ahk`
   - Press F1 to start
   - Press F2 to stop
   - Press F3 to reload
   - Press Esc to exit

## Configuration

Edit `config.ini` to customize:
- Search delays
- Click delays
- Color tolerance
- Search area
- Hotkeys

## Features

- **ImageSearch**: Finds UI elements on screen
- **SearchAndClick**: Automatically clicks found elements
- **WaitForImage**: Waits for elements to appear
- **Configurable**: Customize all parameters via config.ini
- **Hotkey Control**: Start/stop with keyboard shortcuts

## Example Use Cases

- Auto-clicking daily rewards
- Farming resources
- Navigating menus
- Automating repetitive tasks

## Tips

- Use smaller, focused images for faster searches
- Adjust tolerance if images aren't found
- Test in different lighting conditions
- Run Roblox in windowed mode for consistent results

## Safety

- Use responsibly and follow Roblox Terms of Service
- This is for educational purposes
- Be respectful of other players