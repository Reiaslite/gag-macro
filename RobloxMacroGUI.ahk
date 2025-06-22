; Roblox Macro with ImGui-style GUI using AutoHotkey v2.0
; This script includes GUI for configuration and Roblox tab detection

#Requires AutoHotkey v2.0
#SingleInstance Force

; Global variables
global config := {
    searchDelay: 100,
    clickDelay: 50,
    tolerance: 20,
    searchArea: {
        x1: 0,
        y1: 0,
        x2: 800,
        y2: 600
    },
    customResolution: {
        width: 800,
        height: 600
    },
    selectedRobloxWindow: "",
    ; Buy All Seeds macro settings
    buySeeds: {
        delayBeforeE: 1500, ; 1.5 seconds before pressing E
        downKeyPresses: 2,
        enterKeyPresses: 15,
        seedTypesToBuy: 16, ; Number of different seed types to buy
        delayBetweenCycles: 5000, ; 5 seconds between complete cycles
        navigationDelay: 100, ; Delay between navigation keys
        seedButtonImage: "images/main_button/seeds_button.png"
    },
    ; Buy All Gears macro settings
    buyGears: {
        enabled: false, ; Enable/disable gear buying
        enterKeyPresses: 5, ; Number of Enter key presses to confirm purchase
        navigationDelay: 100, ; Delay between navigation keys
        gearTypesToBuy: 8, ; Number of different gear types to buy
        recallWrenchKey: "2", ; Key to activate Recall Wrench
        gearMenuX: 569, ; X coordinate for gear menu button
        gearMenuY: 325 ; Y coordinate for gear menu button
    }
}

; Global state
global isRunning := false
global robloxWindows := []
global mainGui := ""
global statusText := ""
global debugGui := ""
global debugIsRunning := false
global anchorPoint := { x: 0, y: 0, set: false }
global waitingForAnchor := false

; Create main GUI
CreateMainGUI() {
    global mainGui, statusText, config, robloxWindows

    ; Create GUI with dark theme (ImGui-like)
    mainGui := Gui()
    mainGui.Title := "Roblox Macro Controller"
    mainGui.BackColor := "0x1a1a1a"
    mainGui.MarginX := 15
    mainGui.MarginY := 15

    ; Set font
    mainGui.SetFont("s10 cWhite", "Segoe UI")

    ; Title
    title := mainGui.Add("Text", "Center w400", "🎮 Roblox Macro Controller")
    title.SetFont("s16 Bold")

    ; Separator
    mainGui.Add("Text", "w400 h2 Background0x333333", "")

    ; Roblox Window Detection Section
    mainGui.Add("Text", "Section w400", "📋 Roblox Windows (Auto-detect on Start)").SetFont("s12 Bold")

    ; Refresh button and dropdown
    refreshBtn := mainGui.Add("Button", "w100", "🔄 Refresh")
    refreshBtn.OnEvent("Click", RefreshRobloxWindows)

    global windowDropdown := mainGui.Add("DropDownList", "w200 x+10 yp", ["No Roblox windows found"])
    windowDropdown.OnEvent("Change", SelectRobloxWindow)

    resizeBtn := mainGui.Add("Button", "w90 x+10 yp", "📐 Resize")
    resizeBtn.OnEvent("Click", ResizeSelectedWindow)

    ; Debug Section
    mainGui.Add("Text", "xm y+20 w400", "🔧 Debug Tools").SetFont("s12 Bold")

    debugBtn := mainGui.Add("Button", "w150 h35", "🔍 Mouse Coordinates")
    debugBtn.OnEvent("Click", ShowMouseDebugWindow)
    debugBtn.SetFont("s11")

    ; Control Buttons Section
    mainGui.Add("Text", "xm y+20 w400", "🎯 Controls").SetFont("s12 Bold")

    ; Start/Stop buttons
    global startBtn := mainGui.Add("Button", "w120 h35", "▶️ Start Macro")
    startBtn.OnEvent("Click", StartMacroGUI)
    startBtn.SetFont("s11 Bold")

    global stopBtn := mainGui.Add("Button", "w120 h35 x+10 yp Disabled", "⏹️ Stop Macro")
    stopBtn.OnEvent("Click", StopMacroGUI)
    stopBtn.SetFont("s11 Bold")

    reloadBtn := mainGui.Add("Button", "w120 h35 x+10 yp", "🔄 Reload")
    reloadBtn.OnEvent("Click", (*) => Reload())
    reloadBtn.SetFont("s11 Bold")

    ; Status bar
    mainGui.Add("Text", "xm y+20 w400 h2 Background0x333333", "")
    statusText := mainGui.Add("Text", "xm y+10 w400", "Status: Ready")
    statusText.SetFont("s10")

    ; Hotkey info
    hotkeyInfo := mainGui.Add("Text", "xm y+15 w400 c0x888888",
        "Hotkeys: F1 = Start | F2 = Stop | F3 = Reload | F4 = Exit")
    hotkeyInfo.SetFont("s9")

    ; Set GUI events
    mainGui.OnEvent("Close", (*) => ExitApp())

    ; Show GUI
    mainGui.Show()

    ; Initial refresh
    RefreshRobloxWindows()
}

; Refresh Roblox windows list
RefreshRobloxWindows(*) {
    global robloxWindows, windowDropdown

    robloxWindows := []
    windowList := []

    ; Find all Roblox windows
    for window in WinGetList("ahk_exe RobloxPlayerBeta.exe") {
        try {
            title := WinGetTitle(window)
            if (title != "") {
                robloxWindows.Push({ id: window, title: title })
                windowList.Push(title)
            }
        }
    }

    ; Update dropdown
    if (windowList.Length > 0) {
        windowDropdown.Delete()
        windowDropdown.Add(windowList)
        windowDropdown.Choose(1)
        UpdateStatus("Found " . windowList.Length . " Roblox window(s)")
    } else {
        windowDropdown.Delete()
        windowDropdown.Add(["No Roblox windows found"])
        windowDropdown.Choose(1)
        UpdateStatus("No Roblox windows found")
    }
}

; Select Roblox window
SelectRobloxWindow(*) {
    global config, robloxWindows, windowDropdown

    if (windowDropdown.Value > 0 && windowDropdown.Value <= robloxWindows.Length) {
        config.selectedRobloxWindow := robloxWindows[windowDropdown.Value].id

        ; Activate and resize window to 800x600
        try {
            ; First activate the window
            WinActivate(config.selectedRobloxWindow)
            WinWaitActive(config.selectedRobloxWindow, , 2) ; Wait up to 2 seconds for activation
            Sleep(200) ; Small delay to ensure window is ready

            ; Now resize the window
            WinMove(0, 0, 800, 600, config.selectedRobloxWindow)
            config.searchArea := { x1: 0, y1: 0, x2: 800, y2: 600 }
            UpdateStatus("Selected: " . robloxWindows[windowDropdown.Value].title . " (Resized to 800x600)")
        } catch as err {
            UpdateStatus("Error resizing window: " . err.Message)
        }
    }
}

; Resize selected window manually
ResizeSelectedWindow(*) {
    global config

    if (config.selectedRobloxWindow != "") {
        try {
            ; Activate the window first
            WinActivate(config.selectedRobloxWindow)
            WinWaitActive(config.selectedRobloxWindow, , 2)
            Sleep(200)

            ; Get current position
            WinGetPos(&currentX, &currentY, &currentW, &currentH, config.selectedRobloxWindow)

            ; Resize to 800x600
            WinMove(currentX, currentY, 800, 600, config.selectedRobloxWindow)

            ; Update search area
            config.searchArea := { x1: currentX, y1: currentY, x2: currentX + 800, y2: currentY + 600 }

            UpdateStatus("Window resized to 800x600")
        } catch as err {
            UpdateStatus("Error resizing: " . err.Message)
        }
    } else {
        UpdateStatus("Please select a Roblox window first")
    }
}

; Show mouse coordinate debug window
ShowMouseDebugWindow(*) {
    global debugGui, debugIsRunning

    ; If debug window already exists, close it
    if (debugGui != "") {
        try {
            debugGui.Destroy()
        }
    }

    ; Create debug GUI
    debugGui := Gui("+AlwaysOnTop +ToolWindow")
    debugGui.Title := "Mouse Coordinates Debug"
    debugGui.BackColor := "0x1a1a1a"
    debugGui.MarginX := 15
    debugGui.MarginY := 15

    ; Set font
    debugGui.SetFont("s10 cWhite", "Consolas")

    ; Title
    title := debugGui.Add("Text", "Center w300", "🖱️ Mouse Coordinate Tracker")
    title.SetFont("s14 Bold", "Segoe UI")

    ; Separator
    debugGui.Add("Text", "w300 h2 Background0x333333", "")

    ; Coordinate display
    debugGui.Add("Text", "w300 y+10", "Screen Coordinates:").SetFont("s11 Bold", "Segoe UI")
    global screenCoordText := debugGui.Add("Text", "w300 h20", "X: 0, Y: 0")
    screenCoordText.SetFont("s12", "Consolas")

    ; Window relative coordinates
    debugGui.Add("Text", "w300 y+15", "Roblox Window Relative:").SetFont("s11 Bold", "Segoe UI")
    global windowCoordText := debugGui.Add("Text", "w300 h20", "X: N/A, Y: N/A")
    windowCoordText.SetFont("s12", "Consolas")

    ; Color at cursor
    debugGui.Add("Text", "w300 y+15", "Color at Cursor:").SetFont("s11 Bold", "Segoe UI")
    global colorText := debugGui.Add("Text", "w300 h20", "RGB: N/A")
    colorText.SetFont("s12", "Consolas")

    ; Color preview box
    global colorBox := debugGui.Add("Text", "w50 h50 x+10 yp-40 Border Background0x000000", "")

    ; Anchor point section
    debugGui.Add("Text", "w300 xm y+70", "Anchor Point:").SetFont("s11 Bold", "Segoe UI")
    global anchorText := debugGui.Add("Text", "w300 h20", "Not set")
    anchorText.SetFont("s12", "Consolas")

    ; Control buttons
    global pauseBtn := debugGui.Add("Button", "w100 xm y+20", "⏸️ Pause")
    pauseBtn.OnEvent("Click", ToggleDebugPause)

    global anchorBtn := debugGui.Add("Button", "w100 x+10 yp", "🎯 Set Anchor")
    anchorBtn.OnEvent("Click", SetAnchorMode)

    clearAnchorBtn := debugGui.Add("Button", "w100 x+10 yp", "🚫 Clear")
    clearAnchorBtn.OnEvent("Click", ClearAnchor)

    ; Second row of buttons
    closeBtn := debugGui.Add("Button", "w100 xm y+10", "❌ Close")
    closeBtn.OnEvent("Click", (*) => CloseDebugWindow())

    ; Copy button
    copyBtn := debugGui.Add("Button", "w100 x+10 yp", "📋 Copy")
    copyBtn.OnEvent("Click", CopyMouseCoords)

    ; Set GUI events
    debugGui.OnEvent("Close", (*) => CloseDebugWindow())

    ; Show GUI
    debugGui.Show("x50 y50")

    ; Start coordinate tracking
    debugIsRunning := true
    SetTimer(UpdateMouseCoordinates, 50)
}

; Toggle debug pause
ToggleDebugPause(*) {
    global debugIsRunning, pauseBtn

    debugIsRunning := !debugIsRunning
    pauseBtn.Text := debugIsRunning ? "⏸️ Pause" : "▶️ Resume"
}

; Set anchor mode
SetAnchorMode(*) {
    global waitingForAnchor, anchorBtn, debugGui

    waitingForAnchor := true
    anchorBtn.Text := "🎯 Click to set"

    ; Change cursor to crosshair
    DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "Ptr"), "UInt", 32512)

    ; Set up temporary hotkey for left click
    HotKey("LButton", CaptureAnchorPoint, "On")
}

; Capture anchor point on click
CaptureAnchorPoint(*) {
    global anchorPoint, waitingForAnchor, anchorBtn, anchorText

    if (!waitingForAnchor) {
        return
    }

    ; Get mouse position
    MouseGetPos(&mouseX, &mouseY)

    ; Store anchor point
    anchorPoint.x := mouseX
    anchorPoint.y := mouseY
    anchorPoint.set := true

    ; Update display
    anchorText.Text := Format("X: {}, Y: {}", mouseX, mouseY)

    ; Reset
    waitingForAnchor := false
    anchorBtn.Text := "🎯 Set Anchor"

    ; Restore cursor
    DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)

    ; Remove hotkey
    HotKey("LButton", "Off")

    ; Play sound to indicate capture
    SoundBeep(1000, 100)
}

; Clear anchor point
ClearAnchor(*) {
    global anchorPoint, anchorText

    anchorPoint.x := 0
    anchorPoint.y := 0
    anchorPoint.set := false

    anchorText.Text := "Not set"
}

; Copy mouse coordinates to clipboard
CopyMouseCoords(*) {
    global screenCoordText, windowCoordText, colorText, anchorText, anchorPoint

    clipText := "Screen: " . screenCoordText.Text . "`n"
    clipText .= "Window: " . windowCoordText.Text . "`n"
    clipText .= colorText.Text . "`n"

    if (anchorPoint.set) {
        clipText .= "Anchor: " . anchorText.Text
    }

    A_Clipboard := clipText
    UpdateStatus("Coordinates copied to clipboard")
}

; Update mouse coordinates
UpdateMouseCoordinates() {
    global debugIsRunning, screenCoordText, windowCoordText, colorText, colorBox, config, anchorPoint, anchorText

    if (!debugIsRunning) {
        return
    }

    ; Get mouse position
    MouseGetPos(&mouseX, &mouseY)

    ; Update screen coordinates
    screenCoordText.Text := "X: " . mouseX . ", Y: " . mouseY

    ; If anchor is set, also show distance from anchor
    if (anchorPoint.set) {
        distX := mouseX - anchorPoint.x
        distY := mouseY - anchorPoint.y
        distance := Round(Sqrt(distX ** 2 + distY ** 2), 1)
        anchorText.Text := Format("X: {}, Y: {} (Dist: {} px)", anchorPoint.x, anchorPoint.y, distance)
    }

    ; Update window relative coordinates if Roblox window is selected
    if (config.selectedRobloxWindow != "") {
        try {
            WinGetPos(&winX, &winY, &winW, &winH, config.selectedRobloxWindow)
            relX := mouseX - winX
            relY := mouseY - winY

            if (relX >= 0 && relX <= winW && relY >= 0 && relY <= winH) {
                windowCoordText.Text := "X: " . relX . ", Y: " . relY
            } else {
                windowCoordText.Text := "Outside window"
            }
        } catch {
            windowCoordText.Text := "Window not found"
        }
    } else {
        windowCoordText.Text := "No window selected"
    }

    ; Get pixel color
    try {
        pixelColor := PixelGetColor(mouseX, mouseY, "RGB")

        ; Convert RGB format (0xRRGGBB) to display format
        red := (pixelColor >> 16) & 0xFF
        green := (pixelColor >> 8) & 0xFF
        blue := pixelColor & 0xFF

        colorText.Text := Format("RGB: #{:02X}{:02X}{:02X} ({}, {}, {})", red, green, blue, red, green, blue)

        ; Update color box with proper format
        colorBox.BackColor := pixelColor
    } catch {
        colorText.Text := "RGB: N/A"
        colorBox.BackColor := "0x000000"
    }
}

; Close debug window
CloseDebugWindow() {
    global debugGui, debugIsRunning

    debugIsRunning := false
    SetTimer(UpdateMouseCoordinates, 0) ; Stop timer

    if (debugGui != "") {
        debugGui.Destroy()
        debugGui := ""
    }
}

; Update config from GUI
UpdateConfigFromGUI() {
    global config
    ; Config is now using default values
}

; Start macro from GUI
StartMacroGUI(*) {
    global startBtn, stopBtn

    UpdateConfigFromGUI()
    startBtn.Enabled := false
    stopBtn.Enabled := true
    StartMacro()
}

; Stop macro from GUI
StopMacroGUI(*) {
    global startBtn, stopBtn

    startBtn.Enabled := true
    stopBtn.Enabled := false
    StopMacro()
}

; Update status text
UpdateStatus(text) {
    global statusText
    statusText.Text := "Status: " . text
}

; Main macro function
StartMacro() {
    global isRunning, config
    isRunning := true

    UpdateStatus("Finding and resizing Roblox windows...")

    ; Auto-detect and resize all Roblox windows
    robloxFound := false
    for window in WinGetList("ahk_exe RobloxPlayerBeta.exe") {
        try {
            title := WinGetTitle(window)
            if (title != "") {
                robloxFound := true

                ; Activate and resize each Roblox window
                WinActivate(window)
                WinWaitActive(window, , 1) ; Wait up to 1 second
                Sleep(100)

                ; Get current position
                WinGetPos(&currentX, &currentY, &currentW, &currentH, window)

                ; Resize to 800x600
                WinMove(currentX, currentY, 800, 600, window)

                ; If no window was previously selected, use the first one found
                if (config.selectedRobloxWindow == "") {
                    config.selectedRobloxWindow := window
                    config.searchArea := { x1: currentX, y1: currentY, x2: currentX + 800, y2: currentY + 600 }
                }

                UpdateStatus("Resized: " . title . " to 800x600")
                Sleep(200)
            }
        } catch as err {
            ; Continue with next window if error
        }
    }

    if (!robloxFound) {
        UpdateStatus("No Roblox windows found! Please start Roblox first.")
        isRunning := false
        return
    }

    UpdateStatus("Macro running - Buy All Seeds and Gears mode...")

    ; Main loop - Execute both seed and gear buying cycles
    while (isRunning) {
        cycleSuccess := true

        ; === SEED BUYING CYCLE ===
        ; Check if seed button image exists
        if (!FileExist(config.buySeeds.seedButtonImage)) {
            UpdateStatus("Error: Seed button image not found at: " . config.buySeeds.seedButtonImage)
            Sleep(config.searchDelay)
            continue
        }

        ; Execute the seed buying cycle
        UpdateStatus("=== Starting Seed Buying Cycle ===")
        if (ExecuteSeedBuyingCycle()) {
            UpdateStatus("Seed buying completed successfully!")
        } else {
            UpdateStatus("Seed buying failed - will retry next cycle")
            cycleSuccess := false
        }

        ; Short delay between seed and gear buying
        if (cycleSuccess && config.buyGears.enabled) {
            UpdateStatus("Waiting 3 seconds before gear buying...")
            Sleep(3000)
        }

        ; === GEAR BUYING CYCLE ===
        if (cycleSuccess && config.buyGears.enabled) {
            UpdateStatus("=== Starting Gear Buying Cycle ===")
            if (ExecuteGearBuyingCycle()) {
                UpdateStatus("Gear buying completed successfully!")
            } else {
                UpdateStatus("Gear buying failed - will retry next cycle")
                cycleSuccess := false
            }
        }

        ; Wait before next complete cycle
        if (cycleSuccess) {
            UpdateStatus("=== Cycle Complete ===")
            UpdateStatus("Waiting " . (config.buySeeds.delayBetweenCycles / 1000) . " seconds before next cycle...")
            Sleep(config.buySeeds.delayBetweenCycles)
        } else {
            ; Failed - retry after short delay
            UpdateStatus("Cycle failed - retrying in " . (config.searchDelay / 1000) . " seconds...")
            Sleep(config.searchDelay)
        }
    }
}

; Stop macro function
StopMacro() {
    global isRunning
    isRunning := false
    UpdateStatus("Macro stopped")
}

; Search for an image and click if found
SearchAndClick(imagePath, clickOffset := { x: 10, y: 10 }) {
    global config

    try {
        ; Use selected window's area if available
        searchArea := config.searchArea

        ; Debug info
        searchParams := Format("*{} {}", config.tolerance, imagePath)
        UpdateStatus(Format("Searching area: ({},{}) to ({},{}) for: {}",
            searchArea.x1, searchArea.y1, searchArea.x2, searchArea.y2, imagePath))

        if (ImageSearch(&foundX, &foundY,
            searchArea.x1, searchArea.y1,
            searchArea.x2, searchArea.y2,
            searchParams)) {

            ; Calculate click position
            clickX := foundX + clickOffset.x
            clickY := foundY + clickOffset.y

            ; Move mouse in small circular motion before clicking
            MouseMove(clickX - 3, clickY - 3, 5)
            Sleep(50)
            MouseMove(clickX + 3, clickY - 3, 5)
            Sleep(50)
            MouseMove(clickX + 3, clickY + 3, 5)
            Sleep(50)
            MouseMove(clickX - 3, clickY + 3, 5)
            Sleep(50)
            MouseMove(clickX, clickY, 5)
            Sleep(100)

            Sleep(500) ; 0.5 second delay
            Click(clickX, clickY)

            UpdateStatus(Format("Image found and double-clicked at: ({},{})", clickX, clickY))
            return true
        } else {
            UpdateStatus("Image not found in search area")
        }
    } catch as err {
        UpdateStatus("Error searching for image: " . err.Message)
        return false
    }

    return false
}

; Search for an image without clicking
SearchImage(imagePath) {
    global config

    try {
        searchArea := config.searchArea

        if (ImageSearch(&foundX, &foundY,
            searchArea.x1, searchArea.y1,
            searchArea.x2, searchArea.y2,
            "*" . config.tolerance . " " . imagePath)) {

            return { x: foundX, y: foundY, found: true }
        }
    } catch as err {
        ; Handle errors silently
        UpdateStatus("Error searching for image: " . err.Message)
        return { x: 0, y: 0, found: false }
    }

    return { x: 0, y: 0, found: false }
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

    return { x: 0, y: 0, found: false }
}

; ========== Seed Buying Helper Functions ==========

; Navigate menu with arrow keys
NavigateMenu(direction, count, delay := 100) {
    loop count {
        Send("{" . direction . "}")
        Sleep(delay)
    }
}

; Open the seed buying menu
OpenSeedMenu() {
    global config

    ; Press E to interact
    Send("{e}")
    UpdateStatus("Pressed E key")
    Sleep(config.buySeeds.delayBeforeE)

    ; Press \ to open menu
    Send("{\}")
    UpdateStatus("Opened seed menu")
    Sleep(config.buySeeds.delayBeforeE)
}

; Buy a single seed type
BuySingleSeedType(seedNumber, totalSeeds) {
    global config

    UpdateStatus("Buying seed type " . seedNumber . " of " . totalSeeds)

    ; Navigate to seed type
    NavigateMenu("Down", config.buySeeds.downKeyPresses, 500)

    ; Confirm selection
    Send("{Enter}")
    Sleep(200)

    ; Go to quantity selection
    Send("{Down}")
    Sleep(100)

    ; Buy seeds
    loop config.buySeeds.enterKeyPresses {
        Send("{Enter}")
        Sleep(config.buySeeds.navigationDelay)
    }

    UpdateStatus("Bought seed type " . seedNumber)

    ; Navigate back for next seed (if not last)
    if (seedNumber < totalSeeds) {
        Send("{Up}")
        Sleep(200)
    }
}

; Close the seed buying menu
CloseSeedMenu() {
    global config

    ; Navigate to top of menu
    NavigateMenu("Up", 17, config.buySeeds.navigationDelay)
    UpdateStatus("Navigated to top of menu")
    Sleep(500)

    ; Confirm exit
    Send("{Enter}")
    Sleep(500)

    ; Close menu
    Send("{\}")
    UpdateStatus("Closed seed menu")
}

; Execute the complete seed buying cycle
ExecuteSeedBuyingCycle() {
    global config

    try {
        ; Step 1: Find and click seeds button
        if (!SearchAndClick(config.buySeeds.seedButtonImage)) {
            UpdateStatus("Seeds button not found. Will retry...")
            return false
        }

        UpdateStatus("Seeds button clicked, opening menu...")
        Sleep(config.buySeeds.delayBeforeE)

        ; Step 2: Open seed menu
        OpenSeedMenu()

        ; Step 3: Buy all seed types
        UpdateStatus("Starting to buy " . config.buySeeds.seedTypesToBuy . " seed types...")
        loop config.buySeeds.seedTypesToBuy {
            BuySingleSeedType(A_Index, config.buySeeds.seedTypesToBuy)
        }

        ; Step 4: Close menu
        CloseSeedMenu()

        UpdateStatus("Completed buying all seeds!")
        return true

    } catch as err {
        UpdateStatus("Error during seed buying: " . err.Message)
        return false
    }
}

; ========== Gear Buying Helper Functions ==========

OpenGearMenu() {
    global config

    ; Press the recall wrench key
    Send("{" . config.buyGears.recallWrenchKey . "}")
    UpdateStatus("Pressed " . config.buyGears.recallWrenchKey . " key to use Recall Wrench")
    Sleep(config.buySeeds.delayBeforeE)

    ; Click center of screen to use Recall Wrench
    MouseMove(579, 278, 3)
    Sleep(500)
    Click(579, 278)
    Sleep(100)
    Click(579, 278)
    Sleep(1000)
    UpdateStatus("Used Recall Wrench")

    ; Press E to open gear menu
    Send("{e}")
    UpdateStatus("Opened gear menu")
    Sleep(config.buySeeds.delayBeforeE)

    ; Click on gear menu button using configured coordinates
    MouseMove(config.buyGears.gearMenuX - 3, config.buyGears.gearMenuY - 3, 5)
    Sleep(50)
    MouseMove(config.buyGears.gearMenuX + 3, config.buyGears.gearMenuY - 3, 5)
    Sleep(50)
    MouseMove(config.buyGears.gearMenuX + 3, config.buyGears.gearMenuY + 3, 5)
    Sleep(50)
    MouseMove(config.buyGears.gearMenuX - 3, config.buyGears.gearMenuY + 3, 5)
    Sleep(50)
    MouseMove(config.buyGears.gearMenuX, config.buyGears.gearMenuY, 5)
    Sleep(100)

    Sleep(500)
    Click(config.buyGears.gearMenuX, config.buyGears.gearMenuY)
    Sleep(1000)
    UpdateStatus("Accessed gear purchase menu")

    ; Press \ to open navigation menu
    Send("{\}")
    UpdateStatus("Opened gear navigation menu")
    Sleep(config.buySeeds.delayBeforeE)
}

BuyGearType(gearNumber, totalGears) {
    global config

    UpdateStatus("Buying gear type " . gearNumber . " of " . totalGears)

    ; Navigate to gear type
    NavigateMenu("Down", config.buySeeds.downKeyPresses, 500)

    ; Confirm selection
    Send("{Enter}")
    Sleep(200)

    ; Go to quantity selection
    Send("{Down}")
    Sleep(100)

    ; Buy gears
    loop config.buyGears.enterKeyPresses {
        Send("{Enter}")
        Sleep(config.buyGears.navigationDelay)
    }

    UpdateStatus("Bought gear type " . gearNumber)

    ; Navigate back for next gear (if not last)
    if (gearNumber < totalGears) {
        Send("{Up}")
        Sleep(200)
    }
}

CloseGearMenu() {
    global config

    ; Navigate to top of menu
    NavigateMenu("Up", 9, config.buySeeds.navigationDelay)
    UpdateStatus("Navigated to top of gear menu")
    Sleep(500)

    ; Confirm exit
    Send("{Enter}")
    Sleep(500)

    ; Close menu
    Send("{\}")
    UpdateStatus("Closed gear menu")
}

; Execute the complete gear buying cycle
ExecuteGearBuyingCycle() {
    global config

    ; Check if gear buying is enabled
    if (!config.buyGears.enabled) {
        UpdateStatus("Gear buying is disabled - skipping")
        return true
    }

    try {
        ; Step 1: Open gear menu
        OpenGearMenu()

        ; Step 2: Buy all gear types
        UpdateStatus("Starting to buy " . config.buyGears.gearTypesToBuy . " gear types...")
        loop config.buyGears.gearTypesToBuy {
            BuyGearType(A_Index, config.buyGears.gearTypesToBuy)
        }

        ; Step 3: Close menu
        CloseGearMenu()

        UpdateStatus("Completed buying all gears!")
        return true

    } catch as err {
        UpdateStatus("Error during gear buying: " . err.Message)
        return false
    }
}

; ========== Hotkeys and Initialization ==========
; Hotkeys for GUI control
F1:: StartMacroGUI()
F2:: StopMacroGUI()
F3:: Reload
F4:: ExitApp

; Initialize GUI on startup
CreateMainGUI()