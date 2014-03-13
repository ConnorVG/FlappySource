Runtime:addEventListener('unhandledError', function(event)
	print('Error: ' .. event.errorMessage)
end)

--	Requires
	require('cvg_wtf')

--	Globals
	_G.cvg_physics = require('physics')
	_G.cvg_performance = require('performance')

	local cvg_physics, cvg_performance = _G.cvg_physics, _G.cvg_performance

--	Composer
	require('scenes.cvg_base')

	local cvg_composer = _G.cvg_composer

--	Physics
	cvg_physics.start()

	cvg_physics.setGravity(0, 9.8)
	cvg_physics.setDrawMode('normal')

	cvg_physics.pause()

--	Performance
	cvg_performance:newPerformanceMeter()

--	Scenes
	cvg_composer.gotoScene('scenes.cvg_game')