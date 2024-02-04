require("utils.constants")
-- Function to center the polygon coordinates
local json = require("json")


local SCORES_FILE_PATH = system.pathForFile("playerData/highScores.txt", system.ResourceDirectory)

--[[
    Off Screen Coordinates

    Returns the coordinates applied to the direction off the screen

    Example:
    ```lua
    local x, y = unpack(osc(400, 400, {"up", "left"}))
    ```

    Notes:
    - Returns x, y in table format {x, y}
]]
---@param x number
---@param y number
---@param direction table
function osc(x, y, direction)
    for i, v in pairs(direction) do
        if v == "up" then y = y - SCREENH
        elseif v == "right" then x = x + SCREENW
        elseif v == "down" then y = y + SCREENH
        elseif v == "left" then x = x - SCREENW
        else assert(false, "Invalid direction at index "..i) end
    end
    return {x, y}
end

function ternary ( cond , T , F )
    if cond == 0 or cond == false then 
        return F 
    else 
        return T 
    end
end

function formatNumber(value, leadingZeros, commasEabled)
    local output = string.format("%0"..leadingZeros.."d", value)
    
    return output

end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end


local function placeHighScore(score,scores)
    if #scores < 10 then table.insert(scores, score)
    else
        table.sort(scores)
        if score >=  tonumber(scores[1]) then
            table.remove(scores, 1)
            table.insert(scores, score)
        end   
    end
    table.sort(scores) 
    return scores
end


function writeScore(score)
    local scores= readScores()
    output = placeHighScore(score, scores)
    file = io.open(SCORES_FILE_PATH, "w+")
    if file then
        for i, s in pairs(output) do
            file:write(s .. "\n")
        end
        io.close(file)
    else
        print("Levels file not found")
    end
end

function readScores()
    local scores = {}
    local file = io.open(SCORES_FILE_PATH, "r")
    if file then
        for line in file:lines() do
            table.insert(scores, tonumber(line))
        end
        io.close(file)
    else
        print("Levels file not found")
    end
    return scores
end

function resetScores()
    local file = io.open(SCORES_FILE_PATH, "w+")
    io.close(file)
end


function getSettings()
    local playerSettings = {}
    -- Read the contents of the JSON file
    local filePath = system.pathForFile("utils/playerSettings.json", system.ResourceDirectory)
    local file = io.open(filePath, "r")
    if file then
        local contents = file:read("*a") -- Read the entire file as a string
        io.close(file)
        playerSettings = json.decode(contents)
        if not playerSettings then
            print("Failed to parse levels JSON")
        end
    else
        print("Levels file not found")
    end

    return playerSettings

end

function setSetting(playerSettings)
    local filePath = system.pathForFile("utils/playerSettings.json", system.ResourceDirectory)    
    -- Open the file handle
    local file, errorString = io.open( filePath, "w" )
    
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Write encoded JSON data to file
        file:write( json.encode( playerSettings ) )
        -- Close the file handle
        io.close( file )
        return true
    end
end

function getPlayerCurrency()
    local playerData = {}
    -- Read the contents of the JSON file
    local filePath = system.pathForFile("data/player.json", system.ResourceDirectory)
    local file = io.open(filePath, "r")
    if file then
        local contents = file:read("*a") -- Read the entire file as a string
        io.close(file)
        playerData = json.decode(contents)
        if not playerData then
            print("Failed to parse levels JSON")
        end
    else
        print("Levels file not found")
    end

    return playerData["currency"]
end

