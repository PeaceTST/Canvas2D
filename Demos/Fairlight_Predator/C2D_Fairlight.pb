; C2D::Fairlight - Predator Megatrainer - 1988
; Purebasic v5.72 - v6.04! (x86-64) / 14.08.2018

; https://csdb.dk/release/?id=32872

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musicformats #XMU_[Type]

	#IsC2D_Mode			=	0			; DrawingMode
	
	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
		#IsC2D_Music	=	#XMU_THX	; x86-64 (AHX)
	CompilerElse
		#IsC2D_Music	=	#XMU_SID	; x86 (original)
	CompilerEndIf

	#IsC2D_Bitmap		=	1
	#IsC2D_BitmapColor=	1
	#IsC2D_Copper		=	1
	#IsC2D_FontColor	=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_Text			=	1
	#IsC2D_Topaz		=	0

	#IsC2D_Clear		=	2

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"	; adapt path of include

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"	; adapt path of include

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth (zoomed)
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight (zoomed)

Enumeration	; Copper
	#C_R
	#C_G
	#C_B
	#C_T
EndEnumeration

Enumeration	; Text
	#T_0
	#T_1
	#T_2
	#T_3
EndEnumeration

Procedure.l	Blit_Copper(x, y, PenColor.l, PaperColor.l)
	If	PaperColor&$00FFFFFF
		ProcedureReturn	PenColor
	EndIf
EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Fairlight - Predator Megatrainer - 1988"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	; initialize c2d
	C2D::Init(#C2D_G, 10)

	; create coppers
	C2D::CopperInit(#C_G,21, ?c_green)	:	C2D::CopperScale(#C_G, #C2D_Z)
	C2D::CopperInit(#C_R, 9, ?c_red)		:	C2D::CopperScale(#C_R, #C2D_Z)
	C2D::CopperInit(#C_B, 9, ?c_blue)	:	C2D::CopperScale(#C_B, #C2D_Z)

	; copper for scroller
	C2D::CopperInit(#C_T, 7 * #C2D_Z, ?c_text, C2D::#C2F_Horizontal)
	C2D::CopperBlitProc(@Blit_Copper())

	; image for font
	C2D::BitmapInit(0, ?i_font, ?e_font, #Black)

	; create font from image for copperbars
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontColor(0, $FF000000)
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, 0, -#C2D_Z)

	; write texts on coppers
	C2D::CopperText(#C_R, @"PREDATOR - MEGATRAINER")
	C2D::CopperText(#C_B, @"CRACKED 25.02.88 BY STRIDER")

	; create font for subtitle, info & scroller
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontScale(0, #C2D_Z)

	; create messages
	C2D::TextInit(#T_0, @"...THE HOME OF THE REAL CRACKERS", C2D::#C2F_CenterX)
	C2D::TextInit(#T_1, @"PRESENTS:", C2D::#C2F_CenterX)
	C2D::TextInit(#T_2, @"AHH, WHAT A COOL COMMIE-KILLER GAME...", C2D::#C2F_CenterX)

	; create scroller
	C2D::ScrollTextInit(#T_3, ?t_text)
	C2D::ScrollTextSpeed(#T_3, 0.5 * #C2D_Z)

	; create logo & resize by zoom
	C2D::BitmapInit(0, ?i_logo, ?e_logo, #Black)
	C2D::BitmapScale(0, #C2D_Z)

	; at last play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Static	y_alt.f

	Protected.f	y	=	(C2D::BitmapH(0) - C2D::CopperH(#C_G))	* 0.5	+
	         	   	 	MA_GSin(C2D::C2D\Time) * (C2D::BitmapH(0) + 4.5 * #C2D_Z)

	If	y	<=	y_alt
		C2D::CopperDraw(#C_G, 50 * #C2D_Z + y)
	EndIf

	; draw logo + subtitle
	C2D::BitmapDraw(0, 0, 42 * #C2D_Z)
	C2D::TextDraw(#T_0, 0, 82  * #C2D_Z)

	If	y	>=	y_alt
		C2D::CopperDraw(#C_G, 50 * #C2D_Z + y)
	EndIf

	y_alt	=	y

	C2D::TextDraw(#T_1, 0, 122 * #C2D_Z)

	C2D::CopperDraw(#C_R, 137 * #C2D_Z)
	C2D::CopperDraw(#C_B, 153 * #C2D_Z)

	C2D::TextDraw(#T_2, 0, 202 * #C2D_Z)

	; scrolltext + copper
	C2D::ScrollTextDraw(#T_3, 178 * #C2D_Z)
	C2D::CopperBlit(#C_T, 178 * #C2D_Z, -3.0 * #C2D_Z)

EndProcedure

C2D_Init()

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
				C2D_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection

	i_logo:	:	IncludeBinary	"gfx\Fairlight_Logo.bmp"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\Fairlight_Font.bmp"	:	e_font:

	m_music:
	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
		IncludeBinary	"mus\FLT - CRaCKTRo.thx"
	CompilerElse
		IncludeBinary	"mus\Fred - Fairlight Crack Intro.psid"
	CompilerEndIf
	e_music:

	; copper-colors
	c_green:	:	Data.l	21,
	        	 	      	$FF41A968,$FF41A968,$FF88EAAC,$FF41A968,$FF88EAAC,$FF88EAAC,$FF88EAAC,$FFFFFFFF,$FF88EAAC,
	        	 	      	$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,
	        	 	      	$FF88EAAC,$FFFFFFFF,$FF88EAAC,$FF88EAAC,$FF88EAAC,$FF41A968,$FF88EAAC,$FF41A968,$FF41A968

	c_red:	:	Data.l	9,
	      	 	      	$FF363F8A,$FF6D77BC,$FF6D77BC,
	      	 	      	$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,
	      	 	      	$FF6D77BC,$FF6D77BC,$FF363F8A

	c_blue:	:	Data.l	9,
	       	 	      	$FFA2313E,$FFDA707C,$FFDA707C,
	       	 	      	$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,
	       	 	      	$FFDA707C,$FFDA707C,$FFA2313E

	c_text:	:	Data.l	12,
	       	 	      	$FFFFFFFF,$FF959595,$FF444444,
	       	 	      	$FF444444,$FF959595,$FFFFFFFF,
	       	 	      	$FFFFFFFF,$FF959595,$FF444444,
	       	 	      	$FF444444,$FF959595,$FFFFFFFF

	t_text:	:	Data.s	"ANOTHER MASTERPIECE BY STRIDER...	"	+
	       	 	      	"THIS IS THE 'FAST' VERSION... "			+
	       	 	      	"WAIT FOR THE SHORT ONE...	"				+
	       	 	      	"TODAYS CHARTS : FUSION  F.A.C  PAPILLONS  TRIAD  IKARI  HOTLINE  T.W.G.  ACE  DOMINATORS  BEASTIES  T.L.C.  C.F.R.  C64CG  T.L.I.  1001 CREW			"	+
	       	 	      	"USA CHARTS : FBR  INC  ESI  RAD  ABYSS  PE  TAV  TIC  ATC  NFI			"			+
	       	 	      	"NOTE FOR ALL COMMIES : NEVER TRY TO ESCAPE USA....YOU'LL ONLY DIE TIRED...	"	+
	       	 	      	"OTHER COMING CRACKS ARE : IKARI WARRIORS & IO	"	+
	       	 	      	"WANTED : FAKE ID-CARD  1670  TAPES	"					+
	       	 	      	"CAN YOU DELIVER??	SLATES"
EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = Aw
; Executable = C2D_Fairlight_x86.exe
; DisableDebugger
; CompileSourceDirectory