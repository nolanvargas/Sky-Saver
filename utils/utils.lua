require("utils.constants")
-- Function to center the polygon coordinates
local function centerPolygon(vertices)
    -- Find minimum and maximum x and y values
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge

    -- Loop through the vertices to find min and max values
    for i = 1, #vertices, 2 do
        local x, y = vertices[i], vertices[i + 1]
        minX = math.min(minX, x)
        minY = math.min(minY, y)
        maxX = math.max(maxX, x)
        maxY = math.max(maxY, y)
    end

    -- Calculate the center of the polygon
    local centerX = (minX + maxX) / 2
    local centerY = (minY + maxY) / 2

    -- Calculate the translation values to move to the center
    local translateX = -centerX
    local translateY = -centerY

    -- Create a new set of vertices shifted to the center
    local centeredVertices = {}
    for i = 1, #vertices, 2 do
        local x, y = vertices[i] + translateX, vertices[i + 1] + translateY
        table.insert(centeredVertices, x)
        table.insert(centeredVertices, y)
    end

    return centeredVertices
end

local function splitIntoSubTables(originalTable)
    local subTables = {}
    local currentSubTable = {}
    local lastTwoFirstTable = {}

    -- Extract the last two elements from the first sub-table
    for i = 1, 2 do
        table.insert(lastTwoFirstTable, originalTable[i])
    end

    for i = 1, #originalTable do
        table.insert(currentSubTable, originalTable[i])

        if #currentSubTable == 16 or i == #originalTable then
            table.insert(subTables, currentSubTable)

            -- For the last sub-table, append the first two elements from the first sub-table
            if i == #originalTable then
                for j = 1, 2 do
                    table.insert(currentSubTable, lastTwoFirstTable[j])
                end
            end
            local last1, last2 = currentSubTable[15], currentSubTable[16]
            currentSubTable = {last1, last2}
        end
    end

    return subTables
end


function getPhysicsVertices(vertices)
    --forward declaration
    local output = {}
    --center the vertices because the display does that automatically and the physics dosent
    local centeredVertices = centerPolygon(vertices)
    --physics polygons accept a maximum of 8 vertices (16 numbers in the table) so we return tables of 16-max tables
    local output = splitIntoSubTables(centeredVertices)
    return output
end



