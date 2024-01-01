local json = require("json")
local physics = require "physics"
require("utils.constants")

-- density, bounce, friction
local function optionsToValues(options)
    local density
    local bounce
    local friction
    if options[0] == "light" then density = OBS_LIGHT_DENSITY
    elseif options[0] == "heavy" then density = OBS_HEAVY_DENSITY
    else density = OBS_REGULAR_DENSITY end
    if options[1] == "some" then bounce = OBS_SOME_BOUNCE
    elseif options[1] == "more" then bounce = OBS_MORE_BOUNCE
    else bounce = OBS_NONE_BOUNCE end
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
function generateNewLevel(levelNumber)
    local i = 1
    while levelData[levelNumber][tostring(i)] do
        local obs = levelData[levelNumber][tostring(i)]
        local shape = shapeData[tostring(obs["shapeID"])]
        local options = optionsToValues({
            obs["density"] and obs["density"] or nil,
            obs["bounce"] and obs["bounce"] or nil,
            obs["friction"] and obs["friction"] or nil
        })
        
        local output
        if shape["shape"] == "square" then
            output = display.newRect( obs["x"], obs["y"], shape["width"], shape["height"] )
            physics.addBody( output, "dynamic", {density=options[1], friction=options[3], bounce=options[2]} )
        elseif shape["shape"] == "circle" then
            output = display.newCircle( obs["x"], obs["y"], shape["radius"] )
            physics.addBody( output, "dynamic", {density=options[1], friction=options[3], bounce=options[2], radius=shape["radius"]} )
        elseif shape["shape"] == "s_poly" then
            output = display.newPolygon( obs["x"], obs["y"], shape["display"] )
            physics.addBody( output, "dynamic", {density=options[1], friction=options[3], bounce=options[2], shape=shape["physics"]} )
        elseif shape["shape"] == "c_poly" then
            output = display.newPolygon( obs["x"], obs["y"], shape["display"] )
            local bodyShapes = {}
            for i = 1, #shape["physics"] do
                bodyShapes[i] = { shape = shape["physics"][i], density=options[1], friction=options[3], bounce=options[2] }
            end
            physics.addBody(output, unpack(bodyShapes))
        end
    
        assert(output, "shape could not be created from json")

        -- add properties to the object
        output.omega = obs["omega"]
        output.activationY = obs["activationY"]
        output.activationOmega = obs["activationOmega"]
        output.class = "obs" -- obstacle type
        output.isFixedRotation = obs["fixedRotation"]
        output.activationDX = obs["activationDX"]
        output.activationDY = obs["activationDY"]

        if obs["omega"] then 
            print("tourqing")
            output:applyTorque(obs["omega"]*10) end
        output.gravity = obs["gravity"] or true
        if not obs["activated"] then
            output.activated = false -- not free falling
            output.gravityScale = 0
            output:setLinearVelocity( 0, OBS_SLEEP_SPEED )
        else
            output.activated = true
            output.gravityScale = OBS_FALL_SPEED
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
        if object.gravity then object.gravityScale = OBS_FALL_SPEED end
    end
end
