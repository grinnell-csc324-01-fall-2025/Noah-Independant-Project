function love.load()
	levels = require("levels")
	level = 1
	totaldeaths = 2
    player = {
		grid_x = 256,
		grid_y = 256,
		act_x = 200,
		act_y = 200,
		speed = 50,
		deathcount = 0,
	}
    target = {
		grid_x = 64,
		grid_y = 64,
		act_x = 200,
		act_y = 200,
		speed = 100,
		deathcount = 0,
	}
	sound = {}
	sound.collision = love.audio.newSource("sound/collision.wav", "static")
	sound.music = love.audio.newSource("sound/music.wav", "stream")
	sound.collision:setVolume(0.2)
	sound.music:setVolume(0.3)
	sound.collision:setLooping(false)
	sound.music:setLooping(true)
	sound.music:play()
    -- win flag: becomes true when player lands on the same grid cell as the target
    win = false
	winTimer = 0
	winHoldDuration = 3.5 -- time to hold the banner before auto-advancing
	map = levels.get(level)
end

function love.update(dt)
	player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
	player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)
    target.act_y = target.act_y - ((target.act_y - target.grid_y) * target.speed * dt)
	target.act_x = target.act_x - ((target.act_x - target.grid_x) * target.speed * dt)

	-- handle win timer: fade/hold and auto-advance to next level
	if win then
		winTimer = winTimer + dt
		if winTimer >= winHoldDuration then
			-- advance to next level automatically
			level = level + 1
			changeLevel(level)
			win = false
			winTimer = 0
		end
	end
end

function love.draw()
	-- draw map tiles first (walls and death tiles)
	if level > levels.count() then
		local msg = "You and your friend lived " .. tostring(totaldeaths) .. " lives until you found each other. Thanks for playing!"
		local font = love.graphics.getFont()
		local fw = font:getWidth(msg)
		local fh = font:getHeight()
		local x = (love.graphics.getWidth() - fw) / 2
		local y = (love.graphics.getHeight() - fh) / 2
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(msg, x, y)
		return
	end
	for y=1, #map do
		for x=1, #map[y] do
			if map[y][x] == 1 then
				love.graphics.setColor(166/235, 166/235, 166/235)
				love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)
				love.graphics.setColor(1, 1, 1)
				love.graphics.rectangle("line", x * 32, y * 32, 32, 32)
			elseif map[y][x] == 2 then
				-- death tile (red)
                love.graphics.setColor(1, 0, 0)
				love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)
			end
		end
	end

	-- draw entities on top of tiles
	love.graphics.setColor(52/235, 229/235, 1)
	love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)
	love.graphics.setColor(0, 1, 0)
	love.graphics.rectangle("fill", target.act_x, target.act_y, 32, 32)
	love.graphics.setColor(1, 1, 1)

	-- UI: top-right panel with level and death counts
	local windowW, windowH = love.graphics.getDimensions()
	local panelW = 200
	local panelH = 72
	local padding = 10
	local px = windowW - panelW - padding
	local py = padding

	-- panel background (semi-transparent dark)
	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", px, py, panelW, panelH)

	-- panel border
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("line", px, py, panelW, panelH)

	-- text inside panel
	love.graphics.setColor(1, 1, 1)
	local tx = px + 12
	local ty = py + 8
	love.graphics.print("Level: " .. tostring(level), tx, ty)
	love.graphics.print("Player deaths: " .. tostring(player.deathcount or 0), tx, ty + 20)
	love.graphics.print("Target deaths: " .. tostring(target.deathcount or 0), tx, ty + 40)
	
	-- draw win overlay last so it sits above everything
	if win then
		drawWinOverlay()
	end
end

-- draw level-complete overlay when win flag is set
function drawWinOverlay()
	-- full-screen darkening
	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	-- centered banner box (white text on dark)
	local boxW = 360
	local boxH = 120
	local bx = (love.graphics.getWidth() - boxW) / 2
	local by = (love.graphics.getHeight() - boxH) / 2

	love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
	love.graphics.rectangle("fill", bx, by, boxW, boxH, 6, 6)
	love.graphics.setColor(1, 1, 1, 0.9)
	love.graphics.rectangle("line", bx, by, boxW, boxH, 6, 6)

	-- banner text
	love.graphics.setColor(1, 1, 1)
	local title = "LEVEL COMPLETE"
	local subtitle = " You lived " .. tostring(player.deathcount + 1) .. " lives" .. " and Chris lived " .. tostring(target.deathcount + 1) .. "lives until you each other "
	-- if win
	local titleW = love.graphics.getFont():getWidth(title)
	local subtitleW = love.graphics.getFont():getWidth(subtitle)
	love.graphics.print(title, bx + (boxW - titleW) / 2, by + 20)
	love.graphics.print(subtitle, bx + (boxW - subtitleW) / 2, by + 60)
end

function targetMove()
    target.grid_x = target.grid_x + (x * 32)
    target.grid_y = target.grid_y + (y * 32)
end

-- target moves opposite direction as player
function love.keypressed(key)
	-- during win overlay, only accept continue or replay
	if win then
		if key == "return" or key == "enter" then
			level = level + 1
			changeLevel(level)
			win = false
			winTimer = 0
			return
		else
			return
		end
	end
	if key == "up" then
		if testMap(0, -1) then
			player.grid_y = player.grid_y - 32
		else
			sound.collision:play()
		end
        
        if testMapTarget(0, 1) then
            target.grid_y = target.grid_y + 32
		else
			sound.collision:play()
		end
	elseif key == "down" then
		if testMap(0, 1) then
			player.grid_y = player.grid_y + 32
		else
			sound.collision:play()
		end
        if testMapTarget(0, -1) then
            target.grid_y = target.grid_y - 32
		else
			sound.collision:play()
		end
	elseif key == "left" then
		if testMap(-1, 0) then
			player.grid_x = player.grid_x - 32
		else
			sound.collision:play()
		end
        if testMapTarget(1, 0) then
            target.grid_x = target.grid_x + 32
		else
			sound.collision:play()
		end
	elseif key == "right" then
		if testMap(1, 0) then
			player.grid_x = player.grid_x + 32
		else
			sound.collision:play()
		end
        if testMapTarget(-1, 0) then
            target.grid_x = target.grid_x - 32
		else
			sound.collision:play()
		end
	end
	-- check for death tiles first for player
    local pty = (player.grid_y / 32)
	local ptx = (player.grid_x / 32)
	if map[pty] and map[pty][ptx] == 2 then
		player.deathcount = (player.deathcount or 0) + 1
		totaldeaths = totaldeaths + 1
		changeLevel(level)
		return
	end
	-- check for death tiles for target
    local tty = (target.grid_y / 32)
	local ttx = (target.grid_x / 32)
	if map[tty] and map[tty][ttx] == 2 then
		target.deathcount = (target.deathcount or 0) + 1
		totaldeaths = totaldeaths + 1
		changeLevel(level)
		return
	end

	-- check win: trigger level-complete overlay
	if player.grid_x == target.grid_x and player.grid_y == target.grid_y then
		win = true
		winTimer = 0
	end
end

function testMapTarget(x, y)
	local ty = (target.grid_y / 32) + y
	local tx = (target.grid_x / 32) + x
	if not map[ty] or not map[ty][tx] then return false end
	return map[ty][tx] ~= 1
end

function testMap(x, y)
	local py = (player.grid_y / 32) + y
	local px = (player.grid_x / 32) + x
	if not map[py] or not map[py][px] then return false end
	return map[py][px] ~= 1
end

-- changeLevel: switches the current map and resets entities for the given level
function changeLevel(newLevel)
	if newLevel > levels.count() then
		-- no more levels
		map = {}
		return
	end
	level = newLevel
	map = levels.get(level)
	-- reset player/target positions
	player.grid_x = 256
	player.grid_y = 256
	player.act_x = 200
	player.act_y = 200
	target.grid_x = 64
	target.grid_y = 64
	target.act_x = 200
	target.act_y = 200
	win = false
end