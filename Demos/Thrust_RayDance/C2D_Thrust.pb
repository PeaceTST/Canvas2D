; C2D::Thrust - Ray Dance v1.0 - 13.12.1991
; Purebasic v5.72 (x86) / 17.08.2021

; http://janeway.exotica.org.uk/release.php?id=19631

EnableExplicit

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"

	#IsC2D_Music		=	#XMU_TPT
	#IsC2D_GdiPlus		=	2
	#IsC2D_Copper		=	1
	#IsC2D_Brush		=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Clear		=	0
	#IsC2D_FlatBar		=	1
	#IsC2D_ScrollText	=	2	; 2 -> {Code,Param.f}
	#IsC2D_FontColor	=	1
	#IsC2D_Text			=	1

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"
;***************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2
CompilerEndIf

#C2D_G	=	0	; #Gadget
#C2D_W	=	320	*	#C2D_Z
#C2D_H	=	240	*	#C2D_Z

#SQUARE_W	=	32	*	#C2D_Z
#SQUARE_H	=	22	*	#C2D_Z

Procedure	Blit_Copper(x, y, Pen, Back)

	If	Back	<>	$FF0000FF
		ProcedureReturn	Back
	EndIf

	ProcedureReturn	Pen

EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Thrust / Ray Dance v1.0 - 1991"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)	; update every 8ms

	; initialize checkboardbrush
	CreateImage(0, 2 * #SQUARE_W, 2 * #SQUARE_H)
	StartDrawing(ImageOutput(0))
	Box(0, 0, #SQUARE_W, #SQUARE_H, #Red)
	Box(#SQUARE_W, #SQUARE_H, #SQUARE_W, #SQUARE_H, #Red)
	StopDrawing()
	C2D::BrushInit(0, 0, 0, 112 * #C2D_Z, #C2D_W, 4 * #SQUARE_H)

	; scroller back
	C2D::FlatBarInit(0, 22 * #C2D_Z, $888888, #C2D_Z)

	; message
	C2D::GdipCatch(0, ?i_mini, ?e_mini)
	C2D::FontInit(1, 0)
	C2D::FontScale(1, #C2D_Z)
	C2D::TextInit(1, ?t_message)

	; title
	C2D::GdipCatch(0, ?i_font, ?e_font)
	C2D::FontInit(0, 0)
	C2D::FontColor(0, #Red)
	C2D::FontScale(0, #C2D_Z)
	C2D::TextInit(0, ?t_title)

	; fast background
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0,  16 * #C2D_Z, #C2D_W, 92 * #C2D_Z, $660000)
	Box(0,  16 * #C2D_Z, #C2D_W, #C2D_Z)
	Box(0, 110 * #C2D_Z - #C2D_Z, #C2D_W, #C2D_Z)
	C2D::FlatBarDraw(0, 202 * #C2D_Z)
	C2D::TextDraw(0, 0, 23 * #C2D_Z, 255, C2D::#C2F_CenterX)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()

	; scroller
	C2D::FontColor(0, #Black)
	C2D::ScrollTextInit(0, ?t_scroll)
	C2D::ScrollTextSpeed(0, 2 * #C2D_Z)

	; copper
	C2D::CopperInit(0,  5 * C2D::FontH(0),	?c_text)		; title
	C2D::CopperInit(1, 32 * #SQUARE_H,		?c_check)	; checkboard
	C2D::CopperBlitProc(@Blit_Copper())

	; cleanups
	C2D::FlatBarFree(0)
	C2D::TextFree(0)
	FreeImage(0)

	; play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_mus, ?e_mus)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	C2D::BufferBackDraw()

	C2D::BrushMove(0, 0, -0.40 * #C2D_Z)
	C2D::BrushDraw(0)

	C2D::TextDraw(1, (#C2D_W - 27 * 8 * #C2D_Z) * 0.5, 134 * #C2D_Z)

	C2D::ScrollTextDraw(0, 205 * #C2D_Z)

	C2D::CopperBlit(0,  23 * #C2D_Z, -0.40 * #C2D_Z)
	C2D::CopperBlit(1, 112 * #C2D_Z, -0.44 * #C2D_Z)

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE
					Break
			EndSelect

		Default
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
			
	EndSelect
ForEver

C2D::Free()

DataSection

	CompilerIf	IsC2D::#IsC2D_Music
		m_mus:	:	IncludeBinary	"mus\mod.mod"	:	e_mus:
	CompilerEndIf

	i_font:	:	IncludeBinary	"gfx\Thrust_Font.png"	:	e_font:
	i_mini:	:	IncludeBinary	"gfx\Thrust_Mini.png"	:	e_mini:

	t_title:		:	Data.s	"    ##THRUST##     ||     PRESENTS      ||RAY DANCE VER. 1.0"
	t_message:	:	Data.s	"BACK IN BUSINESS -- IN 1991||      +1-416-819-9187"
	t_scroll:	:	Data.s	"{5}#THRUST#{5}{2,2000}{3}PRESENTS:{3,30}RAY DANCE VERSION 1.0{3}FOR CONTACT CALL:{3}{5}+1-416-819-9187{5}{2,2000}{3}GREETINGS TO: #CRYSTAL#   #SKID ROW#   #JUNIOR(PARADISE)#   #VISIONARY(PARADISE)#  #STINGRAY(TERRORDOME)#{3}#C2D RETRO BY PEACE#"

	c_text:
	Data.l	7,
	      	$FF000000|#Red,
	      	$FF000000|#Yellow,
	      	$FF000000|#Green,
	      	$FF000000|#Cyan,
	      	$FF000000|#Blue,
	      	$FF000000|#Black,
	      	$FF000000|#Red

	c_check:
	Data.l	4,
	      	$FF000000|#Red,
	      	$FF000000|#Magenta,
	      	$FF000000|#Blue,
	      	$FF000000|#Red

EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = A+
; Executable = C2D_Thrust_x86.exe
; DisableDebugger
; CompileSourceDirectory