-- import composer
local composer = require( "composer" )
require("utils.constants")
-- composer.effectList.slideUp.sceneAbove = false
composer.effectList.slideUp.concurrent = true

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------
local scoreText
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local allTimeBest
local playButton, settingsButton, scoresButton
local haptic = true
local background, logo, scoresIcon, settingsIcon, playIcon, scoreLabel, scoreText
local buttonGroup, iconGroup, backGroup

local function gotoGame()
    composer.gotoScene( "scenes.play")
end
local function gotoSettings()
    composer.gotoScene( "scenes.settings", {effect="slideUp", time=MENU_TRANSITION_DURATION})
end
local function gotoScores()
    composer.gotoScene( "scenes.scores", {effect="slideDown", time=MENU_TRANSITION_DURATION})
end

local function onBack( event )
    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        if ( system.getInfo("platform") == "android" ) then
            native.requestExit()
        end
    end
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- CREATE SCENE GROUPS

-- create()
function scene:create( event )

    local sceneGroup = self.view
    buttonGroup = display.newGroup()
    iconGroup = display.newGroup()
    backGroup = display.newGroup()

    background = display.newRect(backGroup, halfW, halfH, screenW, screenH)
    background:setFillColor(0.15,0.15,0.15)

    logo = display.newImageRect(buttonGroup, "assets/logo.png", 700, 200 )
    logo.x = display.contentCenterX
    logo.y = 100
    if event.params then
        if event.params.score then 
            scoreLabel = display.newText(buttonGroup, "YOUR SCORE", halfW, halfH-50, native.systemFont, 40 )
            scoreText = display.newText(buttonGroup,  math.floor(event.params.score), halfW, halfH+50, native.systemFont, 120 )
            scoreText.strokeWidth = 5
            scoreText:setStrokeColor( .5,.5,.5 )
        end
    end
    playButton = display.newRoundedRect(buttonGroup, halfW, halfH+200, 500, 180, 70 )
    playButton:setFillColor(38/255, 68/255, 80/255)
    playButton.strokeWidth = 7
    playButton:setStrokeColor( .5,.5,.5 )

    playIcon = display.newImageRect(iconGroup, "assets/play.png", 100, 100 )
    playIcon.x = halfW
    playIcon.y = halfH + 200

    settingsButton = display.newRoundedRect(buttonGroup, halfW-130, halfH+400, 240, 180, 70 )
    settingsButton:setFillColor(38/255, 48/255, 60/255)
    settingsButton.strokeWidth = 7
    settingsButton:setStrokeColor( .5,.5,.5 )

    settingsIcon = display.newImageRect(iconGroup, "assets/settings.png", 100, 100 )
    settingsIcon.x = halfW - 130
    settingsIcon.y = halfH + 400

    scoresButton = display.newRoundedRect(buttonGroup, halfW+130, halfH+400, 240, 180, 70 )
    scoresButton:setFillColor(38/255, 48/255, 60/255)
    scoresButton.strokeWidth = 7
    scoresButton:setStrokeColor( .5,.5,.5 )

    scoresIcon = display.newImageRect(iconGroup, "assets/stats.png", 100, 100 )
    scoresIcon.x = halfW + 130
    scoresIcon.y = halfH + 400



    playButton:addEventListener( "tap", gotoGame )
    settingsButton:addEventListener( "tap", gotoSettings )
    scoresButton:addEventListener( "tap", gotoScores )

    sceneGroup:insert(backGroup)
    sceneGroup:insert(buttonGroup)
    sceneGroup:insert(iconGroup)
    -- function that does nothing so then the back key is released it dosent quit the game
    Runtime:addEventListener("key", function() return true end)
end


function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("key", onBack)
    end
    if event.phase == "did" then
        if scoreLabel then scoreLabel:removeSelf() end
        if scoreText then scoreText:removeSelf() end
        logo:removeSelf()
        playButton:removeSelf()
        playIcon:removeSelf()
        settingsButton:removeSelf()
        settingsIcon:removeSelf()
        scoresButton:removeSelf()
        scoresIcon:removeSelf()
        background:removeSelf()

        composer.removeScene("scenes.menu")
    end
end

function scene:show(event)
    if event.phase == "did" then
        --remove event listener for the back key released
        Runtime:removeEventListener("key", function() return true end)
        Runtime:addEventListener( "key", onBack )
    end

end

-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------
 
-- Add the key event listener

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "show", scene )


return scene