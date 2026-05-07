; C2D::Brush / Move Mouse X & Y

;***************************************************
; *** IsC2D the MUST Init-Module, always needed! ***
;***************************************************
IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D

	#IsC2D_GdiPlus	=	1
	#IsC2D_File		=	1
	#IsC2D_Brush	=	1
	#IsC2D_Clear	=	0
	
	XIncludeFile	"C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;***************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1
CompilerEndIf

; CanvasGadget, Width & Height
#C2D_G	=	0						; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Zoomed width
#C2D_H	=	340	*	#C2D_Z	; Zoomed height

Procedure	C2D_Init()
	
	Protected	*Memory

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Brush / Move Mouse X & Y"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 10)	; update every 10ms

	;************************************************
	;- *** First initialize program here ***
	;************************************************

	*Memory	=	C2D::FileLoad("..\Data\Back\Cloud_Sky.png")
	C2D::GdipCatch(0, *Memory, MemorySize(*Memory))

	C2D::BrushInit(0, 0, 0, 0, #C2D_W, #C2D_H)
	
	FreeImage(0)

EndProcedure
Procedure	C2D_Update()

	;***********************************************************
	;- *** Update here -> NO! StartDrawing() / StopDrawing() ***
	;***********************************************************
	
	Protected	x.f	=	WindowMouseX(0)
	Protected	y.f	=	WindowMouseY(0)
	
	If	x	>	0
		x	=	(#C2D_W	/	2	-	(#C2D_W - x))	*	0.02
	Else
		x	=	0
	EndIf

	If	y	>	0
		y	=	(#C2D_H	/	2	-	(#C2D_H - y))	*	0.02
	Else
		y	=	0
	EndIf
	
	If	Abs(x)	>	0.1	Or	Abs(y)	>	0.1
		C2D::BrushMove(0, -x, -y)
	EndIf

	C2D::BrushDraw(0)

EndProcedure

C2D_Init()	; Must always called before Update

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
			Select	EventwParam()
				Case	#VK_ESCAPE	:	Break
			EndSelect

	EndSelect
ForEver

C2D::Free()
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; Folding = 0
; Executable = ..\Executables\C2D_Brush_Move_x86.exe
; DisableDebugger
; CompileSourceDirectory