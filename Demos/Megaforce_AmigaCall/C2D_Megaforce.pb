; C2D::Megaforce - Amiga Call - 1988
; Purebasic v5.70 (x86-64) / 13.10.2018

; http://janeway.exotica.org.uk/release.php?id=19456

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_TPT ; x86-64 Amiga Protracker 2.3D

	#IsC2D_Mode			=	0
	#IsC2D_Clear		=	0
	#IsC2D_Help			=	0

	#IsC2D_Bitmap		=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Copper		=	1
	#IsC2D_Line3D		=	1
	#IsC2D_Stars3D		=	1

	#IsC2D_ScrollText	=	2	; 2 -> Control-Codes
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_Checker		=	2	; 2 -> draw ColorB in Backbuffer (faster)

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth (zoomed)
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight (zoomed)

#RX	=	0.7134	*	1.51
#RY	= -0.6517	*	1.53
#RZ	=	0.4733	*	1.37

Global	rx.f	=	#RX
Global	ry.f	=	#RY
Global	rz.f	=	#RZ

Procedure	MFC_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Megaforce - Amiga Call - 1988"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 7)
	
	; dusk till down
	C2D::CopperInit(0, 16 * #C2D_Z, ?c_dusk)
	
	; create backbuffer to clear & update background
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, #C2D_H * 0.162, #C2D_W, #C2D_H * 0.394, $FF330000)	; Sky
	Box(0, #C2D_H * 0.558, #C2D_W, #C2D_H * 0.273, $FFAA4444)	; Checker ColorB
	C2D::CopperDraw(0, #C2D_H * 0.491)	; Dusk
	FrontColor($FF555555)
	Box(0, #C2D_H * 0.160, #C2D_W, #C2D_Z)	; Border Top
	Box(0, #C2D_H * 0.832, #C2D_W, #C2D_Z)	; Border Bottom
	C2D::BufferBackGrab()						; Grab for update background
	C2D::BufferClear()
	StopDrawing()
	
	; starfield
	C2D::Stars3DInit(56 * #C2D_Z, #C2D_Z, 0, #C2D_H * 0.165, #C2D_W, #C2D_H * 0.390, 1.6 + #C2D_Z)
	
	; checkboard
	C2D::CheckerInit(#C2D_H * 0.558, #C2D_H * 0.272, #C2D_H * 0.400, 5 + #C2D_Z)
	C2D::CheckerColor($FFCC8888)
	
	; the MFC logo
	C2D::Line3DInit(0, ?l_object, 3.0 * #C2D_Z)
	C2D::Line3DColor(0, $FF00FFFF)
	
	; create font
	C2D::BitmapInit(0, ?i_Font, ?e_font)
	C2D::FontInit(0, C2D::BitmapImage(0), 1, 1)
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, 2 * #C2D_Z)

	; create scroller
	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, 1.5 * #C2D_Z)
	
	; free unused stuff
	C2D::BitmapFree(0)
	C2D::CopperFree(0)
	
	; play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	MFC_Update()
	
	C2D::BufferBackDraw()
	
	C2D::Stars3DDraw(0, #C2D_H * 0.058)
	
	C2D::CheckerDraw(5 * #C2D_Z)
	
	C2D::Line3DRotate(0, rx, ry, rz)
	C2D::Line3DDraw(0, 0, #C2D_H * -0.058)
	
	C2D::ScrollTextDraw(0, #C2D_H * 0.679)

EndProcedure

MFC_Init()

Repeat

	Select	WindowEvent()

		Case	#WM_KEYDOWN

			Select	EventwParam()

				Case	#VK_F1
					rx	=	#RX
					ry	=	#RY
					rz	=	#RZ
				Case	#VK_F2
					rx	=	#RX	*	(1 - Random(1) * 2)
				Case	#VK_F3
					ry	=	#RY	*	(1 - Random(1) * 2)
				Case	#VK_F4
					rx	=	0
					ry	=	0
					rz	=	#RX	*	(1 - Random(1) * 2)
				Case	#VK_F5
					rx	=	#RX	*	(1 - Random(1) * 2)
					ry	=	0
					rz	=	0
				Case	#VK_F6
					rx	=	0
					ry	=	#RX	*	(1 - Random(1) * 2)
					rz	=	0

				Case	#VK_ESCAPE
					Break

			EndSelect

		Case	#PB_Event_CloseWindow
			Break
			
		Default

			If	C2D::Start()
				MFC_Update()
				C2D::Stop()
			EndIf

	EndSelect

ForEver

C2D::Free()

DataSection

	CompilerIf	IsC2D::#IsC2D_Music
		m_music:	:	IncludeBinary	"mus\Megaforce_fixed.mod"	:	e_music:
	CompilerEndIf

	l_object:	:	IncludeBinary	"obj\MFC_Logo.l3d"
	i_font:		:	IncludeBinary	"gfx\MFC_Font.png"	:	e_font:

	c_dusk:		:	Data.l	3, $FF330000, $FF210031, $FF0055FF

	t_text:
	Data.s	"{5}MEGAFORCE{5}{2,5000} FLASHES BACK ON YOUR SCREEN ... AND WE PRESENT AMIGA CALL ... "	+
	      	"IT WAS EASY TO DO CAUSE NO PROTECTION LOADS OUR BRAINS !!! WHAT A PITY !!!	"	+
	      	"HEY CONTROL OUR MFC LOGO ... PRESS HELP AND THEN F1 : F6 FOR DIFFERENT ROTATIONS !!!!		"	+
	      	"WARNING ... WE HAVE NO MEMBERS IN DENMARK OR HOLLAND !!!!  "	+
	      	"OUR MEMBERS ARE FROM AUSTRIA : GERMANY : FRANCE AND U.S.A !!!  "	+
	      	"OKAY OKAY I KNOW THAT YOU LIKE TO SEE THE GREETINGS  SO MEGAFORCED MEGAGREETINGS TO : "	+
	      	"ALL OFFICIAL AND REAL MEGAFORCE MEMBERS WOLRDWIDE ... "	+
	      	"THEN TO:	TRILOGY . IPEC ELITE . BEASTIE BOYS . PLASMA FORCE . WIZZARD . 4FCG . "	+
	      	"POWERSTACK OF AMIGAVISION . NO.1 OF ANTRAX . THE SPECIAL BROTHERS . TFC OF THE 4TH DIMENSION . "	+
	      	"IMP 666 . DISECTOR AND THE CHIP DUO . AND ALL THE OTHERS !!!!{3}"	+
	      	"NOW END OF TRANSMISSION ......	BYE BYE .....{3}"	+
	      	"RETRO BY PEACE"

EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = A-
; Executable = C2D_Megaforce_x86.exe
; DisableDebugger
; CompileSourceDirectory