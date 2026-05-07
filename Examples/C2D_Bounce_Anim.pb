; C2D::Bounce / Anim - Purebasic v5.70

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0	; Zoom-Factor
	#C2D_Z	=	1
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Mode		=	0
	#IsC2D_Bitmap	=	1
	#IsC2D_Anim		=	1
	#IsC2D_Bounce	=	1
	#IsC2D_File		=	1
	#IsC2D_GdiPlus	=	2
	#IsC2D_Clear	=	2
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#Y0	=	32	*	#C2D_Z
#Y1	=	#C2D_H	-	#Y0

Structure	Ball
	ID.i
	x.f
	xd.f
	aw.i
EndStructure

Global	NewList	Ball.Ball()

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Bounce / Anim"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 10)
	C2D::Quality(#PB_Image_Smooth)

	C2D::BitmapInit(0, @"..\Data\Anim\Anim_Paradoxion25_4x4.png")
	C2D::BitmapInit(1, @"..\Data\Anim\Anim_Paradoxion27_4x4.png")

	While	ListSize(Ball())	<	10
		
		AddElement(Ball())
		
		With	Ball()

			\ID	=	ListIndex(Ball())

			C2D::AnimInit(\ID,	C2D::BitmapImage(\ID % 2), 4, 4)	; 2 = # of images (0..1)
			C2D::AnimScale(\ID,	#C2D_Z * (1 + Random(16) * 0.06))
			C2D::AnimDelay(\ID,	8 + Random(20))
			
			\aw	=	#C2D_W	-	C2D::AnimW(\ID)
			
			\x		=	Random(\aw)
			\xd	=	(1.1 + Random(80) * 0.01)	*	C2D::MA_RMP(1)	*	#C2D_Z

			C2D::BounceInit(\ID, #Y0, #C2D_H - #Y0 * 2 - C2D::AnimH(\ID), (60 + Random(777) * 0.1) * #C2D_Z)
			
		EndWith
		
	Wend
	
	C2D::BitmapFree(-1)

EndProcedure
Procedure	C2D_Update()
	
	ForEach	Ball()
		With	Ball()
			
			\x	+	\xd

			If	\x	<	0	Or	\x	>	\aw
				\xd	*	-1
				C2D::AnimDirection(\ID, Bool(\xd > 0) * 2 - 1)
			EndIf
			
			C2D::AnimDraw(\ID, \x, C2D::Bounce(\ID))	; Bounce = y-pos
			
		EndWith
	Next
	
	LineXY(0, #Y0, #C2D_W, #Y0, $FF00FFFF)
	LineXY(0, #Y1, #C2D_W, #Y1, $FF00FFFF)
	
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
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = i
; Executable = ..\Executables\C2D_Bounce_Anim_x86.exe
; CompileSourceDirectory