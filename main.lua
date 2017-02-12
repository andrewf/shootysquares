function love.load()
    love.window.setTitle("Shooty Squares")
    state = newGame()
end

function newGame()
    vx, vy = 4, 3
    x, y = 60, 60
    w, h = 30, 30
    sw, sh = love.graphics.getDimensions()
    local inputstate = {x= sw/2, y= sh-50, w= 30, h= 30}
    local bullets = {}
    local enemies = {}
    local esize = 30
    local counter = 0
    local gameover = false
    local starttime = love.timer.getTime()
    local endtime = starttime
    function endgame()
        gameover = true;
    end
    function inputstate.update(self, dt)
        local v = 4
        if not gameover then
            if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
                self.y = self.y - v
            end
            if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
                self.x = self.x - 2*v
            end
            if love.keyboard.isDown('s') or love.keyboard.isDown('down') then
                self.y = self.y + v
            end
            if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
                self.x = self.x + 2*v
            end
            -- game isn't over, so update end time
            endtime = love.timer.getTime()
        else
            if love.keyboard.isDown('space') then
                state = newGame()
            end
            if love.keyboard.isDown('q') then
                love.event.quit()
            end
        end
        local elapsed = endtime - starttime
        self.x = math.max(self.x, 0)
        self.x = math.min(self.x, (sw-self.w))
        self.y = math.max(self.y, 0)
        self.y = math.min(self.y, (sh-self.h))
        -- update enemies
        -- threshold starts at 80, slowly drops to 10
        local shootThreshold = 10
        if elapsed < (80-10)*2 then
            shootThreshold = 80 - elapsed/2
        end
        for k, v in pairs(enemies) do
            v.y = v.y + 1
            if v.y >= (sh - esize) then
                enemies[k] = nil
                endgame()
            end
            if love.math.random(shootThreshold) < 2 then
                table.insert(bullets, {x = v.x + esize/2, y=v.y + esize + 3, v = 10})
            end
        end
        for k, b in pairs(bullets) do
            if (b.y < 0) or (b.y > sh) then
                bullets[k] = nil
            else
                b.y = b.y + b.v
                -- collide with enemies
                for ek, e in pairs(enemies) do
                    if (e.x <= b.x) and (b.x <= (e.x + esize)) and
                        (e.y <= b.y) and (b.y <= (e.y + esize)) then
                        enemies[ek] = nil
                    end
                end
                -- collide with player
                if (self.x < b.x) and (b.x < (self.x + self.w)) and
                    (self.y < b.y) and (b.y < (self.y + self.h)) then
                    endgame()
                end
            end
        end
        -- shoot
        if not gameover then
            table.insert(bullets, {x=self.x + self.w/2, y = self.y - self.h/2, v=-10})
        end
        -- spawn enemies
        local spawnThreshold = 20
        if elapsed > (60-20)*2 then
            spawnThreshold = 60 - elapsed/2
        end
        if counter > 60 then
            table.insert(enemies, {x=math.random(sw - 2*esize) + esize, y=0})
            counter = 0
        else
            counter = counter + 1
        end
    end
    function inputstate.draw(self)
        love.graphics.setColor(128,255,128)
        love.graphics.print(string.format("Survival time: %.3f", endtime - starttime), 20, 20)
        if gameover then
            love.graphics.print("game over (press 'q' to quit, space to start over)", 20, 50)
            love.graphics.setColor(255, 0, 0)
        end
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        -- enemies
        love.graphics.setColor(0,0,255)
        for k,v in pairs(enemies) do
            love.graphics.rectangle("fill", v.x, v.y, esize, esize)
        end
        -- bullets
        love.graphics.setColor(255,165,0)
        for k, v in pairs(bullets) do
            love.graphics.rectangle("fill", v.x, v.y, 2, 4)
        end
    end
    function inputstate.event(self, ev)
    end

    return inputstate
        
end

function love.update(dt)
    for ev in love.event.poll() do
        state:event(ev)
    end
    state:update(dt)
end

function love.draw()
    state:draw()
end
