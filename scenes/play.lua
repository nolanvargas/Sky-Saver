-- -----------------------------------------------------------------------------------
-- Imports
-- -----------------------------------------------------------------------------------

-- import composer
local composer = require( "composer" )
-- include Corona's "physics" library
local physics = require "physics"
-- import constants
require("utils.constants")
require("utils.utils")
require("gamelogic.levelGenerator")


local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------

-- for quick reference
local contentW, contentH = display.contentWidth, display.contentHeight
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
-- game elements
local bubble, bubbleTarget
local obstacles = {}
local background
local backgroundTop = { 0/255, 140/255, 160/255, 1}
local backgroundBot = { 0/255, 185/255, 210/255, 1}
local paint = {
    type = "gradient",
    color1 = backgroundBot,
    color2 = backgroundTop,
    direction = "up"
}
local backgroundTimer
-- logic
local touchPreviousX, touchPreviousY
local endGameElapsedTime = 0
local deltaTime
local lastFrameTime = os.time()
local endGame = false   
local gameOver = false
local endGameTimeScale = 1
local prevFrame


-- -----------------------------------------------------------------------------------
-- Display groups
-- -----------------------------------------------------------------------------------

local farBackground = display.newGroup()  
local nearBackground = display.newGroup()  --this will overlay 'farBackground'  
local foreground = display.newGroup()  --and this will overlay 'nearBackground'
local front = display.newGroup()


-- -----------------------------------------------------------------------------------
-- local functions
-- -----------------------------------------------------------------------------------

local function updateBackground()
    local topG = backgroundTop[2]
    local topB = backgroundTop[3]
    local botG = backgroundBot[2]
    local botB = backgroundBot[3]

    topG = math.floor((topG*BG_CHANGE_SPEED)*100)/100
    topB = math.floor((topB*BG_CHANGE_SPEED)*100)/100
    botG = math.floor((botG*BG_CHANGE_SPEED)*100)/100
    botB = math.floor((botB*BG_CHANGE_SPEED)*100)/100

    backgroundTop[2] = topG
    backgroundTop[3] = topB
    backgroundBot[2] = botG
    backgroundBot[3] = botB

    background:setFillColor(paint)

    if topG == 0 and topB == 0 and botG == 0 and botB == 0 then
        timer.cancel(backgroundTimer)
    end

    
end

local function flash()
    -- Create a white rectangle covering the screen
    local screenCover = display.newRect(halfW, halfH, screenW, screenH)
    screenCover:setFillColor(1) -- Set the color to white
    screenCover.alpha = 1 -- Initially visible
    front:insert(screenCover)

    -- Function to handle the screen flash effect
    local function flashScreen()
        transition.to(screenCover, {
            time = 500, -- Duration of the transition (adjust as needed)
            alpha = 0, -- Fully invisible (white)
            onComplete = function()
                screenCover:removeSelf() -- Remove the rectangle after the flash
            end
        })
    end 
    flashScreen()   
end

-- Slow physics down
local function slowPhysics()
    if endGameElapsedTime < END_TRANSITION_DURATION then
        endGameTimeScale = (END_TRANSITION_DURATION - endGameElapsedTime) / END_TRANSITION_DURATION
        physics.setTimeScale(endGameTimeScale) -- Update physics time scale
    else 
        if gameOver == false then
            gameOver = true
            physics.stop() -- All done
        end
    end
    endGameElapsedTime = endGameElapsedTime + deltaTime
end

-- Follow bubbleTarget with delay
local function followbubbleTarget()
    local dx = bubbleTarget.x - bubble.x
    local dy = bubbleTarget.y - bubble.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    local vx, vy = bubble:getLinearVelocity()
    vx = (dx*DELAY_FACTOR)
    vy = (dy*DELAY_FACTOR)
    bubble:setLinearVelocity(vx, vy)
end

local function movebubbleTarget(event)
    if event.phase == "began" then
        touchPreviousX = event.x
        touchPreviousY = event.y
    end
    if event.phase == "moved" then
        local changeX = (touchPreviousX - event.x) * BUBBLE_INPUT_SCALAR
        local changeY = (touchPreviousY - event.y) * BUBBLE_INPUT_SCALAR
        bubbleTarget.x = bubbleTarget.x - changeX
        bubbleTarget.y = bubbleTarget.y - changeY
        touchPreviousX = event.x
        touchPreviousY = event.y
    end
    if (event.phase == "ended" or event.phase == "cancelled") then
        touchPreviousX, touchPreviousY = nil
    end
    return true
end

-- Apply forces on collision with obstacles
local function onCollision(event)

    -- collided objects
    local co = { event.object1, event.object2 }

    -- activate obstacles
    for _, object in ipairs(co) do
        if (object.class == "obs") and object.activated == false then
            activateObject(object)
        end
    end

    -- check for balloon obj collision
    if ((co[1].class == "balloon") and (co[2].class == "obs") or
    (co[2].class == "balloon") and (co[1].class == "obs")) then
        if endGame == false then flash() end
        endGame = true
    end
end


local function obstacleCleanUp()
    for i = 1, #obstacles do
        local obs = obstacles[i]
        if obs then
            local b = math.max(obs.width, obs.height)
            if ((obs.x < -b) or (obs.x > screenW + b) or (obs.y > screenH + b)) then
                table.remove(obstacles, i)
                obs:removeSelf()
            end
        end
    end
end

local function checkObs() 
    for i = 1, #obstacles do
        local obs = obstacles[i]
        if obs.activationY then 
            if obs.y >= obs.activationY and not obs.activated then
                activateObject(obs)
                if obs.activationDX and obs.activationDY then
                    obs:applyLinearImpulse(obs.activationDX, obs.activationDY, obs.x, obs.y)
                end
            end
        end
    end
end

local function update(event)
    if not gameOver then
        followbubbleTarget() -- Start following the bubbleTarget with delay
        obstacleCleanUp()
        checkObs()
    end
    if endGame then
        slowPhysics()
        timer.cancelAll()
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------


-- create()
function scene:create( event )    
    local sceneGroup = self.view
    physics.start()
    physics.pause()


    background = display.newRect(halfW, halfH, screenW, screenH)
    background:setFillColor(paint)
    nearBackground:insert(background)
    
    balloon = display.newCircle( halfW, (contentH-BALLOON_HEIGHT), BALLOON_RADIUS )
    balloon.class = "balloon"
    balloon:setFillColor(0,0.6,0.9)
    bubble = display.newCircle(halfW, screenH - 450, BUBBLE_RADIUS)
    bubble.class = "bubble"
    -- invisible bubbleTarget that the bubble follows
    bubbleTarget = display.newCircle(display.contentCenterX, display.contentCenterY+400, 5)
    bubbleTarget:setFillColor(255,0,0,1);
    bubbleTarget.isVisible = DEBUG
    if DEBUG then
        physics.setDrawMode("hybrid")
        local c = display.newCircle(halfW, halfH, 5)
        c:setFillColor(1,0,0)

        -- actualContent
        local o = display.newRect(halfW,halfH,display.actualContentWidth, display.actualContentHeight)
        o:setFillColor(0,0,0,0)
        o:setStrokeColor(1,0,0)
        o.strokeWidth = 10

        --content
        local o = display.newRect(halfW,halfH,display.contentWidth, display.contentHeight)
        o:setFillColor(0,0,0,0)
        o:setStrokeColor(0,1,0)
        o.strokeWidth = 10

        --viewableContent
        local o = display.newRect(halfW,halfH,display.safeActualContentWidth, display.safeActualContentHeight)
        o:setFillColor(0,0,0,0)
        o:setStrokeColor(0,0,1)
        o.strokeWidth = 10
    end
    
    -- Add physics 
    physics.addBody( balloon, "static", {density=0.1, friction=0.5, bounce=0, radius=BALLOON_RADIUS} )
    physics.addBody( bubble, "dynamic", {density=BUBBLE_WEIGHT, friction=0.5, bounce=0, radius=BUBBLE_RADIUS} )
    bubble.isFixedRotation = true
    bubble.gravityScale = 0
    
    -- add event listeners
    
    
    -- Add to scene
    foreground:insert(balloon)
    foreground:insert(bubble) 
    foreground:insert(bubbleTarget)
end


function scene:show( event )
	
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then
        timer.performWithDelay( 1000, function ()
            obstacles = generateNewLevel("1")
        end, -1 )
        backgroundTimer = timer.performWithDelay(BG_CHANGE_UPDATE_RATE, updateBackground, -1)
        Runtime:addEventListener("enterFrame", update)
        Runtime:addEventListener("enterFrame", function (event)
            deltaTime = event.time - lastFrameTime
            lastFrameTime = event.time
        end)
        physics.start()
    end
end


-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
Runtime:addEventListener("collision", onCollision)
Runtime:addEventListener("touch", movebubbleTarget)



return scene