; C2D::Tarkus Team - Player Manager - 1990
; Purebasic v6.30 (x86-64) / 17.04.2026
; Purebasic v6.04 (x86)    / 19.08.2018

; http://janeway.exotica.org.uk/release.php?id=4403

; *** not really like the original, C2D example only! ***

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64	Or	#PB_Compiler_Version	>=	610
		#IsC2D_Music	=	#XMU_TPT	; x86-64 -> TinyPT2
	CompilerElse
		#IsC2D_Music	=	#XMU_S68	; x86 -> S68 = Error PBv610, try #C2D_Music_AMP if AmpMaster is installed
	CompilerEndIf

	#IsC2D_Line3D		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_Text			=	1
	#IsC2D_Copper		=	1
	#IsC2D_Buffer		=	1
	
	#IsC2D_Bitmap		=	1
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_Clear		=	2	; fast canvasclear
	
	#IsC2D_Help	=	0

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width (zoomed)
#C2D_H	=	240	*	#C2D_Z	; Height (zoomed)

Enumeration	; CanvasFX
	#ID_BMAP
	#ID_LOGO
	#ID_SINE
	#ID_TEXT
	#ID_GRID
EndEnumeration

Enumeration	; Coppers
	#ID_CTOP	; copper-bar top
	#ID_CBLT	; copper-blitter
	#ID_CBOT	; copper-bar bottom
EndEnumeration

#LOG_H	=	34	*	#C2D_Z	*	0.9

#COP_H	=	38	*	#C2D_Z
#BLT_H	=	#C2D_H	-	(2 * #COP_H + #LOG_H)	+	1
#SIN_H	=	#BLT_H	*	0.5	-	8	*	#C2D_Z

#COP_YT	=	#LOG_H - 0.5 * #C2D_Z
#COP_YB	=	#C2D_H - #COP_H - #C2D_Z

#FNT_H	=	16	*	#C2D_Z	; font height
#FNT_W	=	16	*	#C2D_Z	; font width

#R_Speed	=	5.0947	; grid rotation-speed
#Z_Speed	=	0.0062	; grid zoom-speed

Procedure.l	Blit_Copper(x, y, PenColor.l, PaperColor.l)	; faded copper
	
	;ProcedureReturn	PenColor

	Static	a.f
	
	If	PenColor	=	$FFFFFFFF	; tarkus team textcolor #white?
		
		ProcedureReturn	$FFFFFFFF
		
	ElseIf	PaperColor	&	$FFFFFF	; raster or sinus?
		
		a	=	Red(PaperColor)	*	0.00392	; 1.0 / 255.0
		
		If	a	>=	0.98
			ProcedureReturn	PenColor
		EndIf
		
		ProcedureReturn	RGBA(Red(PenColor) * a, Green(PenColor) * a, Blue(PenColor) * a, 255)
		
	EndIf
	
EndProcedure

Procedure	TT_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Tarkus Team - Player Manager German - 1990"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 9)

	C2D::CopperInit(#ID_CTOP, #COP_H, ?c_top)	; blue copper top
	C2D::CopperInit(#ID_CBOT, #COP_H, ?c_bot)	; blue copper bottom

	; custom CopperBlit works in x86 only, bug in pb 5.62?
	C2D::CopperInit(#ID_CBLT, #BLT_H, ?c_blt)
	C2D::CopperBlitProc(@Blit_Copper())

	; init tarkus-team logo
	C2D::BitmapInit(#ID_LOGO, ?i_logo, ?e_logo)
	C2D::BitmapScale(#ID_LOGO, 0.9 * #C2D_Z)

	C2D::BitmapInit(#ID_BMAP, ?i_font, ?e_font)	; temp font
	C2D::FontInit(#ID_SINE, C2D::BitmapImage(#ID_BMAP))
	C2D::FontZoom(#ID_SINE, #FNT_W, #FNT_H)

	C2D::FontInit(#ID_TEXT, C2D::BitmapImage(#ID_BMAP))
	C2D::FontZoom(#ID_TEXT, #FNT_W * 0.9, #FNT_H * 0.9)	; resize coz not fit to output
	C2D::FontGap(#ID_TEXT, 0, 3 * #C2D_Z)
	
	C2D::FontSelect(#ID_TEXT)
	C2D::TextInit(#ID_TEXT, ?t_text, C2D::#C2F_CenterX)
	
	C2D::FontSelect(#ID_SINE)
	C2D::ScrollTextInit(#ID_SINE, ?t_sine)
	C2D::ScrollTextSpeed(#ID_SINE, 1.3 * #C2D_Z)

	; 3d-grid
	C2D::Line3DInit(#ID_GRID,	?o_grid)
	C2D::Line3DColor(#ID_GRID,	$FFFFFFFF)
	C2D::Line3DFog(#ID_GRID,	88)

	; fast foreground ********************************************
	StartDrawing(CanvasOutput(#C2D_G))
	; copperbars + logo
	C2D::CopperDraw(#ID_CTOP, #COP_YT)
	C2D::CopperDraw(#ID_CBOT, #COP_YB)
	C2D::BitmapDraw(#ID_LOGO, 0, 8 * #C2D_Z, 255, C2D::#C2F_CenterX)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()	; *********************************************
	
	; tarkus team present
	StartDrawing(ImageOutput(C2D::CopperImage(#ID_CBLT)))
	C2D::TextDraw(#ID_TEXT, (OutputWidth() - C2D::TextW(#ID_TEXT)) * 0.5, (OutputHeight() - C2D::TextH(#ID_TEXT)) * 0.5)
	StopDrawing()

	; no longer needed
	C2D::CopperFree(#ID_CTOP)
	C2D::CopperFree(#ID_CBOT)
	C2D::BitmapFree(#ID_LOGO)
	C2D::BitmapFree(#ID_BMAP)
	C2D::TextFree(#ID_TEXT)

	; play the music
	CompilerSelect	IsC2D::#IsC2D_Music
		CompilerCase	IsC2D::#XMU_S68	; converted by stormbringer?
			C2D::MusicPlay(?m_music, ?e_music)
		CompilerCase	IsC2D::#XMU_TPT	; converted by estrayk
			C2D::MusicPlay(?m_music, ?e_music)
		CompilerCase	IsC2D::#XMU_AMP	; extern, original amiga
			Protected	Music$	=	GetCurrentDirectory()	+	"mus\Tarkus Team - Smash1.sid1"
			C2D::MusicPlay(@Music$)
	CompilerEndSelect

EndProcedure
Procedure	TT_Update()

	Static	Time, Mode=5
	Static	x.f, y.f, z.f, ay.f, az.f, ax.f

	Protected	zg.f = 16 * #C2D_Z
	
	;{ Rotate }
	If	C2D::C2D\Time	>=	Time
		
		Time	=	C2D::C2D\Time	+	7400
		
		Mode	+	1	:	If	Mode	>	8	:	Mode	=	0	:	EndIf
		
		x	=	0
		y	=	0

		If	z	<	0
			z	=	0
			C2D::Line3DAngle(#ID_GRID, 0, 0, 0)
		ElseIf	z	>	1.0
			z	=	1.0
		EndIf
		
		Select	Mode
			Case	0	:	ax	=	#R_Speed	:	ay	=	0	:	az	=	0
			Case	2	:	ay	=	#R_Speed	:	ax	=	0	:	az	=	0
			Case	4	:	az	= -#R_Speed	*	0.8	:	ax	=	0	:	ay	=	0
			Case	6
				ax	=	(#R_Speed	*	Random(88, 23) * 0.01)	*	(1 - Random(1) * 2)
				ay	=	(#R_Speed	*	Random(87, 21) * 0.01)	*	(1 - Random(1) * 2)
				az	=	(#R_Speed	*	Random(86, 19) * 0.01)	*	(1 - Random(1) * 2)
		EndSelect	

	EndIf
	;}

	;{ Zoom in / out }
	If	Mode	&	1	; zoom out
		If	Mode	<	7
			If	z	>	0
				z	-	#Z_Speed
				If	z	<=	0
					Time	=	0	; no wait
				EndIf
			EndIf
		Else
			Time	=	0	; Mode = 7 -> jump next 8
		EndIf
	Else	; zoom in
		If	Mode	>	7	; Mode = 8, move left & zoom out
			x	-	1.350	*	#C2D_Z
			y	-	0.500	*	#C2D_Z
			z	-	#Z_Speed
			If	z	<=	0
				Time	=	0	; no wait
			EndIf
		ElseIf	z	<	1
			z	+	#Z_Speed
		EndIf
	EndIf
	
	zg	*	z	; zoom grid
	;}

	; sinus-scroller (draw first coz clears buffer)
	C2D::ScrollTextDraw(#ID_SINE, #C2D_H * 0.53)
	C2D::BufferSinY(0,
	                #C2D_H * 0.53,
	                #C2D_W,
	                #FNT_H,
	                58.5 * #C2D_Z,
	                0.12 / #C2D_Z * 5,
	                1.4 * 5, 0)	; flags=0 coz drawing after backdraw
	
	; draw back & sinus-scroller
	C2D::BufferBackDraw()
	C2D::BufferSinDraw(36 * #C2D_Z, 45 * #C2D_Z)
	
	; limits for grid
	ClipOutput(0, #COP_YT + #COP_H + #C2D_Z, #C2D_W, #COP_YB - #COP_YT - #COP_H)

	; line3d grid
	C2D::Line3DRotate(#ID_GRID, ax, ay, az)
	C2D::Line3DDraw(#ID_GRID, x, y + #C2D_H * 0.062, zg, zg)

	; copper to sinus + grid (draw text in copper)
	C2D::CopperBlit(#ID_CBLT, #COP_H + #LOG_H)

EndProcedure

TT_Init()

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
				TT_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection

	CompilerSelect	IsC2D::#IsC2D_Music
		CompilerCase	IsC2D::#XMU_S68
			m_music:	:	IncludeBinary	"mus\Tarkus Team - Smash1.sc68"			:	e_music:	; x86
		CompilerCase	IsC2D::#XMU_TPT
			m_music:	:	IncludeBinary	"mus\Estrayk - Tarkus Team_fixed.mod"	:	e_music:	; x86-64
	CompilerEndSelect

	i_logo:	:	IncludeBinary	"gfx\TT_Logo.png"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\TT_Font.png"	:	e_font:

	o_grid:	:	IncludeBinary	"obj\GridShade.l3d"

	c_top:	:	Data.l	2,	$FF000000, $FFEE0000
	c_bot:	:	Data.l	2,	$FFEE0000, $FF000000

	c_blt:
	Data.l	12,
	      	$FF000000|#Red,
	      	$FF000000|#Yellow,
	      	$FF000000|#Green,
	      	$FF000000|#Cyan,
	      	$FF000000|#Blue,
	      	$FF000000|#Magenta,
	      	$FF000000|#Red,
	      	$FF000000|#Yellow,
	      	$FF000000|#Green,
	      	$FF000000|#Cyan,
	      	$FF000000|#Blue,
	      	$FFFF00BB

	t_text:
	Data.s	"TARKUS TEAM|"	+
	      	"PRESENT|"		+
	      	"PLAYER MANAGER GERMAN"	; yep, found the missing "A" ;D

	t_sine:
	Data.s	"ACCEPT NO LIMITS !!!!!     TARKUS TEAM PRESENTS ANOTHER RELEASE !!!  THIS TIME TARKUS TEAM CRACKED       PLAYER MANAGER GERMAN  !!!  PLAYER MANAGER GERMAN WAS CRACKED BY     FFC OF TARKUS TEAM     "	+
	      	"MANY PEOPLE TOLD A LOT OF BULLSHIT IN THE LAST DAYS. THEY TOLD I HAD LEFT TARKUS TEAM, THAT IS NOT TRUE !!!!     MEMBERS OF TARKUS TEAM ARE :  SPIDER,FFC,E 605,CHRIS,DCSL,ULTRA,CONDORMAN,FOX,BERLIN SPREADER,MASON,DUSK,SMASHER   "	+
	      	"IF YOU HAVE THE WISH TO GET IN TOUCH WITH US WRITE TO :   PLK 048509 D   3300 BRAUNSCHWEIG   WEST GERMANY   OR CALL OUR BOARDS IN WEST GERMANY   OUR GREETINX (A-Z ORDER) FLYING TO....  THE SPECIAL REGARDS TO :   "	+
	      	"DESTINY SEVEN,UNICORN,VENOM ---- THE COOL REGARDS TO :   D-TECT,MAD,SUBWAY ---- THE GOOD REGARDS TO :   AEON,ANIMATE,ARCANE,AVENGER,BRAINSTORM,CLASSIC,CULT,DIGITECH,DYNASTY,E-L,EXODUS,FUTURE LIGHT,HEADWAVE,HELLAS,HORIZON,KEFRENS,"	+
	      	"LEVEL 4,MIRACLE,RAZOR 1911,SCOOPEX,SETROX,SUPPLEX,SUPPLY TEAM,WIZZCAT,AND TO ALL OTHER CONTACTS ....     MEGA FUCKINGS TO :  BLACK MONKS"

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = AA-
; Optimizer
; EnableThread
; EnableUser
; EnableOnError
; Executable = C2D_Tarkus_Team_x86.exe
; DisableDebugger
; CompileSourceDirectory
; Compiler = PureBasic 6.30 - C Backend (Windows - x64)