-- -----------------------------------------------------------------------------------
-- Imports
-- -------

local composer = require( "composer" )
local firestore = require("plugin.firestore")
require("utils.constants")
require("utils.components")
require("utils.utils")
require("gamelogic.levelGenerator")
require("gamelogic.backgroundGenerator")
require("gamelogic.rocket")
require("utils.performanceMonitor")
local physics = require "physics"

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
local inGameTime
local endGame = false   
local gameOver = false
local endGameTimeScale = 1
local score = 0
local scoreText, levelText
local playerSettings
local cloudSpawn, levelSpawn
local levelNumber = 1
local currentLevel
local flame, flameTimer
local smoke = {}
local frameCounter = 0
local starsEnabled = false
local darkenSky = false
local cloudsEnabled = true
local stars = {}
local continueCountDownTime = 10
local continueWithAdButton, continueWithPayButton
local isContinueEligible = true
local continueText, gameOverScore
local countUpTimer, continueCountdown
local sessionData = {did_continue = false, first_death_level = 0, first_fatal_level = 0, first_run_time = 0, second_death_level = 0, second_fatal_level = 0, second_run_time = 0, score = 0 }

local gameData = {start_at = 0, second_start_at = 0}




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
-- local functions
-- -----------------------------------------------------------------------------------

local start, update, resume, reset, continue, disableContinue
local updateBackground, updateSky, flash
local slowPhysics, clearObstacles, obstacleCleanUp, checkObs, updateObs, moveStatics
local followbubbleTarget, movebubbleTarget
local onCollision, handleSmoke, handleStars, getScore, pauseTimers, resumeTimers
local gameOverScreen, postGame, goToHome, spawnRandomLevel

function goToHome()
    reset()
	composer.gotoScene( "scenes.menu")
end

function resume()
    resumeTimers()
    endGameElapsedTime = 0
    lastFrameTime = os.time()
    endGame = false   
    gameOver = false
    endGameTimeScale = 1
    gameData["second_start_at"] = os.time()
end

function clear(sceneGroup)
	for i=1, sceneGroup.numChildren do
		sceneGroup[1]:removeSelf()
	end
end

function reset()
	timer.cancel(flameTimer)
	timer.cancel(cloudSpawn)
	timer.cancel(levelSpawn)
    timer.cancel(countUpTimer)
    if continueCountdown then timer.cancel(continueCountdown) end

	inGameTime = 0
	endGameElapsedTime = 0
	endGame = false
	gameOver = false
	endGameTimeScale = 1
	score = 0
	levelNumber = 1
	frameCounter = 0
	starsEnabled = false
	darkenSky = false
	continueCountDownTime = 10
	isContinueEligible = true
	smoke = {}
	stars = {}

	clearObstacles()

	clear(space)
	clear(sky)
	clear(farBackground)
	clear(nearBackground)
	clear(foreground)
	clear(front)
	clear(gameOverBubble)
end

function start()

	background = display.newRect(sky, HALFW, HALFH, SCREENW, SCREENH)
	background:setFillColor(backgroundRGB[1], backgroundRGB[2], backgroundRGB[3], 1)

	local levelBackDrop = display.newRoundedRect( front, 700, MARGINY+120, 150, 60, 10 )
	levelBackDrop:setFillColor(0,0,0,0.3)
		
	local options1 = 
	{
		parent = front,
		text = "L"..levelNumber,
		x = 700,
		y = MARGINY+118,
		font = REM,
		fontSize = 48,
		width = 125,
		align = "left"
	}
	levelText = display.newText( options1 )
	front:insert(levelText)

		
	local scoreBackDrop = display.newRoundedRect( front, 650, MARGINY+50, 250, 60, 10 )
	scoreBackDrop:setFillColor(0,0,0,0.3)

	local options2 = 
	{
		parent = front,
		text = 00000000,
		x = 660,
		y = MARGINY+45,
		font = REM,
		fontSize = 48,
		width = 230,
		height = 60,
		align = "left"
	}
	scoreText = display.newText( options2 )
	scoreText.strokeWidth = 10
	front:insert(scoreText)




		
	sky:insert(background)

	rocket = display.newImageRect( "assets/rocket.png", ROCKET_WIDTH*.75, ROCKET_WIDTH )
	rocket.x = HALFW
	rocket.y = HALFH+364
	rocket.class = "rocket"
	rocket.hapticCooldown = HAPTIC_COOLDOWN
	foreground:insert(rocket)

	flame = updateFlame(foreground, HALFW, HALFH+ 445, inGameTime)

	-- dont know why its radius *2 but it works
	bubble = display.newImageRect( "assets/bubble-full.png", BUBBLE_RADIUS*2, BUBBLE_RADIUS*2 )
	bubble.class = "bubble"
	-- so symetrical levels requiren bubble movement
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
	physics.addBody( bubble, "dynamic", {density=BUBBLE_WEIGHT, friction=0.75, bounce=0, radius=BUBBLE_RADIUS} )
	bubble.isFixedRotation = true
	bubble.gravityScale = 0

    
	local endGameBackdrop = display.newRoundedRect( endGameBubble, HALFW, HALFH-50, CONTENTW-50, SCREENH-500, 50 )
	endGameBackdrop:setFillColor(51/255, 51/255, 51/255)
	endGameBackdrop:setStrokeColor(.9,.9,.9)
	endGameBackdrop.strokeWidth = 15
    
	
	
	continueWithAdButton = display.newRoundedRect(endGameBubble, HALFW, HALFH+100, 500, 150, 20 )
	continueWithAdButton:setFillColor(.3, .3, .3)
	continueWithAdButton.strokeWidth = 10
	continueWithAdButton.stroke = {0.44, 0.6, 0.8}
	
	local options3 = 
	{
        parent = endGameBubble,
		text = "Free",
		x = HALFW+40,
		y = HALFH+101,
		font = TEKTUR,
		fontSize = 56,
	}
	
	local continueWithPayText = display.newText(options3)
	

    local currencyBackdrop = display.newRoundedRect( endGameBubble, 190, endGameBackdrop.y - (endGameBackdrop.height / 2) + 75, 270, 75, 20 )
    currencyBackdrop:setFillColor(.3, .3, .3)

    newCurrencyBox(endGameBubble, 100, endGameBackdrop.y - (endGameBackdrop.height / 2) + 75 )


	
	local continueAdIcon = display.newImageRect(endGameBubble, "assets/ad.png", 60, 60 )
	continueAdIcon.x = HALFW - 60
	continueAdIcon.y = HALFH+100
	
	continueWithPayButton = display.newRoundedRect(endGameBubble, HALFW, HALFH-100, 500, 150, 20 )
	continueWithPayButton:setFillColor(.3, .3, .3)
	continueWithPayButton.strokeWidth = 10
	continueWithPayButton.stroke = {0.44, 0.6, 0.8}
	
	continueWithPayButton:addEventListener("tap", function(event) 
		if isContinueEligible then
		if getPlayerCurrency() >= CONTINUE_PRICE then
			removeCurrency(50)
			continue() 
		end
		end 
	end)
	
	local options1 = 
	{
		parent = endGameBubble,
		text = "x"..CONTINUE_PRICE,
		x = HALFW+40,
		y = HALFH-101,
		font = TEKTUR,
		fontSize = 56,
	}
	
	local continueWithPayText = display.newText(options1)
	
	local continueCoinIcon = display.newImageRect(endGameBubble, "assets/coin.png", 50, 50 )
	continueCoinIcon.x = HALFW-50
	continueCoinIcon.y = HALFH-100
	
	
	
	local options2 = 
	{
      parent = endGameBubble,
      text = "Continue? "..10,
      x = HALFW,
      y = HALFH-300,
      font = REM,
      fontSize = 48,
    }
    
    continueText = display.newText(options2)
    
    local options4 = 
    {
      parent = endGameBubble,
      text = "No Thanks",
      x = HALFW,
      y = HALFH+250,
      font = REM,
      fontSize = 48,
    }
    
    local noThanksButton = display.newText(options4)
    noThanksButton:setFillColor(.5,.5,.5,.5)
    noThanksButton:addEventListener("tap", disableContinue)
    
    local noThanksUnderline = display.newRect(endGameBubble, HALFW, HALFH+285, 250, 6)
    noThanksUnderline:setFillColor(.5, .5, .5, .5)
    
    local gameOverBackdrop = display.newRoundedRect( gameOverBubble, HALFW, HALFH-50, CONTENTW-50, SCREENH-500, 50 )
    gameOverBackdrop:setFillColor(51/255, 51/255, 51/255)
    gameOverBackdrop:setStrokeColor(.9,.9,.9)
    gameOverBackdrop.strokeWidth = 15

	local restartButton = display.newRoundedRect(gameOverBubble, HALFW, HALFH-100, 500, 150, 20 )
	restartButton:setFillColor(.3, .3, .3)
	restartButton.strokeWidth = 10
	restartButton.stroke = {0.44, 0.6, 0.8}

	local restartIcon = display.newImageRect(gameOverBubble, "assets/replay.png", 70, 70 )
	restartIcon.x = HALFW
	restartIcon.y = HALFH-100

	local homeButton = display.newRoundedRect(gameOverBubble, HALFW, HALFH+100, 500, 150, 20 )
	homeButton:setFillColor(.3, .3, .3)
	homeButton.strokeWidth = 10
	homeButton.stroke = {0.44, 0.6, 0.8}

	local homeIcon = display.newImageRect(gameOverBubble, "assets/home.png", 70, 70 )
	homeIcon.x = HALFW
	homeIcon.y = HALFH+100

	restartButton:addEventListener("tap", function() 
        reset()
        create(nil, false)
        removeGameRuntimes()
        begin()
    end)
	homeButton:addEventListener("tap", goToHome)
    
    local options5 = 
    {
        parent = gameOverBubble,
        text = "0",
        x = HALFW,
        y = HALFH-400,
        font = TEKTUR,
        fontSize = 84,
    }
    gameOverScore = display.newText(options5)
    
    local x, y = unpack(osc(HALFW, HALFH, {"down", "down"})) -- to the burning ring of fire
    endGameBubble.y = y - HALFH
    gameOverBubble.y = y - HALFW
    
    
    
end

function updateBackground()

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

function updateSky()
    if starsEnabled then
        local earthHalf = TIME_TO_SPACE*STAR_SPAWN_AT
        local spaceHalf = TIME_TO_SPACE - TIME_TO_SPACE*STAR_SPAWN_AT 
        background.alpha = 1 - (inGameTime - earthHalf) / spaceHalf
    end
    if darkenSky then 
        local earthHalf = TIME_TO_SPACE*DARKEN_SKY_AT
        local spaceHalf = TIME_TO_SPACE - TIME_TO_SPACE*DARKEN_SKY_AT 
        local scalar =  1 - (inGameTime - earthHalf) / spaceHalf
        background:setFillColor(backgroundRGB[1]*scalar, backgroundRGB[2]*scalar, backgroundRGB[3]*scalar)
    end
end

function flash()
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
function slowPhysics()
    if endGameElapsedTime < END_TRANSITION_DURATION then
        endGameTimeScale = (END_TRANSITION_DURATION - endGameElapsedTime) / END_TRANSITION_DURATION
        physics.setTimeScale(endGameTimeScale) -- Update physics time scale
    else
        physics.setTimeScale(0) 
        if gameOver == false then
            gameOver = true
        end
    end
    endGameElapsedTime = endGameElapsedTime + deltaTime
end

-- Follow bubbleTarget with delay
function followbubbleTarget()
    local dx = bubbleTarget.x - bubble.x
    local dy = bubbleTarget.y - bubble.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    local vx, vy = bubble:getLinearVelocity()
    vx = (dx*DELAY_FACTOR)
    vy = (dy*DELAY_FACTOR)
    bubble:setLinearVelocity(vx, vy)
end

function movebubbleTarget(event)
    if not gameOver then
        if touchPreviousX == nil or touchPreviousY == nil or event.phase == "began" then
            touchPreviousX = event.x
            touchPreviousY = event.y
        end
        if event.phase == "moved" then
            local changeX = (touchPreviousX - event.x) * endGameTimeScale
            local changeY = (touchPreviousY - event.y)  * endGameTimeScale
            bubbleTarget.x = bubbleTarget.x - changeX
            bubbleTarget.y = bubbleTarget.y - changeY
            -- keep bubble target on screen
            if bubbleTarget.x < BUBBLE_RADIUS then bubbleTarget.x = BUBBLE_RADIUS 
            elseif bubbleTarget.x > SCREENW - BUBBLE_RADIUS then bubbleTarget.x = SCREENW - BUBBLE_RADIUS end
            if bubbleTarget.y > SCREENH + MARGINY then bubbleTarget.y = SCREENH + MARGINY end
            touchPreviousX = event.x
            touchPreviousY = event.y
        end
        if (event.phase == "ended" or event.phase == "cancelled") then
            touchPreviousX, touchPreviousY = nil
        end
        return true
    end
end

-- Apply forces on collision with obstacles
function onCollision(event)
    
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
        if not INVINCIBLE then
            if endGame == false then
                if isContinueEligible then
                    sessionData["first_death_level"] = levelNumber
                    sessionData["first_fatal_level"] = currentLevel
                    sessionData["first_run_time"] = math.abs(os.time() - gameData["start_at"])
                else 
                    sessionData["second_death_level"] = levelNumber
                    sessionData["second_fatal_level"] = currentLevel
                    sessionData["second_run_time"] = math.abs(os.time() - gameData["second_start_at"])
                    print(gameData["second_start_at"], os.time())
                end
                flash() 
                pauseTimers()
                endGame = true
            end
        end
    end
end

function clearObstacles()
    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        if obs then
            table.remove(obstacles, i)
            obs:removeSelf()
        end
    end
end


function obstacleCleanUp()
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

function checkObs() 
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

function updateObs() 
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

function moveStatics()
    for i = 1, #obstacles do
        local obs = obstacles[i]
        if obs.bodyType == "static" then
            obs.y = obs.y + OBS_SLEEP_SPEED/60 * endGameTimeScale
        end
    end
end

function handleSmoke()
    local smokeElement = spawnSmokeTrail(nearBackground, HALFW, HALFH+450)
    table.insert(smoke, smokeElement)
    checkSmoke(smoke, endGameTimeScale, inGameTime)
end

function handleStars()
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

function getScore()
    local score = round(inGameTime / (1000 / BASE_POINTS_PER_SECOND), 0)
    return score
end

function countUpScore(event)
    if event.count == 25 then
        transition.to(gameOverScore, {time= 500, y = gameOverScore.y - 75, onComplete=function()
            print('hey')
            local coin = display.newImageRect(gameOverBubble, "assets/coin.png", 50, 50 )
            coin.x = HALFW - 50
            coin.y = gameOverScore.y + 75
        end})
    end
	local scoreText = tonumber(gameOverScore.text)
	if scoreText < score then
		scoreText = scoreText + (score*0.05)
	end
	if scoreText >= score then 
        scoreText = score 
    end
	gameOverScore.text = round(scoreText, 0)
end

function gameOverScreen()
    sessionData["score"] = score
    firestore.setData("game_session", tostring(os.time()), sessionData, function() print("data written") end)
    addCurrency(round(score/10, 0))
    Runtime:removeEventListener("enterFrame", update)
	endGameBubble:removeSelf()
    gameOverBubble.y = gameOverBubble.y + SCREENH*4
    transition.to(gameOverBubble, {time=400, y = 100, onComplete = function()
    	countUpTimer = timer.performWithDelay(50, countUpScore, 25)
    end})


end

function continue()
    physics.setTimeScale(1)
    clearObstacles()
    continueWithAdButton:removeEventListener("tap", function() if isContinueEligible then continue() end end)
    Runtime:addEventListener("enterFrame", update)
    endGameBubble.alpha = 0
    isContinueEligible = false
    sessionData["did_continue"] = true
    resume()
end

function disableContinue()
    continueText:setFillColor(.5, .5, .5)
    isContinueEligible = false
    continueWithAdButton:removeEventListener("tap", function() if isContinueEligible then continue() end end)
    transition.to(endGameBubble, {time=200, y = endGameBubble.y - SCREENH, onComplete=function() 
        endGameBubble:removeSelf()
        gameOverScreen() 
    end})
end

function postGame()
    continueCountdown = timer.performWithDelay(1000, function() 
        continueCountDownTime = continueCountDownTime - 1
		if isContinueEligible then
			if continueCountDownTime == -1 then 
				disableContinue() 
			else
				continueText.text = "Continue? "..continueCountDownTime
			end
		end
    end, 11)

end

function getDeltaTime(time) 
    deltaTime = math.abs(round(time - lastFrameTime, 1))
    if deltaTime > 1000 then deltaTime = 0 end --otherwise deltaTime would be time seince epox
    inGameTime = inGameTime + deltaTime
    lastFrameTime = time
end

function pauseTimers()

    timer.pause(levelSpawn)
    timer.pause(cloudSpawn)
    timer.pause(flameTimer)

end

function resumeTimers()
    timer.resume(levelSpawn)
    timer.resume(cloudSpawn)
    timer.resume(flameTimer)
end

function update(event)
    getDeltaTime(event.time)
    if not gameOver then
        followbubbleTarget() -- Start following the bubbleTarget with delay
        checkObs()
        obstacleCleanUp()
        updateObs()
        moveStatics()
        updateBackground()
        updateSky()
        handleSmoke()
        handleStars()

        if DEBUG then frameCounter = frameCounter + 1 end
        if inGameTime/TIME_TO_SPACE > STAR_SPAWN_AT then
            starsEnabled = true
        end
        if inGameTime/TIME_TO_SPACE > DARKEN_SKY_AT then
            timer.cancel(cloudSpawn)
            darkenSky = true
        end
    end
    if not endGame then
        score = getScore()
        scoreText.text = formatNumber(score, 8, true)
    end
    if endGame then
        slowPhysics()
    end
    if gameOver then
        if isContinueEligible then
            Runtime:removeEventListener("enterFrame", update)
            transition.to(endGameBubble, {time=200, y = 100, onComplete = function()
                postGame()
            end})
        else
            timer.pause(flameTimer)
            gameOverScreen()
            --end game screen
        end
    end
end

function create(sceneGroup, new)
    
    physics.start()
    physics.setTimeScale(1) -- Update physics time scale
    physics.pause()
    playerSettings = getSettings()
    inGameTime = 0
    
    space = display.newGroup()
    sky = display.newGroup()
    farBackground = display.newGroup()  
    nearBackground = display.newGroup()  --this will overlay 'farBackground'  
    foreground = display.newGroup()  --and this will overlay 'nearBackground'
    front = display.newGroup()
    endGameBubble = display.newGroup()
    gameOverBubble = display.newGroup()

    start()
    
    -- Add to scene
	if new then
		sceneGroup:insert(space)
		sceneGroup:insert(sky)
		sceneGroup:insert(farBackground)
		sceneGroup:insert(nearBackground)
		sceneGroup:insert(foreground)
		sceneGroup:insert(front)
		sceneGroup:insert(endGameBubble)
		sceneGroup:insert(gameOverBubble)
	end
end

function spawnLevel(level)
    obstacles = generateNewLevel(tostring(level), foreground)
    levelNumber = levelNumber + 1
    levelText.text = "L"..levelNumber
end

function spawnRandomLevel()
    currentLevel = math.random(1,8);
    spawnLevel(currentLevel)
end

function begin()
    levelNumber = 0
    spawnRandomLevel()
    levelSpawn = timer.performWithDelay( 10000, spawnRandomLevel, -1 )

    cloudSpawn = timer.performWithDelay(1000, function ()
        if math.random(1, CLOUD_SPAWN_RATE) == CLOUD_SPAWN_RATE -1 then
            addCloud(farBackground)
        end
    end, -1)

    flameTimer = timer.performWithDelay(50, function ()
        flame:removeSelf()
        flame = updateFlame(foreground, HALFW, HALFH+ 454, inGameTime)
    end, -1)

    if DEBUG then 
        timer.performWithDelay(1000, function ()
            logPerformance(inGameTime, frameCounter)
            frameCounter = 0
        end, -1)
    end
            

    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("touch", movebubbleTarget)
    Runtime:addEventListener("enterFrame", update)
    physics.start()
    if isContinueEligible then
        gameData["start_at"] = os.time()
    end



end

function removeGameRuntimes()
    Runtime:removeEventListener("collision", onCollision)
    Runtime:removeEventListener("touch", movebubbleTarget)
    Runtime:removeEventListener("enterFrame", update)
end

