local limb = entities.derive("base")

function limb:load()

    self.width = 20
    self.height = 20

    self.index = 0

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape =love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.fixture:setSensor(true)
    self.physics.fixture:setUserData("Limb") 

    self.attackDuration = 0.5
    self.attackElapsed = 1
    self.attacking = false
    self.alive = true
    self.correctionForce = 10
    self.target = { x = 0, y = 0 }

    self.health = 2
    self.stunned = false
    self.stunTimer = 0
    self.stunWait = 0.1

    self.randSpeed = love.math.random(1, 3)
end

function limb:update(dt)
    self:tickTimers(dt)
    if not self.attacking then
        self.target.x = self.target.x + math.sin(love.timer.getTime() * self.randSpeed) * 0.05
        self.target.y = self.target.y + math.cos(love.timer.getTime() * self.randSpeed) * 0.05
       self:forceToTarget()  
    end
    self:syncPhysics()
end

function limb:tickTimers(dt)
    if self.stunned then
        self.stunTimer = self.stunTimer - dt
        if self.stunTimer < 0 then
            self.stunTimer = 0
            self.stunned = false
        end
    end
    if self.attacking then
        self.attackElapsed = self.attackElapsed + dt
        if self.attackElapsed > self.attackDuration then
            self.attacking = false
            self.attackElapsed = 0
        end
    end
end

function limb:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.velocity.x, self.velocity.y)
end

function limb:takeDamage()
    if not self.alive or self.attacking then return end

    self.stunned = true
    self.stunTimer = self.stunWait
    self.health = self.health - 1
    self.randSpeed = self.randSpeed * 1.5
    if self.health <= 0 then
        self:setDead()
    end
end

function limb:setDead()
    print("limb died", self.index)
   boss:removeLimb(self.index)
end

function limb:onDeath()
    self.physics.body:destroy()
    self.alive = false
end

function limb:beginContact(a, b, collision)
    if a == self.physics.fixture and b:getUserData() == "Bullet" then
        print("bullet hit limb")
       self:takeDamage()
    end
 end

function limb:forceToTarget()
    local x, y = self.physics.body:getPosition()
    local dx = self.target.x - x
    local dy = self.target.y - y
    -- todo:use math.dist instead
    local dist = math.sqrt(dx * dx + dy * dy)
    local dir = { x = dx/dist, y = dy/dist }
    local force = 100000
    if dist > 10 then
        self.physics.body:applyForce(dir.x * force, dir.y * force)
    else
        self.physics.body:setPosition(self.target.x, self.target.y)
    end  
end

function limb:attack(tx, ty, force)
    if self.attacking == true then return end
    self.attacking = true
    self.attackElapsed = 0

    local target = {x = tx, y = ty}
    local x, y = self.physics.body:getPosition()
    local dx, dy =  target.x - x, target.y - y
    local dir =  math.atan2(dy, dx)
    -- shoot towards target
    self.velocity.x, self.velocity.y = force * math.cos(dir), force * math.sin(dir)
end


function limb:draw()
    
    if self.attacking then
        love.graphics.setColor(1, 0, 1)
    elseif self.stunned then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(1, 0, 0)
    end

    love.graphics.rectangle("line", self.x - self.width * 0.5, self.y - self.height * 0.5, self.width, self.height)
end

return limb