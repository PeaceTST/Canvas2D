; C2D::Megabyte Inc. - Leader Board (Superintro) - 17.07.1986
; Purebasic v5.72 (x86-64) / 31.10.2021

; http://janeway.exotica.org.uk/release.php?id=1356

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_API	 ; wav

	#IsC2D_Mode			=	0	; DrawingMode
	#IsC2D_Clear		=	0

	#IsC2D_Brush		=	1
	#IsC2D_GdiPlus		=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Copper		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_Bounce		=	1
	
	;#IsC2D_Help			=	1

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"	; adapt path of include

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"	; adapt path of include

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth (zoomed)
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight (zoomed)

Procedure	Blit_Copper(x, y, PenColor, PaperColor)
	If	PaperColor	<>	$FFFFFFFF
		ProcedureReturn	PaperColor
	EndIf
	ProcedureReturn	PenColor
EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Megabyte Inc. - Leader Board (Superintro) - 1986"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	; initialize c2d
	C2D::Init(#C2D_G, 15)

	; copper for logo/text
	C2D::CopperInit(0, 37 * #C2D_Z, ?c_logo, C2D::#C2F_Vertical)	; logo
	C2D::CopperInit(1,  8 * #C2D_Z, ?c_text, C2D::#C2F_Vertical)	; text
	C2D::CopperBlitProc(@Blit_Copper())

	; font & scroller
	C2D::GdipCatch(0, ?i_font, ?e_font)
	C2D::FontInit(0, 0)
	C2D::FontScale(0, #C2D_Z)
	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, 0.85 * #C2D_Z)

	; create logo & resize (wonder why zoom x2 create 1x pixelwidth)
	C2D::GdipCatch(0, ?i_logo, ?e_logo)
	ResizeImage(0, ImageWidth(0) * #C2D_Z, ImageHeight(0) * #C2D_Z, #PB_Image_Raw)

	; fast background ********************************************
	StartDrawing(CanvasOutput(#C2D_G))
	DrawImage(ImageID(0), (#C2D_W - ImageWidth(0)) / 2, 72 * #C2D_Z)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()	; *********************************************

	; up/down scrolling background
	C2D::GdipCatch(0, ?i_back, ?e_back)
	ResizeImage(0, 12 * #C2D_Z, 12 * #C2D_Z, #PB_Image_Raw)
	C2D::BrushInit(0, 0, 0, 0, #C2D_W, 54 * #C2D_Z)
	C2D::BrushInit(1, 0, 0, #C2D_H - 54 * #C2D_Z, #C2D_W, 54 * #C2D_Z)

	; bouncing amiga-ball
	C2D::GdipCatch(0, ?i_ball, ?e_ball)
	ResizeImage(0, ImageWidth(0) * #C2D_Z, ImageHeight(0) * #C2D_Z, #PB_Image_Raw)
	C2D::BounceInit(0, 66 * #C2D_Z, 28 * #C2D_Z, 155 * #C2D_Z)

	; play music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Static	s.f	=	0.6 * #C2D_Z
	Static	x.f	=	0.6 * #C2D_W

	; clear backbuffer & draw logo
	C2D::BufferBackDraw()

	; move bouncing ball left/right
	x	+	s	:	If	x	>=	#C2D_W	-	9	*	#C2D_Z	Or	x	<=	101 * #C2D_Z	:	s	*	-1	:	EndIf
	
	; bouncing ball
	DrawImage(ImageID(0), x, C2D::Bounce(0))

	; moving background
	C2D::BrushMove(0, 0, -0.4 * #C2D_Z)	:	C2D::BrushDraw(0)
	C2D::BrushMove(1, 0,  0.4 * #C2D_Z)	:	C2D::BrushDraw(1)

	; scrolltext + mirror
	C2D::ScrollTextDraw(0, 150 * #C2D_Z)
	C2D::BufferMirror(0, 158 * #C2D_Z, #C2D_W, 8 * #C2D_Z)

	; copper logo & scroller
	C2D::CopperBlit(0, 105 * #C2D_Z, -0.40 * #C2D_Z)
	C2D::CopperDraw(1, 158 * #C2D_Z)

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
			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
				Break
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection

	i_logo:	:	IncludeBinary	"gfx\MBI_Logo.png"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\MBI_Font.png"	:	e_font:
	i_back:	:	IncludeBinary	"gfx\MBI_Back.png"	:	e_back:
	i_ball:	:	IncludeBinary	"gfx\MBI_Ball.png"	:	e_ball:

	CompilerIf	IsC2D::#IsC2D_Music
		m_music:	:	IncludeBinary	"mus\Superintro.wav"	:	e_music:
	CompilerEndIf

	; coppers
	c_logo:	:	Data.l	5, $FF666666, $FFFFFFFF, $FF666666, $FFFFFFFF, $FF666666
	c_text:	:	Data.l	2, $FF551100, $FF771100

	; scroller
	t_text:	:	Data.s	"MEGABYTE INC. PROUDLY PRESENTS...     LEADER BOARD          DON'T HIT THE MOUSE BUTTONS YET, BUT TAKE A COMFORTABLE SEAT AND ENJOY OUR BREATHTAKING INTRO.  "	+
	       	 	      	"IT WAS ABOUT TIME THAT SOMEONE STARTED TO USE THE POWERFUL CAPABILITIES OF THIS AWESOME MACHINE.           "	+
	       	 	      	"ABOUT LEADER BOARD: YOU CAN PRESS THE SLASH KEY (/) TO RESTART THE GAME. 	      "	+
	       	 	      	"FIRST OF ALL, HERE ARE THE ESSENTIAL GREETINGS TO ALL OUR FRIENDS: ADJ, BOB, THE GENERAL (THANKS FOR SENDING US THE ORIGINAL !), MIKE, CCL (HOW'S THE ARMY, ROB...?), INDY, HEADBANGER, ECA, JWO, THE AMIGAMASTERS, DR. F, RABBIT SYSTEMS, GAME WORLD, SOFTRUNNER, BYTEBREAKER AND ALL THE OWNERS OF A GENUINE N.T.S.C. AMIGA.           "	+
	       	 	      	"THE STRANGE BACKGROUND SOUNDS WERE TAKEN FROM PART ONE OF J.M. JARRE'S ALBUM 'ZOOLOOK'           "	+
	       	 	      	"SPECIAL THANKS TO W.H.T.T. PRODUCTIONS FOR DEVELOPING THE SOUND SAMPLING DEVICES AND MIDI HARDWARE.          "	+
	       	 	      	"IF YOU LOOK AT THE DISGUSTING TITLE SCREEN OF EA'S 'ONE ON ONE', YOU MIGHT BELIEVE THAT SOFT SCROLLING ON THE AMIGA IS AS BAD AS IT IS ON 'MSX'...  "	+
	       	 	      	"HOWEVER, WE PROVE THAT IT IS ABSOLUTELY NO PROBLEM !           "	+
	       	 	      	"SORRY ATARI; IMITATING THE AMIGA BALL DEMO IS POSSIBLE, BUT CAN YOU PLAY DIGITIZED MUSIC, SCROLL TWO LINES OF TEXT, MOVE SEVERAL BITPLANES UP'N'DOWN, CYCLE COLORS AND DISPLAY ABOUT 80 COLORS SIMULTANEOUSLY AND ALL THIS NEARLY WITHOUT USING THE 68000...?  "	+
	       	 	      	"BETTER LUCK NEXT TIME, OK ?          "	+
	       	 	      	"BY THE WAY, THE LITTLE BALL IS NOT A SPRITE, BUT A BLITTER IMAGE (IF YOU DON'T KNOW WHAT THE BLITTER IS, YOU REALLY SHOULDN'T HAVE BOUGHT THIS MACHINE...!!??)           "	+
	       	 	      	"A LITTLE UNIMPORTANT NOTE: I THINK I'M GOING TO DEGAUSS MY MONITOR TOMORROW.           "	+
	       	 	      	"FINAL NOTE TO ALL AMIGA OWNERS:           MEGABYTE INCORPORATED; YOUR CHOICE FOR HIGH LEVEL PROGRAMMING AND SECURITY CODE REMOVAL.                                         "	+
	       	 	      	"17-07-86                                         "	+
	       	 	      	"C2D RETRO BY PEACE"
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A+
; Executable = C2D_Megabyte_x86.exe
; DisableDebugger
; CompileSourceDirectory