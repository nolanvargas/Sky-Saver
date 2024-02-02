-- -----------------------------------------------------------------------------------
-- Imports
-- -----------------------------------------------------------------------------------


-- local firebaseAnalytics = require "plugin.firebaseAnalytics"
-- firebaseAnalytics.init()
-- firebaseAnalytics.logEvent("test",{test = "hello world"})

-- local firestore = require("plugin.firestore")

-- local firebaseDatabase = require "plugin.firebaseDatabase"
-- firebaseDatabase.init()

-- firebaseDatabase:setOnline(true)

--firebaseDatabase.set("testData",{firstEntry = "Hello World"}, function() end)
    
--     (ev)
--     if(ev.isError) then
--         native.showAlert( "Could not Upload Data", ev.error , {"Ok"} )
--     else
--         native.showAlert( "Data send", "" , {"Ok"} )
--     end
-- end)

-- import composer
local composer = require( "composer" )
-- include Corona's "physics" library
local physics = require "physics"
-- import constants
require("utils.constants")
require("utils.utils")
require("gamelogic.levelGenerator")
require("gamelogic.backgroundGenerator")
require("gamelogic.rocket")


local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------------

-- game elements
local bubble, bubbleTarget
local obstacles = {}
local backgroundElements
local background
local backgroundRGB = { 0/255, 180/255, 215/255, 1}
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
local score = 0
local scoreText
local playerSettings
local cloudSpawn, levelSpawn
local levelNumber = 0
local flame, flameTimer
local smoke = {}
local frameNumber = 0
local starsEnabled = false
local darkenSky = false
local cloudsEnabled = true
local stars = {}

local function reset()
    backgroundTop = { 0/255, 140/255, 160/255, 1}
    backgroundBot = { 0/255, 185/255, 210/255, 1}
    paint = {
        type = "gradient",
        color1 = backgroundBot,
        color2 = backgroundTop,
        direction = "up"
    }
    -- logic
    endGameElapsedTime = 0
    lastFrameTime = os.time()
    endGame = false   
    gameOver = false
    endGameTimeScale = 1
end


-- -----------------------------------------------------------------------------------
-- Display groups
-- -----------------------------------------------------------------------------------

local space
local sky
local farBackground
local nearBackground
local foreground
local front


-- -----------------------------------------------------------------------------------
-- local functions
-- -----------------------------------------------------------------------------------

local function updateBackground()

    for i = 1, nearBackground.numChildren do
        nearBackground[i].y = nearBackground[i].y + OBS_SLEEP_SPEED/60 * endGameTimeScale
    end
    for i = 1, farBackground.numChildren do
        farBackground[i].y = farBackground[i].y + ((OBS_SLEEP_SPEED/60)/4) * endGameTimeScale
    end
    for i = 1, space.numChildren do
        space[i].y = space[i].y + ((OBS_SLEEP_SPEED/60)/4) * endGameTimeScale
    end
end

local function updateSky()
    --print(frameNumber)
    if starsEnabled then
        local earthHalf = TIME_TO_SPACE*STAR_SPAWN_AT
        local spaceHalf = TIME_TO_SPACE - TIME_TO_SPACE*STAR_SPAWN_AT 
        background.alpha = 1 - (frameNumber - earthHalf) / spaceHalf
    end
    if darkenSky then 
        local earthHalf = TIME_TO_SPACE*DARKEN_SKY_AT
        local spaceHalf = TIME_TO_SPACE - TIME_TO_SPACE*DARKEN_SKY_AT 
        local scalar =  1 - (frameNumber - earthHalf) / spaceHalf
        background:setFillColor(backgroundRGB[1]*scalar, backgroundRGB[2]*scalar, backgroundRGB[3]*scalar)
    end
end

local function flash()
    -- Create a white rectangle covering the screen
    local screenCover = display.newRect(HALFW, HALFH, SCREENW, SCREENH)
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
    if touchPreviousX == nil or touchPreviousY == nil or event.phase == "began" then
        touchPreviousX = event.x
        touchPreviousY = event.y
    end
    if event.phase == "moved" then
        local changeX = (touchPreviousX - event.x) 
        local changeY = (touchPreviousY - event.y) 
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

    if PLAYER_HAPTICS then
        if co[1].class == "bubble" or co[2].class == "bubble" then
            if co[1].class == "bubble" then
                if co[2].hapticCooldown == 0 then
                    if playerSettings["PLAYER_HAPTICS"] then 
                        system.vibrate("impact", "light") 
                        co[2].hapticCooldown = HAPTIC_COOLDOWN
                    end
                end
            elseif co[2].class == "bubble" then
                if co[1].hapticCooldown == 0 then
                    if playerSettings["PLAYER_HAPTICS"] then 
                        system.vibrate("impact", "light") 
                        co[2].hapticCooldown = HAPTIC_COOLDOWN
                    end
                end
            end
        end
    end

    -- activate obstacles
    for _, object in ipairs(co) do
        if (object.class == "obs") and object.activated == false then
            activateObject(object)
        end
    end

    -- check for rocket obj collision
    if ((co[1].class == "rocket") and (co[2].class == "obs") or
    (co[2].class == "rocket") and (co[1].class == "obs")) then
        if endGame == false then
                flash() 
            end
        timer.cancelAll()
        endGame = true
    end
end


local function obstacleCleanUp()
    for i = 1, #obstacles do
        local obs = obstacles[i]
        if obs then
            local b = math.max(obs.width, obs.height)
            if ((obs.x < ((-MARGINX-b)-X_BUFFER)) or (obs.x > SCREENW + b + X_BUFFER) or (obs.y > SCREENH + b)) then
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
                if obs.activationDX or obs.activationDY then
                    obs:applyLinearImpulse(obs.activationDX or 0, obs.activationDY or 0, obs.x, obs.y)
                end
            end
        end
    end
end

local function updateObs() 
    for i = 1, #obstacles do
        local obs = obstacles[i]
        if obs.hapticCooldown > 0 then obs.hapticCooldown = obs.hapticCooldown - 1
        elseif obs.hapticCooldown < 0 then obs.hapticCooldown = 0
        end
    end
    if rocket.hapticCooldown > 0 then rocket.hapticCooldown = rocket.hapticCooldown - 1
        elseif rocket.hapticCooldown < 0 then rocket.hapticCooldown = 0
    end
end

local function moveStatics()
    for i = 1, #obstacles do
        local obs = obstacles[i]
        if obs.bodyType == "static" then
            obs.y = obs.y + OBS_SLEEP_SPEED/60 * endGameTimeScale
        end
    end
end

local function handleSmoke()
    local smokeElement = spawnSmokeTrail(nearBackground, HALFW, HALFH+450)
    table.insert(smoke, smokeElement)
    checkSmoke(smoke, endGameTimeScale, frameNumber)
end

local function handleStars()
    if math.random(1,100) < STAR_SPAWN_RATE then
        local star = newStar(space)
        table.insert(stars, star)
    end
    for i = #stars, 1, -1 do
        if stars[i].y > SCREENH then 
            stars[i]:removeSelf() 
            table.remove(stars, i)
        end
    end
end

local function update(event)
    if not gameOver then
        followbubbleTarget() -- Start following the bubbleTarget with delay
        obstacleCleanUp()
        checkObs()
        moveStatics()
        updateObs()
        updateBackground()
        handleSmoke()
        handleStars()
        updateSky()
        frameNumber = frameNumber + 1

        if frameNumber/TIME_TO_SPACE > STAR_SPAWN_AT then
            starsEnabled = true
        end
        if frameNumber/TIME_TO_SPACE > DARKEN_SKY_AT then
            timer.cancel(cloudSpawn)
            darkenSky = true
        end
    end
    if not endGame then
        score = score + 0.05
        scoreText.text = math.floor(score)
        
    end
    if endGame then
        slowPhysics()
    end
    if gameOver then
        writeScore(math.floor(score))
        composer.gotoScene( "scenes.menu", {params = {score = score}} )
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------


-- create()
function scene:create( event )    
    local sceneGroup = self.view
    physics.start()
    physics.setTimeScale(1) -- Update physics time scale
    physics.pause()
    playerSettings = getSettings()

    space = display.newGroup()
    sky = display.newGroup()
    farBackground = display.newGroup()  
    nearBackground = display.newGroup()  --this will overlay 'farBackground'  
    foreground = display.newGroup()  --and this will overlay 'nearBackground'
    front = display.newGroup()

    scoreText = display.newText( math.floor(score), 50, MARGINY +300, native.systemFont, 60 )
    front:insert(scoreText)

    background = display.newRect(HALFW, HALFH, SCREENW, SCREENH)
    background:setFillColor(backgroundRGB[1], backgroundRGB[2], backgroundRGB[3], 1)
    sky:insert(background)

    rocket = display.newImageRect( "assets/rocket.png", ROCKET_WIDTH*.75, ROCKET_WIDTH )
    rocket.x = HALFW
    rocket.y = HALFH+364
    rocket.class = "rocket"
    rocket.hapticCooldown = HAPTIC_COOLDOWN
    foreground:insert(rocket)

    flame = updateFlame(foreground, HALFW, HALFH+ 445, frameNumber)

    -- dont know why its radius *2 but it works
    bubble = display.newImageRect( "assets/bubble-full.png", BUBBLE_RADIUS*2, BUBBLE_RADIUS*2 )
    bubble.class = "bubble"
    -- so symetrical levels require movement
    bubble.x = HALFW + 80
    bubble.y = HALFH  +300
    bubble.alpha = 0.85
    foreground:insert(bubble)

    -- invisible bubbleTarget that the bubble follows
    bubbleTarget = display.newCircle(HALFW +80, HALFH+300, 5)
    bubbleTarget:setFillColor(255,0,0,1);
    bubbleTarget.isVisible = DEBUG
    front:insert(bubbleTarget)

    --background Elements
    backgroundStart(nearBackground, farBackground, MARGINY)

    if DEBUG then
        physics.setDrawMode("hybrid")
        local c = display.newCircle(HALFW, HALFH, 5)
        c:setFillColor(1,0,0)

        -- actualContent
        local o = display.newRect(HALFW,HALFH,SCREENW,SCREENH)
        o:setFillColor(0,0,0,0)
        o:setStrokeColor(1,0,0)
        o.strokeWidth = 10

        --content
        local o = display.newRect(HALFW,HALFH,CONTENTW, CONTENTH)
        o:setFillColor(0,0,0,0)
        o:setStrokeColor(0,1,0)
        o.strokeWidth = 10

        --viewableContent
        local o = display.newRect(HALFW,HALFH,display.safeActualContentWidth, display.safeActualContentHeight)
        o:setFillColor(0,0,0,0)
        o:setStrokeColor(0,0,1)
        o.strokeWidth = 10
    end
    
    -- Add physics 
    local rocketShape = {{ -2,  -94,  24,  -66,  42,  -28},
    { -2,  -94,  42,  -28,  47,   12},
    { 47,   12,  67,   44,  68,   85},
    { -2,  -94,  47,   12,  68,   85},
    { -2,  -94,  68,   85,  37,   69},
    { -2,  -94,  37,   69,  22,  100},
    { -2,  -94,  22,  100,   1,  134},
    { -2,  -94,   1,  134, -21,  103},
    { -2,  -94, -21,  103, -36,   71},
    { -2,  -94, -36,   71, -66,   88},
    {-66,   88, -68,   48, -47,    4},
    { -2,  -94, -66,   88, -47,    4},
    { -2,  -94, -47,    4, -43,  -24},
    {-43,  -24, -27,  -62,  -2,  -94}}
    local rocketPhysics = {}
    for i = 1, #rocketShape do
        table.insert(rocketPhysics, { shape = rocketShape[i], friction=0.2, bounce=0.2})
    end
    physics.addBody(rocket, "static", unpack(rocketPhysics) )
    physics.addBody( bubble, "dynamic", {density=BUBBLE_WEIGHT, friction=0.2, bounce=0, radius=BUBBLE_RADIUS} )
    bubble.isFixedRotation = true
    bubble.gravityScale = 0
    
    -- Add to scene
    sceneGroup:insert(space)
    sceneGroup:insert(sky)
    sceneGroup:insert(farBackground)
    sceneGroup:insert(nearBackground)
    sceneGroup:insert(foreground)
    sceneGroup:insert(front)
end


function scene:show( event )
	
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
    elseif phase == "did" then
        local random = math.random(1,7);
        obstacles = generateNewLevel("2", sceneGroup)
        levleSpawn = timer.performWithDelay( 10000, function ()
            local random = math.random(1,7);
            print(random)
            obstacles = generateNewLevel(tostring(random), sceneGroup)
        end, -1 )

        cloudSpawn = timer.performWithDelay(1000, function ()
            if math.random(1, CLOUD_SPAWN_RATE) == CLOUD_SPAWN_RATE -1 then
                addCloud(farBackground)
            end
        end, -1)

        flameTimer = timer.performWithDelay(50, function ()
            flame:removeSelf()
            flame = updateFlame(foreground, HALFW, HALFH+ 454, frameNumber)
        end, -1)
        

        Runtime:addEventListener("enterFrame", update)
        Runtime:addEventListener("enterFrame", function (event)
            deltaTime = event.time - lastFrameTime
            lastFrameTime = event.time
        end)
        physics.start()
    end
end

function scene:hide(event)
    if event.phase == "will" then
        --physics.stop()
    end
    if event.phase == "did" then
        for i = #obstacles,1,-1 do
            table.remove(obstacles,i)
        end

        Runtime:removeEventListener("collision", onCollision)
        Runtime:removeEventListener("touch", movebubbleTarget)
        Runtime:removeEventListener("enterFrame", update)
        Runtime:removeEventListener("enterFrame")
        composer.removeScene("scenes.play")
        --reset()
    end
end


-- -----------------------------------------------------------------------------------
-- Listeners Setup
-- -----------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
Runtime:addEventListener("collision", onCollision)
Runtime:addEventListener("touch", movebubbleTarget)



return scene