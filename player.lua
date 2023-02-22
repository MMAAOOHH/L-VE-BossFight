Player = {}

function Player:load()
    self.x = 100
    self.y = 0
    self.width = 16
    self.height = 16
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 300
    self.acceleration = 5000
    self.friction = 2000
    self.gravity = 2000
    self.jumpAmount = -600

    self.grounded = false

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape =love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Player:update(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
end

function Player:applyGravity(dt)
    if not self.grounded then
    self.yVel = self.yVel + self.gravity * dt
    end
end

function Player:move(dt)
    if love.keyboard.isDown("d", "right") then
        if self.xVel < self.maxSpeed then
           if self.xVel + self.acceleration * dt < self.maxSpeed then
              self.xVel = self.xVel + self.acceleration * dt
           else
              self.xVel = self.maxSpeed
           end
        end
     elseif love.keyboard.isDown("a", "left") then
        if self.xVel > -self.maxSpeed then
           if self.xVel - self.acceleration * dt > -self.maxSpeed then
              self.xVel = self.xVel - self.acceleration * dt
           else
              self.xVel = -self.maxSpeed
           end
        end
    else
        self:applyFriction(dt)
    end
end

function Player:applyFriction(dt)
    if self.xVel > 0 then
       if self.xVel - self.friction * dt > 0 then
          self.xVel = self.xVel - self.friction * dt
       else
          self.xVel = 0
       end
    elseif self.xVel < 0 then
       if self.xVel + self.friction * dt < 0 then
          self.xVel = self.xVel + self.friction * dt
       else
          self.xVel = 0
       end
    end
 end


function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:beginContact(a,b, collision)
    if self.grounded then return end

    local normalX, normalY = collision:getNormal()
    if a == self.physics.fixture then
        if normalY > 0 then
            self:onLand()
        end
    elseif b == self.physics.fixture then
        if normalY < 0 then
            self:onLand()
        end
    end
end

function Player:onLand(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
end

function Player:jump(key)
    if (key == "w" or key == "up") and self.grounded then
        self.yVel = self.jumpAmount
        self.grounded = false
    end
end

function Player:endContact(a,b, collision)

    if a == self.physics.fixture or b == self.physics.fixture then
        if currentGroundCollision == collision then
            self.grounded = true
        end
    end  
end


function Player:draw()
    love.graphics.rectangle("fill", self.x - self.width * 0.5, self.y - self.height * 0.5, self.width, self.height)
end
