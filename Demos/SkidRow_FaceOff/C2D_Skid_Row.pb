; C2D::Skid Row - Face Off - 29.09.1991
; Purebasic v6.04 (x86-64) / 29.10.2018

; http://janeway.exotica.org.uk/release.php?id=5510

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Types]

 	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64	Or	#PB_Compiler_Version	>=	610	; #Music
 		#IsC2D_Music	=	#XMU_MCI ; x86/x64 (OGG, file only)
 		;#IsC2D_Music	=	#C2D_Music_OGG ; x86/x64 (OGG, *memory & file)
 	CompilerElse
 		#IsC2D_Music	=	#XMU_S68 ; x86 (SC68, *memory)
 	CompilerEndIf

 	#IsC2D_Mode			=	0
 	#IsC2D_Clear		=	0	; 0 = no clear, 1 colorclear (default), 2 = fastclear (RGB black only)

 	#IsC2D_Bitmap		=	1
 	#IsC2D_Buffer		=	1	; direct access to canvasbuffer
 	#IsC2D_FontColor	=	1	; shadow, copper, color
 	#IsC2D_PageText	=	1
 	#IsC2D_ScrollText	=	1

  	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** the main ***

#C2D_G	=	0	; #ID of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width
#C2D_H	=	240	*	#C2D_Z	; Height

#B_W	=	15	*	#C2D_Z	; ball width
#B_H	=	15	*	#C2D_Z	; ball height

#B_CX	=	#B_W	*	0.5	; ball x hotspot (center)
#B_CY	=	#B_H	*	0.5	; ball y hotspot (center)

#C2D_CX	=	(#C2D_W	-	#B_W)	*	0.50
#C2D_CY	=	(#C2D_H	-	#B_H)	*	0.50

#FNT_TH	=	15	*	#C2D_Z	; top/down font height
#FNT_SH	=	7	*	#C2D_Z	; scroller font height

#Y_POS	=	12	*	#C2D_Z	; top/bottom offset

Structure	XY_Pos	; x/y for lines/balls
	x.i[18]
	y.i[18]
EndStructure

Global	XY_Pos.XY_Pos, x_time

Procedure	C2D_Init()
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Skid Row - Face Off - 1991"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G)	; update every 5ms

	; create big copper-font for message
	C2D::BitmapInit(0, ?i_bfnt, ?e_bfnt)
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontCopper(0, ?c_font)
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, #C2D_Z)

	; create message text + fx with font 0
	C2D::PageTextInit(?t_text, 0, #Y_POS, #C2D_W, #FNT_TH, C2D::#C2F_Center)
	C2D::PageTextEffect(1, C2D::#PFX_FadeLeft, 6, 24)
	C2D::PageTextEffect(0, C2D::#PFX_FadeStep, 6, 24)

	; create small font for scroller
	C2D::BitmapInit(0, ?i_sfnt, ?e_sfnt)
	C2D::FontInit(1, C2D::BitmapImage(0))
	C2D::FontColor(1, $FFAA7700)
	C2D::FontScale(1, #C2D_Z)
	
	; create scroller with font 1
	C2D::ScrollTextInit(0, ?t_scroll)
	C2D::ScrollTextSpeed(0, 0.43 * #C2D_Z)
	
	; create logo
	C2D::BitmapInit(0, ?i_logo, ?e_logo)
	C2D::BitmapScale(0, #C2D_Z)
	
	; create fast backbuffer (backcolor + logo)
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, 0, #C2D_W, #C2D_H, $FF330000)
	C2D::BitmapDraw(0, 0, 0, 255, C2D::#C2F_Center)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()
	
	; create ball
	C2D::BitmapInit(0, ?i_ball, ?e_ball)
	C2D::BitmapScale(0, #C2D_Z)
	
	; at last play sidmon2 module (sc68/ogg) by subzero
	CompilerSelect	IsC2D::#IsC2D_Music
		CompilerCase	IsC2D::#XMU_MCI
			Protected	Music$	=	GetCurrentDirectory()	+	"mus\Subzero - Cool Module.ogg"
			C2D::MusicPlay(@Music$)
		CompilerCase	IsC2D::#XMU_S68
			C2D::MusicPlay(?m_music, ?e_music)
		CompilerCase	IsC2D::#XMU_OGG
			C2D::MusicPlay(?m_music);, ?e_music)
	CompilerEndSelect
	
	x_time	=	C2D::MA_TIME()	+	5500	; wait 5.5 sec.

EndProcedure
Procedure	C2D_Update()
	
	Protected	i, x, x_move=#C2D_CX
	
	Static	x_step.f = -512.0	; <- GCos(centerX)
	
	; clear buffer with color + logo
	C2D::BufferBackDraw()
	
	; wait 5.5 sec. to start horizontal moving
	If	C2D::C2D\Time	>=	x_time
		
		; center of horizontal moving lines + balls
		x_step	+	3.70
		x_move	+	MA_GCos(x_step)	*	#C2D_CX
		
		; draw header & fast clone to bottom
		C2D::PageTextDraw(1)
		C2D::BufferCloneY(#Y_POS, #C2D_H - (#Y_POS + #FNT_TH), #FNT_TH)
		
	EndIf
	
	; draw scroller & fast clone to bottom
	C2D::ScrollTextDraw(0, #Y_POS + 2 * #FNT_TH)
	C2D::BufferCloneY(#Y_POS + 2 * #FNT_TH, #C2D_H - (#Y_POS + 2 * #FNT_TH + #FNT_SH), #FNT_SH)
	
	x	=	#B_CX	+	x_move	; x center of lines
	
	If	x	<	#B_W
		x	=	#B_W
	ElseIf	x	>	#C2D_W	-	#B_W
		x	=	#C2D_W	-	#B_W
	EndIf

	FrontColor($FFFFFFFF)	; white... lines ;)
	
	; draw lines & balls
	With	XY_Pos
		
		; 1. calculate x/y + draw 18 rotating lines first
		While	i	<	18
			
			\x[i]	=	x_move	+	MA_GCos(C2D::C2D\Time * 0.5 + i * 114)	*	57	*	#C2D_Z
			\y[i]	=	#C2D_CY	+	MA_GSin(C2D::C2D\Time * 0.5 + i * 114)	*	57	*	#C2D_Z
			
			; x pos min left or max right?
			If	\x[i]	<	0
				\x[i]	=	0
			ElseIf	\x[i]	>	#C2D_W - #B_W
				\x[i]	=	#C2D_W - #B_W
			EndIf
			
			LineXY(x, #C2D_CY + #B_CY, #B_CX + \x[i], #B_CY + \y[i])
			
			i	+	1
			
		Wend

		i	=	0

		; 2. draw 18 rotating balls (pre-calculated & always in front of lines)
		While	i	<	18
			DrawAlphaImage(C2D::RS_Bitmap()\hImage, \x[i], \y[i])	:	i	+	1
		Wend
		
	EndWith

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
	
	i_logo:	:	IncludeBinary	"gfx\SkidRow_Logo.png"		:	e_logo:
	i_ball:	:	IncludeBinary	"gfx\SkidRow_Ball.png"		:	e_ball:
	i_sfnt:	:	IncludeBinary	"gfx\SkidRow_font.png"		:	e_sfnt:
	i_bfnt:	:	IncludeBinary	"gfx\Metallion_font.png"	:	e_bfnt:
	
	; music x86 only
	m_music:
	CompilerSelect	IsC2D::#IsC2D_Music
		CompilerCase	IsC2D::#XMU_S68
			IncludeBinary	"mus\Subzero - Cool Module.sc68"
		CompilerCase	IsC2D::#XMU_OGG
			Data.s	"mus\Subzero - Cool Module.ogg"
			;IncludeBinary	"mus\Subzero - Cool Module.ogg"
	CompilerEndSelect
	e_music:
	
	c_font:	; copper for message font
	Data.l	15,
	      	$FF330000, $FF440000, $FF551111, $FF662222, $FF773333,
	      	$FF884444, $FFAA5555, $FFBB6666, $FFCC7777, $FFBB8888,
	      	$FFAA6666, $FF885555, $FF774444, $FF663333, $FF552222
	
	t_text:	; message text
	Data.s	   "*** SKID ROW ***~"		+
	      	   "ARE PROUD TO PRESENT~"	+
	      	   "** F A C E  O F F **~"	+
	      	   "********************~"	+
	      	   "SPECIAL REGARDS TO~"	+
	      	   "FAIRLIGHT! - CLASSIC~"	+
	      	   "SKYLINE! AND HQC~"		+
	      	   "CRYSTAL! - LEGEND~"		+
	      	   "CRUSADERS! - SILENTS~"	+
	      	   "AGILE AND AFL!!~"		+
	      	   "~"	+
	      	   "C2D RETRO BY PEACE~"	+
	      	   "~"
	
	t_scroll:	; scroller
	Data.s	"IT TAKES A NATION OF MILLIONS TO HOLD THE BEST BACK!!  "	+
	      	"*** SKID ROW *** PROVIDES YOU WITH ANOTHER HOT CRACK... "	+
	      	"- FACE OFF FROM KRISALIS -    GET IT BEFORE IT GETS YOU! "	+
	      	"- CRACKED BY THE PUBLIC ENEMY NO.1 ... * F F C * ... "	+
	      	"AND THE ORIGINAL WAS SUPPLIED BY... *** S.S.R ***  "	+
	      	"FOR THE LATEST UPCOMING WAREZ WRITE TO...  "	+
	      	"P.O. BOX  10 - 4540 AMAY # BELGIUM # ... "	+
	      	"OR TO - SKID ROW - POSTE RESTANTE, 8450 HAMMEL # DENMARK #  "	+
	      	"OR ... PLK 052135   D   4300 ESSEN # UNITED GERMANY #  "	+
	      	"OTHERWISE CALL OUR BULLETIN BOARD SYSTEMS...  # "	+
	      	"ALCATRAZ: 703-323-5997 #  -  # "	+
	      	"AMIGA EAST: 804-499-2266 #  -  # "	+
	      	"INQUISITION: 805-967-8833 #  -  # "	+
	      	"MOTHERBOARD I: 215-944-9712 #  -  # "	+
	      	"CREEPING DEATH: 314-781-5539 #  -  # "	+
	      	"H.M.S. BOUNTY: 714-563-2206 #  -  "	+
	      	"OR CALL IN EUROPE... # THE JAM: 49-201-626-047 #  -  # "	+
	      	"LIGHTHOUSE: 49-212-592-543 #  -  # "	+
	      	"DIABOLIKA: 39-519-365-77 #       "	+
	      	"AND REMEMBER... # WE ARE THE WISDOM BEHIND THE CROWN #  ... "	+
	      	"GREAT INTRO BY... * SKYWALKER *   AND THE   "	+
	      	"LITTLE MUSIX (6KB!) BY... * SUBZERO *"
	
EndDataSection
; IDE Options = PureBasic 6.10 LTS (Windows - x86)
; Folding = A9
; Executable = C2D_Skid_Row_x86.exe
; DisableDebugger
; CompileSourceDirectory