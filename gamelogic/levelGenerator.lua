local json = require("json")
local physics = require "physics"
require("utils.constants")

local data = {}
-- Read the contents of the JSON file
local filePath = system.pathForFile("data/levels.json", system.ResourceDirectory)
local file = io.open(filePath, "r")
if file then
    local contents = file:read("*a") -- Read the entire file as a string
    io.close(file)
    data = json.decode(contents)
--     if data then
--         print(data["2"]["1"])
--     else
--         print("Failed to parse JSON")
--     end
else
    print("File not found")
end

level = {}
local function generateNewLevel(levelNumber)
    local i = 1
    while data[levelNumber][tostring(i)] do
        local obs = data[levelNumber][tostring(i)]
        local shape
        if obs["shape"] == "square" then
            shape = display.newRect( obs["x"], obs["y"], 10, 10 )
            physics.addBody( shape, "dynamic", {density=5, friction=0.5, bounce=0} )
        elseif obs["shape"] == "poly" then
            -- create display
            shape = display.newPolygon( obs["x"], obs["y"], obs["display"] )
            -- add physics body
            local bodyShapes = {}
            for i = 1, #obs["physics"] do
                bodyShapes[i] = { shape = obs["physics"][i] }
            end
            physics.addBody(shape, unpack(bodyShapes))

        end
        shape.class = "obs" -- obstacle type
        shape.activated = false -- not free falling
        shape.gravityScale = 0
        table.insert(level, shape)
        i = i + 1
    end
    return level
end

return generateNewLevel