local composer = require( "composer" )
local scene = composer.newScene()
require("gamelogic.gameManager")

-- -----------------------------------------------------------------------------------
-- Display groups
-- -----------------------------------------------------------------------------------

local space
local sky
local farBackground
local nearBackground
local foreground
local front
local endGameBubble
local gameOverBubble


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------


-- create()
function scene:create( event )    
    local sceneGroup = self.view
    create(sceneGroup, true)
end


function scene:show( event )
    if event.phase == "did" then begin() end
end

function scene:hide(event)
    if event.phase == "will" then
        removeGameRuntimes()
    end
    if event.phase == "did" then
        composer.removeScene( "scenes.play" )
    end
end


-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )



return scene