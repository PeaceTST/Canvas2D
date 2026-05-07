; C2D::Copper / Move - Purebasic v5.72 (x86-64)

EnableExplicit

;***************************************************
; *** IsC2D the MUST Init-Module, always needed! ***
;***************************************************
IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"

	#IsC2D_Music	=	#XMU_SCA	; music?
	
	#IsC2D_Mode		=	0
	#IsC2D_Clear	=	0
	#IsC2D_Copper	=	1
	#IsC2D_Buffer	=	1
	
	#IsC2D_FontRaw		=	1
	#IsC2D_Topaz		=	1	; default topaz.font
	#IsC2D_ScrollText	=	2
	
	XIncludeFile	"C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;***************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1
CompilerEndIf

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Zoomed width
#C2D_H	=	340	*	#C2D_Z	; Zoomed height

#COP_N	=	6	; Copperbar-Number
#COP_H	=	(#C2D_H / ((#COP_N + 1) * 2)) | 1

#FONT_H	=	20 * #C2D_Z

Procedure	_Copperize()

	Protected	*Memory, i

	Static	c	=	-1

	If	c	<	#Null
		c	=	GetTickCount_()	&	$FF	; abs(rnd) - 0.5KB smaller as Random(6)
	EndIf

	c	=	(c	+	1)	%	7

	Select	c
		Case	1	:	*Memory	=	?c_blue
		Case	2	:	*Memory	=	?c_white
		Case	3	:	*Memory	=	?c_red
		Case	4	:	*Memory	=	?c_cyan
		Case	5	:	*Memory	=	?c_yellow
		Case	6	:	*Memory	=	?c_magenta
		Default	:	*Memory	=	?c_green
	EndSelect

	For	i	=	0	To #COP_N
		C2D::CopperInit(i, #COP_H * 2, *Memory)
		C2D::RS_Copper()\y	=	-(i * 4.5 * #C2D_Z)
	Next

EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Copper / Move + Mirror + Scroller - Press Spacebar"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)

	C2D::FontRawInit(0)
	C2D::FontZoom(0, #FONT_H * 0.8, #FONT_H)
	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, 1.25 * #C2D_Z)

	_Copperize()

	CompilerIf	IsC2D::#IsC2D_Music

		Protected	Music$	=	"..\Data\Music\MOD\Hollywood - Trance.mod"

		CompilerSelect	IsC2D::#IsC2D_Music

			CompilerCase	IsC2D::#XMU_AMP
				If	C2D::MusicInit()			; <- Set path to AmpMaster or default -> C:\Users\Public\Documents\AmpMaster\
					C2D::MusicPlay(@Music$)	; <- Ptr to filename
				EndIf

			CompilerCase	IsC2D::#XMU_SCA
				C2D::MusicInit("..\Tools\SCAL\")	; <- Set default-path to scal_x86/x64.dll
				C2D::MusicPlay(@Music$)

			CompilerDefault
				C2D::MusicPlay(@Music$, 0, 0)

		CompilerEndSelect

	CompilerEndIf

EndProcedure
Procedure	C2D_Update()
	
	Protected	i

	For	i	=	0	To	#COP_N
		C2D::CopperMoveDraw(i, i * #COP_H, -0.5 * #C2D_Z)
	Next
	
	C2D::BufferMirror(0, #C2D_H / 2, #C2D_W, #C2D_H / 2 - 1)
	
	C2D::ScrollTextDraw(0, (#C2D_H - #FONT_H) * 0.5)

EndProcedure

C2D_Init()	; Must always called before Update

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE
					Break
				Case	#VK_SPACE
					_Copperize()
			EndSelect
		Case	#PB_Event_CloseWindow
			Break
	EndSelect
ForEver

C2D::Free()

DataSection	; Coppercolors (%7)
	c_blue:		:	Data.l	3,	$FF000000,	$FF004F4F|#Blue,		$FF000000
	c_green:		:	Data.l	3,	$FF000000,	$FF5F005F|#Green,		$FF000000
	c_red:		:	Data.l	3,	$FF000000,	$FF4F4F00|#Red,		$FF000000
	c_yellow:	:	Data.l	3,	$FF000000,	$FF000000|#Yellow,	$FF000000
	c_cyan:		:	Data.l	3,	$FF000000,	$FF000000|#Cyan,		$FF000000
	c_magenta:	:	Data.l	3,	$FF000000,	$FF005F00|#Magenta,	$FF000000
	c_white:		:	Data.l	3,	$FF000000,	$FF000000|#White,		$FF000000
	t_text:		:	Data.s	"COPPERMOVE EXAMPLE USING THE TINY C2D MODULE V" + MA_XC2D() + " CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + "){3,20}{5}SPACEBAR TO COLORIZE THE COPPER{5}{2,3000}"
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A+
; Executable = ..\Executables\C2D_Copper_Move_x86.exe
; DisableDebugger
; CompileSourceDirectory