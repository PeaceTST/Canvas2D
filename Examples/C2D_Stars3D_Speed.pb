; C2D::Stars3D / Speed - Purebasic v5.70
; AV False/True if debugger is enabled?

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Stars3D	=	1
	#IsC2D_Bitmap	=	0
	#IsC2D_Clear	=	0	; try 0, 1, 2 to see fx
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Define	x.f, y.f, i

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Stars3D / Speed - Press Spacebar"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 8)

C2D::Stars3DInit(300 * #C2D_Z, Random(7), 0, 0, #C2D_W, #C2D_H, 4.0)
C2D::Stars3DSpread(1000)

Repeat
	Select	WindowEvent()
		Case	#Null
			
			If	C2D::Start()
				
				Box(0, 0, #C2D_W, #C2D_H, $0E000000)	; notice alpha($0E) for speedstars
				
				If	i	; <- try spacebar (0 or 1)
					x	=	MA_GCos(C2D::C2D\Time * 0.081) * #C2D_W * 0.5
					y	=	MA_GSin(C2D::C2D\Time * 0.053) * #C2D_H * 0.5
					C2D::Stars3DDraw(x, y)
				Else
					C2D::Stars3DDraw()
				EndIf

				C2D::Stop()
				
			EndIf
			
		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_SPACE	:	i!1
				Case	#VK_ESCAPE	:	Break
			EndSelect
	EndSelect
ForEver

C2D::Free()
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = -
; Executable = ..\Executables\C2D_Stars3D_Speed_x86.exe
; DisableDebugger
; CompileSourceDirectory