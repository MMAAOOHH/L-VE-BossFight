player = entities.derive("base")

function player:load(x,y)
    
    self.width = 16
    self.height = 16

    self.win = false

    self.physics = {}
    self.physics.body = love.physics.newBody(World, player.x, player.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape =love.physics.newRectangleShape(player.width, player.height)
    self.physics.fixture = love.physics.newFixture(player.physics.body, player.physics.shape)
    self.physics.fixture:setUserData("Player")

    self.velocity.x = 0
    self.velocity.y = 0
    self.direction = 1
    self.maxSpeed = 300
    self.acceleration = 5000
    self.friction = 2000
    self.gravity = 2000

    self.grounded = false
    self.jumpForce = -400
    self.jumpTime = 0.18
    self.jumping = false
    self.jumpCount = 0
    self.airTimer = 0
    self.coyoteTimer = 0
    self.coyoteWait = 0.15

    self.shootTimer = 0
    self.shootWait = 0.2

    self.health = 10
    self.stunned = false
    self.stunTimer = 0
    self.stunWait = 1

    self.squashTime = 1
    self.squashDuration = 0.15
end

function player:update(dt)
    self:handleInput()
    self:tickTimer(dt)
    self:move(dt)
    self:jump(dt)
    self:shoot(dt)
    self:applyGravity(dt)
    self:syncPhysics()
end

function player:handleInput()
    self.up = love.keyboard.isDown("w", "up")
    self.left = love.keyboard.isDown("a", "left")
    self.right = love.keyboard.isDown("d", "right")
    self.shootKey = love.keyboard.isDown("space", "lctrl", "rctrl")
end

function player:tickTimer(dt)
    -- jumping
    if (not self.grounded) and (not self.up) then
        self.coyoteTimer = self.coyoteTimer - dt
        if self.coyoteTimer < 0 then
            self.coyoteTimer = 0
        end
    end
    -- shooting
    self.shootTimer = self.shootTimer - dt
    if self.shootTimer < 0 then
        self.shootTimer = 0
    end

    -- stun
    if self.stunned then
        self.stunTimer = self.stunTimer - dt
        if self.stunTimer < 0 then
            self.stunTimer = 0
            self.stunned = false
        end
    end

    -- squash
    self.squashTime = self.squashTime + dt
    local t = self.squashTime / self.squashDuration
    if  self.squashTime < self.squashDuration then
        self.width = self.width + math.sin(t * math.pi * 2)
    else
        self.width = 16
    end
end

function player:move(dt)
    if self.right and not self.stunned then
        self.velocity.x = math.min(self.velocity.x + self.acceleration * dt, self.maxSpeed)
        self.direction = 1
     elseif self.left and not self.stunned then
        self.velocity.x = math.max(self.velocity.x - self.acceleration * dt, -self.maxSpeed)
        self.direction = -1
    else
        player:applyFriction(dt)
    end
end

function player:applyFriction(dt)
    if self.velocity.x > 0 then
        self.velocity.x = math.max(self.velocity.x - self.friction * dt, 0)
    elseif self.velocity.x < 0 then
        self.velocity.x = math.min(self.velocity.x + self.friction * dt, 0)
    end
 end


 function player:jump(dt)
    if self.stunned then return end

    if self.up then
        if  self.grounded or  self.coyoteTimer > 0 then
            self.grounded = false
            self.jumping = true
            self.airTimer = 0
            self.coyoteTimer = 0
        elseif self.jumping then
            self.airTimer = self.airTimer + dt
                if self.airTimer < self.jumpTime then
                self.velocity.y = self.jumpForce
            end
        end
    end
end

function player:onLand(collision)
    self.currentGroundCollision = collision
    self.grounded = true
    self.jumping = false
    self.coyoteTimer = self.coyoteWait
    self.velocity.y = 0
    self.airTimer = 0
    self.squashTime = 0
end

 function player:applyGravity(dt)
    if not self.grounded then
        self.velocity.y = self.velocity.y + self.gravity * dt
    end
end

function player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.velocity.x, self.velocity.y)
end

function player:beginContact(a, b, collision)
    --taking damage
    if a == self.physics.fixture and b:getUserData() == "Limb" then
        self:takeDamage()
    end
    --groundchecks and stuff
    if self.grounded then return end
    local normalX, normalY = collision:getNormal()
    if a == self.physics.fixture then
       if normalY > 0 then
        self:onLand(collision)
       elseif normalY < 0 then
        self.velocity.y = 0
       end
    elseif b == self.physics.fixture then
       if normalY < 0 then
        self:onLand(collision)
       elseif normalY > 0 then
        print("hit head")
        self.velocity.y = 0
        self.jumping = false
       end
    end

 end

function player:endContact(a , b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end  
end

function player:shoot(dt)
    if self.shootKey and self.shootTimer <= 0 then
        local bullet = entities.create("bullet", self.x + self.width * self.direction, self.y)
        bullet.direction = self.direction
        self.shootTimer = self.shootWait
    end
end

function player:takeDamage()
    if self.stunned then return end

    self.stunned = true
    self.stunTimer = self.stunWait
    self.health = self.health - 1
    self.jumping = false
    self.grounded = true
    if self.health <= 0 then
            print("player died")
            love.event.quit('restart')
    end
end

local wintext = {
    x = 40,
    y = 40,
    width = 400,
    height = 200,
    text = 'Well done! :)',
    active = false,
    colors = {
        background = { 255, 255, 255, 255 },
        text = { 40, 40, 40, 255 }
    }
}

function player:draw()
    -- body
    if self.stunned then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(1, 1, 0)
    end

    love.graphics.rectangle("fill", self.x - self.width * 0.5, self.y - self.height * 0.5, self.width, self.height)
    -- eye
    love.graphics.setColor(love.graphics.getBackgroundColor())
    love.graphics.rectangle("fill", self.x - 2 + 3 * self.direction , self.y - 4 , 4, 4)

    -- healthbar
    if self.stunned then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(0, 1, 0)
    end
    love.graphics.rectangle("fill", 10, 10 , 16 * self.health, 10)

    if self.win then
        love.graphics.print( "Well done!", 300, 180)
    end
end

return player