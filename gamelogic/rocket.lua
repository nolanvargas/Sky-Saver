require("utils.constants")

function updateFlame(sceneGroup, x, y, time)
    local height = math.random(5,7)
    if time < TIME_TO_SPACE then
        height = height * (1-(time/TIME_TO_SPACE))
    else height = 2.5 end
    local flame = display.newImage( sceneGroup, "assets/flame.png",  x, y)
    flame.width = 60
    flame.height = 20 * height
    if flame.height < 50 then flame.height = 50 end
    flame.anchorY = 0
    return flame
end

function spawnSmokeTrail(sceneGroup, x, y)
    local size = math.random(20, 30)
    local smoke = display.newCircle( sceneGroup, x, y, size)
    smoke.height = smoke.height + 20
    smoke:setFillColor(.1,.1,.1,.6)
    return smoke
end

function checkSmoke(smoke, endGameElapsedTime, time)
    for i = #smoke, 1, -1 do
        smoke[i].y = smoke[i].y + (SMOKE_TRAIL_SPEED * (.1*math.random(8,12))) * endGameElapsedTime
        if smoke[i].width < 200 then 
            smoke[i].width = smoke[i].width + (1.5+ (2*endGameElapsedTime))
        end
        if smoke[i].height < 50 then
            smoke[i].height = smoke[i].height + (1+ (1.3*endGameElapsedTime))
        end
        smoke[i].alpha = smoke[i].alpha * (1.3 - (time / TIME_TO_SPACE))
        if time < 3000 then
            smoke[i].width = smoke[i].width + 10 * (1-(time/3000))
            if smoke[i].height < 10 then smoke[i].height = smoke[i].height + 20 * (1-(time/3000)) end
        end
        if smoke[i].y > SCREENH then 
            smoke[i]:removeSelf() 
            table.remove(smoke, i)
        end
    end
end