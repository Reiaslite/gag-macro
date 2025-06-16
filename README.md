# Roblox AutoHotkey v2.0 Macro with GUI

An advanced macro system for Roblox with a modern GUI interface, featuring automated seed purchasing and mouse coordinate debugging tools.

## Requirements

- Windows OS
- AutoHotkey v2.0 installed
- Roblox game client

## Installation

1. Install AutoHotkey v2.0 from https://www.autohotkey.com/
2. Clone or download this project
3. Add your target images to the `images` folder

## Main Features

### GUI Interface
- **Dark themed interface** with intuitive controls
- **Auto-detection** of Roblox windows
- **Automatic window resizing** to 800x600 (Roblox minimum resolution)
- **Real-time status updates** showing macro progress

### Buy All Seeds Macro
Automated purchasing of multiple seed types with customizable parameters:
- Automatically finds and clicks the seeds button
- Navigates through menus with keyboard inputs
- Purchases multiple seed types in sequence
- Fully customizable delays and repetitions

### Mouse Coordinate Debugger
Advanced debugging tool featuring:
- **Real-time mouse coordinates** (screen and window-relative)
- **Color detection** with RGB values and visual preview
- **Anchor point system** for measuring distances
- **Pause/Resume functionality**
- **Copy coordinates to clipboard**

## Usage

### Running the Macro

1. **Start the GUI**:
   ```
   Double-click RobloxMacroGUI.ahk
   ```

2. **Using the Interface**:
   - Click **"🔄 Refresh"** to detect Roblox windows
   - Select a Roblox window from the dropdown (optional - auto-detects on start)
   - Click **"▶️ Start Macro"** to begin automation
   - Click **"⏹️ Stop Macro"** to stop

3. **Hotkeys**:
   - **F1**: Start macro
   - **F2**: Stop macro
   - **F3**: Reload script
   - **F4**: Exit application

### Mouse Coordinate Debugger

1. Click **"🔍 Mouse Coordinates"** button
2. Features:
   - View real-time mouse position
   - See coordinates relative to Roblox window
   - Preview color under cursor
   - Set anchor points by clicking **"🎯 Set Anchor"**
   - Measure distances from anchor point
   - Copy all coordinate data with **"📋 Copy"**

### Configuration

Edit the configuration in `RobloxMacroGUI.ahk`:

```ahk
buySeeds: {
    delayBeforeE: 1500,      ; Delay before pressing E (milliseconds)
    downKeyPresses: 2,       ; Number of Down arrow presses
    enterKeyPresses: 15,     ; Number of Enter presses per seed
    seedTypesToBuy: 22       ; Number of different seed types to buy
}
```

## Image Setup

1. **Required Images**:
   - `images/main_button/seeds_button.png` - The seeds button in Roblox

2. **Capturing Images**:
   - Use Win+Shift+S to capture UI elements
   - Save as PNG files in the appropriate subfolder
   - Ensure images are clear and distinct

## Features in Detail

### Auto Window Resizing
- Automatically resizes all Roblox windows to 800x600
- Ensures consistent image detection
- Maintains window position while resizing

### Enhanced Click Detection
- Mouse moves in small circular pattern before clicking
- Double-click functionality for better reliability
- Visual feedback showing click locations

### Buy All Seeds Workflow
1. Searches for and clicks seeds button
2. Waits 1.5 seconds (customizable)
3. Presses E to interact
4. Presses \ to open menu
5. For each seed type:
   - Navigates with Down arrow
   - Confirms with Enter
   - Purchases with multiple Enter presses
   - Moves to next seed type
6. Closes menu after all purchases

## Troubleshooting

### Macro Not Finding Images
- Ensure Roblox is running and visible
- Check that images exist in the correct folder
- Try adjusting the tolerance value (default: 20)
- Use the Mouse Coordinate Debugger to verify positions

### Clicking Not Working
- The enhanced click system should resolve most issues
- Ensure Roblox window is active and in focus
- Check that the window is properly resized to 800x600

## Safety & Ethics

- Use responsibly and follow Roblox Terms of Service
- This tool is for educational purposes
- Be respectful of other players
- Do not use in competitive scenarios

## File Structure

```
gag-macro/
├── RobloxMacroGUI.ahk      # Main GUI application
├── RobloxMacro.ahk         # Original macro script
├── config.ini              # Configuration file
├── README.md               # This file
└── images/                 # Image folder
    ├── main_button/        # Main UI buttons
    │   ├── seeds_button.png
    │   └── garden_button.png
    └── seeds/              # Seed-related images
        └── last_seeds.png
```

## Updates

- **v2.0**: Added GUI interface with auto-detection
- **v2.1**: Added mouse coordinate debugger
- **v2.2**: Implemented Buy All Seeds automation
- **v2.3**: Enhanced click detection with circular motion
- **v2.4**: Added multi-seed purchasing loop

## Contributing

Feel free to submit issues or pull requests to improve the macro system.