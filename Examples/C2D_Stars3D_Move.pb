; C2D::Stars3D Move - Purebasic v5.70

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Bitmap	=	0
	#IsC2D_File		=	1
	#IsC2D_GdiPlus	=	2
	#IsC2D_Stars3D	=	1
	#IsC2D_Clear	=	2	; fast clearcanvas
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Define	x.f, y.f, *Memory

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Stars3D / Move"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G)

*Memory	=	C2D::FileLoad("..\Data\Ball\Pearl\" + Str(Random(7)) + ".png")

C2D::GdipCatch(0, *Memory, MemorySize(*Memory))

C2D::Stars3DInit(300 * #C2D_Z, 12 * #C2D_Z, 0, 0, #C2D_W, #C2D_H, 1.8, 0)
C2D::Stars3DSpread(2500)

FreeImage(0)

Repeat
	Select	WindowEvent()

		Case	#Null
			
			If	C2D::Start()

				x	=	Cos(C2D::C2D\Time * 0.0002) * #C2D_W * 0.5
				y	=	Sin(C2D::C2D\Time * 0.0002) * #C2D_H * 0.5

				C2D::Stars3DDraw(x, y)

				x	+	#C2D_W * 0.5
				y	+	#C2D_H * 0.5

				LineXY(x - 8, y, x + 8, y)
				LineXY(x, y - 8, x, y + 8)

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
; Executable = ..\Executables\C2D_Stars3D_Move_x86.exe
; CompileSourceDirectory