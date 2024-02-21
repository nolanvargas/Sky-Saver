---sceneGroup - Scene group to add the toggle switch to 
--- 
---x - X coordinate
---
---y - Y coodinate
---
---enabled - start state for switch
---
---toggleEvent - callback for toggle event
---@param x number
---@param y number
---@param enabled boolean
---@param sceneGroup display.sceneGroup
---@param toggleEvent function
function newToggleSwitch(sceneGroup, x, y, enabled, toggleEvent)
    local toggleGroup = display.newGroup()
    local back = display.newRoundedRect(toggleGroup, x, y, 80, 34, 17)
    local button = display.newCircle(toggleGroup, ternary(enabled, x+20, x-20), y, 30)
    back.width = 100
    if enabled then 
        button:setFillColor(230/255, 230/255, 230/255)
        back:setFillColor(201/255, 201/255, 201/255)
    else 
        button:setFillColor(201/255, 201/255, 201/255)
        back:setFillColor(133/255, 133/255, 133/255)
    end   
    sceneGroup:insert(toggleGroup)
    toggleGroup:addEventListener("touch", function(event)
        if event.phase == "began" then 
            toggleSwitch(toggleGroup, enabled)
            enabled = not enabled
            toggleEvent()
        end
    end)
end

function toggleSwitch(toggleSwitch, state)
    if state == true then
        toggleSwitch[1]:setFillColor(133/255, 133/255, 133/255)
        toggleSwitch[2]:setFillColor(201/255, 201/255, 201/255)
        transition.to(toggleSwitch[2], {time=100, x = toggleSwitch[2].x -40})
    elseif state == false then
        toggleSwitch[1]:setFillColor(201/255, 201/255, 201/255)
        toggleSwitch[2]:setFillColor(230/255, 230/255, 230/255)
        transition.to(toggleSwitch[2], {time=100, x = toggleSwitch[2].x +40})
    end

end

function newCurrencyBox(sceneGroup, x, y)

    -- currency
    local currency = getPlayerCurrency()
    local coin = display.newImageRect(sceneGroup, "assets/coin.png", 50, 50 )
    coin.x = x
    coin.y = y
    local seperator = display.newRect(sceneGroup, coin.x+50 , coin.y,4, 75)
                
    local options1 = 
    {
        parent = sceneGroup,
        text = currency,
        x = coin.x + 275,
        y = coin.y,
        font = TEKTUR,
        fontSize = 52,
        width = 400,
        align = "left"
    }
    local currencyAmount = display.newText(options1)
    currencyAmount.align = "left"
end