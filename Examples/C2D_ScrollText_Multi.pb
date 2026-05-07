; C2D::ScrollText - Multi / PB 5.72 (x86)

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x86
		XIncludeFile	"..\Include\C2D_Types.pbi"
		#IsC2D_Music	=	#XMU_SCA	;YMP
	CompilerElse	; Ooops, error - can't play ym in x64!
		#IsC2D_Guru		=	1
	CompilerEndIf
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_Topaz		=	1	; default topaz-rawfont
	#IsC2D_ScrollText	=	2
	#IsC2D_Clear		=	2
	XIncludeFile	"..\Include\C2D_Defaults.pbi"	; adapt path of include
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"	; adapt path of include

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#T_NUM	=	8 + 3
#Y_GAP	=	2

Procedure	C2D_Init()

	Protected	i, n, t

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("ScrollText / Multi + SCAL"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 6)

	For	i	=	0	To	#T_NUM

		C2D::FontRawInit(i)
		C2D::FontZoom(i, Random(80,8), (#C2D_H - #T_NUM * #Y_GAP) / (#T_NUM + 1))
		C2D::FontGap(i, 0, #Y_GAP)

		C2D::FontCopper(i, PeekI(?c_t + i % 3 * SizeOf(Integer)))

		t$	=	PeekS(?t_t)	; 96 chars

		n	=	Random(16)	+	3		:	t	=	Random(2000)	+	1000	:	t$	=	InsertString(t$, "{2," + Str(t) + "}", n)	; 104
		n	=	Random(40)	+	n + 9	:	t	=	Random(2000)	+	1000	:	t$	=	InsertString(t$, "{2," + Str(t) + "}", n)	; 112
		n	=	Random(40)	+	n + 9	:	t	=	Random(2000)	+	1000	:	t$	=	InsertString(t$, "{2," + Str(t) + "}", n)	; 120

		t$	=	ReplaceString(t$, "#", MA_XC2D(),0, 1, 1)
		t$	=	ReplaceString(t$, "#", MA_XPB(),	0, 1, 1)
		t$	=	ReplaceString(t$, "#", MA_XOS(),	0, 1)

		;C2D::FontSelect(i)
		C2D::ScrollTextInit(i, @t$)
		C2D::ScrollTextSpeed(i,	0.1 * Random(25, 8))

	Next
	
	; Play music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicInit(#SCAL_PATH$)	; set default-path to SCAL_(x86-64).dll
		C2D::MusicPlay(@"..\Data\Music\YM\Kentron - ARTvision music.ym")
	CompilerElseIf	IsC2D::#IsC2D_Guru
		t$	=	"|SOFTWARE FAILURE.	PRESS LEFT MOUSE BUTTON TO CONTINUE.|"	+
		  	 	"|MUSICFORMAT *.YM NOT SUPPORTED IN X64|"
		C2D::GuruInit(@t$)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Protected	i, y = #Y_GAP + #C2D_Z

	For	i	=	0	To	#T_NUM
		C2D::ScrollTextDraw(i, y)	:	y	+	C2D::ScrollTextH(i)
	Next

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

		CompilerIf	IsC2D::#IsC2D_Guru
		Case	#WM_LBUTTONDOWN
			C2D::GuruFree()
		CompilerEndIf

	EndSelect
ForEver

C2D::Free()

DataSection
	
	c_t:	:	Data.i	?c_r, ?c_b, ?c_g	; Copper-Table
	
	c_r:	:	Data.l	4,	$FF000000|#Red,	$FF000000|#Yellow,	$FF000000|#Yellow,	$FF000000|#Red
	c_b:	:	Data.l	4,	$FF000000|#Blue,	$FF000000|#Cyan,		$FF000000|#White,		$FF000000|#Magenta
	c_g:	:	Data.l	4,	$30000000|#White,	$FF000000|#White,		$FF000000|#Green,		$30000000|#Green

	t_t:	:	Data.s	"EXAMPLE USING THE TINY C2D MODULE V# CODED IN PUREBASIC V# (#) ... VISIT:TESTAWARE.WORDPRESS.COM"
	
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = G+
; Executable = ..\Executables\C2D_ScrollText_Multi_x86.exe
; CompileSourceDirectory