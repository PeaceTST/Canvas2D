; C2D::Ball3D / Airplane - Purebasic v5.70

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Bitmap	=	0
	#IsC2D_Ball3D	=	1
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0		; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Ball3D / Airplane + DataSection"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 6, $FFB863)

C2D::Quality(#PB_Image_Smooth)

C2D::Ball3DInit(0, ?b3d_object, 20 * #C2D_Z)
C2D::Ball3DAngle(0, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))	; start with random 3D-position

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D::Ball3DRotate(0, MA_GSin(C2D::C2D\Time * 0.021), MA_GCos(C2D::C2D\Time * 0.033), MA_GCos(C2D::C2D\Time * 0.025))
				C2D::Ball3DDraw(0, 0, 0, 223, 32)
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
	b3d_object:
	Data.l	C2D::#ID_B3D0
	Data.l	70
	Data.b	0,-2,-2,-6, 0,0,0,0,  0,-1,-2,-6,0,0,0,0,  0,-2,-2,-5,0,0,0,0,  0,-1,-2,-5,0,0,0,0,  0,-2,-2,-4,0,0,0,0,  0,-1,-2,-4,0,0,0,0,  0,-2,-2,-3,0,0,0,0,  0,-1,-2,-3,0,0,0,0
	Data.b	0,-2,-2,-2, 0,0,0,0,  0,-1,-2,-2,0,0,0,0,  0,-2,-2,-1,0,0,0,0,  0,-1,-2,-1,6,0,0,0,  6,-4, 0,-1,5,5,0,0,  0,-2, 0,-1,0,0,0,0,  0,-1, 0,-1,0,0,0,0,  0, 0, 0,-1,8,0,0,0
	Data.b	0, 1, 0,-1, 8,0,0,0,  0, 2, 0,-1,8,0,0,0,  0,-3, 1,-1,0,0,0,0,  0,-2, 1,-1,5,0,0,0,  0,-1, 1,-1,5,0,0,0,  0, 0, 1,-1,5,0,0,0,  0, 1, 1,-1,5,0,0,0,  7,-2, 2,-1,0,0,0,0
	Data.b	0,-2,-2, 0,13,0,0,0,  0,-1,-2, 0,5,0,0,0,  6,-4,-1, 0,5,5,0,0,  1,-1,-1, 0,7,0,0,0,  0, 0,-1, 0,5,0,0,0,  0, 3,-1, 0,6,0,0,0,  0, 4,-1, 0,8,0,0,0,  7,-4, 0, 0,0,0,0,0
	Data.b	0,-3, 0, 0, 0,0,0,0,  7,-2, 0, 0,6,0,0,0,  4,-1, 0, 0,0,0,0,0,  0, 0, 0, 0,8,0,0,0,  0, 1, 0, 0,8,0,0,0,  0, 2, 0, 0,8,0,0,0,  0, 3, 0, 0,8,0,0,0,  0, 4, 0, 0,8,0,0,0
	Data.b	6,-4, 1, 0, 5,5,0,0,  0,-2, 1, 0,0,0,0,0,  0,-1, 1, 0,0,0,0,0,  0, 0, 1, 0,8,0,0,0,  0, 1, 1, 0,6,0,0,0,  7, 2, 1, 0,0,0,0,0,  0,-2,-2, 1,0,0,0,0,  0,-1,-2, 1,6,0,0,0
	Data.b	6,-4, 0, 1, 5,5,0,0,  0,-2, 0, 1,0,0,0,0,  0,-1, 0, 1,0,0,0,0,  0, 0, 0, 1,8,0,0,0,  0, 1, 0, 1,8,0,0,0,  0, 2, 0, 1,8,0,0,0,  0,-3, 1, 1,0,0,0,0,  0,-2, 1, 1,5,0,0,0
	Data.b	0,-1, 1, 1, 5,0,0,0,  0, 0, 1, 1,5,0,0,0,  0, 1, 1, 1,5,0,0,0,  7,-2, 2, 1,0,0,0,0,  0,-2,-2, 2,0,0,0,0,  0,-1,-2, 2,0,0,0,0,  0,-2,-2, 3,0,0,0,0,  0,-1,-2, 3,0,0,0,0
	Data.b	0,-2,-2, 4, 0,0,0,0,  0,-1,-2, 4,0,0,0,0,  0,-2,-2, 5,0,0,0,0,  0,-1,-2, 5,0,0,0,0,  0,-2,-2, 6,0,0,0,0,  0,-1,-2, 6,0,0,0,0
EndDataSection
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = 9
; Executable = ..\Executables\C2D_Ball3D_Airplane_x86.exe
; CompileSourceDirectory