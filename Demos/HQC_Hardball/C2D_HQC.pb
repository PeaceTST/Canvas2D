; C2D::HQC - Hardball - 1987
; Purebasic v6.30 (x86-64) / 17.04.2026

; http://janeway.exotica.org.uk/release.php?id=21387

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2
CompilerEndIf

IncludePath	"..\..\Include\"

DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"	; Music, Gui, XUnPack predefined #Types

	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64	Or	#PB_Compiler_Version	>=	610	; #Music
		#IsC2D_Music	=	#XMU_TPT
	CompilerElse
		#IsC2D_Music	=	#XMU_S68
	CompilerEndIf

	#IsC2D_Mode			=	0
	#IsC2D_Clear		=	0
	#IsC2D_Copper		=	1
	#IsC2D_FlatBar		=	1
	#IsC2D_Bitmap		=	1
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_ScrollText	=	1
	#IsC2D_Buffer		=	1

	XIncludeFile	"C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0						; #Gadget
#C2D_W	=	320	*	#C2D_Z	; Zoomed width
#C2D_H	=	240	*	#C2D_Z	; Zoomed height

; Scrolling copper-background
#BAK_Y	=	50	*	#C2D_Z
#BAK_W	=	#C2D_W	/	2
#BAK_H	=	#C2D_H	-	2	*	#BAK_Y

#BAR_H	=	30	*	#C2D_Z	; flatbar height
#COP_H	=	7	*	#C2D_Z	; bouncing copperbars height
#C2D_C	=	(#C2D_H	-	#COP_H)	*	0.5	; center of screen

Procedure.l	_BlitLogo(x, y, PenColor.l, PaperColor.l)

	Static	r, m=15, Time=20

	If	PenColor
		If	C2D::C2D\Time	>	Time
			r	+	m
			If	r	<=	0
				r	=	0
				m	*	-1
			ElseIf	r	>=	$FF
				r	=	$FF
				m	*	-1
			EndIf
			Time	=	C2D::C2D\Time	+	20
		EndIf
		ProcedureReturn	$FF0000|r
	EndIf

	ProcedureReturn	PaperColor

EndProcedure

Procedure	HQC_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("HQC - Hardball - 1987"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)	; update every 8ms

	; moving background coppers (resize for less ressources)
	With	C2D::RS_Copper()
		C2D::CopperInit(0, #BAK_H, ?c_b)	:	ResizeImage(\Image, #C2D_W / 2, #BAK_H)	:	\hImage	=	ImageID(\Image)
		C2D::CopperInit(1, #BAK_H, ?c_b)	:	ResizeImage(\Image, #C2D_W / 2, #BAK_H)	:	\hImage	=	ImageID(\Image)	:	\x	=	#C2D_W / 2
	EndWith

	; bouncing copper(s)
	C2D::CopperInit(2, #COP_H, ?c_g)

	; font + scrolltext
	C2D::BitmapInit(0, ?i_font, ?e_font)
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontScale(0, #C2D_Z)
	C2D::ScrollTextInit(0, ?l_Text)
	C2D::ScrollTextSpeed(0, 1.5 * #C2D_Z)

	; logo
	C2D::BitmapInit(0, ?i_logo, ?e_logo)
	C2D::BitmapScale(0, #C2D_Z)

	; create buffered background
	C2D::FlatBarInit(0, #BAR_H, $FFFF6688, #C2D_Z)	; flatbar
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::FlatBarDraw(0, #BAK_Y - #BAR_H)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()
	C2D::FlatBarFree(0)

	; play music?
	CompilerIf	IsC2D::#IsC2D_Music	=	IsC2D::#XMU_AMP
		; "C:\Users\Public\Documents\AmpMaster\" -> must be installed -> \Tools\AmpInstaller\
		Protected	Music$	=	GetCurrentDirectory()	+	PeekS(?m_music)
		C2D::MusicPlay(@Music$)	; <- must Ptr to @filename, always Length=0
	CompilerElseIf	IsC2D::#IsC2D_Music	<>	#Null
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	HQC_Update()

	Protected	i, y.f
	
	; clear & scroller
	C2D::BufferBackDraw()
	C2D::ScrollTextDraw(0, (#BAK_Y - #BAR_H) + 11 * #C2D_Z)
	C2D::BufferCloneY(#BAK_Y - #BAR_H, #BAK_H + #BAK_Y, #BAR_H)
	
	; moving background (u+d)
	C2D::CopperMoveDraw(0, #BAK_Y,-0.82)
	C2D::CopperMoveDraw(1, #BAK_Y, 0.82)
	
	; bouncing copperbars (green)
	ClipOutput(0, #BAK_Y, #C2D_W, #C2D_H - #BAK_Y * 2)
	For	i	=	7	To 0	Step	-1
		y	=	MA_GSin(C2D::C2D\Time * 0.85 + #COP_H * (9.6 / #C2D_Z) * i)	*	#BAK_H	*	0.280
		C2D::CopperDraw(2, #C2D_C	*	1.33	-	y)
		C2D::CopperDraw(2, #C2D_C	*	0.67	+	y)
	Next
	
	; blinking logo
	DrawingMode(#PB_2DDrawing_CustomFilter)
   CustomFilterCallback(@_BlitLogo())
	C2D::BitmapDraw(0, 0, MA_GSin(C2D::C2D\Time * 5.3) * 4.5 * #C2D_Z, 255, C2D::#C2F_Center)

EndProcedure

HQC_Init()

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
				HQC_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection
	
	IncludePath	""
	
	CompilerIf	IsC2D::#IsC2D_Music
		m_music:
		CompilerSelect	IsC2D::#IsC2D_Music
			CompilerCase	IsC2D::#XMU_S68
				IncludeBinary	"mus\HQC 1987.sc68"
			CompilerCase	IsC2D::#XMU_AMP
				Data.s	"mus\hqc 1987.cus"
			CompilerDefault
				IncludeBinary	"mus\Maniac - Storm.mod"
		CompilerEndSelect
		e_music:
	CompilerEndIf

	i_logo:	:	IncludeBinary	"gfx\HQC_Logo.png"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\HQC_Font.png"	:	e_font:

	c_b:	:	Data.l	10,
	    	 	      	$FFFFFFFF, $FFDD0000, $20DD0000,
	    	 	      	$FFFFFFFF, $FFDD0000, $20DD0000,
	    	 	      	$FFFFFFFF, $FFDD0000, $20DD0000,
	    	 	      	$FFFFFFFF

	c_g:	:	Data.l	3, $FF449922, $FFAAFF88, $FF449922

	l_text:
	Data.s	"HQC INC. PRESENT --- HARDBALL ---   SOME HINTS: PRESS CTRL + R TO RESTART THE GAME, ESC TO EXIT MENU, CTRL + A FOR AMERICAN FLAG, CTRL + C FOR CANADIAN FLAG AND CTRL + S TOGGLE SOUND!       "		+
	      	"WE HAVE NOW ANSWERED ALL LETTERS THAT ARRIVED AT OUR PLK BUT WE LOST SOME ADRESSES !! SO A PROCLAMATION TO ALL WHO WROTE US BUT HAVEN'T GOT A RESPOND FROM US YET: PLEASE WRITE AGAIN. "					+
	      	"WRITE TO: H.Q.C, POSTLAGERND, 8000 MUENCHEN 71. 1001/S.C.A/POWERSLAVE CONTACT US !!! AS YOU SEE, LARGE BOOT-INTROS CAUSE NO TROUBLE AT ALL, EVEN WITH MUSIC IN IT, BUT WITHOUT ANY DISK ACCESS !!! "	+
	      	"SO WE ARE ABLE TO CRUNCH 11K OF CODING INTO THE SMALL BOOT-BLOCK !? GREETING TIME ..... YOHOO TO: CRM-CREW, THE MOVERS, LIGHT CIRCLE, IRATA, SKYLINE, A.C.F, S.S.S, P.C.T, YETI FACTORIES, A.C.S, "	+
	      	"BITKILLERSOFT, THE VISITORS, MARC AUREL, THE NEW TWO, U.S.R,  VISION, E.C.A, S.S.I, S.C.A, ATOM-SOFT, A.C.S, THE STREAMERS, THE WIZARDS, J.M.C, PROPHETS AG, STAR FRONTIERS, POWERSTATION, VISION, "	+
	      	"DANISH GOLD, HOPPERS, SUPREMACY, RBB, KCG, BITSTOPPERS, HOTLINE, EXPLORER/TOC, NEW EDITION, MEGAFORCE, AND ALL WE HAVE FORGOTTEN. SEE YOU IN LATER CRACKS NOW A LAST NOTE TO BAMIGA SECTOR ONE: "		+
	      	"WE THINK THAT CRACKERS, THAT KEEP ORIGINALS FOR THEMSELVES BECAUSE OF BEING TO SILLY TO INSTALL A INTRO ON IT, SHOULD FUCK OFF!!! AS YOU SEE WE ARE (AGAIN) THE FIRST IN HAVING 11K BOOTBLOCKS, "		+
	      	"SO BEWARE OF IMITATIONS!!! BYYYYEEEEEEEEE"

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; CursorPosition = 1
; FirstLine = 1
; Folding = A5
; Executable = C2D_HQC_x86.exe
; DisableDebugger
; CompileSourceDirectory