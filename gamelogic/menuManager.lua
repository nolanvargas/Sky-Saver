require("utils.constants")
require("utils.utils")
require("utils.components")
require("gamelogic.backgroundGenerator")
local composer = require( "composer" )
--
--
--                  Settings
--
--
-- 
--
--                  Home
--
--
--
--                  Game Modes
--
--


-- -----------------------------------------------------------------------------------
-- Display Groups
-- -----------------------------------------------------------------------------------

local starGroup, skyGroup, backGroup

-- home group
local homeButtonGroup, homeIconGroup
local homeGroup

-- home ui

local homeUIButtonGroup, homeUIIconGroup
local homeUIGroup

-- settings group
local settingsBackDrop, settingsLabels
local settingsGroup

-- gamemodes group
local gameModeTiles, gameModeTilesBackground, scrollBar
local gameModesGroup

-- scores group

-- -----------------------------------------------------------------------------------
-- Forward Declarations
-- -----------------------------------------------------------------------------------

-- display constants

local background
local rocket, flame
local touchX, touchY = 0,0
local currentScene, prevScene
local moveRocket = false

-- Flags
local touchInBounds = false
local goingToGame

-- Home Buttons
local playButton, gameModesButton

-- UI Buttons
local settingsIcon
local economy
local scoresButton, slotsButton, customizeButton

-- -----------------------------------------------------------------------------------
-- Local Functions
-- -----------------------------------------------------------------------------------

local spinToTransition, send
local goToGame, goToGameModes, goToSettings, goToScores, goToHome
local disableHomeButtons, enableHomeButtons
local disableSettingsButtons, enableSettingsButtons
local disableGameModesButtons, enableGameModesButtons
local disableUIButtons, enableUIButtons
local disableAllButtons, enableButtons
local goToScene, changeScene, goToPreviousScene
local globalTouchEvent


-- -----------------------------------------------------------------------------------
-- Scene Change Functions
-- -----------------------------------------------------------------------------------

function goToSettings()
    changeScene(currentScene, "settings")
end

function goToScores()
    composer.gotoScene( "scenes.scores", {effect="slideDown", time=MENU_TRANSITION_DURATION})
end

function goToHome()
    changeScene(currentScene, "home")
end

function goToGame()
    goingToGame = true  
    disableAllButtons()
    removeAllRuntimes()
    transition.to(homeGroup, {time=200, y = homeGroup.y - SCREENH-500, transition=easing.inCirc})
    transition.to(homeUIGroup, {time=200, y = homeUIGroup.y - SCREENH-500, transition=easing.inCirc})
    transition.to(backGroup, {time=200, y = backGroup.y - SCREENH-500, transition=easing.inCirc})
    transition.to(starGroup, {time=300, y = starGroup.y - SCREENH, transition=easing.inCirc, onComplete=function() 
        transition.to(background, {time=200, alpha = 1, onComplete=function() 
            local clouds = display.newGroup()
            for i=1, 7 do 
                addCloud(clouds)
                for j=1, clouds.numChildren do
                    clouds[j].y = clouds[j].y + SCREENH*0.7
                end
            end
            transition.to(clouds, {time=400, y = -9000, onComplete= function() 
                clouds:removeSelf()
                composer.gotoScene("scenes.play", {effect="slideUp", transition=easing.outCirc, time=200}) 
            end})
        end})
        transition.to(starGroup, {time=100, y = starGroup.y - math.abs(MARGINY)-MENU_STAR_BUFFER})
    end})
    --composer.gotoScene( "scenes.play")
end

function goToGameModes()
    changeScene(currentScene, "gameModes")
end

function goToPreviousScene()
    if prevScene == "home" then goToHome()
    elseif prevScene == "settings" then goToSettings()
    elseif prevScene == "gameModes" then goToGameModes() end
end

function goToScene(scene)
    if prevScene == scene then return end
    if scene == "home" then goToHome()
    elseif scene == "settings" then goToSettings()
    elseif scene == "gameModes" then goToGameModes() end
end

local function moveStars(direction)
    if direction == "up" then
        for i=1, starGroup.numChildren do
            transition.to(starGroup[i], {time=MENU_TRANSITION_DURATION, y = starGroup[i].y + 100, transition=easing.inOutCubic})
        end
    elseif direction == "down" then 
        for i=1, starGroup.numChildren do
            transition.to(starGroup[i], {time=MENU_TRANSITION_DURATION, y = starGroup[i].y - 100, transition=easing.inOutCubic})
        end
    elseif direction == "left" then
        for i=1, starGroup.numChildren do
            transition.to(starGroup[i], {time=MENU_TRANSITION_DURATION, x = starGroup[i].x + 100, transition=easing.inOutCubic})
        end
    elseif direction == "right" then
        for i=1, starGroup.numChildren do
            transition.to(starGroup[i], {time=MENU_TRANSITION_DURATION, x = starGroup[i].x - 100, transition=easing.inOutCubic})
        end
    else assert(false, "Invalid direction") end
end

function send(scene, direction)
    local x, y
    if direction == "up" then y = -SCREENH
    elseif direction == "down" then y = SCREENH
    elseif direction == "left" then x = -SCREENW
    elseif direction == "right" then x = SCREENW
    else assert(false, "Invalid direction: "..direction) end
    if scene == "home" then
        if x then
            moveStars(ternary(x> 0, "right", "left"))
            for i=1, homeGroup.numChildren do
                for j=1, homeGroup[i].numChildren do
                    transition.to(homeGroup[i][j], {time=MENU_TRANSITION_DURATION, y = homeGroup[i][j].y + y, transition=easing.inOutCubic})
                end
            end
        elseif y then 
            moveStars(ternary(y> 0, "up", "down"))
            for i=1, homeGroup.numChildren do
                for j=1, homeGroup[i].numChildren do
                    transition.to(homeGroup[i][j], {time=MENU_TRANSITION_DURATION, y = homeGroup[i][j].y + y, transition=easing.inOutCubic})
                end
            end
        end

    elseif scene == "settings" then
        if x then
            moveStars(ternary(x> 0, "right", "left"))
            for i=1, settingsGroup.numChildren do
                transition.to(settingsGroup[i], {time=MENU_TRANSITION_DURATION, y = settingsGroup[i].y + y, transition=easing.inOutCubic})
            end
        elseif y then 
            moveStars(ternary(y> 0, "up", "down"))
            for i=1, settingsGroup.numChildren do
                transition.to(settingsGroup[i], {time=MENU_TRANSITION_DURATION, y = settingsGroup[i].y + y, transition=easing.inOutCubic})
            end
        end
    elseif scene == "gameModes" then
        if x then
            moveStars(ternary(x> 0, "right", "left"))
            for i=1, gameModesGroup.numChildren do
                transition.to(gameModesGroup[i], {time=MENU_TRANSITION_DURATION, y = gameModesGroup[i].y + y, transition=easing.inOutCubic})
            end
        elseif y then 
            moveStars(ternary(y> 0, "up", "down"))
            for i=1, gameModesGroup.numChildren do
                transition.to(gameModesGroup[i], {time=MENU_TRANSITION_DURATION, y = gameModesGroup[i].y + y, transition=easing.inOutCubic})
            end
        end
    end
end

function changeScene(fromScene, toScene)
    if prevScene == nil then prevScene = fromScene end
    prevScene = fromScene
    currentScene = toScene

    local transitionDirection
    local willSend = true
    if fromScene == "settings" and toScene == "home" then
        transitionDirection = "up"
    elseif fromScene == "home" and toScene == "settings" then
        transitionDirection = "down"
    elseif fromScene == "home" and toScene == "gameModes" then
        transitionDirection = "up"
    elseif fromScene == "gameModes" and toScene == "home" then
        transitionDirection = "down"
    elseif fromScene == "gameModes" and toScene == "settings" then
        transitionDirection = "up"
    elseif fromScene == "settings" and toScene == "gameModes" then
        transitionDirection = "down"
    else willSend = false end
    if willSend then
        send(fromScene, transitionDirection)
        send(toScene, transitionDirection)
    end
end

-- -----------------------------------------------------------------------------------
-- Button Enablers/Disablers
-- -----------------------------------------------------------------------------------

function removeAllRuntimes()
    Runtime:removeEventListener("touch", globalTouchEvent)
end

function disableHomeButtons()
    playButton.isEnabled = false
    gameModesButton.isEnabled = false
end

function enableHomeButtons()
    playButton.isEnabled = true
    gameModesButton.isEnabled = true
    -- playButton:addEventListener( "tap", goToGame )
    -- gameModesButton:addEventListener("tap", goToGameModes)
    -- gameModesButton:addEventListener( "tap", function() spinToTransition(homeUIButtonGroup, settingsIcon, nil, true) end )

end

function disableSettingsButtons()
end

function enableSettingsButtons()
end

function enableGameModesButtons()
end

function disableGameModesButtons()
end

function disableUIButtons()
    settingsIcon.isEnabled = false
    slotsButton.isEnabled = false
    scoresButton.isEnabled = false
    customizeButton.isEnabled = false
    economy.isEnabled = false

end

function enableUIButtons()
    settingsIcon.isEnabled = true
    slotsButton.isEnabled = true
    scoresButton.isEnabled = true
    customizeButton.isEnabled = true
    economy.isEnabled = true

end

function disableAllButtons()
    disableHomeButtons()
    disableSettingsButtons()
    disableGameModesButtons()
    disableUIButtons()
end

function enableButtons(scene)
    if scene == "home" then enableHomeButtons()
    elseif scene == "settings" then enableSettingsButtons()
    elseif scene == "gameModes" then enableGameModesButtons()
    else assert(false, "invalid scene to enable buttons") end
end

-- -----------------------------------------------------------------------------------
-- Toggling Functions
-- -----------------------------------------------------------------------------------

function spinToTransition(sceneGroup, original, back, isBack)
    
    if not isBack and back == nil then assert(false, "back button required if isBack is true") end
    
    --disable buttons so that no button is pressed in transition, causing problems
    disableAllButtons()
    local newBack, originalX, originalY, originalHeight, originalWidth
    
    -- function for when we are ready to switch from original button to new button
    local function transitionGo(original, back)
        --if statements to keep runtime errors away
        if isBack then 
            -- switch over visually
            original.alpha = 0
            back.alpha = 1
            
            -- set this flag to false to stop current functionality
            if not (original.isEnabled == nil) then original.isEnabled = false end
            
            -- start the back arrow spinning animation 
            transition.to(back, {time=200, rotation=-720, transition=easing.outCubic, onComplete=function() 
                -- this may posibly be run after the play button is pressed so just in case 
                if not goingToGame then
                    -- event for functionality
                    back:addEventListener( "tap", goToPreviousScene )
                    -- event for animation into transition
                    back:addEventListener( "tap", function()
                        spinToTransition(homeUIButtonGroup, original, back, false)
                    end)
                end
                enableButtons(currentScene)
            end})
        else
            -- is not back button
            -- switch over visually
            original.alpha = 1
            back.alpha = 0
            -- all done with the back button so out u go
            back:removeSelf()

            -- start the original icon spinning animation 
            transition.to(original, {time=200, rotation=-720, transition=easing.outCubic, onComplete=function() 
                -- this may posibly be run after the play button is pressed so just in case 
                if not goingToGame then
                    -- set this flag to true to resume regular functionality
                    if not (original.isEnabled == nil) then original.isEnabled = true end
                end
                enableButtons(currentScene)
            end})
        end
    end

    -- no need to make anything new if isBack == false

    if isBack then -- we create a new back button that runs gotoPrevScene
        -- keep track of location and dimension for new back button
        originalX = original.x
        originalY = original.y
        originalWidth = original.width
        originalHeight = original.height
        newBack = display.newImageRect( sceneGroup, "assets/back.png", original.width, original.height )
        -- Sometimes the newBack isnt created properly so rather than find out why,
        -- simply run it through an if statement
        if newBack then
            newBack.x = originalX 
            newBack.y = originalY
            -- set invisible at start so we can rotate previous icon into transition
            newBack.alpha = 0
        end
        transition.to(original, {time=10, rotation=-360, transition=easing.inCubic, onComplete=function() transitionGo(original, newBack) end})
    else
        transition.to(back, {time=100, rotation=-360, transition=easing.inCubic, onComplete=function() transitionGo(original, back) end})
    end
end

local function toggleLabelColor(label, isToggled)

    if isToggled then
        label:setFillColor(230/255, 230/255, 230/255)
    else
        label:setFillColor(167/255, 167/255, 167/255)
    end

end

-- -----------------------------------------------------------------------------------
-- Updates/Events
-- -----------------------------------------------------------------------------------


local function update()
    local fX, fY = 0,0
    if moveRocket then 
        local angle = ((rocket.rotation-90)* math.pi)  / 180
        fX = math.cos(angle)
        fY = math.sin(angle)
        rocket:applyForce(fX*5, fY*5, rocket.x, rocket.y)
    end

    if math.abs(touchX - rocket.x) < 125 and math.abs(touchY - rocket.y) < 100 then touchInBounds = true
    else 
        moveRocket = false
        touchInBounds = false 
    end

    --update flame
    flame.rotation = rocket.rotation
    flame.y = rocket.y + fY * 100 * -1.42
    flame.x = rocket.x + fX * 100 * -1.42
    flame.alpha = (moveRocket) and 1 or 0  -- Set alpha based

    --wrap ship
    if rocket.x > SCREENW + 150 then rocket.x = -MARGINX - 150
    elseif rocket.x < MARGINX -150 then rocket.x = SCREENW + 150
    elseif rocket.y > SCREENH + 100 then rocket.y = MARGINY - 150
    elseif rocket.y < MARGINY -150 then rocket.y = SCREENH+ 100
    end
end

function updateRocket()
    local fX, fY = 0,0
    if moveRocket then 
        local angle = ((rocket.rotation-90)* math.pi)  / 180
        fX = math.cos(angle)
        fY = math.sin(angle)
        rocket:applyForce(fX*5, fY*5, rocket.x, rocket.y)
    end

    if math.abs(touchX - rocket.x) < 125 and math.abs(touchY - rocket.y) < 100 then touchInBounds = true
    else 
        moveRocket = false
        touchInBounds = false 
    end

    --update flame
    flame.rotation = rocket.rotation
    flame.y = rocket.y + fY * 100 * -1.42
    flame.x = rocket.x + fX * 100 * -1.42
    flame.alpha = (moveRocket) and 1 or 0  -- Set alpha based

    --wrap ship
    if rocket.x > SCREENW + 150 then rocket.x = -MARGINX - 150
    elseif rocket.x < MARGINX -150 then rocket.x = SCREENW + 150
    elseif rocket.y > SCREENH + 100 then rocket.y = MARGINY - 150
    elseif rocket.y < MARGINY -150 then rocket.y = SCREENH+ 100
    end
end

function globalTouchEvent(event)

    touchX, touchY = event.x, event.y
    -- touch x and touch y start at 0, so it would miss the "began" phase and the rocket would not move unless the
    -- phase was "moved". we fix that by checking here as well as in update because if the touch is not "moved" then
    -- this function would not run
    if math.abs(touchX - rocket.x) < 125 and math.abs(touchY - rocket.y) < 100 then touchInBounds = true end
    if touchInBounds and (event.phase == "began" or event.phase == "moved") then moveRocket = true 
    else 
        moveRocket = false 
    end
end


-- -----------------------------------------------------------------------------------
-- Scene Creation Functions
-- -----------------------------------------------------------------------------------

local function menuBackground() 
    if DEBUG then
        physics.setDrawMode("hybrid")
    end

    -- add space background
    background = display.newRect(skyGroup, HALFW, HALFH, SCREENW, SCREENH)
    background:setFillColor(unpack(SKY_COLOR))
    background.alpha = 0

    -- add stars
    generateStars(starGroup, 300, MARGINX, MARGINY)

    
    rocket = display.newImageRect(backGroup, "assets/rocket.png", 225, 300 )
    flame = display.newImageRect(backGroup, "assets/flame.png", 150, 150)
    physics.addBody( rocket, "dynamic" )
    rocket.x = math.random(200, 600)
    rocket.y = math.random(100, 300)
    rocket.rotation = math.random(0,359)
    rocket.gravityScale = 0
    flame.width = 85
    flame.height = 70
    flame.alpha = 0  -- Initially invisible
    flame.anchorY = 0  -- Set anchor point to the bottom
    flame.y = rocket.y + rocket.height / 2  -- Position it at the bottom of the rocket
    flame.x = rocket.x  -- Align it horizontally with the rocket
    local tourqe = ternary(math.random(0,1), math.random(-400, -250), math.random(250, 400))
    rocket.angularVelocity = 0  
    rocket:setLinearVelocity( 0, 0)
    rocket:applyTorque( tourqe )

end

local function newMenu()
    
    -- settings button
    settingsIcon = display.newImageRect(homeUIIconGroup, "assets/settings.png", 80, 80 )
    if MARGINY < 0 then settingsIcon.y = MARGINY + 100 else settingsIcon.y = 100 end
    if MARGINX < 0 then settingsIcon.x = 800 + math.abs(MARGINX) - 100 else settingsIcon.x = 700 end
    -- give the settings icon a flag to determine if it should be enabled or not when it transitions to a back button
    settingsIcon.isEnabled = false

    -- currency
    local currency = getPlayerCurrency()
    local coin = display.newImageRect(economy, "assets/coin.png", 50, 50 )
    if MARGINY < 0 then coin.y = MARGINY + 100 else coin.y = 100 end
    if MARGINX < 0 then coin.x = MARGINX + 100 else coin.x = 100 end

    local seperator = display.newRect(economy, coin.x+50 , coin.y,4, 75)
            
    local options1 = 
    {
        parent = economy,
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

    playButton = display.newRoundedRect(homeButtonGroup, HALFW, HALFH+100, 500, 150, 75 )
    playButton:setFillColor(54/255, 162/255, 228/255)
    playButton.strokeWidth = 20
    playButton:setStrokeColor(27/255, 112/255, 177/255)
    playButton.isEnabled = false

    playIcon = display.newImageRect(homeIconGroup, "assets/play.png", 100, 100 )
    playIcon.x = HALFW
    playIcon.y = HALFH + 100


    gameModesButton = display.newRoundedRect(homeButtonGroup, HALFW, HALFH+300, 500, 150, 75 )
    gameModesButton:setFillColor(54/255, 162/255, 228/255)
    gameModesButton.strokeWidth = 20
    gameModesButton:setStrokeColor(27/255, 112/255, 177/255)
    gameModesButton.isEnabled = false

    local gameIcon = display.newImageRect(homeIconGroup, "assets/videoGame.png", 130, 130 )
    gameIcon.x = HALFW
    gameIcon.y = HALFH + 300


    scoresButton = display.newRoundedRect(homeUIButtonGroup, 150, SCREENH+MARGINY-70, 225, 160, 25 )
    scoresButton:setFillColor(54/255, 162/255, 228/255)
    scoresButton.strokeWidth = 15
    scoresButton:setStrokeColor(27/255, 112/255, 177/255)
    scoresButton.isEnabled = false

    local scoresIcon = display.newImageRect(homeUIIconGroup, "assets/stats.png", 100, 100 )
    scoresIcon.x = HALFW -250
    scoresIcon.y = SCREENH+MARGINY-70


    slotsButton = display.newRoundedRect(homeUIButtonGroup, HALFW, SCREENH+MARGINY-70, 225, 160, 25 )
    slotsButton:setFillColor(54/255, 162/255, 228/255)
    slotsButton.strokeWidth = 15
    slotsButton:setStrokeColor(27/255, 112/255, 177/255)
    slotsButton.isEnabled = false

    local slotsIcon = display.newImageRect(homeUIIconGroup, "assets/slots.png", 100, 100 )
    slotsIcon.x = HALFW
    slotsIcon.y = SCREENH+MARGINY-70


    customizeButton = display.newRoundedRect(homeUIButtonGroup, HALFW+ 250, SCREENH+MARGINY-70, 225, 160, 25 )
    customizeButton:setFillColor(54/255, 162/255, 228/255)
    customizeButton.strokeWidth = 15
    customizeButton:setStrokeColor(27/255, 112/255, 177/255)
    customizeButton.isEnabled = false

    local customizeIcon = display.newImageRect(homeUIIconGroup, "assets/rocketSilouette.png", 130, 130 )
    customizeIcon.rotation = 45
    customizeIcon.x = HALFW + 250
    customizeIcon.y = SCREENH+MARGINY-70

    enableHomeButtons()
    enableUIButtons()

    playButton:addEventListener("tap", function() if playButton.isEnabled then goToGame() end end)
    gameModesButton:addEventListener("tap", function() if gameModesButton.isEnabled then goToGameModes() end end)
    gameModesButton:addEventListener( "tap", function() if gameModesButton.isEnabled then spinToTransition(homeUIButtonGroup, settingsIcon, nil, true) end end )
    settingsIcon:addEventListener( "tap", function() if settingsIcon.isEnabled then goToSettings() end end )
    settingsIcon:addEventListener( "tap", function() if settingsIcon.isEnabled then spinToTransition(homeUIButtonGroup, settingsIcon, nil, true) end end )
    scoresButton:addEventListener( "tap", function() if scoresButton.isEnabled then goToScores() end end )

end

local function newSettings()
    local x, y
    local location = {"up"}
    local playerSettings = getSettings()

    x, y = unpack(osc(HALFW, HALFH-50, location))
    local settingsBackground = display.newRoundedRect( settingsBackDrop, x, y, CONTENTW-50, SCREENH-500, 50 )
    settingsBackground:setFillColor(51/255, 51/255, 51/255)
    
    x, y = unpack(osc(190, (settingsBackground.y+SCREENH)-(settingsBackground.height*0.43), location))
    local options1 = 
    {
        parent = settingsLabels,
        text = "Vibration",
        x = x,
        y = y,
        font = "assets/fonts/tektur/Tektur-Medium.ttf",
        fontSize = 48,
    }
    local vibrationLabel = display.newText( options1 )
    toggleLabelColor(vibrationLabel, playerSettings["PLAYER_HAPTICS"])

    x, y = unpack(osc(CONTENTW - 150, (settingsBackground.y+SCREENH)-(settingsBackground.height*0.43), location))
    newToggleSwitch(settingsLabels, x, y, playerSettings["PLAYER_HAPTICS"], function() 
        playerSettings["PLAYER_HAPTICS"] = not playerSettings["PLAYER_HAPTICS"] 
        toggleLabelColor(vibrationLabel, playerSettings["PLAYER_HAPTICS"])
        setSetting(playerSettings)
    end)

end

local function newGameModes()

    local x, y
    x, y = unpack(osc(HALFW, MARGINY + 375, {"down"}))
    local standard = display.newRoundedRect(gameModeTilesBackground, x, y, CONTENTW-100, 400, 30)
    standard:setFillColor(61/255, 61/255, 61/255)
    standard:setStrokeColor(230/255, 230/255, 230/255)
    standard.strokeWidth = 10

    x, y = unpack(osc(HALFW - 120, MARGINY + 500, {"down"}))
    local options1 = 
    {
        parent = gameModeTiles,
        text = "Classic",
        x = x,
        y = y,
        font = TEKTUR,
        fontSize = 72,
        width = 400,
        align = "left"
    }
    local standardText = display.newText(options1)

    x, y = unpack(osc(HALFW, MARGINY + 800, {"down"}))
    local standard = display.newRoundedRect(gameModeTilesBackground, x, y, CONTENTW-100, 400, 30)
    standard:setFillColor(40/255, 78/255, 80/255)
    standard:setStrokeColor(88/255, 204/255, 207/255)
    standard.strokeWidth = 10


end

-- -----------------------------------------------------------------------------------
-- Global Functions
-- -----------------------------------------------------------------------------------


function newHomeScene(sceneGroup) 

    goingToGame = false

    skyGroup = display.newGroup()
    backGroup = display.newGroup()
    starGroup = display.newGroup()

    homeButtonGroup, homeIconGroup = display.newGroup(), display.newGroup()
    homeGroup = display.newGroup()
    homeGroup:insert(homeButtonGroup)
    homeGroup:insert(homeIconGroup)

    homeUIButtonGroup, homeUIIconGroup, economy = display.newGroup(), display.newGroup(), display.newGroup()
    homeUIGroup = display.newGroup()
    homeUIButtonGroup:insert(economy)
    homeUIGroup:insert(homeUIButtonGroup)
    homeUIGroup:insert(homeUIIconGroup)

    settingsGroup = display.newGroup()
    settingsBackDrop = display.newGroup()
    settingsLabels = display.newGroup()
    settingsGroup:insert(settingsBackDrop)
    settingsGroup:insert(settingsLabels)

    gameModeTiles = display.newGroup()
    scrollBar = display.newGroup()
    gameModeTilesBackground = display.newGroup()
    gameModesGroup = display.newGroup()
    gameModesGroup:insert(gameModeTilesBackground)
    gameModesGroup:insert(gameModeTiles)
    gameModesGroup:insert(scrollBar)

    currentScene = "home"

    menuBackground()

    newMenu()

    newSettings()

    newGameModes()




    sceneGroup:insert(skyGroup)
    sceneGroup:insert(starGroup)
    sceneGroup:insert(backGroup)

    sceneGroup:insert(homeUIGroup)
    sceneGroup:insert(homeGroup)
    sceneGroup:insert(settingsGroup)

    Runtime:addEventListener("touch", globalTouchEvent)    


end


