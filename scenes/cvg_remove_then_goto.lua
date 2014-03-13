--	--	--	--
--	Init	--
--	--	--	--

local scene = cvg_composer.newScene()
Scenes.setBase(scene, Scenes.baseScene)
Scenes.listen(scene)



--	--	--	--
--	Locals	--
--	--	--	--

local removeScene = nil
local targetScene = nil



--	--	--	--
--	Methods	--
--	--	--	--

--[[
--	 Creation
--]]
function scene:create(event)
	removeScene, targetScene = unpack(event.params)
end


--[[
--	 Showing
--]]
function scene:willShow(event) 
	cvg_composer.removeScene(removeScene)
end

function scene:didShow(event)
	cvg_composer.gotoScene(targetScene)
end


--[[
--	 Hiding
--]]
function scene:willHide(event) end
function scene:didHide(event) end


--[[
--	 Destruction
--]]
function scene:destroy(event) end



--	--	--	--
--	Return	--
--	--	--	--

return scene