; C2D::Stars2D / Simple - Purebasic v5.70

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Stars2D	=	1
	#IsC2D_Bitmap	=	0
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Stars2D / Simple"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G)

C2D::Stars2DInit(300 * #C2D_Z, 2, 0, 0, #C2D_W, #C2D_H, 2.5)

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D::Stars2DDraw()
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
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = -
; Executable = ..\Executables\C2D_Stars2D_Simple_x86.exe
; DisableDebugger
; CompileSourceDirectory