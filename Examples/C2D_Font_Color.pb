; C2D::Font / Color + Sinus + SCAL - Purebasic v5.72 (x86-64)

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

IncludePath	"..\Include\"

DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"
	
	#IsC2D_Music		=	#XMU_SCA	; PT2

	#IsC2D_Bitmap		=	1
	#IsC2D_BitmapColor=	1
	#IsC2D_File			=	1
	#IsC2D_FontColor	=	1
	#IsC2D_GdiPlus		=	1
	#IsC2D_Text			=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_Clear		=	2

	XIncludeFile	"C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Procedure	C2D_Init()

	Protected	i, t0$, t1$, t2$

	Global	y0, y1, y2

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Font / Color + Sinus + SCAL"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 10)

	; Random chars to colorize
	For	i	=	C2D::#MIN_CHR + 1	To	C2D::#MAX_CHR
		If	Random(1)	:	t0$	+	Chr(i)	:	EndIf
		If	Random(1)	:	t1$	+	Chr(i)	:	EndIf
		If	Random(1)	:	t2$	+	Chr(i)	:	EndIf
	Next

	; Fonts
	C2D::BitmapInit(0, @"..\Data\Font\PNG\32x30_Font0.png", 0, #Black)
	C2D::FontInit(0, C2D::BitmapImage(0), 3)	:	C2D::FontScale(0, 8.0 * #C2D_Z)	:	C2D::FontColor(0, #Cyan,	t0$)
	C2D::FontInit(1, C2D::BitmapImage(0), 1)	:	C2D::FontScale(1, 1.0 * #C2D_Z)	:	C2D::FontColor(1, #Red,		t1$)	:	C2D::FontShadow(1, 5, 5, 144)
	C2D::FontInit(2, C2D::BitmapImage(0), 1)	:	C2D::FontScale(2, 1.0 * #C2D_Z)	:	C2D::FontColor(2, #Green,	t2$)	:	C2D::FontShadow(2, 5, 5, 144)

	; Back SinusText
	C2D::FontSelect(0)
	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, 0.8 * #C2D_Z)
	C2D::ScrollTextSinus(0, 48 * #C2D_Z, 8.0 / #C2D_Z, 80 * #C2D_Z)

	; Title
	C2D::FontSelect(1)	:	C2D::TextInit(1, @"CANVAS 2D")

	; Scroller
	C2D::FontSelect(2)	:	C2D::ScrollTextInit(2, ?t_text)
	C2D::ScrollTextSpeed(2, 1.0 * #C2D_Z)

	y0	=	(#C2D_H - C2D::ScrollTextH(0)) * 0.5
	y1	=	#C2D_H  * 0.5 - C2D::TextH(1)  * 2
	y2	=	#C2D_H  * 0.5

	; Play music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicInit(#SCAL_PATH$)	; set default-path to SCAL_(x86-64).dll
		C2D::MusicPlay(@"..\Data\Music\IT\Erko - Chip Tune 02.mod")
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	C2D::ScrollTextDraw(0, y0, 112)
	C2D::TextDraw(1, 0, y1, 255, C2D::#C2F_CenterX)
	C2D::ScrollTextDraw(2, y2)

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

DataSection
	t_text:
	Data.s	"EXAMPLE USING THE TINY C2D MODULE V" + MA_XC2D() + " CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + ") ... "	+
	      	"KEWL IMPULSE-TRACKER SONG BY ERKO - CHIP TUNE 02.IT ... "	+
	      	"CONVERTED TO PROTRACKER 2.3D COZ SIMPLY NEED A STABILE PLAYABLE FORMAT FOR SCAL.DLL"
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = i
; Executable = ..\Executables\C2D_Font_Color_x86.exe
; DisableDebugger
; CompileSourceDirectory