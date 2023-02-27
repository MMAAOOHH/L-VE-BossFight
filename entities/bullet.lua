local bullet = entities.derive("base")

function bullet:load()
    self.width = 4
    self.height = 4
    self.velocity.x = 500
    self.direction = 1
    self.alive = true
    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.fixture:setUserData("Bullet") 
end

function bullet:update(dt)
    if not self.alive then return end
        
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.velocity.x * self.direction, self.velocity.y)
end

function bullet:beginContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        entities.destroy(self.id)
    end
 end

function bullet:onDeath()
    self.physics.body:destroy()
    self.alive = false
end

function bullet:draw()
    if not self.alive then return end
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", self.x - self.width * 0.5, self.y - self.height * 0.5, self.width,self.height)
end


return bullet