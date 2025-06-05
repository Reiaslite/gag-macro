Image Folder Instructions
========================

Place your target images in this folder. The macro will search for these images on the screen.

Image Requirements:
- Format: PNG (recommended), BMP, or JPG
- Size: Capture only the essential part of the UI element
- Quality: Clear, without compression artifacts

How to Capture Images:
1. Open Roblox and navigate to the UI element you want to automate
2. Use Windows Snipping Tool (Win+Shift+S) or any screenshot tool
3. Capture ONLY the specific button/element you want to click
4. Save the image with a descriptive name (e.g., "play_button.png", "collect_reward.png")

Tips:
- Smaller images search faster
- Avoid capturing dynamic elements (changing numbers, timers)
- Test your images with different game lighting/backgrounds
- Use consistent naming for easy script maintenance

Example Usage in Script:
SearchAndClick("images/play_button.png")
SearchAndClick("images/collect_reward.png")