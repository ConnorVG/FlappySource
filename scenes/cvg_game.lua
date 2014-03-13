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

local remove, os = table.remove, os

local contentWidth, contentHeight

local scene_ground, scene_player, scene_obstacles, scene_hud_score

local scene_framesLeft

local scene_removal

local scene_score = 0



--	--	--	--	--	--	--
--	Utility Functions	--
--	--	--	--	--	--	--

local function newObstacle()
	local quarter = (contentHeight - 64) * 0.25
	local midPoint = (math.random() * quarter * 2) + quarter

--	Top
	local part_one = display.newRect(contentWidth + 16, midPoint - quarter - 100, 32, quarter * 2 + 40)

	physics.addBody(part_one, 'kinematic', {  })

	part_one.isFixedRotation = true
	part_one.isSleepingAllowed = false
	part_one.gravityScale = 0
	part_one.isSensor = true

	part_one.isObstacle = true

--	Bottom
	local part_two = display.newRect(contentWidth + 16, midPoint + quarter + 100, 32, quarter * 2 + 40)

	physics.addBody(part_two, 'kinematic', {  })

	part_two.isFixedRotation = true
	part_two.isSleepingAllowed = false
	part_two.gravityScale = 0
	part_two.isSensor = true

	part_two.isObstacle = true

--	Score
	local part_three = display.newRect(contentWidth + 16, midPoint, 1, quarter * 2 + 40)

	physics.addBody(part_three, 'kinematic', {  })

	part_three.isFixedRotation = true
	part_three.isSleepingAllowed = false
	part_three.gravityScale = 0
	part_three.isSensor = true
	part_three.isVisible = false

	part_three.isScore = true

	return part_one, part_two, part_three
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

--	Ground
	scene_ground = display.newRect(contentWidth / 2, contentHeight - 32, contentWidth, 64)

	physics.addBody(scene_ground, 'static', { bounce = 0.0, friction = 0.3 })

--	Player
	scene_player = display.newCircle(48, contentHeight / 2 - 16, 16)

	physics.addBody(scene_player, 'dynamic', { radius = 16, density = 1 })

	scene_player.isFixedRotation = true
	scene_player.isSleepingAllowed = false
	scene_player.gravityScale = 2.5

--	HUD
	scene_hud_score = display.newText({ 
		text = scene_hud_score,
		x = contentWidth / 2,
		y = 16,
		font = native.systemFont,
		fontSize = 24
	})

--	Events
	Runtime:addEventListener('enterFrame', self.logic)
	Runtime:addEventListener('touch', self.tap)

	scene_player:addEventListener('collision', function(event)
		if event.phase ~= 'began' or not event.other then return end

		if event.other.isObstacle then
			timer.performWithDelay(0, function()
				cvg_composer.gotoScene('scenes.cvg_reload', { params = 'scenes.cvg_game' })
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
	scene_framesLeft = scene_framesLeft - 1
	if scene_framesLeft <= 0 then
		scene_framesLeft = 120 + math.random() * 45

		local one, two, three = newObstacle()
		one:setLinearVelocity(-90, 0)
		two:setLinearVelocity(-90, 0)
		three:setLinearVelocity(-90, 0)

		local frames = (contentWidth + 32) / 90
		scene_removal[#scene_removal + 1] = { one, frames }
		scene_removal[#scene_removal + 1] = { two, frames }
		scene_removal[#scene_removal + 1] = { three, frames }
	end

	local removes = #scene_removal
	while removes > 0 do
		local obj = scene_removal[removes]

		if obj[2] == 1 then
			obj[1]:removeSelf()

			remove(scene_removal, removes)
		else obj[2] = obj[2] - 1 end

		removes = removes - 1
	end
end


--[[
--	 Input
--]]
function scene:tap()
	scene_player:setLinearVelocity(0, -350)
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
	scene_ground:removeSelf()
	scene_ground = nil

--	Removals
	local removes = #scene_removal
	while removes > 0 do
		local obj = scene_removal[removes]
		obj[1]:removeSelf()

		removes = removes - 1
	end
	scene_removal = {}
end



--	--	--	--
--	Return	--
--	--	--	--

return scene