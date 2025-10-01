function love.load()
	level = 1;
    player = {
		grid_x = 256,
		grid_y = 256,
		act_x = 200,
		act_y = 200,
		speed = 50
	}
    target = {
		grid_x = 64,
		grid_y = 64,
		act_x = 200,
		act_y = 200,
		speed = 100
	}
    -- win flag: becomes true when player lands on the same grid cell as the target
    win = false
	map = {
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1 },
		{ 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1 },
		{ 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1 },
		{ 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1 },
		{ 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1 },
		{ 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1 },
		{ 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
	}
	map2 = {
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
	}
end

function love.update(dt)
	player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
	player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)
    target.act_y = target.act_y - ((target.act_y - target.grid_y) * target.speed * dt)
	target.act_x = target.act_x - ((target.act_x - target.grid_x) * target.speed * dt)
end

function love.draw()
	love.graphics.setColor(52/235, 229/235, 1)
	love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", target.act_x, target.act_y, 32, 32)
    love.graphics.setColor(1, 1, 1)
    if win then
        love.graphics.print("YOU WIN", 10, 10)
    end
	for y=1, #map do
		for x=1, #map[y] do
			if map[y][x] == 1 then
				love.graphics.setColor(166/235, 166/235, 166/235)
    			love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)
				love.graphics.setColor(1, 1, 1)
				love.graphics.rectangle("line", x * 32, y * 32, 32, 32)
			end
		end
	end
end

function targetMove()
    target.grid_x = target.grid_x + (x * 32)
    target.grid_y = target.grid_y + (y * 32)
end

function love.keypressed(key)
	if key == "up" then
		if testMap(0, -1) then
			player.grid_y = player.grid_y - 32
		end
        -- target moves down when player moves up (opposite direction)
        if testMapTarget(0, 1) then
            target.grid_y = target.grid_y + 32
		end
	elseif key == "down" then
		if testMap(0, 1) then
			player.grid_y = player.grid_y + 32
		end
        -- target moves up when player moves down
        if testMapTarget(0, -1) then
            target.grid_y = target.grid_y - 32
		end
	elseif key == "left" then
		if testMap(-1, 0) then
			player.grid_x = player.grid_x - 32
		end
        -- target moves right when player moves left
        if testMapTarget(1, 0) then
            target.grid_x = target.grid_x + 32
		end
	elseif key == "right" then
		if testMap(1, 0) then
			player.grid_x = player.grid_x + 32
		end
        -- target moves left when player moves right
        if testMapTarget(-1, 0) then
            target.grid_x = target.grid_x - 32
		end
	end
    -- check win: same grid cell
    if player.grid_x == target.grid_x and player.grid_y == target.grid_y then
        print("YOU WIN")
        win = true
    end
end

function testMapTarget(x, y)
	local ty = (target.grid_y / 32) + y
	local tx = (target.grid_x / 32) + x
	if not map[ty] then return false end
	if not map[ty][tx] then return false end
	if map[ty][tx] == 1 then
		return false
	end
	return true
end

function testMap(x, y)
	if map[(player.grid_y / 32) + y][(player.grid_x / 32) + x] == 1 then
		return false
	end
	return true
end