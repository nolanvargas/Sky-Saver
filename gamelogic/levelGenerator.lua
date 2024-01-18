local json = require("json")
local physics = require "physics"
require("utils.constants")

-- density, friction
local function optionsToValues(options)
    local density
    local friction
    if options[0] == "light" then density = OBS_LIGHT_DENSITY
    elseif options[0] == "heavy" then density = OBS_HEAVY_DENSITY
    else density = OBS_REGULAR_DENSITY end
    if options[2] == "less" then friction = OBS_LESS_FRICTION
    elseif options[2] == "more" then friction = OBS_MORE_FRICTION
    else friction = OBS_REGULAR_FRICTION end

    return {density, bounce, friction}
end

local levelData = {}
-- Read the contents of the JSON file
local filePath = system.pathForFile("data/levels.json", system.ResourceDirectory)
local file = io.open(filePath, "r")
if file then
    local contents = file:read("*a") -- Read the entire file as a string
    io.close(file)
    levelData = json.decode(contents)
    if not levelData then
        print("Failed to parse levels JSON")
    end
else
    print("Levels file not found")
end

local shapeData = {}
-- Read the contents of the JSON file
filePath = system.pathForFile("data/shapes.json", system.ResourceDirectory)
file = io.open(filePath, "r")
if file then
    local contents = file:read("*a") -- Read the entire file as a string
    io.close(file)
    shapeData = json.decode(contents)
    if not shapeData then
        print("Failed to parse shapes JSON")
    end
else
    print("Shapes file not found")
end

level = {}
function generateNewLevel(levelNumber, marginY)
    local i = 1
    while levelData[levelNumber][tostring(i)] do
        local obs = levelData[levelNumber][tostring(i)]
        local shape = shapeData[tostring(obs["shapeID"])]
        local options = optionsToValues({
            obs["density"] and obs["density"] or nil,
            obs["friction"] and obs["friction"] or nil,
        })
        
        local output
        local type

        if obs["static"] then type = "static" else type = "dynamic" end
        if shape["shape"] == "square" then
            output = display.newRect( obs["x"], obs["y"], shape["width"], shape["height"] )
            physics.addBody( output, type, {density=options[1], friction=options[3], bounce=obs["bounce"]} )
        elseif shape["shape"] == "circle" then
            output = display.newCircle( obs["x"], obs["y"], shape["radius"] )
            physics.addBody( output, type, {density=options[1], friction=options[3], bounce=obs["bounce"], radius=shape["radius"]} )
        elseif shape["shape"] == "s_poly" then
            output = display.newPolygon( obs["x"], obs["y"], shape["display"] )
            physics.addBody( output, type, {density=options[1], friction=options[3], bounce=obs["bounce"], shape=shape["physics"]} )
        elseif shape["shape"] == "c_poly" then
            output = display.newPolygon( obs["x"], obs["y"], shape["display"] )
            local bodyShapes = {}
            for i = 1, #shape["physics"] do
                bodyShapes[i] = { shape = shape["physics"][i], density=options[1], friction=options[3], bounce=obs["bounce"]}
            end
            physics.addBody(output, type, unpack(bodyShapes) )
        end
    
        assert(output, "shape could not be created from json")

        output.y = output.y + marginY - 200
        if obs["rotation"] then output.rotation = obs["rotation"] end

        -- add properties to the object
        output.hapticCooldown = HAPTIC_COOLDOWN
        output.omega = obs["omega"]
        output.activationY = obs["activationY"]
        output.activationOmega = obs["activationOmega"]
        output.class = "obs" -- obstacle type
        output.isFixedRotation = obs["fixedRotation"]
        output.activationDX = obs["activationDX"]
        output.activationDY = obs["activationDY"]
        if obs["static"] then output:setFillColor(0,0,0) end

        if obs["omega"] then 
            output:applyTorque(obs["omega"]*10) end
        if obs["gravity"] == false then output.gravity = false else output.gravity = true end
        if not obs["activated"] then
            output.activated = false -- not free falling
            output.gravityScale = 0 -- also not free falling
            output:setLinearVelocity( 0, OBS_SLEEP_SPEED ) -- kick it downwards
        else
            output.activated = true -- is activated
            output.gravityScale = OBS_FALL_SPEED -- free falling
        end
        table.insert(level, output)
        i = i + 1
    end
    return level
end



function activateObject(object)
    if not object.activated then
        object.angularVelocity = object.activationOmega or object.angularVelocity
        object.activated = true
        if object.gravity then
            object.gravityScale = OBS_FALL_SPEED end
    end
end
