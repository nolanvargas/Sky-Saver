require("utils.constants")
-- Function to center the polygon coordinates
local json = require("json")

local SCORES_FILE_PATH = system.pathForFile("playerData/highScores.txt", system.ResourceDirectory)


local function placeHighScore(score,scores)
    if #scores < 10 then table.insert(scores, score)
    else
        table.sort(scores)
        print(scores[1])
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