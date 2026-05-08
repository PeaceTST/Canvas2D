; ***************************************************
; C2D::Splatter Editor - 15.01.2024 - 13:11 - PB 6.04
; C2D::Splatter Editor - 04.04.2023 - 14:15 - PB 6.01
; ***************************************************

EnableExplicit

;***************************************************
; *** IsC2D the MUST Init-Module, always needed! ***
;***************************************************
IncludePath	"..\..\Include\"	; adapt path of include

DeclareModule	IsC2D	; Defaults -> all on!

	XIncludeFile	"C2D_Types.pbi"	; Music, Gui, XUnPack predefined #Types

	#IsC2D_Gui			=	#Gui_GadgetDrawButton|#Gui_GadgetTrack|#Gui_GadgetDrawText
	#IsC2D_Splatter	=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Clear		=	0
	#IsC2D_Anim			=	1
	#IsC2D_Bitmap		=	1
	#IsC2D_BitmapColor=	1
	#IsC2D_GdiPlus		=	1
	#IsC2D_File			=	1
	#IsC2D_Fps			=	1
	#IsC2D_Help			=	0

	XIncludeFile	"C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;***************************************************
;UseModule	C2D

#R_SIZE	=	10		; Raster size for transparent background
#S_SIZE	=	8		; default splatter size
#G_W		=	360	; Trackerwidth
#B_W		=	46		; Buttonwidth
#G_H		=	20		; Gadgetheight

; CanvasGadget, Width & Height
#C2D_G	=	0	; #Gadget
#C2D_W	=	800	/	#R_SIZE	*	#R_SIZE
#C2D_H	=	(600 - 8 - 6 * 16)	/	#R_SIZE	*	#R_SIZE	+	 12 + 7 * 16

Enumeration	1
	#G_START
	#G_STOP
	#G_CODE
	#G_LOOP
	#G_COLOR
	#G_BACK
	#G_ANIM
	#G_IMAGE
	#G_LOAD
	#G_MODE
	#G_PREVIEW
	#G_INFO
	#G_ZERO
	#G_SIZE
	#G_NUMBER
	#G_GRAVITY
	#G_ENERGY
	#G_SPREADX
	#G_SPREADY
	#G_ACCLX
	#G_ACCLY
	#G_FADE
	#G_BOUNCE
	#G_ALPHA
	#G_SPEED	; C2D Updatetime
	#G_0
	#G_1
	#G_2
	#G_3
	#G_4
	#G_5
	#G_6
	#G_7
	#G_8
	#G_9
EndEnumeration

Structure	RS_Init
	ID.i	; setup
	Color.q
	Back.q
	Preview.i	; 0=Splatter / 1=Image / 2=Anim
	Speed.i		; C2D Updatetime in ms
	PrefsPath$
EndStructure

Structure	SetUp
	Gravity.i
	Energy.i
	Fade.i
	SpreadX.i
	SpreadY.i
	AcclX.i
	AcclY.i
	Bounce.i
	Alpha.i
	Number.i
	Size.i
EndStructure

Structure	RS_PanelImage
	Window.i
	w.i
	h.i

	Gadget.i
	gW.d
	gH.d

	Factor.d
	Percent.d
	IsRaster.i
	RasterSize.i	; RasterSize

	IsFrame.i		; x/y frames

	BitmapID.i
	AnimID.i

	BackColor.q
	ClearRGB.q	; use Quad coz Long is only upto $7FFFFFFF
	Mode.i		; DrawingMode
	Image.i
	iWidth.i		; Real Imagewidth
	iHeight.i	; Real Imageheight
	sW.d			; Sized Imagewidth
	sH.d			; Sized Imageheight
	iPosX.i		; X-StartDrawPos
	iPosY.i		; Y-StartDrawPos

	File$
	Info$
	List Quick.String()

	IsAnim.i	; IsAnim?
	FramesX.i	; FramesX
	FramesY.i	; FramesY
	Time.i		; Frame Time
	IsPingPong.i	; PingPong Loop?
	IsBackward.i	; Reverse play
	FrameStart.i	; FrameStart
	FrameNumber.i	; FrameEnd
EndStructure

Global	RS_PI.RS_PanelImage

Global	RS_Init.RS_Init, Dim	SetUp.SetUp(9)

Procedure	C2D_About()

	Protected	t$

	t$	=	MA_C2DOS("Splatter / Editor "	+	ReplaceString(FormatDate("v%yy.%mm%ddß", #PB_Compiler_Date), ".0", "."))	+	#LF$	+	#LF$	+
	  	 	"Module:"	+	#TAB$	+	"Canvas2D v"+	MA_XC2D()	+	#LF$	+	#LF$	+
	  	 	"Window:"	+	#TAB$	+	Str(WindowWidth(0)) + " × " + Str(WindowHeight(0))	+	#LF$	+
	  	 	"Canvas:"	+	#TAB$	+	Str(GadgetWidth(#C2D_G)) + " × " + Str(GadgetHeight(#C2D_G))	+	#LF$	+	#LF$	+
	  	 	FormatDate("Compiled: %dd.%mm.%yyyy %hh:%ii:%ss - Purebasic v" + StrF(#PB_Compiler_Version * 0.01, 2)	+	#LF$	+	#LF$	+
	  	 	"Peace^TST - testaware.wordpress.com", #PB_Compiler_Date)

	MessageRequester("About", t$, #PB_MessageRequester_Ok|#PB_MessageRequester_Info)

EndProcedure

Procedure	C2D_Prefs(Mode)

	Protected	t$, i

	If	RS_Init\PrefsPath$	=	""
		t$	=	ProgramFilename()
		RS_Init\PrefsPath$	=	GetPathPart(t$)	+	GetFilePart(t$, #PB_FileSystem_NoExtension)	+	".prefs"
	EndIf

	If	Mode

		If	CreatePreferences(RS_Init\PrefsPath$, #PB_Preference_GroupSeparator)

			PreferenceComment(MA_C2DPB("Splatter Editor")) ; Marker
			PreferenceComment("")

			PreferenceGroup("Color")

			With	RS_Init
				WritePreferenceInteger("ID",		\ID)
				WritePreferenceQuad("Color",		\Color)
				WritePreferenceQuad("Back",		\Back)
				WritePreferenceInteger("Speed",	\Speed)
			EndWith

			PreferenceGroup("Image")

			With	RS_PI
				WritePreferenceInteger("IsRaster",		\IsRaster)
				WritePreferenceQuad("BackColor",			\BackColor)
				WritePreferenceQuad("ClearRGB",			\ClearRGB)
				WritePreferenceInteger("IsAnim",			\IsAnim)
				WritePreferenceInteger("FramesX",		\FramesX)
				WritePreferenceInteger("FramesY",		\FramesY)
				WritePreferenceInteger("Time",			\Time)
				WritePreferenceInteger("FrameStart",	\FrameStart)
				WritePreferenceInteger("FrameNumber",	\FrameNumber)
				WritePreferenceInteger("IsPingPong",	\IsPingPong)
				WritePreferenceInteger("IsBackward",	\IsBackward)
				WritePreferenceInteger("IsFrame",		\IsFrame)
				ForEach	\Quick()
					WritePreferenceString(Str(ListIndex(\Quick())),	\Quick()\s)
				Next
			EndWith

			For	i	=	0	To	9

				PreferenceGroup("ID" + Str(i))

				With	SetUp(i)
					WritePreferenceInteger("AcclX",	\AcclX)
					WritePreferenceInteger("AcclY",	\AcclY)
					WritePreferenceInteger("Alpha",	\Alpha)
					WritePreferenceInteger("Bounce",	\Bounce)
					WritePreferenceInteger("Energy",	\Energy)
					WritePreferenceInteger("Fade",	\Fade)
					WritePreferenceInteger("Gravity",\Gravity)
					WritePreferenceInteger("Number",	\Number)
					WritePreferenceInteger("Size",	\Size)
					WritePreferenceInteger("SpreadX",\SpreadX)
					WritePreferenceInteger("SpreadY",\SpreadY)
				EndWith

			Next

			ClosePreferences()

		EndIf

	Else

		OpenPreferences(RS_Init\PrefsPath$, #PB_Preference_GroupSeparator)

			PreferenceGroup("Color")

			With	RS_Init
				\ID		=	ReadPreferenceInteger("ID",		0)
				\Color	=	ReadPreferenceQuad("Color",		#Red)
				\Back		=	ReadPreferenceQuad("Back",			#Black)
				\Speed	=	ReadPreferenceInteger("Speed",	5)	; C2D UpdateTime in ms
			EndWith

			PreferenceGroup("Image")

			With	RS_PI
				\IsRaster	=	ReadPreferenceInteger("IsRaster",	\IsRaster)
				\BackColor	=	ReadPreferenceQuad("BackColor",		\BackColor)
				\ClearRGB	=	ReadPreferenceQuad("ClearRGB",		\ClearRGB)
				\IsAnim		=	ReadPreferenceInteger("IsAnim",		\IsAnim)
				\FramesX		=	ReadPreferenceInteger("FramesX",		\FramesX)
				\FramesY		=	ReadPreferenceInteger("FramesY",		\FramesY)
				\Time			=	ReadPreferenceInteger("Time",			\Time)
				\FrameStart	=	ReadPreferenceInteger("FrameStart",	\FrameStart)
				\FrameNumber=	ReadPreferenceInteger("FrameNumber",\FrameNumber)
				\IsPingPong	=	ReadPreferenceInteger("IsPingPong",	\IsPingPong)
				\IsBackward	=	ReadPreferenceInteger("IsBackward",	\IsBackward)
				\IsFrame		=	ReadPreferenceInteger("IsFrame",		\IsFrame)
				i	=	0
				Repeat
					t$	=	ReadPreferenceString(Str(i),	#Null$)
					If	t$
						AddElement(\Quick())	:	\Quick()\s	=	t$	:	i	+	1
					EndIf
				Until	t$	=	""
			EndWith

			For	i	=	0	To	9

				PreferenceGroup("ID" + Str(i))

				With	SetUp(i)
					\AcclX	=	ReadPreferenceInteger("AcclX",	190)
					\AcclY	=	ReadPreferenceInteger("AcclY",	160)
					\Alpha	=	ReadPreferenceInteger("Alpha",	$FF)
					\Bounce	=	ReadPreferenceInteger("Bounce",	50)
					\Energy	=	ReadPreferenceInteger("Energy",	256)
					\Fade		=	ReadPreferenceInteger("Fade",		8)
					\Gravity	=	ReadPreferenceInteger("Gravity",	40)
					\Number	=	ReadPreferenceInteger("Number",	128)
					\Size		=	ReadPreferenceInteger("Size",		50)
					\SpreadX	=	ReadPreferenceInteger("SpreadX",	1)
					\SpreadY	=	ReadPreferenceInteger("SpreadY",	1)
				EndWith

			Next

		ClosePreferences()

	EndIf

EndProcedure
Procedure	C2D_SetUp(i)

	Static	n=0

	If	i	<	0	Or	i	>	9	:	ProcedureReturn	:	EndIf

	RS_Init\ID	=	i

	With	SetUp(n)
		\AcclX	=	C2D::GuiGetState(#G_ACCLX)
		\AcclY	=	C2D::GuiGetState(#G_ACCLY)
		\Alpha	=	C2D::GuiGetState(#G_ALPHA)
		\Bounce	=	C2D::GuiGetState(#G_BOUNCE)
		\Energy	=	C2D::GuiGetState(#G_ENERGY)
		\Fade		=	C2D::GuiGetState(#G_FADE)
		\Gravity	=	C2D::GuiGetState(#G_GRAVITY)
		\Number	=	C2D::GuiGetState(#G_NUMBER)
		\Size		=	C2D::GuiGetState(#G_SIZE)
		\SpreadX	=	C2D::GuiGetState(#G_SPREADX)
		\SpreadY	=	C2D::GuiGetState(#G_SPREADY)
	EndWith

	With	SetUp(i)
		C2D::GuiSetState(#G_ACCLX,		\AcclX)
		C2D::GuiSetState(#G_ACCLY,		\AcclY)
		C2D::GuiSetState(#G_ALPHA,		\Alpha)
		C2D::GuiSetState(#G_BOUNCE,	\Bounce)
		C2D::GuiSetState(#G_ENERGY,	\Energy)
		C2D::GuiSetState(#G_FADE,		\Fade)
		C2D::GuiSetState(#G_GRAVITY,	\Gravity)
		C2D::GuiSetState(#G_NUMBER,	\Number)
		C2D::GuiSetState(#G_SIZE,		\Size)
		C2D::GuiSetState(#G_SPREADX,	\SpreadX)
		C2D::GuiSetState(#G_SPREADY,	\SpreadY)
	EndWith

	n	=	i

EndProcedure

Procedure	C2D_SetAnimation()

	With	RS_PI

		If	\BitmapID	<=	#Null	Or	C2D::IsBitmap(\BitmapID)	<=	#Null	:	ProcedureReturn	:	EndIf

		If	\AnimID	And	C2D::IsAnim(\AnimID)
			C2D::AnimFree(\AnimID)
		EndIf

		\AnimID	=	C2D::AnimInit(#PB_Any, C2D::BitmapImage(\BitmapID), \FramesX, \FramesY)
		C2D::AnimScale(\AnimID,	0.01 * C2D::GuiGetState(#G_SIZE) * 2)	; scale ± 100%
		C2D::AnimDelay(\AnimID,	\Time)												; timer per frame
		C2D::AnimPingPong(\AnimID,	\IsPingPong)												; ping pong

		If	\IsBackward	:	C2D::AnimDirection(\AnimID, -1)	:	EndIf			; Reverse direction

		C2D::AnimRange(\AnimID, \FrameStart-1, \FrameNumber-1)

	EndWith

EndProcedure

Procedure	C2D_Set(x.f=#C2D_W*0.5, y.f=#C2D_H*0.15)

	Protected	Image, Zoom, s, n, m=-1, IsChanged
	Static	Scale=100, AnimScale=100

	n	=	C2D::GuiGetState(#G_NUMBER)
	s	=	C2D::GuiGetState(#G_SIZE)	*	2

	If	m	<>	C2D::GuiGetState(#G_MODE)
		m	=	C2D::GuiGetState(#G_MODE)
		C2D::Quality(Bool(m=0))
	EndIf

	If	C2D::IsSplatter(0)	=	0	Or	ListSize(C2D::RS_Splatter()\ID())	<>	n	Or	Scale	<>	s
		IsChanged	=	#True
	EndIf

	If	RS_PI\BitmapID	And	C2D::IsBitmap(RS_PI\BitmapID)

		If	C2D::GuiGetState(#G_IMAGE)

			C2D::SplatterAnim(0, -1)

			If	IsChanged

				Scale	=	s

				C2D::SplatterInit(0, 1, n, RS_Init\Color)
				C2D::SplatterImage(0, C2D::BitmapImage(RS_PI\BitmapID))
				C2D::SplatterScale(0, 0.01 * Scale)

			EndIf

		ElseIf	C2D::GuiGetState(#G_ANIM)	And	C2D::IsAnim(RS_PI\AnimID)	; is anim toggled in mainwindow?

			If	IsChanged
				C2D::SplatterInit(0, 1, n, RS_Init\Color)
			EndIf

			If	AnimScale	<>	s
				AnimScale	=	s
				C2D_SetAnimation()
			EndIf

			C2D::SplatterAnim(0, RS_PI\AnimID)		; use anim!

		Else

			C2D::SplatterAnim(0, -1)

			If	IsChanged

				Scale	=	s
				Zoom	=	0.01 * Scale * 8	:	If	Zoom	<	1	:	Zoom	=	1	:	EndIf

				C2D::SplatterInit(0, Zoom, n, RS_Init\Color)

			EndIf

		EndIf

	Else

		C2D::SplatterAnim(0, -1)

		If	IsChanged

			Scale	=	s
			Zoom	=	0.01 * Scale * 8	:	If	Zoom	<	1	:	Zoom	=	1	:	EndIf

			C2D::SplatterInit(0, Zoom, n, RS_Init\Color)

		EndIf

	EndIf

	C2D::SplatterAcceleration(0,	C2D::GuiGetState(#G_ACCLX),	C2D::GuiGetState(#G_ACCLY))
	C2D::SplatterSpread(0,			C2D::GuiGetState(#G_SPREADX),	C2D::GuiGetState(#G_SPREADY))
	C2D::SplatterGravity(0,			C2D::GuiGetState(#G_GRAVITY))
	C2D::SplatterEnergy(0,			C2D::GuiGetState(#G_ENERGY) * 10)
	C2D::SplatterFade(0,				C2D::GuiGetState(#G_FADE))
	C2D::SplatterBounce(0,			C2D::GuiGetState(#G_BOUNCE))
	C2D::SplatterLoop(0,				C2D::GuiGetState(#G_LOOP))
	C2D::SplatterAlpha(0,			C2D::GuiGetState(#G_ALPHA))

	If	y	>	C2D::C2D\h
		x	=	(C2D::C2D\w	-	C2D::SplatterW(0))	*	0.5
		y	=	C2D::C2D\h	*	0.2
	EndIf

	C2D::SplatterStart(0, x, y)

EndProcedure
Procedure	C2D_Code()

	Protected g, t$, Gadget

	DisableGadget(#C2D_G, 1)	:	HideGadget(#C2D_G, 1)

	C2D::GuiDisableRegion(0, 1, 0, 0, #C2D_W, #C2D_H)
	C2D::GuiDisable(#G_CODE, 0)
	C2D::GuiRefresh(#PB_All)

	g = EditorGadget(#PB_Any, GadgetX(#C2D_G), GadgetY(#C2D_G), GadgetWidth(#C2D_G), GadgetHeight(#C2D_G))

	t$	=	"C2D::SplatterAcceleration(0, "	+ Str(C2D::GuiGetState(#G_ACCLX)) + ", "		+	Str(C2D::GuiGetState(#G_ACCLY)) + ")"		+	#LF$	+
	  	 	"C2D::SplatterSpread(0, "			+ Str(C2D::GuiGetState(#G_SPREADX)) + ", "	+	Str(C2D::GuiGetState(#G_SPREADY)) + ")"	+	#LF$	+
	  	 	"C2D::SplatterGravity(0, "			+ Str(C2D::GuiGetState(#G_GRAVITY)) + ")"		+	#LF$	+
	  	 	"C2D::SplatterEnergy(0, "			+ Str(C2D::GuiGetState(#G_ENERGY)) + ")"		+	#LF$	+
	  	 	"C2D::SplatterFade(0, "				+ Str(C2D::GuiGetState(#G_FADE)) + ")"			+	#LF$	+
	  	 	"C2D::SplatterBounce(0, "			+ Str(C2D::GuiGetState(#G_BOUNCE)) + ")"		+	#LF$	+
	  	 	"C2D::SplatterLoop(0, "				+ Str(C2D::GuiGetState(#G_LOOP))	+	")"		+	#LF$	+
	  	 	"C2D::SplatterAlpha(0, "			+ Str(C2D::GuiGetState(#G_ALPHA)) + ")"		+	#LF$	+
	  	 	"C2D::SplatterScale(0, "			+ StrF(0.02 * C2D::GuiGetState(#G_SIZE),2) +	")"

	SetGadgetText(g, t$)

	Repeat
		Select	WaitWindowEvent()
			Case	#PB_Event_Gadget
				Gadget	=	EventGadget()
				Select	C2D::GuiEvent(Gadget)
					Case	#G_CODE
						Break
				EndSelect
			Case	#WM_KEYDOWN
				Select	EventwParam()
					Case	#VK_ESCAPE	:	Break
				EndSelect
			Case	#PB_Event_CloseWindow
				Break
		EndSelect
	ForEver

	C2D::GuiDisableRegion(0, 0, 0, 0, #C2D_W, #C2D_H)
	C2D::GuiSetState(#G_CODE, 0)

	C2D::GuiDisable(#G_IMAGE,	Bool(C2D::IsBitmap(RS_PI\BitmapID)<=0))
	C2D::GuiDisable(#G_ANIM,	Bool(C2D::IsAnim(RS_PI\AnimID)<=0))
	C2D::GuiDisable(#G_PREVIEW,C2D::GuiGetState(#G_COLOR))

	C2D::GuiRefresh(#PB_All)

	DisableGadget(#C2D_G, 0)	:	HideGadget(#C2D_G, 0)

	FreeGadget(g)

EndProcedure

Procedure	Panel_Init()

	With	RS_PI

		\IsAnim		=	0
		\FramesX		=	8
		\FramesY		=	8
		\Time			=	100
		\IsPingPong	=	0
		\IsBackward	=	0
		\FrameStart	=	0
		\FrameNumber=	8	*	8

		\IsRaster	=	1
		\RasterSize	=	#R_SIZE
		\BackColor	=	#Black
		\ClearRGB	=	$FFFF00FF

		\IsFrame		=	1

		\w	=	((760	-	240)	/	#R_SIZE)	*	#R_SIZE	+	240
		\h	=	((440	-	8)		/	#R_SIZE)	*	#R_SIZE	+	8	; (+8 = 4 left / 4 right)

		\gW	=	((\w	- 240)	/	#R_SIZE)	*	#R_SIZE
		\gH	=	((\h	-	8)		/	#R_SIZE)	*	#R_SIZE

	EndWith

EndProcedure
Procedure	Panel_Image()

	Protected	i, x, y

	With	RS_PI

		\iWidth	=	ImageWidth(\Image)
		\iHeight	=	ImageHeight(\Image)

		\sW	=	\iWidth
		\sH	=	\iHeight

		\gW	=	GadgetWidth(\Gadget)		-	2
		\gH	=	GadgetHeight(\Gadget)	-	2

		\Factor	=	0
		\Percent	=	1.0

		; calculate size of image. strange results in some cases!
		; -------------------------------------------------------
		Repeat

			If	\sW	>	\gW	Or	\sH	>	\gH

				If	\sW	>	\sH
					\Factor	=	\gW	*	(\Percent	/	\sW)
				Else
					\Factor	=	\gH	*	(\Percent	/	\sH)
				EndIf

				\sW	*	\Factor
				\sH	*	\Factor

			EndIf

			\Percent	-	0.01

		Until	\sW	<=	\gW	And	\sH	<=	\gH

		; draw sized image in canvas
		; --------------------------
		StartDrawing(CanvasOutput(\Gadget))

		DrawingMode(#PB_2DDrawing_AlphaBlend)

		\gW	=	OutputWidth()
		\gH	=	OutputHeight()

		\iPosX	=	(\gW	-	\sW)	/	2
		\iPosY	=	(\gH	-	\sH)	/	2

		If	\IsRaster	; raster
			Box(0, 0, \gW, \gH, $FFFFFFFF)
			FrontColor($34000000)
			For	y	=	0	To	\gH	/	\RasterSize
				For	x	=	0	To	\gW	/	(\RasterSize * 2)
					Box((x * \RasterSize * 2) + i * \RasterSize, y * \RasterSize, \RasterSize, \RasterSize)
				Next
				i	!	1
			Next
		Else	; backcolor
			Box(0, 0, \gW, \gH, $FF000000|\BackColor)
		EndIf

		DrawImage(ImageID(\Image), \iPosX, \iPosY, \sW, \sH)

		If	\IsAnim	And	\IsFrame	And	\BitmapID	And	C2D::IsBitmap(\BitmapID)
			DrawingMode(#PB_2DDrawing_XOr)
			For	x	=	0	To	\FramesX
				i	=	\iPosX + \sW / \FramesX * x
				LineXY(i, \iPosY, i, \iPosY + \sH, $FFFFFFFF)
			Next
			For	y	=	0	To	\FramesY
				i	=	\iPosY + \sH / \FramesY * y
				LineXY(\iPosX, i, \iPosX + \sW, i, $FFFFFFFF)
			Next
			DrawingMode(#PB_2DDrawing_AlphaBlend)
		EndIf

		C2D::GuiDrawFrame(C2D::#Gui_FrameFlat, 0, 0, \gW, \gH, 112)

		StopDrawing()

		; set window-title with dimensions of image
		; -----------------------------------------
		\Info$	=	Str(\iWidth) + " x " + Str(\iHeight)
		If	\Factor
			\Factor	=	\sW	/	\iWidth	;:	Debug	\Factor
			;\Factor	=	\sH	/	\iHeight	:	Debug	\Factor
			\Info$	+ " - Sized: " + Str(\sW) + " x " + Str(\sH) + " - Factor: " + StrF(\Factor, 3)
		EndIf
		If	\File$	:	\Info$	=	GetFilePart(\File$)	+	": "	+	\Info$	:	EndIf
		SetWindowTitle(\Window, \Info$)

	EndWith

EndProcedure
Procedure	Panel_Request()

	Protected	t$, i, x, y, w, Time.q, Color.q
	Protected	gAnim, gAF, gAP, gAX, gAY, gAT, gAR, gAS, gAE, gFS, gFE
	Protected	Gadget, gOpen, gQuick, gRaster, gBack, gRGB, gClear, gAbort, gOK

	While	WindowEvent()	:	Wend	:	Delay(100)

	With	RS_PI

		If	\w	<=	#Null	:	Panel_Init()	:	EndIf	; simple check to init

		;{ GUI of ImageRequest }

		\Window	=	OpenWindow(#PB_Any, 0, 0, \w, \h, "", #PB_Window_SystemMenu|#PB_Window_WindowCentered|#PB_Window_Invisible, GadgetID(#C2D_G))
		SetWindowColor(\Window, GetWindowColor(0))

		\Gadget	=	CanvasGadget(#PB_Any, 4, 4, \gW, \gH)

		If	\BitmapID	And	C2D::IsBitmap(\BitmapID)
			\Image	=	C2D::BitmapImage(\BitmapID)
		Else
			\Image	=	C2D::RS_Splatter()\Image
		EndIf

		Panel_Image()

		x	=	\gW	+	8	:	y	=	-#G_H	:	w	=	\w	-	x	-	4	-	160

		C2D::GuiFrame(C2D::#Gui_Frame3D)	:	C2D::GuiColor(#Black)

		y	+	#G_H	+	4	:	gOpen	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "Load Image")

		C2D::GuiLine(x-4, y+#G_H+9, w+8, $7F, C2D::#Gui_FlagToggle)

		gQuick	=	ListViewGadget(#PB_Any, x + w + 4, y, \w - x - w - 8, \h - 8)

		y	+	#G_H	+	18	:	C2D::GuiFrame(C2D::#Gui_FrameNone)	:	C2D::GuiDrawTextGadget(#PB_Any, x, y, w, 0, "Background", C2D::#Gui_FlagCenter)	:	C2D::GuiFrame(C2D::#Gui_Frame3D)
		y	=	C2D::GuiPosY(2)	:	gRaster	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "Raster On", C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle, "Raster Off")
		y	+	#G_H					:	gBack		=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "Set Backcolor")

		C2D::GuiLine(x-4, y+#G_H+9, w+8)

		t$	=	"{PF,3}{BX,6,6," + Str(w/2-12) + "," + Str(#G_H-12) + "}"	; Color to clear

		y	+	#G_H	+	18	:	C2D::GuiFrame(C2D::#Gui_FrameNone)	:	C2D::GuiDrawTextGadget(#PB_Any, x, y, w, 0, "Transparency", C2D::#Gui_FlagCenter)	:	C2D::GuiFrame(C2D::#Gui_Frame3D)	:	y	=	C2D::GuiPosY(2)
		gRGB		=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w/2, #G_H, t$, C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
		gClear	=	C2D::GuiDrawButtonGadget(#PB_Any, C2D::GuiPosX(), y, w/2, #G_H, "Clear")

		C2D::GuiLine(x-4, y+#G_H+9, w+8)

		y	+	#G_H	+	18	:	C2D::GuiFrame(C2D::#Gui_FrameNone)	:	C2D::GuiDrawTextGadget(#PB_Any, x, y, w, 0, "Animation", C2D::#Gui_FlagCenter)	:	C2D::GuiFrame(C2D::#Gui_Frame3D)
		y	=	C2D::GuiPosY(2)	:	gAnim	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "Anim On", C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle, "Anim Off")

		C2D::GuiFrame(C2D::#Gui_FrameNone)	:	y	+	4
		y	+	#G_H	:	C2D::GuiDrawTextGadget(#PB_Any, x, y, 12, #G_H, "X:")	:	gAX	=	SpinGadget(#PB_Any, C2D::GuiPosX(), y, w-12, #G_H, 1, 255, #PB_Spin_Numeric)
		y	+	#G_H	:	C2D::GuiDrawTextGadget(#PB_Any, x, y, 12, #G_H, "Y:")	:	gAY	=	SpinGadget(#PB_Any, C2D::GuiPosX(), y, w-12, #G_H, 1, 255, #PB_Spin_Numeric)
		y	+	#G_H	:	C2D::GuiDrawTextGadget(#PB_Any, x, y, 12, #G_H, "T:")	:	gAT	=	SpinGadget(#PB_Any, C2D::GuiPosX(), y, w-12, #G_H, 1, 255, #PB_Spin_Numeric)

		y	+	#G_H	:	gAS	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, 12, #G_H, "S:")	:	gFS	=	SpinGadget(#PB_Any, C2D::GuiPosX(), y, w-12, #G_H, 1, 255*255, #PB_Spin_Numeric)
		y	+	#G_H	:	gAE	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, 12, #G_H, "N:")	:	gFE	=	SpinGadget(#PB_Any, C2D::GuiPosX(), y, w-12, #G_H, 1, 255*255, #PB_Spin_Numeric)

		C2D::GuiFrame(C2D::#Gui_Frame3D)

		y	+	#G_H	+	4	:	gAR	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "Backwards",	C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
		y	+	#G_H			:	gAP	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "Ping Pong",	C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
		y	+	#G_H			:	gAF	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "Frames On",	C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle, "Frames Off")

		C2D::GuiLine(x-4, y+#G_H+9, w+8)

		y	=	\h - 3	*	(#G_H + 4)
		y	+	#G_H	+	4	:	gAbort	=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "Abort")
		y	+	#G_H	+	4	:	gOK		=	C2D::GuiDrawButtonGadget(#PB_Any, x, y, w, #G_H, "OK")

		; quick file-select
		ForEach	\Quick()
			AddGadgetItem(gQuick, -1, GetFilePart(\Quick()\s))
		Next

		C2D::GuiSetState(gRaster, \IsRaster)

		C2D::GuiDisable(gRGB,	Bool(\BitmapID<=0))
		C2D::GuiDisable(gClear, Bool(\BitmapID<=0))

		; anim
		C2D::GuiSetState(gAnim,	\IsAnim)
		C2D::GuiDisable(gAnim,	Bool(\BitmapID<=0))

		SetGadgetState(gAX,	\FramesX)
		SetGadgetState(gAY,	\FramesY)
		SetGadgetState(gAT,	\Time)
		SetGadgetState(gFS,	\FrameStart)
		SetGadgetState(gFE,	\FrameNumber)

		C2D::GuiSetState(gAP,\IsPingPong)
		C2D::GuiSetState(gAR,\IsBackward)
		C2D::GuiSetState(gAF,\IsFrame)

		i	=	Bool(\IsAnim=0 Or \BitmapID<=0)
		DisableGadget(gAX,	i)
		DisableGadget(gAY,	i)
		DisableGadget(gAT,	i)
		C2D::GuiDisable(gAS,	i)	:	DisableGadget(gFS,	i)
		C2D::GuiDisable(gAE,	i)	:	DisableGadget(gFE,	i)
		C2D::GuiDisable(gAP,	i)
		C2D::GuiDisable(gAR,	i)
		C2D::GuiDisable(gAF,	i)

		C2D::GuiRefresh(#PB_All)

		HideWindow(\Window, 0)

		;}

		Repeat
			Select	WaitWindowEvent()
				Case	#PB_Event_Gadget

					Gadget	=	EventGadget()

					Select	C2D::GuiEvent(Gadget)

						Case	gOpen

							t$	=	OpenFileRequester("Load image", \File$, "Imagefiles|*.*",0)

							If	t$

								\File$	=	t$

								; file already in list (recursive)?
								t$	=	UCase(t$)
								i	=	#True
								While	i
									i	=	#False
									ForEach	\Quick()
										If	UCase(\Quick()\s)	=	t$
											RemoveGadgetItem(gQuick, ListIndex(\Quick()))
											DeleteElement(\Quick())
											i	=	#True
											Break
										EndIf
									Next
								Wend

								If	\BitmapID	And	C2D::IsBitmap(\BitmapID)
									C2D::BitmapFree(\BitmapID)
								EndIf

								\BitmapID	=	C2D::BitmapInit(#PB_Any, @\File$)

								If	\BitmapID	And	C2D::IsBitmap(\BitmapID)
									\Image	=	C2D::BitmapImage(\BitmapID)
									\FramesX	=	GetGadgetState(gAX)
									\FramesY	=	GetGadgetState(gAY)
									Panel_Image()
								EndIf

								i	=	Bool(\BitmapID<=0)
								C2D::GuiDisable(gRGB,	i)
								C2D::GuiDisable(gClear, i)
								C2D::GuiDisable(gAnim,	i)

								i	=	Bool(\IsAnim=0 Or \BitmapID<=0)
								DisableGadget(gAX,	i)
								DisableGadget(gAY,	i)
								DisableGadget(gAT,	i)
								C2D::GuiDisable(gAS,	i)	:	DisableGadget(gFS,	i)
								C2D::GuiDisable(gAE,	i)	:	DisableGadget(gFE,	i)
								C2D::GuiDisable(gAP,	i)
								C2D::GuiDisable(gAR,	i)
								C2D::GuiDisable(gAF,	i)

								FirstElement(\Quick())	:	InsertElement(\Quick())	:	\Quick()\s	=	\File$
								AddGadgetItem(gQuick, 0, GetFilePart(\File$))

								; tricky max. entries
								While	ListSize(\Quick())	And	CountGadgetItems(gQuick)	And	GetWindowLongPtr_(GadgetID(gQuick), #GWL_STYLE)	&	#WS_VSCROLL	<>	0
									LastElement(\Quick())	:	DeleteElement(\Quick())
									RemoveGadgetItem(gQuick, CountGadgetItems(gQuick) - 1)
								Wend

								If	CountGadgetItems(gQuick)
									SetGadgetState(gQuick, 0)
								EndIf

							EndIf

						Case	gRaster

							\IsRaster	=	C2D::GuiGetState(gRaster)

							\FramesX	=	GetGadgetState(gAX)
							\FramesY	=	GetGadgetState(gAY)

							Panel_Image()

						Case	gBack

							i	=	ColorRequester(\BackColor)

							If	i	>	-1
								\BackColor	=	i
								\IsRaster	=	0
								C2D::GuiSetState(gRaster, 0)
								C2D::GuiPaletteSetColor(2, \BackColor)
								\FramesX	=	GetGadgetState(gAX)
								\FramesY	=	GetGadgetState(gAY)
								Panel_Image()
							EndIf

						Case	gClear	; ClearColor of Bitmap

							If	C2D::IsBitmap(\BitmapID)

								StartDrawing(ImageOutput(C2D::BitmapImage(\BitmapID)))
								DrawingMode(#PB_2DDrawing_AlphaChannel)
								For	y	=	0	To	\iHeight-1
									For	x	=	0	To	\iWidth-1
										Color	=	Point(x, y)
										If	Color	=	\ClearRGB	; use Quad coz Long is only upto $7FFFFFFF
											Plot(x, y, #Null)
										EndIf
									Next
								Next
								StopDrawing()

								\FramesX	=	GetGadgetState(gAX)
								\FramesY	=	GetGadgetState(gAY)

								Panel_Image()	; Update

							EndIf

						Case	gAnim

							\IsAnim	=	C2D::GuiGetState(gAnim)

							i	=	Bool(\IsAnim=0)
							DisableGadget(gAX, i)
							DisableGadget(gAY, i)
							DisableGadget(gAT, i)
							C2D::GuiDisable(gAS, i)	:	DisableGadget(gFS, i)
							C2D::GuiDisable(gAE, i)	:	DisableGadget(gFE, i)

							C2D::GuiDisable(gAP, i)
							C2D::GuiDisable(gAR, i)
							C2D::GuiDisable(gAF, i)

							\FramesX	=	GetGadgetState(gAX)
							\FramesY	=	GetGadgetState(gAY)

							Panel_Image()

						Case	gAS	:	SetGadgetState(gFS, #Null)	; startframe
						Case	gAE	:	SetGadgetState(gFE, GetGadgetState(gAX) * GetGadgetState(gAY))	; endframe

						Case	gAF

							\IsFrame	=	C2D::GuiGetState(gAF)

							\FramesX	=	GetGadgetState(gAX)
							\FramesY	=	GetGadgetState(gAY)

							Panel_Image()

						Case	gOK

							If	\BitmapID	And	C2D::IsBitmap(\BitmapID)

								If	\IsAnim

									\FramesX	=	GetGadgetState(gAX)	; Frames X
									\FramesY	=	GetGadgetState(gAY)	; Frames Y

									\Time	=	GetGadgetState(gAT)	; Time per frame

									\FrameStart	=	GetGadgetState(gFS)	; FrameStart
									\FrameNumber=	GetGadgetState(gFE)	; FrameEnd

									\IsPingPong	=	C2D::GuiGetState(gAP); Ping Pong
									\IsBackward	=	C2D::GuiGetState(gAR); Reverse

									\IsFrame	=	C2D::GuiGetState(gAF)

									C2D_SetAnimation()

								EndIf

								ForEach	\Quick()
									If	\Quick()\s	=	\File$
										DeleteElement(\Quick())
										FirstElement(\Quick())
										InsertElement(\Quick())
										\Quick()\s	=	\File$
										Break
									EndIf
								Next

							EndIf

							Break

						Case	gAbort
							Break

						Default	; *** No C2D Gadgets ***

							If	ElapsedMilliseconds()	>	Time

								Select	Gadget

									Case	\Gadget

										If	GetGadgetAttribute(\Gadget, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton	And	C2D::IsBitmap(\BitmapID)

											x	=	GetGadgetAttribute(\Gadget, #PB_Canvas_MouseX)	-	\iPosX
											y	=	GetGadgetAttribute(\Gadget, #PB_Canvas_MouseY)	-	\iPosY

											If	\Factor
												x	/	\Factor
												y	/	\Factor
											EndIf

											If	x	>=	0	And	x	<	\iWidth	And	y	>=	0	And	y	<	\iHeight
												If	C2D::GuiGetState(gRGB)

													StartDrawing(ImageOutput(C2D::BitmapImage(\BitmapID)))
													DrawingMode(#PB_2DDrawing_AlphaChannel)
													\ClearRGB	=	Point(x, y)
													StopDrawing()

													C2D::GuiPaletteSetColor(3, \ClearRGB)

													t$	=	"{PF,3}{BX,6,6," + Str(C2D::GuiW(gRGB)-12) + "," + Str(C2D::GuiH(gRGB)-12) + "}"	; ClearColor
													C2D::GuiSetText(gRGB, t$)
													C2D::GuiSetToggleText(gRGB, t$)

												Else

													i	=	\iWidth	/	GetGadgetState(gAX)	+	1	:	x	/	i	+	1
													i	=	\iHeight	/	GetGadgetState(gAY)	+	1	:	y	/	i	+	1

													x	+	(y - 1)	*	GetGadgetState(gAX)

													If	GetActiveGadget()	=	gFE
														x - (GetGadgetState(gFS) - 1)
														If	x	<	0	:	x	=	1	:	EndIf
														SetGadgetState(gFE, x)
													Else
														SetGadgetState(gFS, x)
													EndIf

												EndIf
											EndIf
										EndIf

									Case	gQuick

										i	=	GetGadgetState(gQuick)

										If	i	>=	0

											SelectElement(\Quick(), i)	:	\File$	=	\Quick()\s

											If	\BitmapID	And	C2D::IsBitmap(\BitmapID)
												C2D::BitmapFree(\BitmapID)
											EndIf

											\BitmapID	=	C2D::BitmapInit(#PB_Any, @\File$)

											If	\BitmapID	And	C2D::IsBitmap(\BitmapID)
												\Image	=	C2D::BitmapImage(\BitmapID)
												Panel_Image()
											EndIf

											C2D::GuiDisable(gRGB,	Bool(\BitmapID<=0))
											C2D::GuiDisable(gClear,	Bool(\BitmapID<=0))
											C2D::GuiDisable(gAnim,	Bool(\BitmapID<=0))

											i	=	Bool(\IsAnim=0 Or \BitmapID<=0)
											DisableGadget(gAX,	i)
											DisableGadget(gAY,	i)
											DisableGadget(gAT,	i)
											C2D::GuiDisable(gAS,	i)	:	DisableGadget(gFS,	i)
											C2D::GuiDisable(gAE,	i)	:	DisableGadget(gFE,	i)
											C2D::GuiDisable(gAP,	i)
											C2D::GuiDisable(gAR,	i)
											C2D::GuiDisable(gAF,	i)

										EndIf

									Case	gAX, gAY

										If	\IsAnim
											\FramesX	=	GetGadgetState(gAX)
											\FramesY	=	GetGadgetState(gAY)
											Panel_Image()
										EndIf

								EndSelect

								Time	=	ElapsedMilliseconds()	+	10

							EndIf

					EndSelect

				Case	#WM_KEYDOWN
					Select	EventwParam()
						Case	#VK_ESCAPE	:	Break
					EndSelect

				Case	#PB_Event_CloseWindow
					Break

			EndSelect

		ForEver

		\IsAnim		=	C2D::GuiGetState(gAnim)
		\FramesX		=	GetGadgetState(gAX)
		\FramesY		=	GetGadgetState(gAY)
		\Time			=	GetGadgetState(gAT)
		\FrameStart	=	GetGadgetState(gFS)
		\FrameNumber=	GetGadgetState(gFE)
		\IsPingPong	=	C2D::GuiGetState(gAP)
		\IsBackward	=	C2D::GuiGetState(gAR)
		\IsFrame		=	C2D::GuiGetState(gAF)

		; free gadgets only in window[ID]
		C2D::GuiFree(#PB_All, \Window)
		CloseWindow(\Window)

		UseGadgetList(WindowID(0))

	EndWith

EndProcedure

Procedure	C2D_Back(Color.l)

	Protected	i, x, y, w, h

	StartDrawing(CanvasOutput(#C2D_G))

	DrawingMode(#PB_2DDrawing_AlphaBlend)

	If	Color	>=	#Null

		Box(0, 0, OutputWidth(), OutputHeight(), $FF000000|Color)

	Else

		w	=	OutputWidth()
		h	=	OutputHeight()

		Box(0, 0, w, h, $FFFFFFFF)
		FrontColor($34000000)

		h	/	#R_SIZE
		w	/	(#R_SIZE	*	2)

		For	y	=	0	To	h
			For	x	=	0	To	w
				Box((x * #R_SIZE * 2) + i * #R_SIZE, y * #R_SIZE, #R_SIZE, #R_SIZE)
			Next
			i	!	1
		Next

	EndIf

	C2D::GuiDrawFrame(C2D::#Gui_FrameFlat, 0, 0, OutputWidth(), OutputHeight(), 80)

	C2D::BufferBackGrab()
	;C2D::BufferClear()

	StopDrawing()

EndProcedure

Procedure	C2D_Init()

	LoadFont(0, #Null$, 7)
	SetGadgetFont(#PB_Default, FontID(0))

	Protected	x, y, w, h, i

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Splatter Editor"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)
	SetWindowColor(0, GetSysColor_(#COLOR_SCROLLBAR));C2D::#Gui_DefBackColor)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H - 12 - 7 * 16)

	C2D::Init(#C2D_G)	; default: update every 5ms

	C2D::GuiPaletteInit(?p_rgb, 5)
	C2D::GuiPaletteSetColor(0, RS_Init\Color)
	C2D::GuiPaletteSetColor(1, RS_Init\Back)
	C2D::GuiPaletteSetColor(2, RS_PI\BackColor)
	C2D::GuiPaletteSetColor(3, RS_PI\ClearRGB)

	C2D::GuiColor(GetSysColor_(#COLOR_WINDOWTEXT), GetSysColor_(#COLOR_SCROLLBAR))
	C2D::GuiToggleColor($FF000000|C2D::#Gui_DefBackColor)

	x	=	4	: 	y	=	GadgetHeight(#C2D_G)	+	4	:	C2D::GuiFrame(C2D::#Gui_Frame3D)

	C2D::GuiDrawButtonGadget(#G_START,	x,					y,	#B_W,	16, "Start")
	C2D::GuiDrawButtonGadget(#G_STOP,	C2D::GuiPosX(),y,	#B_W, 16, "Stop")
	C2D::GuiDrawButtonGadget(#G_LOOP,	C2D::GuiPosX(),y,	#B_W, 16, "Loop",		C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
	C2D::GuiDrawButtonGadget(#G_COLOR,	C2D::GuiPosX(),y,	#B_W,	16, "{PF,0}{CI,"+Str(#B_W/2)+",7,4}", C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
	C2D::GuiDrawButtonGadget(#G_IMAGE,	C2D::GuiPosX(),y, #B_W,	16, "Image",	C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
	C2D::GuiDrawButtonGadget(#G_ANIM,	C2D::GuiPosX(),y, #B_W,	16, "Anim",		C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
	C2D::GuiDrawButtonGadget(#G_PREVIEW,C2D::GuiPosX(),y, #B_W,	16, "Preview",	C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle, "Stop")
	C2D::GuiDrawButtonGadget(#G_LOAD,	C2D::GuiPosX(),y, #B_W, 16, "Request")
	C2D::GuiDrawButtonGadget(#G_BACK,	C2D::GuiPosX(),y, #B_W,	16, "{PF,1}{BX,12,3," + Str(#B_W-24) + ",9}", C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
	C2D::GuiDrawButtonGadget(#G_MODE,	C2D::GuiPosX(),y, #B_W, 16, "Quality",	C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
	C2D::GuiDrawButtonGadget(#G_CODE,	C2D::GuiPosX(),y,	#B_W,	16, "Code",		C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)
	C2D::GuiDrawButtonGadget(#G_INFO,	C2D::GuiPosX(),y, #B_W, 16, "Info")

	x	=	C2D::GuiPosX(4)	:	w	=	(#C2D_W	-	x	-	4)	/	10	:	C2D::GuiColor(0)	:	C2D::GuiFrame(C2D::#Gui_Frame3D)

	For	i	=	#G_0	To	#G_9
		If	i	=	#G_9	:	w	=	#C2D_W - x - 4	:	EndIf	; max. size on right
		C2D::GuiDrawButtonGadget(i, x, y, w, 16, Str(i-#G_0), C2D::#Gui_FlagCenter|C2D::#Gui_FlagToggle)	:	x	+	w
	Next

	x	=	4	:	y	=	C2D::GuiPosY(4)	:	C2D::GuiColor(0)	:	C2D::GuiFrame(C2D::#Gui_FrameNone)

					C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "Number:")
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "Gravity:")
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "Energy:")
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "AcclerateX:")
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "AcclerateY:")	:	i	=	C2D::GuiPosX()
	y	+	16	:	C2D::GuiDrawButtonGadget(#G_ZERO,x, y, 0, 16, "Size (%):", C2D::#Gui_FlagLeft)

	x	=	i	:	y	=	GadgetHeight(#C2D_G)	+	4	+	16	:	C2D::GuiFrame(C2D::#Gui_FrameSunken)	:	C2D::GuiColor(#White)

	y	+	4	:	C2D::GuiTrackGadget(#G_NUMBER,	x, y,	#G_W,	16, 1, 1000,C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_GRAVITY,	x, y,	#G_W, 16, 0, 200,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_ENERGY,	x, y,	#G_W, 16, 1, 1024,C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_ACCLX,		x, y,	#G_W, 16, 0, 500,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_ACCLY,		x, y,	#G_W, 16, 0, 500,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_SIZE,		x, y,	#G_W, 16, 1, 100,	C2D::#Gui_Frame3D, C2D::#Gui_FlagLevel)

	x	=	C2D::GuiPosX(4)	:	y	=	GadgetHeight(#C2D_G)	+	4	+	16	:	C2D::GuiColor(0)	:	C2D::GuiFrame(C2D::#Gui_FrameNone)

	y	+	4	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "SpreadX:")
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "SpreadY:")	:	i	=	C2D::GuiPosX()
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "Alpha:")
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "Fade:")
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "Bounce:")
	y	+	16	:	C2D::GuiDrawTextGadget(#PB_Any,	x, y, 0, 16, "Delay:")

	x	=	i	:	y	=	GadgetHeight(#C2D_G)	+	4	+	16	:	w	=	#C2D_W - (i + 4)	:	C2D::GuiFrame(C2D::#Gui_FrameSunken)	:	C2D::GuiColor(#White)

	y	+	4	:	C2D::GuiTrackGadget(#G_SPREADX,	x, y,	w, 16, 1, 200,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_SPREADY,	x, y,	w, 16, 1, 200,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_ALPHA,		x, y,	w, 16, 0, $FF,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_FADE,		x, y,	w,	16, 0, 255,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_BOUNCE,	x, y,	w,	16, 0, 200,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)
	y	+	16	:	C2D::GuiTrackGadget(#G_SPEED,		x, y,	w,	16, 0, 50,	C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)

	C2D::GuiSetState(#G_SPEED, RS_Init\Speed)	:	C2D::C2D\Speed	=	RS_Init\Speed

	C2D::GuiSetState(#G_0 + RS_Init\ID, 1)

	With	SetUp(RS_Init\ID)
		C2D::GuiSetState(#G_ACCLX,		\AcclX)
		C2D::GuiSetState(#G_ACCLY,		\AcclY)
		C2D::GuiSetState(#G_ALPHA,		\Alpha)
		C2D::GuiSetState(#G_BOUNCE,	\Bounce)
		C2D::GuiSetState(#G_ENERGY,	\Energy)
		C2D::GuiSetState(#G_FADE,		\Fade)
		C2D::GuiSetState(#G_GRAVITY,	\Gravity)
		C2D::GuiSetState(#G_NUMBER,	\Number)
		C2D::GuiSetState(#G_SIZE,		\Size)
		C2D::GuiSetState(#G_SPREADX,	\SpreadX)
		C2D::GuiSetState(#G_SPREADY,	\SpreadY)
	EndWith

	C2D_SetUp(RS_Init\ID)

	C2D::GuiSetState(#G_COLOR,	1)

	C2D::GuiDisable(#G_IMAGE,	Bool(C2D::IsBitmap(RS_PI\BitmapID)<=0))
	C2D::GuiDisable(#G_ANIM,	Bool(C2D::IsAnim(RS_PI\AnimID)<=0))
	C2D::GuiDisable(#G_PREVIEW,Bool(C2D::GuiGetState(#G_COLOR)))

	C2D_Back(-1)

	C2D::GuiRefresh(#PB_All)

	C2D_Set()

	HideWindow(0, 0)

EndProcedure
Procedure	C2D_Update()

	Protected	Count, t$

	C2D::BufferBackDraw()

	Select	RS_Init\Preview
		Case	0
			Count	=	C2D::SplatterDraw(0, C2D::C2D\h)
			t$	=	"Count:" + Str(Count)
		Case	1
			C2D::BitmapDraw(RS_PI\BitmapID, 0, 0, 255, C2D::#C2F_Center)
			t$	=	"ID:" + Str(RS_PI\BitmapID)
			Count	=	1
		Case	2
			Count	=	C2D::AnimDraw(RS_PI\AnimID, 0, 0, 255, C2D::#C2F_Center)	+	1
			t$	=	"Frame:" + Str(Count-1)
	EndSelect

	DrawingMode(#PB_2DDrawing_XOr|#PB_2DDrawing_Transparent)
	DrawText(0, 0, "FPS:" + Str(C2D::C2D\FPS))
	DrawText(#C2D_W - TextWidth(t$), 0, t$)

	ProcedureReturn	Count

EndProcedure

Define	x, y, Gadget, t$, Path$, Event, Count

Panel_Init()
C2D_Prefs(0)	; Must called before init
C2D_Init()

;************************************************
;{ - *** Mainloop *** }
;************************************************
Repeat

	If	Count
		Event	=	WindowEvent()
	Else
		Event	=	WaitWindowEvent()
	EndIf

	Select	Event

		Case	#PB_Event_Gadget
			Gadget	=	EventGadget()
			Select	C2D::GuiEvent(Gadget)

				Case	#G_START
					If	ListSize(C2D::RS_Splatter()\ID())	<>	C2D::GuiGetState(#G_NUMBER)
						C2D::SplatterInit(0, #S_SIZE, C2D::GuiGetState(#G_NUMBER), RS_Init\Color)
					EndIf

					C2D_Set()

				Case	#G_CODE	:	C2D_Code()

				Case	#G_STOP	:	C2D::SplatterStop(#PB_All)

				Case	#G_BACK	; Background

					If	C2D::GuiGetState(#G_BACK)

						x	=	ColorRequester(RS_Init\Back)

						If	x	>	-1

							RS_Init\Back	=	x

							C2D::GuiPaletteSetColor(1, RS_Init\Back)

							t$	=	"{PF,1}{BX,12,3," + Str(#B_W-24) + ",9}"

							C2D::GuiSetText(#G_BACK, t$)
							C2D::GuiSetToggleText(#G_BACK, t$)

							C2D_Back(RS_Init\Back)

						Else

							C2D::GuiSetState(#G_BACK, 0)

						EndIf

					Else

						C2D_Back(-1)

					EndIf

				Case	#G_COLOR	; Color of Splatter

					If	C2D::GuiGetState(#G_IMAGE)	=	0	And	C2D::GuiGetState(#G_ANIM)	=	0
						C2D::GuiSetState(#G_COLOR, 1)
					EndIf

					x	=	ColorRequester(RS_Init\Color)

					If	x	>	-1

						RS_Init\Color	=	x

						C2D::GuiPaletteSetColor(0, RS_Init\Color)

						t$	=	"{PF,0}{CI,"+Str(#B_W/2)+",7,4}"
						C2D::GuiSetText(#G_COLOR, t$)
						C2D::GuiSetToggleText(#G_COLOR, t$)

						C2D::GuiSetState(#G_ANIM, 0)
						C2D::GuiSetState(#G_IMAGE,0)

						C2D::SplatterInit(0, #S_SIZE, C2D::GuiGetState(#G_NUMBER), RS_Init\Color)

						C2D_Set()

					ElseIf	(C2D::GuiGetState(#G_ANIM)	Or	C2D::GuiGetState(#G_IMAGE))

						C2D::GuiSetState(#G_COLOR,	0)

					EndIf

					C2D::GuiDisable(#G_PREVIEW,Bool(C2D::GuiGetState(#G_COLOR)))

				Case	#G_ANIM

					C2D::GuiSetState(#G_ANIM, 1)
					C2D::GuiSetState(#G_COLOR,	0)
					C2D::GuiSetState(#G_IMAGE,	0)
					C2D::GuiDisable(#G_PREVIEW,0)

					C2D_Set()

				Case	#G_IMAGE

					C2D::GuiSetState(#G_IMAGE, 1)
					C2D::GuiSetState(#G_COLOR,	0)
					C2D::GuiSetState(#G_ANIM,	0)
					C2D::GuiDisable(#G_PREVIEW,0)

					If	C2D::GuiGetState(#G_IMAGE)	And	C2D::IsBitmap(RS_PI\BitmapID)
						C2D::SplatterImage(0, C2D::BitmapImage(RS_PI\BitmapID))
					EndIf

					C2D_Set()

				Case	#G_PREVIEW

					C2D::SplatterStop(#PB_All)

					If	C2D::GuiGetState(#G_PREVIEW)
						If	C2D::GuiGetState(#G_IMAGE)
							RS_Init\Preview	=	1
						ElseIf	C2D::GuiGetState(#G_ANIM)
							RS_Init\Preview	=	2
						Else
							RS_Init\Preview	=	0
						EndIf
					Else
						RS_Init\Preview	=	0
					EndIf

					C2D::GuiDisableRegion(0, Bool(RS_Init\Preview), 0, 0, #C2D_W, #C2D_H)
					C2D::GuiDisable(#G_LOAD,	0)
					C2D::GuiDisable(#G_PREVIEW,0)

					C2D::GuiSetState(#G_PREVIEW, Bool(RS_Init\Preview))

				Case	#G_MODE

						C2D_Set()	;C2D::Quality(C2D::GuiGetState(#G_MODE))

				Case	#G_LOAD

					C2D::GuiDisableRegion(0, 1, 0, 0, #C2D_W, #C2D_H)	:	C2D::GuiRefresh(#PB_All)

					Panel_Request()

					If	RS_Init\Preview	; preview image or anim?
						C2D::GuiDisable(#G_LOAD,	0)
						C2D::GuiDisable(#G_PREVIEW,0)
					Else
						C2D::GuiDisableRegion(0, 0, 0, 0, #C2D_W, #C2D_H)
						C2D::GuiDisable(#G_IMAGE,	Bool(C2D::IsBitmap(RS_PI\BitmapID)<=0))
						C2D::GuiDisable(#G_ANIM,	Bool(C2D::IsAnim(RS_PI\AnimID)<=0))
						C2D::GuiDisable(#G_PREVIEW,Bool(C2D::GuiGetState(#G_IMAGE)<=0 And C2D::GuiGetState(#G_ANIM)<=0))
					EndIf

					C2D_Set()
					C2D::SplatterStop()

				Case	#G_0	To	#G_9

					For	x	=	#G_0	To	#G_9
						C2D::GuiSetState(x, Bool(x=Gadget))
					Next

					C2D_SetUp(Gadget-#G_0)

					C2D_Set()

				Case	#G_ZERO	:	C2D::GuiSetState(#G_SIZE, 50)	; Size % Center

				Case	#G_SIZE	:	x	=	C2D::GuiGetState(#G_SIZE)	*	2	:	C2D_Set()	;Debug	x

				Case	#G_INFO	:	C2D_About()

				Case	#G_GRAVITY					:	C2D::SplatterGravity(0,			C2D::GuiGetState(#G_GRAVITY))
				Case	#G_ACCLX, #G_ACCLY		:	C2D::SplatterAcceleration(0,	C2D::GuiGetState(#G_ACCLX),	C2D::GuiGetState(#G_ACCLY))
				Case	#G_SPREADX, #G_SPREADY	:	C2D::SplatterSpread(0,			C2D::GuiGetState(#G_SPREADX),	C2D::GuiGetState(#G_SPREADY))
				Case	#G_ENERGY					:	C2D::SplatterEnergy(0,			C2D::GuiGetState(#G_ENERGY) * 10)
				Case	#G_FADE						:	C2D::SplatterFade(0,				C2D::GuiGetState(#G_FADE))
				Case	#G_BOUNCE					:	C2D::SplatterBounce(0,			C2D::GuiGetState(#G_BOUNCE))
				Case	#G_LOOP						:	C2D::SplatterLoop(0,				C2D::GuiGetState(#G_LOOP))
				Case	#G_ALPHA						:	C2D::SplatterAlpha(0,			C2D::GuiGetState(#G_ALPHA))
				Case	#G_SPEED						:	RS_Init\Speed	=	C2D::GuiGetState(#G_SPEED)	:	C2D::C2D\Speed	=	RS_Init\Speed
			EndSelect

		Case	#WM_LBUTTONUP,#WM_RBUTTONUP

			x	=	WindowMouseX(0)
			y	=	WindowMouseY(0)

			If	x	>=	#Null	And	y	<=	C2D::C2D\h
				C2D_Set(x, y)
			EndIf

		Case	#PB_Event_CloseWindow
			Break

		Default	;Case	#Null
			If	C2D::Start()
				Count	=	C2D_Update()
				C2D::Stop()
			EndIf

	EndSelect
ForEver

For	x	=	#G_0	To	#G_9
	If	C2D::GuiGetState(x)
		C2D_SetUp(x-#G_0)
		Break
	EndIf
Next

C2D_Prefs(1)	; save prefs

C2D::Free()

DataSection
	; 0 = Splatter
	; 1 = Back
	; 2 = PanelColor
	; 3 = PanelClear
	p_rgb:	:	Data.l	0, 0, 0, 0, 0, 0
EndDataSection
;}
; ***********************************************
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = AAA+
; Optimizer
; EnableXP
; UseIcon = ..\..\Data\Icon\ProjectSmall.ico
; Executable = C2D_Splatter_Editor_x86.exe
; CompileSourceDirectory