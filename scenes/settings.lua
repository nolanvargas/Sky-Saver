-- import composer
local composer = require( "composer" )
local audio = require("audio")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local hapticButton, resetScoresButton, mysteryButton, backButton
local background, hapticIcon, resetText, mysteryButtonText, backIcon
local haptic
local whistle = audio.loadSound( "assets/whistle.mp3" )
local josh


local function toggleHaptic()
    haptic = not haptic
end

local function gotoMenu()
    composer.gotoScene( "scenes.menu" )
end

local function startTroll()
    audio.stop()
    audio.play(whistle);
    display.remove(josh);
    josh = display.newImageRect("assets/josh.png", 1000, 1000)
    josh.alpha = 0
    josh.y = halfH+200
    josh.x = halfW
    transition.fadeIn(josh,{time=3000});
    transition.moveTo(josh,{time=4000, y = halfH-200});
end

local function confirm()

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

    haptic = event.params.haptic

    hapticButton = display.newRoundedRect(halfW, halfH-200, 500, 180, 70 )
    hapticButton:setFillColor(38/255, 68/255, 80/255)
    hapticButton.strokeWidth = 7
    hapticButton:setStrokeColor( .5,.5,.5 )

    hapticIcon = display.newImageRect( "assets/haptic.png", 100, 100 )
    hapticIcon.x = halfW
    hapticIcon.y = halfH -200
    
    resetScoresButton = display.newRoundedRect(halfW, halfH, 500, 180, 70 )
    resetScoresButton:setFillColor(38/255, 68/255, 80/255)
    resetScoresButton.strokeWidth = 7
    resetScoresButton:setStrokeColor( .5,.5,.5 )

    resetText = display.newText( "RESET SCORES",halfW,halfH,native.systemFont, 40 )

    mysteryButton = display.newRoundedRect(halfW, halfH+200, 500, 180, 70 )
    mysteryButton:setFillColor(38/255, 68/255, 80/255)
    mysteryButton.strokeWidth = 7
    mysteryButton:setStrokeColor( .5,.5,.5 )

    mysteryButtonText = display.newText( "?",halfW,halfH+200,native.systemFont, 100 )

    backButton = display.newRoundedRect(halfW, halfH+400, 500, 180, 70 )
    backButton:setFillColor(38/255, 68/255, 80/255)
    backButton.strokeWidth = 7
    backButton:setStrokeColor( .5,.5,.5 )

    backIcon = display.newImageRect( "assets/back.png", 100, 100 )
    backIcon.x = halfW
    backIcon.y = halfH +400

    hapticButton:addEventListener("tap", toggleHaptic);
    backButton:addEventListener("tap", gotoMenu);
    resetScoresButton:addEventListener("tap", confirm)
    mysteryButton:addEventListener("tap", startTroll);



end


function scene:hide(event)
    if event.phase == "did" then
        background:removeSelf()
        hapticIcon:removeSelf()
        hapticButton:removeSelf()
        backButton:removeSelf()
        backIcon:removeSelf()
        mysteryButton:removeSelf()
        mysteryButtonText:removeSelf()
        resetScoresButton:removeSelf()
        resetText:removeSelf()
        if josh then josh:removeSelf() end
        audio.stop();
        audio.dispose( whistle )
        composer.removeScene("scenes.settings")
    end
end

-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )


return scene