-- import composer
local composer = require( "composer" )
composer.effectList.fromTop.from.yStart = -display.contentHeight
composer.effectList.fromTop.to.yStart = -display.contentHeight
local audio = require("audio")
local scene = composer.newScene()
require("utils.utils")



-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local hapticButton, resetScoresButton, mysteryButton, backButton
local background, hapticIcon, resetText, mysteryButtonText, backIcon
local whistle
local josh
local hapticDisabled
local confirmBox, cancelButton, confirmButton, cancelText, confirmText, confirmPrompt
local isResetConfirming = false

local enableSettingsButtons, disableSettingsButtons, toggleHaptic, confirmReset, startTroll, clearResetConfirmation, cancelTroll, gotoMenu

function clearResetConfirmation()
    isResetConfirming = false
    if confirmButton then confirmButton:removeEventListener("tap", resetScores) end
    if confirmButton then confirmButton:removeEventListener("tap", clearResetConfirmation) end
    if cancelButton then cancelButton:removeEventListener("tap", clearResetConfirmation) end
    if confirmBox then confirmBox:removeSelf() end
    if confirmPrompt then confirmPrompt:removeSelf() end
    if confirmButton then confirmButton:removeSelf() end
    if confirmText then confirmText:removeSelf() end
    if cancelButton then cancelButton:removeSelf() end
    if cancelText then cancelText:removeSelf() end
    enableSettingsButtons()
    return true
end

function enableSettingsButtons()
    hapticButton:addEventListener("tap", toggleHaptic);
    backButton:addEventListener("tap", gotoMenu);
    resetScoresButton:addEventListener("tap", confirmReset)
    mysteryButton:addEventListener("touch", startTroll);
    return true
end

function disableSettingsButtons()
    hapticButton:removeEventListener("tap", toggleHaptic);
    backButton:removeEventListener("tap", gotoMenu);
    resetScoresButton:removeEventListener("tap", confirmReset)
    mysteryButton:removeEventListener("touch", startTroll);
end

function toggleHaptic()
    PLAYER_HAPTICS = not PLAYER_HAPTICS
    if PLAYER_HAPTICS then
        hapticDisabled.alpha = 0
        hapticIcon:setFillColor(1,1,1)
    else
        hapticDisabled.alpha = 1
        hapticIcon:setFillColor(.5,.5,.5)
    end

end

function gotoMenu()
    composer.gotoScene( "scenes.menu", {effect="slideDown", time=MENU_TRANSITION_DURATION})
end

function startTroll()
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

function confirmReset()
    isResetConfirming = true
    disableSettingsButtons()
    confirmBox =display.newRoundedRect( halfW, halfH, (halfW*2)-100, halfW*1.5, 70)
    confirmBox:setFillColor(38/255, 48/255, 60/255)
    confirmBox.strokeWidth = 7
    confirmBox:setStrokeColor(.5,.5,.5)

    confirmPrompt = display.newText("Are you sure you want to reset all scores?", halfW, halfH-150, halfW*1.5, 0, native.systemFont, 50)

    confirmButton = display.newRoundedRect( halfW, halfH+50, (halfW*2)-300, 130, 60)
    confirmButton:setFillColor(38/255, 68/255, 80/255)
    confirmButton.strokeWidth = 7
    confirmButton:setStrokeColor(.5,.5,.5)

    confirmText = display.newText("Yes", halfW, halfH+50, native.systemFont, 50)

    cancelButton = display.newRoundedRect( halfW, halfH+200, (halfW*2)-300, 130, 60)
    cancelButton:setFillColor(255/255, 68/255, 80/255)
    cancelButton.strokeWidth = 7
    cancelButton:setStrokeColor(.5,.5,.5)

    cancelText = display.newText("Cancel", halfW, halfH+200, native.systemFont, 50)

    confirmButton:addEventListener("tap", resetScores)
    confirmButton:addEventListener("tap", clearResetConfirmation)
    cancelButton:addEventListener("tap", clearResetConfirmation)

end


function cancelTroll()
    if josh then josh:removeSelf() end
    audio.stop();
    audio.dispose( whistle )
end


local function onBack( event )
    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        gotoMenu()
    end
    print(event.keyName)
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return true
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- CREATE SCENE GROUPS

-- create()
function scene:create( event )

    local sceneGroup = self.view

    background = display.newRect(sceneGroup, halfW, halfH, screenW, screenH)
    background:setFillColor(0.15,0.15,0.15)


    hapticButton = display.newRoundedRect(sceneGroup, halfW, halfH-200, 500, 180, 70 )
    hapticButton:setFillColor(38/255, 68/255, 80/255)
    hapticButton.strokeWidth = 7
    hapticButton:setStrokeColor( .5,.5,.5 )

    hapticIcon = display.newImageRect(sceneGroup, "assets/haptic.png", 100, 100 )
    hapticIcon.x = halfW
    hapticIcon.y = halfH -200

    hapticDisabled = display.newPolygon(sceneGroup, halfW, halfH-200, {-50,-40,-40,-50,50,30,40,40} )
    hapticDisabled:setFillColor(.5,.5,.5)
    hapticDisabled.alpha = 0
    if not PLAYER_HAPTICS then
        hapticDisabled.alpha = 1
        hapticIcon:setFillColor(.5,.5,.5)
    end
    


    resetScoresButton = display.newRoundedRect(sceneGroup, halfW, halfH, 500, 180, 70 )
    resetScoresButton:setFillColor(38/255, 68/255, 80/255)
    resetScoresButton.strokeWidth = 7
    resetScoresButton:setStrokeColor( .5,.5,.5 )

    resetText = display.newText( sceneGroup,"RESET SCORES",halfW,halfH,native.systemFont, 40 )

    mysteryButton = display.newRoundedRect(sceneGroup, halfW, halfH+200, 500, 180, 70 )
    mysteryButton:setFillColor(38/255, 68/255, 80/255)
    mysteryButton.strokeWidth = 7
    mysteryButton:setStrokeColor( .5,.5,.5 )

    mysteryButtonText = display.newText(sceneGroup,  "?",halfW,halfH+200,native.systemFont, 100 )

    backButton = display.newRoundedRect(sceneGroup, halfW, halfH+400, 500, 180, 70 )
    backButton:setFillColor(38/255, 68/255, 80/255)
    backButton.strokeWidth = 7
    backButton:setStrokeColor( .5,.5,.5 )

    backIcon = display.newImageRect(sceneGroup,  "assets/back.png", 100, 100 )
    backIcon.x = halfW
    backIcon.y = halfH +400
    -- function that does nothing so then the back key is released it dosent quit the game
    Runtime:addEventListener("key", function() end)
end


function scene:hide(event)
    if event.phase == "will" then
        disableSettingsButtons()
        cancelTroll()     
        Runtime:removeEventListener("key", onBack)
    end
    if event.phase == "did" then
        background:removeSelf()
        hapticIcon:removeSelf()
        if hapticDisabled then hapticDisabled:removeSelf() end
        hapticButton:removeSelf()
        backButton:removeSelf()
        backIcon:removeSelf()
        mysteryButton:removeSelf()
        mysteryButtonText:removeSelf()
        resetScoresButton:removeSelf()
        resetText:removeSelf()
        if isResetConfirming then clearResetConfirmation() end
        composer.removeScene("scenes.settings")
    end
end

function scene:show(event)
    if event.phase == "will" then
        enableSettingsButtons()
    end
    if event.phase == "did" then
        --remove event listener for the back key released
        Runtime:removeEventListener("key", function() end)
        Runtime:addEventListener( "key", onBack )
        whistle = audio.loadSound( "assets/whistle.mp3" )
    end
end

-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "show", scene )



return scene