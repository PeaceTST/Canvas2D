; C2D::Legend - A Small Intro - 26.09.1992
; Purebasic v5.72 (x86-64) / 31.03.2020

; http://janeway.exotica.org.uk/release.php?id=18053

;*******************************************************************
; *** IsC2D the Init-Module, always needed! ************************
;*******************************************************************
IncludePath	"..\..\Include\"	; adapt path of \C2D\Include

DeclareModule	IsC2D	; FX-Switches

	XIncludeFile	"C2D_Types.pbi"	; Music, Gui, XUnPack predefined #Types
	
	#IsC2D_Mode			=	0
	#IsC2D_Clear		=	0

	#IsC2D_Music		=	#XMU_TPT ; x86-64 TinyProTracker 2.3D
	#IsC2D_Bitmap		=	1
	#IsC2D_FontColor	=	1	; TextShadow
	#IsC2D_Buffer		=	1
	#IsC2D_PageText	=	1
	#IsC2D_Copper		=	1
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_Checker		=	2	; 2 -> draw ColorB in Backbuffer (faster)

	XIncludeFile	"C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;*******************************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2
CompilerEndIf

; CanvasGadget
#C2D_G	=	0						; #Gadget
#C2D_W	=	320	*	#C2D_Z	; Zoomed width
#C2D_H	=	240	*	#C2D_Z	; Zoomed height

#Y_TOP	=	90		*	#C2D_Z
#Y_END	=	224	*	#C2D_Z
#H_CHK	=	90		*	#C2D_Z

Procedure	Legend_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Legend - A Small Intro - 1992"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)	; update every 8ms

	; create big copper-font for message
	C2D::BitmapInit(0, ?i_font, ?e_font)
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontShadow(0, 2, 2)
	C2D::FontScale(0, #C2D_Z)

	; create message text + fx with font 0
	C2D::PageTextInit(?t_text, 0, #Y_TOP + 12 * #C2D_Z, #C2D_W, 6 * 17 * #C2D_Z, C2D::#C2F_Center)
	C2D::PageTextEffect(1, C2D::#PFX_Random, 6, 24)
	C2D::PageTextEffect(0, C2D::#PFX_Random, 6, 24)
	;C2D::PageTextColor($8F00FF00)
	;C2D::PageTextID(10)
	
	C2D::BitmapInit(0, ?i_logo, ?e_logo)
	C2D::BitmapScale(0, #C2D_Z)

	; create backbuffer to clear & update background
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, #Y_TOP, #C2D_W, #Y_END - #Y_TOP, $FF440000)	; Sky
	Box(0, #Y_END - #H_CHK, #C2D_W, #H_CHK, $FFCC0000)	; Checker ColorB
	FrontColor($FFFFFFFF)
	Box(0, #Y_TOP,	#C2D_W, #C2D_Z)	; Border Top
	Box(0, #Y_END,	#C2D_W, #C2D_Z)	; Border Bottom
	C2D::BitmapDraw(0, 0, 0, 255, C2D::#C2F_CenterX)
	C2D::BufferBackGrab()	; Grab for update background
	C2D::BufferClear()
	StopDrawing()
	
	C2D::BitmapFree(0)
	
	; checkboard
	C2D::CheckerInit(#Y_END - #H_CHK, #H_CHK, 96 * #C2D_Z, 5 + #C2D_Z)
	C2D::CheckerColor($FFFFBBBB)
	
	; fog
	C2D::CopperInit(0, #H_CHK / 4, ?c_fog)

	;music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	Legend_Update()

	C2D::BufferBackDraw()
	
	C2D::CheckerDraw(6.7 * MA_GSin(C2D::C2D\Time * 0.23), 3.3 * MA_GCos(C2D::C2D\Time * 0.81))
	C2D::CopperDraw(0, #Y_END - #H_CHK)
	
	C2D::PageTextDraw(#C2D_Z)
	
EndProcedure

Legend_Init()	; Must always called before Update

Repeat
	Select	WindowEvent()
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE	:	Break
			EndSelect
		Default
			If	C2D::Start()
				Legend_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection
	
	IncludePath	".\"

	CompilerIf	IsC2D::#IsC2D_Music
		m_music:	:	IncludeBinary	"mus\wandering mind.mod"	:	e_music:
	CompilerEndIf
	
	i_logo:	:	IncludeBinary	"gfx\Legend_Logo.png"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\Legend_Font.png"	:	e_font:

	c_fog:	:	Data.l	2,	$FF440000, $00000000
	
	t_text:	; message text
	Data.s	"LEGEND SWEDEN||"		+
	      	"THE WILL OF GOD -92-||"	+
	      	"BRINGS YA~"	+
	      	"A SMALL INTRO|||~"	+
	      	"CODING BY:|"	+
	      	"DISSO & SHADE|"	+
	      	"GFX BY:|"	+
	      	"SCARLOC & TOAST|"	+
	      	"MUSIC BY:|"	+
	      	"DIRK~"	+
	      	"CONTACT -L- SWE|"	+
	      	"AT|"	+
	      	"HURRICANE/LEGEND|"	+
	      	"NORRANGS VAGEN 68|"	+
	      	"14143 HUDDINGE|"	+
	      	"SWEDEN....~"	+
	      	"OR CALL OUR BOARDS||"	+
	      	"FRIKHANDLE BBS|"	+
	      	"+31-188-015-410|"	+
	      	"SYSOP:BABYFACE|"	+
	      	"LEGEND WHQ~"	+
	      	"DREAMPARK|"	+
	      	"+41-618-800-26|"	+
	      	"SYSOP:SPIDER|"	+
	      	"LEGEND EHQ~"	+
	      	"ICEPALACE|"	+
	      	"+46-427-070-2|"	+
	      	"SYSOP:XSTAZ|"	+
	      	"LEGEND SCAN.HQ~"+
	      	"A KIND OF MAGIC|"	+
	      	"+44-582-476-923|"	+
	      	"SYSOP:REFLEX|"	+
	      	"LEGEND UK HQ~"	+
	      	"EURO BBS|"	+
	      	"+49-713-843-70|"	+
	      	"SYSOP:FLASHLIGHT|"	+
	      	"LEGEND GHQ~"	+
	      	"SWEDEN MEMBERS|"	+
	      	"ARE||"	+
	      	"XSTAZ - VIRUS - MAD|"	+
	      	"TOAST - SHAPECHANGER|"	+
	      	"CEDRIC - DIRK~"	+
	      	"SHADE - DISSO|"	+
	      	"HURRICANE - SCARLOC|"	+
	      	"CALYPSO - YORAK|"	+
	      	"KODAK~"	+
	      	"SOME GREETINGS GOES|"	+
	      	"TO|"	+
	      	"2000 AD - CRYSTAL|"	+
	      	"THRILL KILL KULT|"	+
	      	"SKID ROW - NEMESIS|"	+
	      	"ALPHA FLIGHT - TRSI~"	+
	      	"FUSION - ACCESSION|||~"	+
	      	"KEFRENS - DYTEC|"	+
	      	"DIAMONDS & RUST|"	+
	      	"SILENTS - SUPPLEX|"	+
	      	"SCOOPEX - ANARCHY|"	+
	      	"AND TO THE REST OF|"	+
	      	"THE SCENE......~"	+
	      	"SEE U IN A NEXT||"	+
	      	"LEGEND -SWE-|"	+
	      	"PRODUCTION~"	+
	      	"THE WILL OF GOD -92-|||~"	+
	      	"      ---          |"	+
	      	"      ---          |"	+
	      	"---   ---       ---|"	+
	      	"---   ---       ---|"	+
	      	"      -------      |"	+
	      	"      -------      ~"	+
	      	"~"	+
	      	"C2D RETRO BY PEACE|||"	+
	      	"~"

EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = A-
; Executable = C2D_Legend_x86.exe
; DisableDebugger
; CompileSourceDirectory