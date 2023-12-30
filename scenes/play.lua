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
local generateNewLevel = require("gamelogic.levelGenerator")


local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------

-- for quick reference
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
        local changeX = touchPreviousX - event.x
        local changeY = touchPreviousY - event.y
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

    local function activateObject(object)
        object.activated = true
        object.gravityScale = OBS_FALL_SPEED
    end

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
        --endGame = true
    end
end


local function obstacleCleanUp()
    for i = 1, #obstacles do
        local obs = obstacles[i]
        if obs then
            if ((obs.x < -100) or (obs.x > screenW + 100) or (obs.y > screenH + 100)) then
                table.remove(obstacles, i)
                obs:removeSelf()
            end
        end
    end
end

local function moveSleepers() 
    for i = 1, #obstacles do
        local obs = obstacles[i]
        if obs.activated == false then
            obs.y = obs.y + OBS_SLEEP_SPEED * endGameTimeScale
        end
    end
end

local function update(event)
    if not gameOver then
        followbubbleTarget() -- Start following the bubbleTarget with delay
        obstacleCleanUp()
        moveSleepers()
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
    
    balloon = display.newCircle( halfW, screenH-200, BALLOON_RADIUS )
    balloon.class = "balloon"
    bubble = display.newCircle(halfW, screenH - 250, BUBBLE_RADIUS)
    bubble.class = "bubble"
    -- invisible bubbleTarget that the bubble follows
    bubbleTarget = display.newCircle(display.contentCenterX, display.contentCenterY+400, 5)
    bubbleTarget:setFillColor(255,0,0,1);
    bubbleTarget.isVisible = DEBUG
    if DEBUG then
        physics.setDrawMode("hybrid")
    end
    
    -- Add physics 
    physics.addBody( balloon, "static", {density=0.1, friction=0.5, bounce=0, radius=BALLOON_RADIUS} )
    physics.addBody( bubble, "dynamic", {density=BUBBLE_WEIGHT, friction=0.5, bounce=0, radius=BUBBLE_RADIUS} )
    bubble.isFixedRotation = true
    bubble.gravityScale = 0
    
    -- add event listeners
    
    
    -- Add to scene
    local c = display.newCircle(halfW, halfH, 10)
    c:setFillColor(1,0,0)
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
        timer.performWithDelay( 1100, function ()
            obstacles = generateNewLevel("3")
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