boss = entities.derive("base")
boss.limbs = {}

function boss:load()

    self.velocity = { x = 0, y = 0 }
    self.target = { x = 0, y = 0 }
    self.eyePos = { x = 0, y = 0 }

    self.attackTime = 1
    self.attackWait = 5
    self.attackDuration = 0.5
    self.attackElapsed = 1
    self.attacking = false
    self.chase = false
    self.stunned = false
    self.limbCount = 0 
    self.stunTimer = 0
    self.stunWait = 0.1
    self.health = 10

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape =love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.fixture:setSensor(true)
    self.physics.fixture:setUserData("Limb") 
end

function boss:createLimbs()
    local radius = 60
    local numParts = 6
    -- create limbs in circle around origin
    for i = 1, numParts do
        local angle = (i-1) * (2*math.pi / numParts) 
        local x = self.x + radius * math.cos(angle) 
        local y = self.y + radius * math.sin(angle)
        local limb = entities.create("limb", x, y)
        limb.target.x = x
        limb.target.y = y
        limb.index = i
        self.limbs[limb.index] = limb
        self.limbCount = self.limbCount + 1
    end
end

function boss:removeLimb(index)
    for i, limb in pairs(self.limbs) do
        if limb.index == index then
            entities.destroy(self.limbs[i].id)
            table.remove(self.limbs, i)
            self.limbCount = self.limbCount - 1
            print(self.limbCount)
            if self.limbCount <= 0 then
                self:setChase()
            else
                self:enrage()
            end
        end
    end
end

function boss:takeDamage()
    if not self.chase then return end

    self.stunned = true
    self.stunTimer = self.stunWait
    self.health = self.health - 1
    if self.health <= 0 then
        self:setDead()
    end
end

function boss:setDead()
    entities.destroy(self.id)
    player.win = true
end

function boss:onDeath()
    self.physics.body:destroy()
end

function boss:update(dt)
    self:tickTimers(dt)
    self:updateEye()
    if self.attackTime <= 0 then
        self:attack()
    end
    if self.attacking then
        if self.attackElapsed > self.attackDuration then
            self:attackEnd()
        end
    end
    if self.chase then
        self.target.x = player.x
        self.target.y = player.y
        self:forceToTarget()
    else
        self.velocity.y = math.sin(love.timer.getTime()* 2) * 5
    end
    self:syncPhysics()
end

function boss:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.velocity.x, self.velocity.y)
end

function boss:forceToTarget()
    local x, y = self.physics.body:getPosition()
    local dx = self.target.x - x
    local dy = self.target.y - y
    local dist = math.sqrt(dx * dx + dy * dy)
    local dir = { x = dx/dist, y = dy/dist }
    local force = 3000
    self.physics.body:applyForce(dir.x * force, dir.y * force)
end

function boss:tickTimers(dt)
    self.attackTime = self.attackTime - dt
    if self.attacking then
        self.attackElapsed = self.attackElapsed + dt
    end

    if self.stunned then
        self.stunTimer = self.stunTimer - dt
        if self.stunTimer < 0 then
            self.stunTimer = 0
            self.stunned = false
        end
    end
end

function boss:attack()
    if self.attacking == true then return end

    self.attacking = true
    self.attackElapsed = 0

    if self.limbCount <= 0 then return end
    local randLimb = self.limbs[math.random(#self.limbs)]
    if randLimb then
        self.attackingLimb = randLimb
        self.attackingLimb:attack(player.x, player.y, 500)
    end
end

function boss:attackEnd()
    self.attacking = false
    self.attackTime = self.attackWait
end

function boss:enrage()
    self.attackWait = self.attackWait - 0.4
end

function boss:setChase()
    self.chase = true
end

function boss:beginContact(a, b, collision)
    if not self.chase then return end
    if a == self.physics.fixture and b:getUserData() == "Bullet" then
       self:takeDamage()
    end
 end

function boss:updateEye()
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local dir = { x = dx/dist, y = dy/dist }
    local offset = 5
    self.eyePos.x = self.x + dir.x * offset
    self.eyePos.y = self.y + dir.y * offset
end

function boss:draw(dt)
    if self.stunned then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.circle("fill", self.x, self.y, 10, 20)

    love.graphics.setColor(love.graphics.getBackgroundColor())
    love.graphics.circle("fill", self.eyePos.x, self.eyePos.y, 4, 20)
end

return boss