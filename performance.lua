local _M = {}
 
local mFloor = math.floor
local sGetInfo = system.getInfo
local sGetTimer = system.getTimer
local dislay = display
local tostring = tostring

local showing = false
 
local prevTime = 0
_M.added = true
local function createText()
	return display.newText({ 
		text = '00 00.00 000',
		x = display.contentCenterX,
		y = display.screenOriginY + 32,
		font = native.systemFont,
		fontSize = 12
	})
end
 
function _M.labelUpdater(event)
	local curTime = sGetTimer()

	_M.text.text = tostring(mFloor( 1000 / (curTime - prevTime))) .. ' ' ..
			tostring(mFloor(sGetInfo('textureMemoryUsed') * 0.0001) * 0.01) .. ' ' ..
			tostring(mFloor(collectgarbage('count')))
	_M.text:toFront()

	prevTime = curTime
end
 
function _M:show()
	if showing then return end

	self.text = createText(self)
	Runtime:addEventListener('enterFrame', _M.labelUpdater)
end

function _M:hide()
	if not showing then return end
	
	collectgarbage('collect')
	if _M.added then
		Runtime:removeEventListener('enterFrame', _M.labelUpdater)
		_M.added = false
		memory.alpha = .01
	else
		Runtime:addEventListener('enterFrame', _M.labelUpdater)
		_M.added = true
		memory.alpha = 1
	end
end
 
return _M