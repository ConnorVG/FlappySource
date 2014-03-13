_G.cvg_composer = require('composer')
local scene = cvg_composer.newScene()



--	--	--	--
--	Events	--
--	--	--	--

function scene:create(event)
	print('scene.create')

	-- Initialize the scene here.
	-- Example: add display objects to "sceneGroup", add touch listeners, etc.

	-- We expect the scene to have it's own create method.
end

function scene:willShow(event) print('scene.willShow') end
function scene:didShow(event) print('scene.didShow') end

function scene:show(event)
	local phase = event.phase

	if (phase == 'will') then
		-- Called when the scene is still off screen (but is about to come on screen).

		self:willShow(event)
	elseif (phase == 'did') then
		-- Called when the scene is now on screen.
		-- Insert code here to make the scene come alive.
		-- Example: start timers, begin animation, play audio, etc.

		self:didShow(event)
	end
end

function scene:willHide(event) print('scene.willHide') end
function scene:didHide(event) print('scene.didHide') end

function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase

	if (phase == 'will') then
		-- Called when the scene is on screen (but is about to go off screen).
		-- Insert code here to "pause" the scene.
		-- Example: stop timers, stop animation, stop audio, etc.

		self:willHide(event)
	elseif (phase == 'did') then
		-- Called immediately after scene goes off screen.

		self:didHide(event)
	end
end

function scene:destroy(event)
	print('scene.destroy')

	-- Called prior to the removal of scene's view ("sceneGroup").
	-- Insert code here to clean up the scene.
	-- Example: remove display objects, save state, etc.

	-- We expect the scene to have it's own destroy method.
end



--	--	--	--
--	Init	--
--	--	--	--

if Scenes == nil then _G.Scenes = {} end

Scenes.baseScene = scene



--	--	--	--	--	--	--
--	Simple Subclassing	--
--	--	--	--	--	--	--

function Scenes.setBase(target, base)
	target.create = base.create

	target.willShow = base.willShow
	target.didShow = base.didShow
	target.show = base.show

	target.willHide = base.willHide
	target.didHide = base.didHide
	target.hide = base.hide

	target.destroy = base.destroy
end



--	--	--	--	--
--	Listeners	--
--	--	--	--	--

function Scenes.listen(target)
	target:addEventListener('create', target)
	target:addEventListener('show', target)
	target:addEventListener('hide', target)
	target:addEventListener('destroy', target)
end



--	--	--	--
--	Return	--
--	--	--	--

return scene