-- import composer
local composer = require( "composer" )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- start random seed generator
math.randomseed( os.time() )

-- Go to the menu screen
composer.gotoScene( "scenes.play" )

