-- import composer
local composer = require( "composer" )
require("utils.constants")
require("utils.utils")
require("gamelogic.backgroundGenerator")
require("scenes.menuManager")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Display Groups
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------

local playButton, scoresButton
local background, scoresIcon, settingsIcon, playIcon, scoreLabel, scoreText
local rocket, flame
local moveRocket = false
local touchX, touchY = 0,0
local touchInBounds = false
local currentScene


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

local function update()
    updateRocket()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- CREATE SCENE GROUPS

-- create()
function scene:create( event )

    physics.start()
    physics.setTimeScale(1) -- Update physics time scale

    local sceneGroup = self.view

    -- function that does nothing so then the back key is released it dosent quit the game
    Runtime:addEventListener("key", function() return true end)

    newHomeScene(sceneGroup)
end


function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("key", onBack)
        Runtime:removeEventListener("enterFrame", update)
        removeAllRuntimes()
        physics.stop()
    end
    if event.phase == "did" then
        composer.removeScene("scenes.menu")
    end
end

function scene:show(event)
    if event.phase == "did" then
        --remove event listener for the back key released
        Runtime:removeEventListener("key", function() return true end)
        Runtime:addEventListener( "key", onBack )
        Runtime:addEventListener("enterFrame", update)
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