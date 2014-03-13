local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
	content = {
	--	Content Dimensions
	--	width = 640,
	--	height = 1136,

		width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
		height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),

	--	Scaling method (letterbox, zoomEven, zoomStretch)
		scale = 'letterbox',

	--	Target FPS
		fps = 60,

	--	Image Scaling
		imageSuffix = {
			["@2x"] = 1.5,
			["@4x"] = 3.0,
		},
	},

--	Analytics
	launchPad = false,

--	Runtime Error Dialogues
	showRuntimeErrors = false
}