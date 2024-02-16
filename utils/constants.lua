DEBUG = false
INVINCIBLE = false

HAPTIC_COOLDOWN = 100 --frames (60/fps)  -- actually not sure

-- Rocket
ROCKET_WIDTH = 190
ROCKET_HEIGHT = 100 --pixels above bottom of content area
SMOKE_TRAIL_SPEED = 30 --400


-- Bubble
BUBBLE_RADIUS = 35
DELAY_FACTOR = 15  -- lower is slower
BUBBLE_WEIGHT = 2

-- Background
BG_NEAR_SPEED = 20
CLOUD_SPAWN_RATE = 6
STAR_SPAWN_AT = 0.7
DARKEN_SKY_AT = 0.5
STAR_SPAWN_RATE = 20 -- /100
SKY_COLOR = { 0/255, 180/255, 215/255, 1}


-- Obstacles
OBS_FALL_SPEED = 2
OBS_SLEEP_SPEED = 180
OBS_REGULAR_DENSITY = 5
OBS_LIGHT_DENSITY = 2
OBS_HEAVY_DENSITY = 10
OBS_LESS_FRICTION = 0.2
OBS_REGULAR_FRICTION = 0.5
OBS_MORE_FRICTION = 0.8

-- Game
END_TRANSITION_DURATION = 1000 --ms
X_BUFFER = 250
TIME_TO_SPACE = 100000 -- ms
BASE_POINTS_PER_SECOND = 100
CONTINUE_PRICE = 50

-- Menu
TEKTUR = "assets/fonts/tektur/Tektur-Medium.ttf"
HANDJET = "assets/fonts/handJet/Handjet-Regular.ttf"
REM = "assets/fonts/rem/Rem-Regular.ttf"
MENU_TRANSITION_DURATION = 170 --ms
MENU_STAR_BUFFER = 100
MANU_TRANSITION_EFFECT = easing.inOutCubic

-- Screen

local SCREENW, SCREENH, HALFW, HALFH
local CONTENTW, CONTENTH
local MARGINX
local MARGINY