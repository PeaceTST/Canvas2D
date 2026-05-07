; C2D::Copper / Loop - Purebasic v5.72 (x86-64)

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Copper	=	1
	#IsC2D_Clear	=	2
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#COP_H	=	80	*	#C2D_Z

Enumeration
	#ID_0
	#ID_1
	#ID_2
EndEnumeration

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Copper / Loop"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 8)

C2D::CopperInit(#ID_0,	#COP_H,					?c_red)
C2D::CopperInit(#ID_1,	#COP_H,					?c_blue)
C2D::CopperInit(#ID_2,	#C2D_H - #COP_H * 2,	?c_rainbow, C2D::#C2F_Horizontal)

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				s.f	=	MA_GCos(C2D::C2D\Time * 0.08)
				C2D::CopperMoveDraw(#ID_0,	0,						s *  1.5)
				C2D::CopperMoveDraw(#ID_2, #COP_H,				s *  3.0)
				C2D::CopperMoveDraw(#ID_1,	#C2D_H - #COP_H,	s * -1.5)
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
	c_red:		:	Data.l	3,	#Red,			$FF5F5F00|#Red,		#Red
	c_green:		:	Data.l	3,	#Green,		$FF5F005F|#Green,		#Green
	c_blue:		:	Data.l	3,	#Blue,		$FF005F5F|#Blue,		#Blue
	c_yellow:	:	Data.l	3,	#Yellow,		$FF000000|#Yellow,	#Yellow
	c_cyan:		:	Data.l	3,	#Cyan,		$FF000000|#Cyan,		#Cyan
	c_magenta:	:	Data.l	3,	#Magenta,	$FF005F00|#Magenta,	#Magenta
	c_white:		:	Data.l	3,	#White,		$FF000000|#White,		#White
	c_rainbow:	:	Data.l	7,	$FF000000|#Magenta, $FF000000|#Red, $FF000000|#Yellow, $FF000000|#Green, $FF000000|#Cyan, $FF000000|#Blue, $FF000000|#Magenta
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = 5
; Executable = ..\Executables\C2D_Copper_Loop.exe
; CompileSourceDirectory