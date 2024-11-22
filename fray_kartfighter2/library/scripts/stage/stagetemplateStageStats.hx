// Stats for Template Stage

{
	spriteContent: self.getResource().getContent("kartfight"),
	animationId: "stage",
	ambientColor: 0x00000000,
	shadowLayers: [
		{
			id: "0",
			maskSpriteContent: self.getResource().getContent("kartfight"),
			maskAnimationId: "shadowMaskFront",
			color:0x40000000,
			foreground: true
		},
		{
			id: "1",
			maskSpriteContent: self.getResource().getContent("kartfight"),
			maskAnimationId: "shadowMask",
			color:0xff000000,
			foreground: false
		}
	],
	camera: {
		startX : 0,
		startY : 0,
		zoomX : 0,
		zoomY : 0,
		camEaseRate : 1 / 4,
		camZoomRate : 1 / 15,
		minZoomHeight : 240,
		initialHeight: 240,
		initialWidth: 426.67,
		backgrounds: [

			{
				spriteContent: self.getResource().getContent("kartfight"),
				animationId: "background",
				mode: ParallaxMode.BOUNDS,
				originalBGWidth: 307,
				originalBGHeight: 201,
				horizontalScroll: false,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 0.06,
				yPanMultiplier: 0.06,
				scaleMultiplier: 1,
				foreground: false,
				depth: 2001
			},

			{
				spriteContent: self.getResource().getContent("kartfight"),
				animationId: "bgElement2",
				mode: ParallaxMode.DEPTH,
				originalBGWidth: 307,
				originalBGHeight: 201,
				horizontalScroll: true,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 0.135,
				yPanMultiplier: 0.135,
				scaleMultiplier: 1,
				foreground: false,
				depth: 2500
			},

			{
				spriteContent: self.getResource().getContent("kartfight"),
				animationId: "bgElement1",
				mode: ParallaxMode.DEPTH,
				originalBGWidth: 307,
				originalBGHeight: 201,
				horizontalScroll: true,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 0.135,
				yPanMultiplier: 0.135,
				scaleMultiplier: 1,
				foreground: false,
				depth: 1250
			},

			{
				spriteContent: self.getResource().getContent("kartfight"),
				animationId: "bgElement0",
				mode: ParallaxMode.PAN,
				originalBGWidth: 307,
				originalBGHeight: 201,
				horizontalScroll: true,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 2.5,
				yPanMultiplier: 2.5,
				scaleMultiplier: 1.05,
				foreground: true,
				depth: 800
			}
		]
	}
}
