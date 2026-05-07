; C2D::Anim / Logo - Purebasic v6.01

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0	; Zoom-Factor
	#C2D_Z	=	1
CompilerEndIf

DeclareModule	IsC2D
	;XIncludeFile	"..\Include\C2D_Formats.pbi"
	#IsC2D_Mode			=	0
	#IsC2D_Anim			=	1
	#IsC2D_Bitmap		=	1
	#IsC2D_File			=	1
	#IsC2D_GdiPlus		=	2
	#IsC2D_Clear		=	2
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Anim / Logo"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 10)

	C2D::BitmapInit(0, @"..\Data\Anim\Anim_TRS_17x3_51.png")

	C2D::AnimInit(0, C2D::BitmapImage(0), 17, 3)
	C2D::AnimScale(0, #C2D_Z)

	C2D::AnimDelay(0, 80)			; all frames wait 80ms
	C2D::AnimDelay(0, 2500, 50)	; last frame wait 2.5s
	C2D::AnimDelay(0, 2500, 0)		; first frame wait 2.5s & set as actual frame

	C2D::AnimPingPong(0)	; loop ping pong

	C2D::BitmapFree(0)

EndProcedure
Procedure	C2D_Update()
	
	C2D::AnimDraw(0, 0, 0, 255, C2D::#C2F_Center)	; that's all
	
	;FrontColor($FFFFFFFF)
	DrawText(10, 10, "Width:  " + Str(C2D::AnimW(0)))
	DrawText(10, 28, "Heigth: " + Str(C2D::AnimH(0)))
	DrawText(10, 46, "Frame:  " + Str(C2D::AnimFrame(0)))
	
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
; IDE Options = PureBasic 6.01 LTS (Windows - x86)
; Folding = w
; Executable = ..\Executables\C2D_Anim_Logo_x86.exe
; DisableDebugger
; CompileSourceDirectory