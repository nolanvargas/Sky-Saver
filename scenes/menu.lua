-- import composer
local composer = require( "composer" )

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
local function gotoGame()
    composer.gotoScene( "scenes.play" , {params = {haptic}})
end
local function gotoSettings()
    composer.gotoScene( "scenes.settings", {params = {haptic}} )
end
local function gotoScores()
    composer.gotoScene( "scenes.scores")
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- CREATE SCENE GROUPS

-- create()
function scene:create( event )

    local sceneGroup = self.view

    background = display.newRect(halfW, halfH, screenW, screenH)
    background:setFillColor(0.15,0.15,0.15)

    logo = display.newImageRect( "assets/logo.png", 700, 200 )
    logo.x = display.contentCenterX
    logo.y = 100
    if event.params then
        if event.params.score then 
            scoreLabel = display.newText( "YOUR SCORE", halfW, halfH-50, native.systemFont, 40 )
            scoreText = display.newText( math.floor(event.params.score), halfW, halfH+50, native.systemFont, 120 )
            scoreText.strokeWidth = 5
            scoreText:setStrokeColor( .5,.5,.5 )
         end
    end
    playButton = display.newRoundedRect(halfW, halfH+200, 500, 180, 70 )
    playButton:setFillColor(38/255, 68/255, 80/255)
    playButton.strokeWidth = 7
    playButton:setStrokeColor( .5,.5,.5 )

    playIcon = display.newPolygon( halfW+10, halfH+200, {-40,60,60,0,-40,-60} )
    playIcon:setFillColor(.9,.9,.9)

    settingsButton = display.newRoundedRect(halfW-130, halfH+400, 240, 180, 70 )
    settingsButton:setFillColor(38/255, 48/255, 60/255)
    settingsButton.strokeWidth = 7
    settingsButton:setStrokeColor( .5,.5,.5 )

    settingsIcon = display.newImageRect( "assets/settings.png", 100, 100 )
    settingsIcon.x = halfW - 130
    settingsIcon.y = halfH + 400

    scoresButton = display.newRoundedRect(halfW+130, halfH+400, 240, 180, 70 )
    scoresButton:setFillColor(38/255, 48/255, 60/255)
    scoresButton.strokeWidth = 7
    scoresButton:setStrokeColor( .5,.5,.5 )

    scoresIcon = display.newImageRect( "assets/stats.png", 100, 100 )
    scoresIcon.x = halfW + 130
    scoresIcon.y = halfH + 400



    playButton:addEventListener( "tap", gotoGame )
    settingsButton:addEventListener( "tap", gotoSettings )
    scoresButton:addEventListener( "tap", gotoScores )

    sceneGroup:insert(background)
    sceneGroup:insert(playButton)
    sceneGroup:insert(settingsButton)
    sceneGroup:insert(scoresButton)
    sceneGroup:insert(logo)


end


function scene:hide(event)
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

-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )


return scene