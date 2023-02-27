local STI = require("sti")
require("entities")

function love.load()
    Map = STI("map/first.lua", {"box2d"})
    love.graphics.setBackgroundColor(0,0.1,0.1)
    World = love.physics.newWorld(0,0)
    World:setCallbacks(beginContact, endContact)
    Map:box2d_init(World)
    Map.layers.solid.visible = false
    
    entities.init()
    local p = entities.create("player",60,200)
    local boss = entities.create("boss", 320  ,200)
    boss:createLimbs()
    --local limb = entities.create("limb", 400  ,200)
end

function love.update(dt)
    World:update(dt)
    entities:update(dt)
    --entities:clean()
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    Map:draw(0,0,2,2)
    love.graphics.push()
    love.graphics.scale(2,2)
    entities:draw()
    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function beginContact(a,b, collision)
    entities:beginContact(a,b, collision)
end

function endContact(a,b, collision)
    entities:endContact(a,b, collision)
end

function love.quit()
end