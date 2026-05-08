; C2D::Vision Factory - Atomix - 1990
; Purebasic v6.30 (x86-64) / 17.04.2026
; Purebasic v6.04 (x86-64) / 29.04.2018

; http://janeway.exotica.org.uk/release.php?id=6200

; *** Nerving AntiVir Warning -> DAMN AV FALSE/TRUE HEURISTIC! ***

; DisableDebugger	; TURN OFF THE DEBUGGER! - Increase the copper-speed ;)
; Hmm, error in PB if debugger on by default and call disabledebugger!?

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; musictypes #XMU_[Type]

	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64	Or	#PB_Compiler_Version	>=	610
		#IsC2D_Music	=	#XMU_TPT	; x86-64 (TinyPT2)
	CompilerElse
		#IsC2D_Music	=	#XMU_S68	; x86 -> #C2D_Music_(PT2,AMP,BAS,FT2,S68,MOD)
	CompilerEndIf

	#IsC2D_Mode			=	#PB_2DDrawing_Outlined
	
	#IsC2D_Bitmap		=	1
	#IsC2D_BitmapColor=	1
	#IsC2D_Brush		=	1
	#IsC2D_Buffer		=	1	; -> SinusTextX/Y
	#IsC2D_Copper		=	1
	#IsC2D_FontColor	=	1
	#IsC2D_Text			=	1
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_ScrollText	=	2	; 2 -> support for Control-Codes
	#IsC2D_Clear		=	2	; 2 -> fast clear canvasbuffer (black only)

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID of CanvasGadget

#C2D_C	=	12		*	#C2D_Z	; Cut left & right pitchcrap by sinx
#C2D_W	=	320	*	#C2D_Z	+	#C2D_C	; CanvasWidth (center canvas!)
#C2D_H	=	240	*	#C2D_Z					; CanvasHeight

#FNT_H	=	11	*	#C2D_Z		; Font-Height

#COP_H	=	9		*	#C2D_Z	; Height of bordercopper
#COP_S	=	-3.9	*	#C2D_Z	; Speed of rotation (simulation)
#COP_Y	=	3		*	#C2D_Z	; Distance bordercopper to back fx

#FX_Y	=	92		*	#C2D_Z		; Start of back fx
#FX_H	=	113	*	#C2D_Z		; Height of back fx
#FX_L	=	198	*	#C2D_Z		; Loop of back fx (circle)

#SIN_Y	=	#FX_Y	+	(#FX_H	-	#FNT_H)	/	2	; Center Scrolltext (sinus)
#SIN_X	=	#C2D_C	/	2		; Start l/r sinx

#LOGO_Y	=	4	*	#C2D_Z

#TIME_FADE	=	5000				; Swap logo in ms

Enumeration
	#ID_BORDER
	#ID_VISION
	#ID_VISION_BLEND
	#ID_FACTORY
	#ID_FACTORY_BLEND
	#ID_PRESENT
	#ID_FRAXION
	#ID_FSINUS
	#ID_SINUS
	#ID_TITLE
	#ID_FTITLE
	#ID_CSINUS
EndEnumeration

Procedure.l	VF_Copper(x, y, PenColor.l, PaperColor.l)
	; sinus-copper
	If	PaperColor	&	$00FFFF
		ProcedureReturn	PenColor
	EndIf
	ProcedureReturn	PaperColor
EndProcedure

Procedure	VF_Init()
	
	Protected	cr = 4
	
	OpenWindow(0, 0, 0, #C2D_W - #C2D_C, #C2D_H, MA_C2DOS("Vision Factory - Fraxion - Atomix - 1990"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, -(#C2D_C / 2), 0, #C2D_W, #C2D_H)	; center canvas, clip r+l buffercrap!
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 9)
	
	; Pseudo-BorderCoppers
	C2D::BitmapInit(#ID_BORDER,?i_copper, ?e_copper)
	C2D::BitmapZoom(#ID_BORDER,C2D::BitmapW(#ID_BORDER) * #C2D_Z * 2, #COP_H)
	C2D::BrushInit(#ID_BORDER,	C2D::BitmapImage(#ID_BORDER), 0, #FX_Y - #COP_H - #COP_Y, #C2D_W, #COP_H)
	
	; Vision + Factory
	C2D::BitmapInit(#ID_VISION,	?i_vision,	?e_vision)	:	C2D::BitmapScale(#ID_VISION,	#C2D_Z)
	C2D::BitmapInit(#ID_FACTORY,	?i_factory,	?e_factory)	:	C2D::BitmapScale(#ID_FACTORY,	#C2D_Z)
	
	; Vision + Factory for #White blending
	C2D::BitmapAdd(#ID_VISION_BLEND,	C2D::BitmapImage(#ID_VISION))		:	C2D::BitmapFill(#ID_VISION_BLEND,	$FF000000|#White)
	C2D::BitmapAdd(#ID_FACTORY_BLEND,C2D::BitmapImage(#ID_FACTORY))	:	C2D::BitmapFill(#ID_FACTORY_BLEND,	$FF000000|#White)
	
	; Presents + Fraxion
	C2D::BitmapInit(#ID_PRESENT,	?i_presents,?e_presents)	:	C2D::BitmapScale(#ID_PRESENT, #C2D_Z)
	C2D::BitmapInit(#ID_FRAXION,	?i_fraxion,	?e_fraxion)		:	C2D::BitmapScale(#ID_FRAXION, #C2D_Z)
	
	; Font for Atomix (coppered)
	C2D::BitmapInit(#ID_FTITLE, ?i_font, ?e_font)
	C2D::FontInit(#ID_FTITLE, C2D::BitmapImage(#ID_FTITLE))
	C2D::FontScale(#ID_FTITLE, #C2D_Z)
	C2D::FontCopper(#ID_FTITLE, ?c_title)

	; Font for SinusScroller
	C2D::FontInit(#ID_FSINUS, C2D::BitmapImage(#ID_FTITLE), 1, 1)	; optimized width/height
	C2D::FontScale(#ID_FSINUS, #C2D_Z)
	C2D::FontGap(#ID_FSINUS, 1 * #C2D_Z, -1 * #C2D_Z)
	
	; Create Atomix
	C2D::FontSelect(#ID_FTITLE)
	C2D::TextInit(#ID_TITLE, ?t_title)
	
	; Create Scroller for Sinusbuffer
	C2D::FontSelect(#ID_FSINUS)
	C2D::ScrollTextInit(#ID_SINUS, ?t_sinus)
	C2D::ScrollTextSpeed(#ID_SINUS, 0.80 * #C2D_Z)
	
	; Copper for SinusScroller
	C2D::CopperInit(#ID_CSINUS, #FX_H, ?c_sinus)
	C2D::CopperBlitProc(@VF_Copper())
	
	;============================================================
	; *** Buffer static text + fx background (bug with debugger?)
	;============================================================
	StartDrawing(CanvasOutput(#C2D_G))
	
	C2D::BitmapDraw(#ID_FRAXION, -#C2D_C * 0.5 - 2, #LOGO_Y,	255,	C2D::#C2F_Right)
	C2D::BitmapDraw(#ID_PRESENT,  0, 44 * #C2D_Z, 255, C2D::#C2F_CenterX)
	C2D::TextDraw(#ID_TITLE,		0, 60 * #C2D_Z, 255, C2D::#C2F_CenterX)

	ClipOutput(0, #FX_Y, #C2D_W, #FX_H)
	DrawingMode(#PB_2DDrawing_Outlined)
	While	cr	<	#FX_L
		Circle(#C2D_W * 0.5, #FX_Y + #FX_H, cr, $FF550000)
		cr	+	2
	Wend

	C2D::BufferBackGrab()	; get static background
	C2D::BufferClear()		; black screen at start

	StopDrawing()
	;============================================================

	; No longer needed
	C2D::BitmapFree(#ID_BORDER)
	C2D::BitmapFree(#ID_PRESENT)
	C2D::BitmapFree(#ID_FRAXION)
	C2D::BitmapFree(#ID_FTITLE)
	C2D::TextFree(#ID_TITLE)
	C2D::FontFree(#ID_FTITLE)

	; play music
	CompilerIf	IsC2D::#IsC2D_Music
		CompilerSelect	IsC2D::#IsC2D_Music
			CompilerCase	IsC2D::#XMU_AMP	; x86 (original custom AmpMaster)
				; AmpMaster x86 must be installed to replay original custom-formats (s. Tools\AmpInstaller)!
				Protected	Music$	=	GetCurrentDirectory()	+	"mus\msx-intro.cust"
				C2D::MusicPlay(@Music$)
			CompilerDefault	; converted to ProTracker / SC68 (x86)
				C2D::MusicPlay(?m_music, ?e_music)	; bas, ft2, pt2, sc68
		CompilerEndSelect
	CompilerEndIf

EndProcedure
Procedure	VF_Update()
	
	Static	i=2, LogoAlpha, LogoTime, LogoFade
	Static	a_logo=#ID_FACTORY,	a_blend=#ID_FACTORY_BLEND
	Static	b_logo=#ID_VISION,	b_blend=#ID_VISION_BLEND

	Protected	cr=4, cx.f=MA_GCos(C2D::C2D\Time * 0.3) * 20	; back-fx
	
	; buffer scroller to real sinustext for later draw (s. BufferSinDraw())
	C2D::ScrollTextDraw(#ID_SINUS, #SIN_Y)
	;
	C2D::BufferSinX(#SIN_X,
	                #SIN_Y,
	                #C2D_W - #SIN_X * 2,
	                #FNT_H,
	                #SIN_X,
	                49.5 / #C2D_Z,
	                32.5)
	C2D::BufferSinY(#SIN_X,
	                #SIN_Y,
	                #C2D_W,
	                #FNT_H,
	                (#FX_H - #FNT_H) / 2,
	                1.8 / #C2D_Z,
	                8.1,
	                #False)
	
	; fast clear canvas & draw static background
	C2D::BufferBackDraw()
	
	; simulation of a nice amiga-demo-fx then ;)
	ClipOutput(0, #FX_Y, #C2D_W, #FX_H)
	FrontColor($FF550000)
	While	cr	<	#FX_L
		Circle(#C2D_W * 0.5 + cx, #FX_Y + #FX_H, cr)	; outline by default
		cr	+	2
	Wend
	UnclipOutput()

	; time to swap header-logos?
	If	C2D::C2D\Time	>=	LogoTime
		i	+	1
		If	i	>	2
			i	=	0
			Swap	a_logo,	b_logo
			Swap	a_blend,	b_blend
		EndIf
		LogoFade		=	#True
		LogoAlpha	=	0
		LogoTime		=	C2D::C2D\Time	+	#TIME_FADE
	EndIf
	;
	If	LogoFade
		LogoAlpha	+	4	:	If	LogoAlpha	>=	255	:	LogoFade	=	#False	:	LogoAlpha	=	255	:	EndIf
	EndIf
	;
	; blend logo(s) in/out
	Select	i
		Case	0
			C2D::BitmapDraw(a_blend, 0, #LOGO_Y, LogoAlpha, C2D::#C2F_CenterX)
			If	LogoAlpha	>=	255	:	LogoTime	=	0	:	EndIf	; next step, no wait
		Case	1
			C2D::BitmapDraw(a_logo, 0, #LOGO_Y, 255, C2D::#C2F_CenterX)
			If	LogoFade	:	C2D::BitmapDraw(a_blend, 0, #LOGO_Y, 255 - LogoAlpha, C2D::#C2F_CenterX)	:	EndIf
		Case	2
			C2D::BitmapDraw(a_logo, 0, #LOGO_Y, 255 - LogoAlpha, C2D::#C2F_CenterX)
			If	LogoAlpha	>=	255	:	LogoTime	=	0	:	EndIf	; next step, no wait
	EndSelect
	
	; display fraxions kewl "copper"-bars on top/down
	C2D::BrushMove(#ID_BORDER, #COP_S, 0)
	C2D::BrushDraw(#ID_BORDER)
	C2D::BufferCloneY(#FX_Y - #COP_H - #COP_Y, #FX_Y + #FX_H + #COP_Y, #COP_H)
	
	; now display buffered sinustext + copper in front of all
	C2D::BufferSinDraw(35 * #C2D_Z)
	C2D::CopperBlit(#ID_CSINUS, #FX_Y)
	
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

C2D::Free()	; always when end!

DataSection

	CompilerIf	IsC2D::#IsC2D_Music
		m_music:
		CompilerSelect	IsC2D::#IsC2D_Music
			CompilerCase	IsC2D::#XMU_S68
				IncludeBinary	"mus\msx-intro.sc68"	; x86 nearly original
			CompilerDefault
				IncludeBinary	"mus\vision_factory_fixed.mod"	; x86-64
		CompilerEndSelect
		e_music:
	CompilerEndIf

	; pictures
	IncludePath	"gfx\"
	i_vision:	:	IncludeBinary	"VF_Vision.png"	:	e_vision:
	i_factory:	:	IncludeBinary	"VF_Factory.png"	:	e_factory:
	i_presents:	:	IncludeBinary	"VF_Presents.png"	:	e_presents:
	i_fraxion:	:	IncludeBinary	"VF_Fraxion.png"	:	e_fraxion:
	i_font:		:	IncludeBinary	"VF_Font.png"		:	e_font:
	i_copper:	:	IncludeBinary	"VF_Copper.png"	:	e_copper:

	; copper
	c_title:	:	Data.l	2, $FF330022, $FFFFCCEE
	c_sinus:	:	Data.l	9, $FFEEAAFF, $FF0000FF, $FFDDD0EE, $FFFF0077, $FFFFFF55, $FFFFFF00, $FFFFDFCF, $FFFF0000, $FFFF27FF

	; text-title
	t_title:	:	Data.s	"ATOMIX"

	; text-sinus (space & tabs(3) not displayed)
	t_sinus:	:	Data.s	"{5}VISION FACTORY{5}{2,4500}"	+
	        	 	      	"PROVIDES YOU WITH MORE STUNNING STUFF."	+	#TAB$	+
	        	 	      	"GREETINGS TO: BAMIGA SECTOR ONE, ACCUMULATORS, TRILOGY, FAIRLIGHT, BENCOR BROTHERS, DEFJAM, NEMESIS, FRAXION, ZODACT, ORACLE, ECLIPSE, RED SECTOR, ESI AND THE REST!!!"	+	#TAB$	+
	        	 	      	"CONTACT US UNDER"	+	#TAB$	+
	        	 	      	"...P.O BOX 48 , SOUTHAMPTON , SO17DQ ,ENGLAND"	+	#TAB$	+
	        	 	      	"...OTHERWISE CALL OUR BBS 216-798-8154, BBS 516-783-1450 OR +49-211-7270374 IN WEST-GERMANY."	+	#TAB$	+
	        	 	      	"THATS ALL!!!{3}BYE...{3}"	+
	        	 	      	"C2D RETRO BY PEACE"
EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = Ag
; Executable = C2D_Vision_Factory_x86.exe
; DisableDebugger
; CompileSourceDirectory