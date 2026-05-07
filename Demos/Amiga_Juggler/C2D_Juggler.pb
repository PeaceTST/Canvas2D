; C2D::Eric Graham - Juggler - 1986
; Purebasic v6.04 (x86-64) / 03.10.2018

; http://janeway.exotica.org.uk/release.php?id=20371

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictype #XMU_[Type]

	#IsC2D_Mode		=	#PB_2DDrawing_Transparent

	#IsC2D_Clear	=	0

	#IsC2D_Bitmap	=	1
	#IsC2D_Buffer	=	1
	#IsC2D_GdiPlus	=	1
	#IsC2D_Anim		=	1
	#IsC2D_SysFont	=	1	; TTF, FON, OTF, RAW

	;#IsC2D_Help	=	1

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width
#C2D_H	=	240	*	#C2D_Z	; Height

#ANIM_DELAY	=	40

Global	Anim_On, Snd_On
Global	t$	=	PeekS(?t_info)
Global	Count	=	CountString(t$, #LF$)	; #linefeeds

Procedure	Juggler_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Eric Graham - Juggler - 1986"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, #ANIM_DELAY)

	C2D::BitmapInit(0, ?a_anim, ?e_anim)	; 24 HAM6-frames

	C2D::AnimInit(0, C2D::BitmapImage(0), 24, 1)	; FramesX=24, FramesY=1
	C2D::AnimScale(0, #C2D_Z)
	C2D::AnimDelay(0, 0)	; framerate by speed of Init() (#ANIM_DELAY)

	C2D::BitmapInit(0, ?i_back, ?e_back)
	C2D::BitmapScale(0, #C2D_Z)

	StartDrawing(CanvasOutput(#C2D_G))
	C2D::BitmapDraw(0, 0, 20 * #C2D_Z)
	C2D::BufferBackGrab()
	StopDrawing()

	C2D::BitmapFree(0)

	C2D::SysFontInit(0, "Topaz a500a1000a2000 v1.0", ?f_font, ?e_font, 12 * #C2D_Z);, 0, Bool(#C2D_Z<>2) * #PB_Font_HighQuality)

EndProcedure
Procedure	Juggler_Update()

	Protected	i

	; Juggler? or Messagetext?
	If	Anim_On

		; restore static background
		C2D::BufferBackDraw()

		; draw anim & play sound if frame(0) only
		If	C2D::AnimDraw(0, 91 * #C2D_Z, 20 * #C2D_Z)	=	0	And	Snd_On	=	0
			Snd_On	=	PlaySound_(?m_beep, #Null, #SND_MEMORY|#SND_ASYNC|#SND_NODEFAULT)
		ElseIf	Snd_On
			Snd_On	=	0
		EndIf

	Else

		Box(0, 0, #C2D_W, #C2D_H, $990000)

		C2D::SysFontSet(0)

		While	Count	>=	i
			i	+	1	:	DrawText(12 * #C2D_Z, 8 * #C2D_Z + i * 10 * #C2D_Z, StringField(t$, i, #LF$))	; PB default -> #White
		Wend

	EndIf

EndProcedure

Juggler_Init()

Repeat
	Select	WindowEvent()

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN

			Key	=	EventwParam()

			Select	Key

				Case	#VK_0	To	#VK_9

					If	Anim_On	; is Juggler juggling?

						Key	-	#VK_0

						C2D::C2D\Speed	=	#ANIM_DELAY	+	Key	*	#ANIM_DELAY	*	1.6	; Framerate
						PokeL(?m_beep	+	$18, 8000	-	Key	*	700)						; SamplesPerSeconds

					EndIf

				Case	#VK_ESCAPE
					Break

				Default
					Anim_On	!	1	; any other key start/stop juggler

			EndSelect

		Case	#WM_LBUTTONUP
			Anim_On	!	1

		Default
			If	C2D::Start()
				Juggler_Update()
				C2D::Stop()
			EndIf

	EndSelect
ForEver

C2D::Free()

DataSection

	; splittet anim & back for less memory (~14mb} & faster display {~2% cpu)
	a_anim:	:	IncludeBinary	"gfx\Anim_Juggler_24x1.png"			:	e_anim:
	i_back:	:	IncludeBinary	"gfx\Back_Juggler.png"					:	e_back:
	f_font:	:	IncludeBinary	"fnt\Topaz a500a1000a2000 v1.0.fon"	:	e_font:
	m_beep:	:	IncludeBinary	"mus\Beep.wav"

	t_info:
	Data.s	"The individual frames of the movie are being fetched from disk.  When"	+	#LF$	+
	      	"the movie starts you may press any of the digit keys '0' to '9' to"		+	#LF$	+
	      	"change the speed of the movie.  Press the escape key 'ESC' to exit the"+	#LF$	+
	      	"program."	+	#LF$	+
	      	#LF$	+
	      	"The images were generated with a standard Amiga with 512K memory.  A ray"	+	#LF$	+
	      	"tracing method was used, which simulates rays of light reflecting within"	+	#LF$	+
	      	"a mathematically defined scene.  Each image requires the calculation of"	+	#LF$	+
	      	"64,000 light rays and takes approximately 1 hour to generate.  An image"	+	#LF$	+
	      	"is compressed to about 10K bytes for storage.  Images are expanded in"		+	#LF$	+
	      	"less than 30 milliseconds.  The Amiga hold and modify mode is employed"	+	#LF$	+
	      	"so that up to 4096 colors can be displayed at one time."	+	#LF$	+
	      	#LF$	+
	      	#LF$	+
	      	" Copyright © 1986 Eric Graham"	+	#LF$	+
	      	#LF$	+
	      	"NOW PRESS ANY KEY TO START THE MOVIE"

EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = w
; Executable = C2D_Juggler_x86.exe
; CompileSourceDirectory