; C2D::Anim / Copper + Text - Purebasic v6.30 (x86-64)

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0	; Zoom-Factor
	#C2D_Z	=	1	; try = 2
CompilerEndIf

DeclareModule	IsC2D
	XIncludeFile	"..\Include\C2D_Types.pbi"
	#IsC2D_Music		=	#XMU_SCA
	#IsC2D_Mode			=	0
	#IsC2D_Clear		=	0	; no autoclear canvas (cleared by buffered background)
	#IsC2D_Copper		=	1
	#IsC2D_Anim			=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Bitmap		=	1
	#IsC2D_BitmapColor=	1
	#IsC2D_FontColor	=	1
	#IsC2D_File			=	1
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_ScrollText	=	2	; 2 -> Control-Codes
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0		; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#ID_FIRE		=	0
#ID_WATER	=	1
#ID_DANCE	=	2
#ID_FONT		=	0
#ID_SMALL	=	1
#ID_TEXT		=	0

#C2F_X		=	3
#SIN_X	=	4

Global	x.f, y_water.f, y_fire.f, y_dance.f, y_text.f, h_mirror.f

Procedure.l	Blit_Copper(x, y, PenColor.l, PaperColor.l)
	If	PaperColor	<>	$FFFF00FF
		ProcedureReturn	PaperColor
	EndIf
	ProcedureReturn	PenColor|$DF
EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Anim / Buffer + Copper + Scroller + Mirror + SCAL") , #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 8)
	
	C2D::BitmapInit(0, @"..\Data\Font\PNG\16x16_Shaolin.png", 0, #Black)
	C2D::BitmapFill(0, $FFFF00FF)
	C2D::FontInit(#ID_FONT, C2D::BitmapImage(0))
	C2D::FontZoom(#ID_FONT, 32 * #C2D_Z, 48 * #C2D_Z)
	C2D::FontShadow(#ID_FONT, 3, 3, 100)
	C2D::FontGap(#ID_FONT, 0, #C2D_Z * 2)
	
	; smaller font for testaware.com
	C2D::FontInit(#ID_SMALL, C2D::BitmapImage(0))
	C2D::FontZoom(#ID_SMALL, 23 * #C2D_Z, 48 * #C2D_Z)
	C2D::FontShadow(#ID_SMALL, 3, 3, 100)
	C2D::FontGap(#ID_SMALL, 0, #C2D_Z * 2)
	
	C2D::ScrollTextInit(#ID_TEXT, ?t_text)
	C2D::ScrollTextSpeed(#ID_TEXT, 0.8 * #C2D_Z)
	
	C2D::BitmapInit(0, @"..\Data\Anim\Anim_Fire_5x2.png")
	C2D::AnimInit(#ID_FIRE, C2D::BitmapImage(0), 5, 2)
	C2D::AnimZoom(#ID_FIRE, #C2D_W / #C2F_X, C2D::FontH(#ID_FONT))
	C2D::AnimDelay(#ID_FIRE, 50)

	C2D::BitmapInit(0, @"..\Data\Anim\Anim_Water_13x2.png")
	C2D::AnimInit(#ID_WATER, C2D::BitmapImage(0), 13, 2)
	C2D::AnimZoom(#ID_WATER, #C2D_W, #C2D_H * 0.32)
	C2D::AnimDelay(#ID_WATER, 64)
	
	C2D::BitmapInit(0, @"..\Data\Anim\Anim_IK+Dance_16x18.png")
	C2D::AnimInit(#ID_DANCE, C2D::BitmapImage(0), 16, 18)
	C2D::AnimScale(#ID_DANCE, 4 * #C2D_Z)
	C2D::AnimDelay(#ID_DANCE, 70)
	C2D::AnimPingPong(#ID_DANCE)
	
	C2D::BitmapInit(0, @"..\Data\Back\Asia_IK+.png")
	C2D::BitmapZoom(0, #C2D_W, #C2D_H - C2D::AnimH(#ID_WATER))
	
	; create background (no clear needed)
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::BitmapDraw(0, 0, 0, 128)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()
	
	C2D::BitmapFree(0)
	
	y_water	=	#C2D_H	-	C2D::AnimH(#ID_WATER)
	y_fire	=	y_water	-	C2D::AnimH(#ID_FIRE)
	y_dance	=	y_water	-	C2D::AnimH(#ID_DANCE)
	y_text	=	y_water	-	C2D::FontH(#ID_FONT)	+	1
	h_mirror	=	y_water	*	0.94

	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicInit(#SCAL_PATH$)	; set default-path to SCAL_(x86-64).dll
		C2D::MusicPlay(@"..\Data\Music\FC\Jochen Hippel - Shaolin1.smod")
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Protected	i

	C2D::BufferBackDraw()	; fast clearcanvas by restore buffered background
	
	C2D::AnimDraw(#ID_DANCE, 0, y_dance, 255, C2D::#C2F_CenterX)	; ik+ dancer
	
	ClipOutput(#SIN_X, y_text, #C2D_W - #SIN_X * 2, C2D::FontH(#ID_FONT))
	C2D::ScrollTextDraw(#ID_TEXT, y_text)	; scrolltext
	UnclipOutput()
	
	DrawingMode(#PB_2DDrawing_CustomFilter); anim fire on scrolltext only
	CustomFilterCallback(@Blit_Copper())
	For	i	=	0	To	#C2F_X	-	1
		C2D::AnimDraw(#ID_FIRE, i * C2D::AnimW(#ID_FIRE), y_fire)
	Next
	
	DrawingMode(#PB_2DDrawing_AlphaBlend)	; restore drawingmode!
	
	i	=	C2D::BufferMirror(0, y_water, #C2D_W, h_mirror, %1)	; mirror
	Box(0, y_water, #C2D_W, i, $80FF0000)
	
	;anim & scroll water
	x	+	0.4 * #C2D_Z	:	If	x	>	#C2D_W	:	x	=	0	:	EndIf
	
	C2D::AnimDraw(#ID_WATER, x, y_water, 124)
	
	If	x	>	0
		x - #C2D_W
	ElseIf	x	<	0
		x	+	#C2D_W
	EndIf
	
	If	x
		C2D::AnimDraw(#ID_WATER, x, y_water, 124)
	EndIf
	
	; sinwave water
	C2D::BufferSinX(#SIN_X,
	                y_water,
	                #C2D_W - #SIN_X * 2,
	                i-2,
	                #SIN_X,
	                50.0,
	                15.0)
	
EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection
	t_text:		:	Data.s	"{1}{4,1.5}EXAMPLE USING THE: {5}C2D MODULE V" + MA_XC2D() + "{5}{2,5000}CODED IN: {5}PUREBASIC V" + MA_XPB() + "{5}{2,5000}SOUND PLAYING WITH THE:   {5}SCAL " + MA_XOS() + " DLL{5}{2,5000}VISIT US AT: {1,1}{5}TESTAWARE.WORDPRESS.COM{5}{2,5000}"
EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A-
; Executable = ..\Executables\C2D_Anim_Copper_x86.exe
; CompileSourceDirectory