; Roblox Macro using AutoHotkey v2.0
; This script uses ImageSearch to find and interact with elements in Roblox

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Global variables
global config := {
    searchDelay: 100,      ; Delay between image searches (ms)
    clickDelay: 50,        ; Delay after clicking (ms)
    tolerance: 20,         ; Color tolerance for ImageSearch (0-255)
    searchArea: {          ; Search area coordinates
        x1: 0,
        y1: 0,
        x2: A_ScreenWidth,
        y2: A_ScreenHeight
    }
}

; Hotkeys
F1::StartMacro()          ; Press F1 to start the macro
F2::StopMacro()           ; Press F2 to stop the macro
F3::Reload                ; Press F3 to reload the script
Esc::ExitApp              ; Press Escape to exit

; Global state
global isRunning := false

; Main macro function
StartMacro() {
    global isRunning
    isRunning := true
    
    ToolTip("Macro Started!", A_ScreenWidth/2 - 50, 20)
    SetTimer(() => ToolTip(), -2000)  ; Remove tooltip after 2 seconds
    
    ; Main loop
    while (isRunning) {
        ; Example: Search for a button image
        if (SearchAndClick("images/button.png")) {
            Sleep(config.clickDelay)
        }
        
        ; Example: Search for another element
        if (SearchAndClick("images/collect.png")) {
            Sleep(config.clickDelay)
        }
        
        ; Add more image searches as needed
        
        Sleep(config.searchDelay)
    }
}

; Stop macro function
StopMacro() {
    global isRunning
    isRunning := false
    
    ToolTip("Macro Stopped!", A_ScreenWidth/2 - 50, 20)
    SetTimer(() => ToolTip(), -2000)
}

; Search for an image and click if found
SearchAndClick(imagePath, clickOffset := {x: 0, y: 0}) {
    global config
    
    try {
        ; Perform image search
        if (ImageSearch(&foundX, &foundY, 
            config.searchArea.x1, config.searchArea.y1, 
            config.searchArea.x2, config.searchArea.y2, 
            "*" . config.tolerance . " " . imagePath)) {
            
            ; Click at the found position with offset
            Click(foundX + clickOffset.x, foundY + clickOffset.y)
            return true
        }
    } catch as err {
        ; Handle errors silently or log them
    }
    
    return false
}

; Search for an image without clicking
SearchImage(imagePath) {
    global config
    
    try {
        if (ImageSearch(&foundX, &foundY, 
            config.searchArea.x1, config.searchArea.y1, 
            config.searchArea.x2, config.searchArea.y2, 
            "*" . config.tolerance . " " . imagePath)) {
            
            return {x: foundX, y: foundY, found: true}
        }
    } catch as err {
        ; Handle errors silently
    }
    
    return {x: 0, y: 0, found: false}
}

; Wait for an image to appear
WaitForImage(imagePath, timeout := 5000) {
    startTime := A_TickCount
    
    while (A_TickCount - startTime < timeout) {
        result := SearchImage(imagePath)
        if (result.found) {
            return result
        }
        Sleep(100)
    }
    
    return {x: 0, y: 0, found: false}
}

; Utility function to set search area
SetSearchArea(x1, y1, x2, y2) {
    global config
    config.searchArea := {x1: x1, y1: y1, x2: x2, y2: y2}
}

; Display help information
ShowHelp() {
    helpText := "
    (
    Roblox Macro Controls:
    F1 - Start Macro
    F2 - Stop Macro
    F3 - Reload Script
    Esc - Exit Script
    
    Place your target images in the 'images' folder.
    )"
    
    MsgBox(helpText, "Macro Help", "Iconi")
}

; Show help on startup
ShowHelp()