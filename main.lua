-- import composer
local composer = require( "composer" )
local json = require("json")
require("utils.constants")

SCREENW, SCREENH, HALFW, HALFH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
CONTENTW, CONTENTH = display.contentWidth, display.contentHeight
MARGINX = (display.contentWidth - display.actualContentWidth) / 2
MARGINY = (display.contentHeight - display.actualContentHeight) / 2




-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )

-- start random seed generator
math.randomseed( os.time() )


-- Go to the menu screen
composer.gotoScene( "scenes.menu" )

