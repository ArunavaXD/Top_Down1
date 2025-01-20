-- Alt + L to run Project --
function love.load()

    love.window.setMode(800, 600, {resizable = true}) -- resizable window

    sounds = {}
    sounds.blip = love.audio.newSource("sounds/blip.mp3", "static") -- sound effets static
    sounds.music = love.audio.newSource("sounds/music.mp3", "stream") -- music streamed
    sounds.music:setLooping(true) -- looping the audio

    sounds.music:play()

    wf = require "libraries/windfield"
    world = wf.newWorld(0, 0)

    camera = require "libraries/camera"
    cam = camera()

    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest") -- removes Blur

    sti = require "libraries/sti"
    gameMap = sti("maps/testMap.lua")

    player = {}
    player.collider = world:newBSGRectangleCollider(400, 250, 50, 100, 10)
    player.collider:setFixedRotation(true)
    player.x = 400 -- left  is 0 and right is max
    player.y = 200 -- top is 0 and bottom is max
    player.speed = 300
    player.spriteSheet = love.graphics.newImage("sprites/player-sheet.png")
    player.grid = anim8.newGrid( 12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {}
    player.animations.s = anim8.newAnimation( player.grid("1-4", 1), 0.2 )
    player.animations.w = anim8.newAnimation( player.grid("1-4", 4), 0.2 )
    player.animations.d = anim8.newAnimation( player.grid("1-4", 3), 0.2 )
    player.animations.a = anim8.newAnimation( player.grid("1-4", 2), 0.2 )

    player.anim = player.animations.a

        chests = {}
    if gameMap.layers["Chests"] then
        for i, obj in pairs(gameMap.layers["Chests"].objects) do
            local chest = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height )
            chest:setType("static")
            table.insert(chests, chest)
        end
    end

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height )
            wall:setType("static")
            table.insert(walls, wall)
        end
    end

end

function love.update(dt) -- any sort of activity that requires active update(every frame)
    local isMoving = false

    local vx = 0 -- velocity in X direction
    local vy = 0 -- velocity in Y direction
    
    if love.keyboard.isDown("d") then
       vx = player.speed
        player.anim = player.animations.d
        isMoving = true
    end

    if love.keyboard.isDown("a") then
        vx =  player.speed *  -1
        player.anim = player.animations.a
        isMoving = true
    end

    if love.keyboard.isDown("w") then
        vy = player.speed *  -1
        player.anim = player.animations.w
        isMoving = true
    end

    if love.keyboard.isDown("s") then
        vy =  player.speed
        player.anim = player.animations.s
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
            player.anim:gotoFrame(2)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    player.anim:update(dt)

    cam:lookAt(player.x, player.y)

    local windowWidth = love.graphics:getWidth()
    local windowHeight = love.graphics:getHeight()

    if cam.x < windowWidth/2 then 
        cam.x = windowWidth/2
    end

    if cam.y < windowHeight/2 then 
        cam.y = windowHeight/2
    end

    local mapWidth = gameMap.width * gameMap.tilewidth -- only when using a tiled map
    local mapHeight = gameMap.height * gameMap.tileheight

    if cam.x > (mapWidth - windowWidth/2) then
        cam.x = (mapWidth - windowWidth/2)
    end

    if cam.y > (mapHeight - windowHeight/2) then
        cam.y = (mapHeight - windowHeight/2)
    end

end

function love.draw() -- Any sort of graphics on the screen

    --[[local windowWidth, windowHeight = love.graphics.getDimensions()
    local backgroundWidth = background:getWidth()
    local backgroundHeight = background:getHeight()
    local scaleX = windowWidth/backgroundWidth
    local scaleY = windowHeight/backgroundHeight
    love.graphics.draw(background, 0, 0, 0,  scaleX, scaleY) -- (x, y, r, sX, sY, ox, oy, kx, ky)--]]

    

    cam:attach()
        gameMap:drawLayer(gameMap.layers["Base"]) -- importing all layers
        gameMap:drawLayer(gameMap.layers["Pathways"])
        gameMap:drawLayer(gameMap.layers["Trees"])
        gameMap:drawLayer(gameMap.layers["Cliffs"])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)
        gameMap:drawLayer(gameMap.layers["Tree Top"])
        gameMap:drawLayer(gameMap.layers["Cliff Bottom"])
        gameMap:drawLayer(gameMap.layers["Lootboxes"])
        --world:draw()
    cam:detach()
end

function love.keypressed(key)

    if key == "space" then
        sounds.blip:play()
    end

    if key == "m" then
        if isMusicPaused then
            sounds.music:play()  -- Resume music
            isMusicPaused = false
        else
            sounds.music:pause()  -- Pause music
            isMusicPaused = true
        end
    end

    if key == "f11" then
        local isFullscreen = love.window.getFullscreen()

        if isFullscreen then
            love.window.setMode(800, 600, {resizable = true}) -- resizable window
        else
            love.window.setMode(0, 0, {fullscreen = true}) -- fullscreen whenn f11 is pressed
        end

    end

    if key == "escape" then -- pressing escape key quits the game
        love.event.quit()


    end
end