local player = { x = 50, y = 200, width = 50, height = 50 }
local gravity = 400
local jumpSpeed = -200
local velocity = 0
local pipes = {}
local pipeWidth = 50
local pipeGap = 150
local pipeSpawnTimer = 0
local pipeInterval = 2
local score = 0
local isGameOver = false
local background
local playerImages = {}
local currentFrame = 1
local frameTimer = 0
local frameInterval = 0.1
local desiredWidth = 50
local desiredHeight = 50
local pipeImage

function love.load()
    love.window.setTitle("Flappy Duck")
    love.window.setMode(288, 512)
    background = love.graphics.newImage("background-day.png")
    playerImages[1] = love.graphics.newImage("Duck1.png")
    playerImages[1]:setFilter("nearest", "nearest") 
    playerImages[2] = love.graphics.newImage("Duck2.png")
    playerImages[2]:setFilter("nearest", "nearest")
    playerImages[3] = love.graphics.newImage("Duck3.png")
    playerImages[3]:setFilter("nearest", "nearest")
    pipeImage = love.graphics.newImage("pipe-green.png")
    player.width = desiredWidth
    player.height = desiredHeight
    spawnPipe()
end

function love.update(dt)
    if not isGameOver then
        velocity = velocity + gravity * dt
        player.y = player.y + velocity * dt

        if love.keyboard.isDown('space') then
            velocity = jumpSpeed
            frameTimer = frameTimer + dt
            if frameTimer >= frameInterval then
                currentFrame = currentFrame + 1
                if currentFrame > #playerImages then
                    currentFrame = 1
                end
                frameTimer = 0
            end
        end

        pipeSpawnTimer = pipeSpawnTimer + dt
        if pipeSpawnTimer >= pipeInterval then
            spawnPipe()
            pipeSpawnTimer = 0
        end

        for i = #pipes, 1, -1 do
            pipes[i].x = pipes[i].x - 100 * dt
            if pipes[i].x < -pipeWidth then
                table.remove(pipes, i)
                score = score + 1
            end
            if checkCollision(player, pipes[i]) then
                isGameOver = true
            end
        end

        if player.y > 512 or player.y < 0 then
            isGameOver = true
        end
    elseif love.keyboard.isDown('space') then
        resetGame()
    end
end

function love.draw()
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(playerImages[currentFrame], player.x, player.y, 0, desiredWidth/playerImages[currentFrame]:getWidth(), desiredHeight/playerImages[currentFrame]:getHeight())
    for _, pipe in ipairs(pipes) do
        love.graphics.draw(pipeImage, pipe.x, pipe.y, 0, pipe.width/pipeImage:getWidth(), pipe.height/pipeImage:getHeight())
    end
    love.graphics.print("Score: " .. score, 10, 10)

    if isGameOver then
        love.graphics.print("Game Over! Press Space to Restart", 50, 256)
    end
end

function spawnPipe()
    local topPipeHeight = love.math.random(50, 300)
    local bottomPipeY = topPipeHeight + pipeGap
    local bottomPipeHeight = 512 - bottomPipeY

    table.insert(pipes, { x = 288, y = 0, width = pipeWidth, height = topPipeHeight })
    table.insert(pipes, { x = 288, y = bottomPipeY, width = pipeWidth, height = bottomPipeHeight })
end

function checkCollision(player, pipe)
    return player.x < pipe.x + pipe.width and
           player.x + player.width > pipe.x and
           player.y < pipe.y + pipe.height and
           player.y + player.height > pipe.y
end

function resetGame()
    player.y = 200
    velocity = 0
    pipes = {}
    pipeSpawnTimer = 0
    score = 0
    isGameOver = false
    currentFrame = 1
    frameTimer = 0
    spawnPipe()
end
