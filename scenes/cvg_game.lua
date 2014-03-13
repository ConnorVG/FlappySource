--	--	--	--
--	Init	--
--	--	--	--

local scene = cvg_composer.newScene()
Scenes.setBase(scene, Scenes.baseScene)
Scenes.listen(scene)



--	--	--	--
--	Locals	--
--	--	--	--

local cvg_physics

local remove, os, abs, floor, random, unpack = table.remove, os, math.abs, math.floor, math.random, unpack

local contentWidth, contentHeight

local scene_ground, scene_ceiling, scene_player, scene_obstacles, scene_hud_score

local scene_framesLeft

local scene_removal

local scene_score

local scene_layer_back, scene_layer_main, scene_layer_front

local max_obstacle_offset, last_obstacle_offset_frame, last_midpoint



--	--	--	--	--	--	--
--	Utility Functions	--
--	--	--	--	--	--	--

local function newObstacle(sceneGroup, maxDiff, lastMidpoint)
	local quarter = (contentHeight - 64) * 0.25
	local midPoint = (random() * quarter * 2) + quarter

	if maxDiff ~= 0 and abs(lastMidpoint - midPoint) > abs(maxDiff) then
		midPoint = lastMidpoint + maxDiff

		if midPoint < quarter then midPoint = quarter end
		if midPoint > quarter * 3 then midPoint = quarter * 3 end
	end

--	Top
	local part_one = display.newImageRect(sceneGroup, 'pipe_base.png', 16, quarter * 2 + 40)
	part_one.x, part_one.y = contentWidth + 8, midPoint - quarter - 90

	physics.addBody(part_one, 'kinematic', {  })

	part_one.isFixedRotation = true
	part_one.isSleepingAllowed = false
	part_one.gravityScale = 0
	part_one.isSensor = true

	part_one.isObstacle = true
	part_one:setLinearVelocity(-120, 0)

--	Top Head
	local head_one = display.newImageRect(sceneGroup, 'pipe_head.png', 16, 8)
	head_one.x, head_one.y = contentWidth + 8, floor(part_one.y + part_one.height * 0.5)

	physics.addBody(head_one, 'kinematic', {  })

	head_one.isFixedRotation = true
	head_one.isSleepingAllowed = false
	head_one.gravityScale = 0
	head_one.isSensor = true

	head_one.isObstacle = true
	head_one:setLinearVelocity(-120, 0)

--	Bottom
	local part_two = display.newImageRect(sceneGroup, 'pipe_base.png', 16, quarter * 2 + 40)
	part_two.x, part_two.y = contentWidth + 8, midPoint + quarter + 90

	physics.addBody(part_two, 'kinematic', {  })

	part_two.isFixedRotation = true
	part_two.isSleepingAllowed = false
	part_two.gravityScale = 0
	part_two.isSensor = true

	part_two.isObstacle = true
	part_two:setLinearVelocity(-120, 0)

--	Bottom Head
	local head_two = display.newImageRect(sceneGroup, 'pipe_head.png', 16, 8)
	head_two.x, head_two.y = contentWidth + 8, floor(part_two.y - (part_two.height * 0.5) - 0.5)
	head_two.yScale = -1

	physics.addBody(head_two, 'kinematic', {  })

	head_two.isFixedRotation = true
	head_two.isSleepingAllowed = false
	head_two.gravityScale = 0
	head_two.isSensor = true

	head_two.isObstacle = true
	head_two:setLinearVelocity(-120, 0)

--	Score
	local part_three = display.newRect(sceneGroup, contentWidth + 16, midPoint, 1, quarter * 2 + 40)

	physics.addBody(part_three, 'kinematic', {  })

	part_three.isFixedRotation = true
	part_three.isSleepingAllowed = false
	part_three.gravityScale = 0
	part_three.isSensor = true
	part_three.isVisible = false

	part_three.isScore = true
	part_three:setLinearVelocity(-120, 0)

	return midPoint, { part_one, part_two, part_three }
end



--	--	--	--
--	Methods	--
--	--	--	--


--[[
--	 Creation
--]]
function scene:create(event)
--	Defaults
	cvg_physics = _G.cvg_physics
	cvg_physics.start()

	contentWidth, contentHeight = display.contentWidth, display.contentHeight

	scene_ground, scene_player, scene_obstacles = nil, nil, {}

	scene_framesLeft = 80

	scene_removal = {}

	scene_hud_score = 0

	scene_score = 0

	max_obstacle_offset, last_obstacle_offset_frame = 0, 0

	last_midpoint = contentHeight / 2

	scene_layer_back, scene_layer_main, scene_layer_front = display.newGroup(), display.newGroup(), display.newGroup()
	self.view:insert(scene_layer_back)
	self.view:insert(scene_layer_main)
	self.view:insert(scene_layer_front)

	scene_layer_main:toFront()
	scene_layer_front:toFront()

--	Ground
	scene_ground = display.newRect(scene_layer_front, contentWidth / 2, contentHeight - 32, contentWidth, 64)

	physics.addBody(scene_ground, 'static', { bounce = 0.0, friction = 0.3 })

--	Ceiling
	scene_ceiling = display.newRect(scene_layer_front, contentWidth / 2, -1, contentWidth, 2)

	physics.addBody(scene_ceiling, 'static', { bounce = 0.0, friction = 0.3 })

--	Player
	scene_player = display.newImageRect(scene_layer_front, 'bird.png', 16, 16)
	scene_player.x = 48	--	contentWidth * 0.5
	scene_player.y = contentHeight * 0.5

	physics.addBody(scene_player, 'dynamic', { shape = { -7, -7, 7, -7, 7, 7, -7, 7 }, density = 1 })

	scene_player.isFixedRotation = true
	scene_player.isSleepingAllowed = false
	scene_player.gravityScale = 4

--	HUD
	scene_hud_score = display.newText({ 
		text = scene_hud_score,
		x = contentWidth / 2,
		y = 16,
		font = native.systemFont,
		fontSize = 24,
		parent = scene_layer_front
	})

--	Events
	Runtime:addEventListener('enterFrame', self.logic)
	Runtime:addEventListener('touch', self.tap)

	scene_player:addEventListener('collision', function(event)
		if event.phase ~= 'began' or not event.other then return end

		if event.other.isObstacle then
			timer.performWithDelay(0, function()
				cvg_composer.gotoScene('scenes.cvg_remove_then_goto', { params = { 'scenes.cvg_game', 'scenes.cvg_game' } })
			end)
		elseif event.other.isScore then
			scene_score = scene_score + 1
			scene_hud_score.text = scene_score
		end
	end)

	cvg_physics.pause()
end


--[[
--	 Showing
--]]
function scene:willShow(event) end

function scene:didShow(event) 
	cvg_physics.start()
end


--[[
--	 Logic
--]]
function scene:logic()
	local removes = #scene_removal
	while removes > 0 do
		local obj = scene_removal[removes]

		if obj[2] == 1 then
			obj[1]:removeSelf()

			remove(scene_removal, removes)
		else obj[2] = obj[2] - 1 end

		removes = removes - 1
	end
	local removes = #scene_removal
	while removes > 0 do
		local obj = scene_removal[removes]
		local objs = obj[1]

		if obj[2] == 1 then
			local i = #obj[1]
			while i > 0 do
				objs[i]:removeSelf()
				objs[i] = nil

				i = i - 1
			end

			remove(scene_removal, obj)
		else obj[2] = obj[2] - 1 end

		removes = removes - 1
	end

	if last_obstacle_offset_frame > 0 then
		last_obstacle_offset_frame = last_obstacle_offset_frame - 1
		last_obstacle_offset_frame = last_obstacle_offset_frame < 0 and 0 or last_obstacle_offset_frame
	elseif last_obstacle_offset_frame < 0 then
		last_obstacle_offset_frame = last_obstacle_offset_frame + 1
		last_obstacle_offset_frame = last_obstacle_offset_frame > 0 and 0 or last_obstacle_offset_frame
	end

	scene_framesLeft = scene_framesLeft - 1
	if scene_framesLeft <= 0 then
		local maxDiff
		if max_obstacle_offset == 0 then maxDiff = contentHeight
		else maxDiff = (max_obstacle_offset - last_obstacle_offset_frame) * 1.49999 end

		local obstacle
		last_midpoint, obstacle = newObstacle(scene_layer_main, maxDiff, last_midpoint)

		local frames = (contentWidth + 32) / 90
		scene_removal[#scene_removal + 1] = { { unpack(obstacle) } , frames }

		local case = floor(random() * 7)
		scene_framesLeft = random() * 30 + (case <= 5 and 20 or 40)

		local mult = floor(random() * 2) == 0 and 1 or -1

		max_obstacle_offset = scene_framesLeft * mult
		last_obstacle_offset_frame = max_obstacle_offset
	end
end


--[[
--	 Input
--]]
function scene:tap()
	scene_player:setLinearVelocity(0, -300)
end


--[[
--	 Hiding
--]]
function scene:willHide(event)
	cvg_physics.stop()
end

function scene:didHide(event) end


--[[
--	 Destruction
--]]
function scene:destroy(event)
--	Events
	Runtime:removeEventListener('touch', self.tap)
	Runtime:removeEventListener('enterFrame', self.logic)

--	HUD
	scene_hud_score:removeSelf()
	scene_hud_score = nil

--	Player
	scene_player:removeSelf()
	scene_player = nil

--	Ground
	scene_ceiling:removeSelf()
	scene_ceiling = nil

--	Ground
	scene_ground:removeSelf()
	scene_ground = nil

--	Removals
	local removes = #scene_removal
	while removes > 0 do
		local obj = scene_removal[removes]
		local objs = obj[1]

		local i = #obj[1]
		while i > 0 do
			objs[i]:removeSelf()
			objs[i] = nil

			i = i - 1
		end

		removes = removes - 1
	end
	scene_removal = {}

--	Layers
	scene_layer_back:removeSelf()
	scene_layer_back = nil

	scene_layer_main:removeSelf()
	scene_layer_main = nil

	scene_layer_front:removeSelf()
	scene_layer_front = nil
end



--	--	--	--
--	Return	--
--	--	--	--

return scene