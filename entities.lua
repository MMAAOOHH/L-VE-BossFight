entities = {}
entities.objects = {}
entities.toRemove = {}
local register = {}
local id = 0

function entities.init()
    register["player"] = love.filesystem.load("entities/" .. "player.lua")
    register["bullet"] = love.filesystem.load("entities/" .. "bullet.lua")
    register["boss"] = love.filesystem.load("entities/" .. "boss.lua")
    register["limb"] = love.filesystem.load("entities/" .. "limb.lua")
end

function entities.derive(name)
    return love.filesystem.load("entities/" .. name .. ".lua")()
end

function entities.create(name, x, y)
   
    x = x or 0
    y = y or 0

    if register[name] then
        id = id + 1
        local e = register[name]()
        e.x = x
        e.y = y
        e.id = id
        e:load()
        entities.objects[#entities.objects + 1] = e
        return entities.objects[#entities.objects]
    else
        print("Name not registered")
        return false
    end
end

function entities.destroy(id)
    for i, e in pairs(entities.objects) do
        if e.id == id then
            if e.onDeath then
                e:onDeath()
            end
            --table.insert(entities.toRemove,entities.objects[id])
            entities.objects[i] = nil
        end
    end
end

function entities.clean()
    for i, e in pairs(entities.toRemove) do
            print("deleting", e.id)
            entities.toRemove[i] = nil
            --table.remove(entities.toRemove, e)
    end
end

function entities:update(dt)
    for i, e in pairs(entities.objects) do
        if e.update then
            e:update(dt)
        end
    end
end

function entities:draw()
    for i, e in pairs(entities.objects) do
        if e.draw then
            e:draw()
        end
    end
end

function entities:beginContact(a,b, collision)
    for i, e in pairs(entities.objects) do
        if e.beginContact then
            e:beginContact(a,b, collision)
        end
    end
end

function entities:endContact(a,b, collision)
    for i, e in pairs(entities.objects) do
        if e.endContact then
            e:endContact(a,b, collision)
        end
    end
end