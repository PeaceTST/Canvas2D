; C2D::Vision Factory - Kick Off - 27.06.1989
; Purebasic v6.30 (x86) / 17.04.2026
; Purebasic v5.72 (x86) / 25.10.2021

; http://janeway.exotica.org.uk/release.php?id=2481

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor (try 1)
CompilerEndIf

DeclareModule	IsC2D
	
	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictype #XMU_[Type]

	#IsC2D_Mode			=	0

	#IsC2D_Stars2D		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_Text			=	1
	#IsC2D_Copper		=	1
	#IsC2D_Buffer		=	1

	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_Clear		=	2	; fast canvasclear

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width (zoomed)
#C2D_H	=	240	*	#C2D_Z	; Height (zoomed)

#Orange	=	$008CFF

#COP_Y	=	40		*	#C2D_Z
#BLT_H	=	125	*	#C2D_Z
#SIN_H	=	54		*	#C2D_Z

#FNT_H	=	18	*	#C2D_Z	; sinus font height (bordered)

Procedure.l	Blit_Copper(x, y, PenColor.l, PaperColor.l)

	;ProcedureReturn	PenColor

	If	PaperColor	<>	$FF666666
		ProcedureReturn	PaperColor
	EndIf

	ProcedureReturn	PenColor

EndProcedure
Procedure.l	Sinus_Copper(x, y, PenColor.l, PaperColor.l)

	; only mirrored sinus-scoller (gray-color)
	If	PaperColor	<>	$FF666666	And	PaperColor	<>	$FF555555	And	PaperColor	<>	$FF888888
		ProcedureReturn	#Null
	EndIf

	; fading blue
	PenColor	=	((PaperColor & $00FF0000) >> 16 - (y - #COP_Y - #BLT_H - 40 * #C2D_Z)) - 26 * #C2D_Z

	If	PenColor	<=	#Null
		ProcedureReturn	#Null
	EndIf

	ProcedureReturn	(PenColor << 16)

EndProcedure

Procedure	VF_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Vision Factory - Kick Off - 1989"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 9)

	; create 2d-starfield
	C2D::Stars2DInit(140, #C2D_Z, 0, 10, #C2D_W, 170 * #C2D_Z, 2.5 * #C2D_Z)

	; custom CopperBlit, bug in pb 5.62?
	C2D::CopperInit(0, #BLT_H, ?c_blt)
	C2D::CopperBlitProc(@Blit_Copper())

	; text font
	C2D::GdipCatch(0, ?i_font, ?e_font)
	C2D::FontInit(0, 0)
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, 0, #C2D_Z)

	C2D::TextInit(0, ?t_text, C2D::#C2F_CenterX)

	; nitrobit logo
 	C2D::GdipCatch(0, ?i_logo, ?e_logo)
 	ResizeImage(0, ImageWidth(0) * #C2D_Z, ImageHeight(0) * #C2D_Z, #PB_Image_Raw)

 	; fast background ********************************************
 	StartDrawing(CanvasOutput(#C2D_G))
 	DrawImage(ImageID(0), #C2D_W - ImageWidth(0) - 25 * #C2D_Z, 0.65 * #C2D_H)
	C2D::TextDraw(0, 0, 0.39 * #C2D_H)
 	C2D::BufferBackGrab()
 	C2D::BufferClear()
 	StopDrawing()	; *********************************************

	; sinus font
	C2D::GdipCatch(0, ?i_border, ?e_border)
	C2D::FontInit(0, 0)
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, #C2D_Z)

	C2D::ScrollTextInit(0, ?t_sine)
	C2D::ScrollTextSpeed(0, 1.5 * #C2D_Z)

	; no longer needed
	FreeImage(0)
	C2D::TextFree(0)

EndProcedure
Procedure	VF_Update()

	; sinus-scroller (draw first)
	C2D::ScrollTextDraw(0, 0.39 * #C2D_H)
	C2D::BufferSinY(0, 0.39 * #C2D_H, #C2D_W, #FNT_H, #SIN_H, 0.18 / #C2D_Z * 6, 1.18 * 14, 0)	; flags=0 coz drawing after backdraw

	; clear / draw back (text)
	C2D::BufferBackDraw()

	; starfield
	C2D::Stars2DDraw()

	; sinus-scroller
	C2D::BufferSinDraw()

	; mirror as (blue) sinus-scoller only
	C2D::BufferMirror(0, #COP_Y + #BLT_H + #C2D_Z, #C2D_W, 70 * #C2D_Z)
	DrawingMode(#PB_2DDrawing_CustomFilter)
	CustomFilterCallback(@Sinus_Copper())
	Box(0, #COP_Y + #BLT_H + #C2D_Z, #C2D_W, 70 * #C2D_Z)

	; copper to sinus-scrolltext
	C2D::CopperBlit(0, #COP_Y)

EndProcedure

VF_Init()

Repeat
	Select	WindowEvent()
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
				Break
			EndIf
		Default
			If	C2D::Start()
				VF_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection

	i_logo:		:	IncludeBinary	"gfx\VF_Nitrobit.png"	:	e_logo:

	i_font:		:	IncludeBinary	"gfx\VF_Font.png"			:	e_font:
	i_border:	:	IncludeBinary	"gfx\VF_Border.png"		:	e_border:

	c_blt:
	Data.l	11,
	      	$FF000000|#Blue,
	      	$FF000000|#Cyan,
	      	$FF000000|#Green,
	      	$FF000000|#Yellow,
	      	$FF000000|#Orange,
	      	$FF000000|#Red,
	      	$FF000000|#Orange,
	      	$FF000000|#Yellow,
	      	$FF000000|#Green,
	      	$FF000000|#Cyan,
	      	$FF000000|#Blue

	t_text:
	Data.s	"VISION FACTORY|"	+
	      	"PRESENTS|"	+
	      	"KICK OFF"

	t_sine:
	Data.s	"PARTY CRACK NO.2 !!! RELEASED THE SAME DAY AS WE RELEASED MICRO PROSE SOCCER....       "	+
	      	"GREETINGS TO ALL OUR FRIENDS ESPECIALLY TO     "	+
	      	"BAMIGA SECTOR ONE (NOT THE AGNOSTIC) - ORACLE (THE CHAMELEON) - RED SECTOR - DEFJAM AND SPREADPOINT - PIRANHAS  AND ALL THE OTHERS....     "	+
	      	"FOR MODEM TRADING CALL OUR BBS AT 312-452-6511....               "	+
	      	"THAT'S ALL..... BYE !"	+	#TAB$	+	#TAB$	+	#TAB$	+	#TAB$	+	#TAB$	+	#TAB$	+	#TAB$	+
	      	"RETRO BY PEACE"

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A-
; Executable = C2D_KickOff_x86.exe
; DisableDebugger
; CompileSourceDirectory