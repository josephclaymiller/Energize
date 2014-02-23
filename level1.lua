-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local gameTime = 0.05 -- Total game time in minutes
local gameSeconds = gameTime * 60
local secondsLeft = gameSeconds
-- tick once a second
local gameTimerTicks = secondsLeft 
local gameTimerDelay = 1000
local gameTimerid = nil
-- clock
local startTime = nil
local totalSeconds = 0 -- seconds passed since game started
-- energy
local energy = nil
local targetBPM = 120
local targetEnergy = targetBPM * gameTime
local totalEnergy = 0
local energyBall = nil
local overEnergized = false
-- score
local score = 0
local feedback = nil
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-- set score
local function setScore(totalEnergy, targetEnergy)
	local energyDifference = math.abs(totalEnergy - targetEnergy)
	if (energyDifference > targetEnergy) then
		energyDifference = energyDifference % targetEnergy
	end
	local percentEnergyOfTarget = math.floor(((targetEnergy - energyDifference)/targetEnergy) * 100)
	print("score: "..percentEnergyOfTarget)
	return percentEnergyOfTarget
end 

-- end game
local function endGame()
	timer.cancel( gameTimerid ) -- cancel game timer
	print( "Game over" )
	if (totalEnergy > targetEnergy) then
		feedback = "Too much energy"
		overEnergized = true
	elseif (totalEnergy < targetEnergy) then
		feedback = "Too little energy"
	else
		feedback = "Great Energy!"
		overEnergized = false
	end
	score = setScore(totalEnergy, targetEnergy)
	local options =
	{
	    effect = "fade",
	    time = 500,
	    params = {
	        score = score,
	        feedback = feedback
	    }
	}
	composer.gotoScene( "level_over", options )
end

-- game timer
local function gameTimerListener(event)
	if not startTime then
		startTime = event.time -- set start time first time
	end
	-- stringify seconds left
	local paddedSecondsLeft = tostring ( 1000 + secondsLeft )
	local stringTimeLeft = string.sub(paddedSecondsLeft, 3, 4)

	-- calculate total seconds of game so far
	totalSeconds = math.floor((event.time - startTime) / 1000)
	-- stringify seconds passed
	local paddedSecondsPassed = tostring ( 1000 + totalSeconds)
	local stringTimePassed = string.sub(paddedSecondsPassed, 3, 4)

	-- display the time passed/left
	print("Time Passed: 0:"..stringTimePassed)
	print("Time Left: 0:"..stringTimeLeft)

	-- decrement seconds left counter
	secondsLeft = secondsLeft - 1

	-- check if game over
	if (secondsLeft <= 0) then
		endGame()
	end
end

-- touch listener
local function onTouch( event )
	if event.phase == "began" then
		print("touch")
	    totalEnergy = totalEnergy + 1
	    local currentTarget = math.floor(targetEnergy * (totalSeconds/gameSeconds))
	    setScore(totalEnergy, targetEnergy)
	    local ballY = screenH/2 + (100 - score)
	    if overEnergized then
	    	ballY = screenH/2 - (100 - score)
	    end
	    print( "ball y" .. ballY )
	    energyBall.y = ballY
	    return true
	end
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- display background image
	local background = display.newImageRect( "background.jpg", screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	-- display energy bar 
	local energyBarFill = display.newImageRect( "energy_bar_fill_2.png", 152, 480 )
	energyBarFill.anchorX = 1
	energyBarFill.anchorY = 0
	energyBarFill.x, energyBarFill.y = screenW, 0

	local energyBar = display.newImageRect( "energy_bar.png", 152, 480 )
	energyBar.anchorX = 1
	energyBar.anchorY = 0
	energyBar.x, energyBar.y = screenW, 0

	-- display energy ball
	energyBall = display.newImageRect( "ball.png", 100, 100 )
	energyBall.anchorX = 1
	energyBall.anchorY = 0.5
	energyBall.x, energyBall.y = screenW - 25, screenH

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( energyBarFill )
	sceneGroup:insert( energyBar )
	sceneGroup:insert( energyBall )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		-- Set up game
		totalEnergy = 0
		energyBall.y = screenH - energyBall.contentHeight / 2
		overEnergized = false
		-- set up and start game timer
		startTime = nil
		secondsLeft = gameTime * 60
		gameTimerid = timer.performWithDelay(gameTimerDelay, gameTimerListener, gameTimerTicks)
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	timer.cancel( gameTimerid ) -- cancel game timer
	Runtime:removeEventListener("touch", onTouch )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

Runtime:addEventListener("touch", onTouch )

-----------------------------------------------------------------------------------------

return scene