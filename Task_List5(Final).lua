-- Wrap the monitor peripheral
local monitor = peripheral.wrap("right")

-- Define button properties
local buttons = {}
local buttonWidth = 30  -- Width for the main buttons
local buttonHeight = 15 -- Height for the main buttons
local buttonSpacing = 2
local screenWidth, screenHeight = monitor.getSize()

-- Define default button label
local defaultLabel = "New"

-- Define custom labels for initial display
local buttonLabels = {"Task1", "Task2", "Task3", "Task4", "Task5", "Task6", "Task7", "Task8", "Task9"}

-- Define properties for the "Edit Labels" button
local editButtonWidth = 16
local editButtonHeight = 5
local editMode = false -- Track whether we're in edit mode

-- Function to draw a button on the monitor
local function drawButton(button, fillColor)
    monitor.setBackgroundColor(fillColor)
    for y = button.y, button.y + button.height - 1 do
        monitor.setCursorPos(button.x, y)
        monitor.write(string.rep(" ", button.width))
    end

    -- Draw the label   
    monitor.setCursorPos(button.x + math.floor((button.width - #button.label) / 2), button.y + math.floor(button.height / 2))
    monitor.setTextColor(colors.white)
    monitor.write(button.label)

    -- Draw the outline
    monitor.setBackgroundColor(colors.gray)
    monitor.setCursorPos(button.x, button.y)
    monitor.write(string.rep(" ", button.width))
    monitor.setCursorPos(button.x, button.y + button.height - 1) 
    monitor.write(string.rep(" ", button.width))
    for y = button.y, button.y + button.height - 1 do
        monitor.setCursorPos(button.x, y)
        monitor.write(" ")
        monitor.setCursorPos(button.x + button.width - 1, y)
        monitor.write(" ")
    end
end

-- Function to handle button clicks
local function buttonClicked(button)
    if button.clicked then
        return -- Ignore the click if the button was already clicked
    end

    if button.label == "Edit Labels" then
        editMode = true
        print("Edit mode enabled. Click on a button to edit its label.")
        drawButton(button, colors.blue)
    elseif editMode then
        -- Allow user to edit the label of the clicked button
        print("Enter new label for " .. button.label .. ":")
        local newLabel = read()
        if newLabel ~= "" then
            button.label = newLabel
        end
        drawButton(button, colors.red)
        editMode = false -- Exit edit mode after one button is edited
        print("Edit mode disabled.")
    else
        monitor.setBackgroundColor(colors.green)
        drawButton(button, colors.green)
        button.clicked = true -- Mark the button as clicked
        print("Button " .. button.label .. " clicked!")
        button.label = defaultLabel .. " Clicked"

        -- Check if all buttons have been clicked
        local allClicked = true
        for _, btn in ipairs(buttons) do
            if not btn.clicked and btn.label ~= "Edit Labels" then
                allClicked = false
                break
            end
        end

        -- If all buttons are clicked, reset them
        if allClicked then
            os.sleep(1) -- Small delay before reset
            for _, btn in ipairs(buttons) do
                if btn.label ~= "Edit Labels" then
                    btn.label = defaultLabel
                    btn.clicked = false -- Reset the clicked status
                    drawButton(btn, colors.red)
                end
            end
        end
    end
end

-- Function to draw all buttons on the monitor
local function drawAllButtons()
    local buttonCount = #buttonLabels
    local buttonsPerRow = 3
    local startX = math.floor((screenWidth - (buttonsPerRow * (buttonWidth + buttonSpacing) - buttonSpacing)) / 2)
    local startY = math.floor((screenHeight - (3 * (buttonHeight + buttonSpacing) - buttonSpacing)) / 2)
    
    for i = 1, buttonCount do
        local row = math.ceil(i / buttonsPerRow)
        local col = i - (row - 1) * buttonsPerRow
        local x = startX + (col - 1) * (buttonWidth + buttonSpacing)
        local y = startY + (row - 1) * (buttonHeight + buttonSpacing)
        
        buttons[i] = {x = x, y = y, width = buttonWidth, height = buttonHeight, label = buttonLabels[i], clicked = false}
        drawButton(buttons[i], colors.red)
    end

    -- Place the "Edit Labels" button directly below the last button in the grid
    local lastButton = buttons[#buttons]
    local editButtonX = lastButton.x + math.floor((buttonWidth - editButtonWidth) / 2)
    local editButtonY = lastButton.y + buttonHeight + buttonSpacing
    local editButton = {x = editButtonX, y = editButtonY, width = editButtonWidth, height = editButtonHeight, label = "Edit Labels", clicked = false}
    table.insert(buttons, editButton)
    drawButton(editButton, colors.blue)
end 

-- Function to handle monitor touch events
local function handleMonitorTouch()
    while true do
        local event, side, cx, cy = os.pullEvent("monitor_touch")
        
        for _, btn in ipairs(buttons) do
            if cx >= btn.x and cx < btn.x + btn.width and cy >= btn.y and cy < btn.y + btn.height then
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
