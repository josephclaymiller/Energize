-----------------------------------------------------------------------------------------
--
-- level_over.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local score = 0
local endGameText = nil
local feedback = nil

local function endGameTimerListener( )
	print("back to menu")
	composer.gotoScene( "menu", "fade", 500 )
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene

	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- display background image
	local background = display.newImageRect( "background.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	-- display text
	endGameText = display.newText( "Your score: "..score, halfW, 200, native.systemFont, 16 )

	-- display feedback
	feedback = display.newText( "Good Energy", halfW, 300, native.systemFont, 16 )

	-- display energy bar 
	-- local energyBarFill = display.newImageRect( "energy_bar_fill_2.png", 152, 480 )
	-- energyBarFill.anchorX = 1
	-- energyBarFill.anchorY = 0
	-- energyBarFill.x, energyBarFill.y = display.contentWidth, 0

	-- local energyBar = display.newImageRect( "energy_bar.png", 152, 480 )
	-- energyBar.anchorX = 1
	-- energyBar.anchorY = 0
	-- energyBar.x, energyBar.y = display.contentWidth, 0

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( endGameText )
	sceneGroup:insert( feedback )
	-- sceneGroup:insert( energyBarFill )
	-- sceneGroup:insert( energyBar )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		if event.params then
			score = event.params.score -- get score passed in params from transition from level
			endGameText.text = "Your score: "..score
			feedback.text = event.params.feedback
		else
			score = 0
			feedback.text = "?"
		end
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		-- start game timer
		local endGameTimerDelay = 2000
		gameTimerid = timer.performWithDelay(endGameTimerDelay, endGameTimerListener)
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
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene