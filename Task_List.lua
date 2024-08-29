-- Wrap the monitor peripheral
local monitor = peripheral.wrap("right")

-- Define button properties
local buttons = {}
local buttonWidth = 24 
local buttonHeight = 15
local buttonSpacing = 2
local screenWidth, screenHeight = monitor.getSize()

-- Function to draw a button on the monitor
local function drawButton(button, fillColor)
    monitor.setBackgroundColor(fillColor)
    for y = button.y, button.y + buttonHeight - 1 do
        monitor.setCursorPos(button.x, y)
        monitor.write(string.rep(" ", buttonWidth))
    end


-- Draw the label   
 monitor.setCursorPos(button.x + (buttonWidth - #button.label)  / 2, button.y + buttonHeight / 2)
 monitor.setTextColor(colors.white)
 monitor.write(button.label)


-- Draw the outline
monitor.setBackgroundColor(colors.gray)
monitor.setCursorPos(button.x, button.y)
monitor.write(string.rep(" ", buttonWidth) )
 monitor.setCursorPos(button.x, button.y + buttonHeight - 1) 
 monitor.write(string.rep(" ", buttonWidth))
 for y = button.y, button.y + buttonHeight - 1 do
     monitor.setCursorPos(button.x, y)
     monitor.write(" ")
     monitor.setCursorPos(button.x + buttonWidth - 1, y)
     monitor.write(" ")
 end
end

-- Function to handle button clicks
local function buttonClicked(button)
    monitor.setBackgroundColor(colors.green)
    drawButton(button, colors.green)
    -- Call a custom method or action here
    print("Button " .. button.label .. " clicked!")
end

-- Function to draw all buttons on the monitor
local function drawAllButtons()
    local buttonCount = 6
    local buttonsPerRow = 3
    local startX = (screenWidth - (buttonsPerRow * (buttonWidth + buttonSpacing) - buttonSpacing)) / 2
    local startY = (screenHeight - (2 * (buttonHeight + buttonSpacing) - buttonSpacing))  /  2
    
     
    for i = 1, buttonCount do
     local row = math.ceil(i / buttonsPerRow)
     local col = i - (row - 1) * buttonsPerRow
     local x = startX + (col - 1) * (buttonWidth + buttonSpacing)
     local y = startY + (row - 1) * (buttonHeight + buttonSpacing)
     
     buttons[i] = {x = x, y = y, label = "Btn" .. i}
     drawButton(buttons[i], colors.red)
 end
end 

-- Function to handle monitor touch events
local function handleMonitorTouch()
    while true do
    local event, side, cx, cy = os.pullEvent("monitor_ touch")
    
    for , btn in ipairs(buttons) do
     if cx >= btn.x and cx < btn.x + buttonWidth and cy >= btn.y and cy < btn.y + buttonHeight then
     buttonClicked(btn)
     break
 end
end
end
end

-- Initialize monitor and draw buttons
monitor.clear()
monitor.setTextScale(0.7) -- Adjust text scale for better fitting
drawAllButtons()

-- Handle monitor touch indefinitely
handleMonitorTouch() 
    