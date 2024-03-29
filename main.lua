-- import composer
local composer = require( "composer" )
local json = require("json")
local firestore = require("plugin.firestore")
local firebaseAuth = require "plugin.firebaseAuth"
require("utils.constants")

-- set constants here because they get executed here and not in the constants.lua file
SCREENW, SCREENH, HALFW, HALFH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
CONTENTW, CONTENTH = display.contentWidth, display.contentHeight
MARGINX = (display.contentWidth - display.actualContentWidth) / 2
MARGINY = (display.contentHeight - display.actualContentHeight) / 2

-- load firestore
firestore.init()

firebaseAuth.init()

function keyListener( event , params ) 
    local phase = event.phase 
    local keyName = event.keyName 
    -- Let the OS handle the volume buttons 
    if ( keyName == "volumeUp" ) then 
        return false 
    elseif ( keyName == "volumeDown" ) then 
        return false 
    end 
    return false 
end
    
-- preload fonts for faster in-game loading
local text = {} 
local font 
for i = 1, 3 do 
    if i == 1 then 
        font = TEKTUR
    elseif i == 2 then 
        font = HANDJET
    elseif i == 3 then
        font = REM
    end
    text[i] = display.newText( "", 0, 0, font, 24 ) 
    display.remove(text[i]) 
end



-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )

-- start random seed generator
math.randomseed( os.time() )


-- Go to the menu screen
composer.gotoScene( "scenes.menu" )

