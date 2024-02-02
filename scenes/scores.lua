-- import composer
local composer = require( "composer" )
local scene = composer.newScene()
require("utils.utils")
require("utils.constants");


-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------
local scoreDisplays = {}
local background
local highScores, noScores, backButton, backIcon


local function gotoMenu()
    composer.gotoScene( "scenes.menu", {effect="slideUp", time=MENU_TRANSITION_DURATION} )
end


local function onBack( event )
    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        gotoMenu()
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

    background = display.newRect(sceneGroup, HALFW, HALFH, SCREENW, SCREENH)
    background:setFillColor(0.15,0.15,0.15)
    local scores = readScores()


    highScores = display.newText(sceneGroup, "HIGH SCORES", HALFW, 100, native.systemFont, 100)
    local y = 250


    if #scores > 0 then
        for i,s in pairs(scores) do
            local value = display.newText(sceneGroup, i ..": ........ " .. scores[(#scores+1)-i] .. "           ", HALFW, y, native.systemFont, 50, "left" )
            table.insert(scoreDisplays, value)
            y = y + (SCREENH/22)
        end
    else
        noScores = display.newText(sceneGroup, "No scores yet", HALFW, 200, native.systemFont, 50)
    end

    backButton = display.newRoundedRect(sceneGroup, HALFW, HALFH+600, 500, 180, 70 )
    backButton:setFillColor(38/255, 68/255, 80/255)
    backButton.strokeWidth = 7
    backButton:setStrokeColor( .5,.5,.5 )

    backIcon = display.newImageRect(sceneGroup,  "assets/back.png", 100, 100 )
    backIcon.x = HALFW
    backIcon.y = HALFH +600
    
    backButton:addEventListener("tap", gotoMenu);

    -- function that does nothing so then the back key is released it dosent quit the game
    Runtime:addEventListener("key", function() end)
end


function scene:hide(event)
    if event.phase == "will" then 
        Runtime:removeEventListener("key", onBack)
    end
    if event.phase == "did" then
        background:removeSelf()
        for i = 1, #scoreDisplays do
            scoreDisplays[i]:removeSelf()
        end
        for i = #scoreDisplays,1,-1 do
            table.remove(scoreDisplays,i)
        end
        backButton:removeSelf()
        backIcon:removeSelf()
        highScores:removeSelf()
        if noScores then noScores:removeSelf() end
        composer.removeScene("scenes.scores")
    end
end

function scene:show(event) 
    if event.phase == "did" then
        --remove event listener for the back key released
        Runtime:removeEventListener("key", function() end)
        Runtime:addEventListener( "key", onBack )
    end
end

-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "show", scene )


return scene