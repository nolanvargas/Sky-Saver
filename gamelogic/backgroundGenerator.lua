require("utils.utils")
require("utils.constants")


local function newTree(sceneGroup, x, y)

    local stump = display.newRect(sceneGroup, x, y + CONTENTH, 40, 100)
    stump:setFillColor(129/255,69/255,19/255)
    local stump = display.newPolygon(sceneGroup, x, y + CONTENTH- 60, {0, -100, 86, 50, -86, 50})
    stump:setFillColor(34/255,139/255,34/255)
    local stump = display.newPolygon(sceneGroup, x, y + CONTENTH- 120, {0, -100, 86, 50, -86, 50})
    stump:setFillColor(34/255,139/255,34/255)
    local stump = display.newPolygon(sceneGroup, x, y + CONTENTH- 180, {0, -50, 43, 25, -43, 25})
    stump:setFillColor(34/255,139/255,34/255)

end

local function newPond(sceneGroup, MARGINY)

    local pond1 = display.newCircle( sceneGroup, math.random(100, 700), math.random(50, 200)+CONTENTH, math.random(40, 60) )
    pond1.width = math.random(150, 200)
    pond1:setFillColor(34/255,144/255,255/255)
    local pond2 = display.newCircle( sceneGroup, math.random((pond1.x - 120), (pond1.x-60)), math.random(pond1.y-10, pond1.y+10), math.random(40, 60) )
    pond2.width = math.random(150, 200)
    pond2:setFillColor(34/255,144/255,255/255)
    local pond3 = display.newCircle( sceneGroup, math.random((pond1.x + 60), (pond1.x+120)), math.random(pond2.y-10, pond2.y+10), math.random(40, 60) )
    pond3.width = math.random(150, 200)
    pond3:setFillColor(34/255,144/255,255/255)
    local pond4 = display.newCircle( sceneGroup, math.random((pond3.x + 60), (pond3.x+120)), math.random(pond3.y-10, pond3.y+10), math.random(40, 60) )
    pond4.width = math.random(150, 200)
    pond4:setFillColor(34/255,144/255,255/255)

end

local function newCloud(sceneGroup, offScreen)

    local cloudNodes = math.random(4, 8)

    local startingX = math.random(100, 700)
    local startingY
    if not offScreen then 
        startingY = math.random(MARGINY, 500)
    else
        startingY = math.random(MARGINY-300, MARGINY-100)
    end

    local prevX = startingX
    local prevY = startingY

    for i = 1, cloudNodes do
        local x, y
        repeat
            x = math.random(startingX - 100, startingX + 100) 
            y = math.random(startingY - 100, startingY + 100) 
        until math.abs(x-prevX) > 55 and math.abs(y-prevY) > 55
        local cloud = display.newCircle(sceneGroup, x, math.random(startingY - 50, startingY + 50), math.random(75, 100))
        cloud:setFillColor(210/255,210/255,210/255,0.85)
        prevX = x
        prevY = y
    end

end

function newStar(sceneGroup)
    local star = display.newCircle( sceneGroup, math.random(0, SCREENW), math.random(MARGINY-300, MARGINY), math.random(2,4) )
    return star
end

function generateStars(sceneGroup, count)
    for i=1, count do
        local star = display.newCircle( sceneGroup, math.random(MARGINX - MENU_STAR_BUFFER, SCREENW + MENU_STAR_BUFFER),
         math.random(MARGINY - MENU_STAR_BUFFER, SCREENH+ MENU_STAR_BUFFER), math.random(1,3) )
    end
end




function backgroundStart(nearSceneGroup, farSceneGroup)
    local backgroundElements = {}
    local ground = display.newRect( nearSceneGroup, HALFW, SCREENH+MARGINY, SCREENW, math.abs(MARGINY)*2 )
    ground:setFillColor(76/255,153/255,0)
    local tree1x, tree1y, tree2x, tree2y, tree3x, tree3y 
    tree1x = math.random(0,800)
    tree1y = math.random(-20,200)

    --evenly space out trees but with a pinch of random
    repeat
        tree2x = math.random(0,800)
    until math.abs(tree1x - tree2x) > 200

    repeat
        tree3x = math.random(0,800)
    until math.abs(tree3x - tree2x) > 200 and math.abs(tree1x - tree3x) > 200

    newTree(nearSceneGroup, tree1x, math.random(-20, 200))
    newTree(nearSceneGroup, tree2x, math.random(-20, 200))
    newTree(nearSceneGroup, tree3x, math.random(-20, 200))

    -- FIX TEH DAMN POND
    --newPond(nearSceneGroup, MARGINY)

    newCloud(farSceneGroup, false)
    newCloud(farSceneGroup, false)
    newCloud(farSceneGroup, false)
end

function addCloud(farSceneGroup)
    newCloud(farSceneGroup, true)
end