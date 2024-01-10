-- import composer
local composer = require( "composer" )
local scene = composer.newScene()
require("utils.utils")


-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local scoreDisplays = {}
local background
local highScores, noScores, backButton, backIcon


local function gotoMenu()
    composer.gotoScene( "scenes.menu" )
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
    local scores = readScores()


    highScores = display.newText("HIGH SCORES", halfW, 100, native.systemFont, 100)
    local y = 250


    if #scores > 0 then
        for i,s in pairs(scores) do
            local value = display.newText( i ..": ........ " .. scores[(#scores+1)-i] .. "           ", halfW, y, native.systemFont, 50, "left" )
            table.insert(scoreDisplays, value)
            y = y + (screenH/22)
        end
    else
        noScores = display.newText("No scores yet", halfW, 200, native.systemFont, 50)
    end

    backButton = display.newRoundedRect(halfW, halfH+600, 500, 180, 70 )
    backButton:setFillColor(38/255, 68/255, 80/255)
    backButton.strokeWidth = 7
    backButton:setStrokeColor( .5,.5,.5 )

    backIcon = display.newImageRect( "assets/back.png", 100, 100 )
    backIcon.x = halfW
    backIcon.y = halfH +600
    backButton:addEventListener("tap", gotoMenu);

end


function scene:hide(event)
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

-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )


return scene