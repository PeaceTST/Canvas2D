; C2D::StarsR3D / Simple - Purebasic v5.72

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_StarsR3D	=	1
	#IsC2D_Clear		=	2
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#S_W	=	0	*	#C2D_Z
#S_H	=	40	*	#C2D_Z

Define	Key

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("StarsR3D / Simple - Press Spacebar"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 10)

C2D::StarsR3DInit(400 * #C2D_Z, #S_W, #S_H, #C2D_W - #S_W * 2, #C2D_H - #S_H * 2, 3)

Repeat
	Select	WindowEvent()
		Case	#Null
			
			If	C2D::Start()
				
				If	Key	; <- pressed spacebar (0 or 1)
					C2D::StarsR3DDraw(MA_GCos(C2D::C2D\Time * 0.091) * 18 * #C2D_Z, MA_GCos(C2D::C2D\Time * 0.083) * 8 * #C2D_Z, MA_GCos(C2D::C2D\Time * 0.111) * 0.1)
				Else
					C2D::StarsR3DDraw(0, 0, MA_GCos(C2D::C2D\Time * 0.111) * 0.1)
					;C2D::StarsR3DDraw(16, 0, 0)
					;C2D::StarsR3DDraw(0, 16, 0)
				EndIf

				C2D::Stop()
				
			EndIf
			
		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_SPACE	:	Key!1
				Case	#VK_ESCAPE	:	Break
			EndSelect
	EndSelect
ForEver

C2D::Free()
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = -
; Executable = ..\Executables\C2D_StarsR3D_Simple_x86.exe
; DisableDebugger
; CompileSourceDirectory