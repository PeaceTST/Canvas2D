; C2D::Line3D / Goldrunner - Purebasic v6.30 (x86-64)

DisableDebugger	; turn debugger of for faster copper

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor - try 1 or 2
CompilerEndIf

IncludePath	"..\Include\"	; adapt path of include
DeclareModule	IsC2D
	XIncludeFile	"C2D_Types.pbi"
	#IsC2D_Music		=	#XMU_TPT
	#IsC2D_Line3D		=	1
	#IsC2D_Copper		=	1
	#IsC2D_Stars3D		=	2
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_Text			=	1
	#IsC2D_MoveText	=	2	; ControlCodes {1,#Font}
	#IsC2D_Buffer		=	1
	#IsC2D_Topaz		=	0
	#IsC2D_Clear		=	0
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

; Min/Max Line3D Objects
#ID_MIN		=	#Null
#ID_MAX		=	8		; max. number of objects
#TIME_WAIT	=	5000	; wait ms for zoom (5 sec)

; Start / stop vertical pixelview
#Y_START		=	#C2D_Z	*	64
#Y_HEIGHT	=	#C2D_H	-	#Y_START	*	2

Global	ID, Time

Procedure	Copper_Color(x, y, PenColor, PaperColor)
	If	PaperColor	&	#Red	;($FF000000|#Red)
		ProcedureReturn	PenColor
	EndIf
	ProcedureReturn	PaperColor
EndProcedure

Procedure	C2D_Init()
	
	Protected	t$

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Line3D / Goldrunner + Copper + MoveText + TPT"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 10)
	
	; *** Starfield
	C2D::Stars3DInit(228 * #C2D_Z, 1, 0, #Y_START, #C2D_W, #Y_HEIGHT, 5)

	; *** Init objects (#ID_MAX)
	ID	=	0	:	C2D::Line3DInit(ID, ?l_0, 0.30)	; TST.l3d
	ID	+	1	:	C2D::Line3DInit(ID, ?l_1, 0.60, 1.4)	; Flugzeug.l3d
	ID	+	1	:	C2D::Line3DInit(ID, ?l_2, 0.40)	; 911.l3d
	ID	+	1	:	C2D::Line3DInit(ID, ?l_3, 0.52)	; 113.l3d
	ID	+	1	:	C2D::Line3DInit(ID, ?l_4, 1.30)	; Question_Double.l3d
	ID	+	1	:	C2D::Line3DInit(ID, ?l_5, 0.30)	; Rocket.l3d
	ID	+	1	:	C2D::Line3DInit(ID, ?l_6, 0.43)	; Skull&Bones.l3d
	ID	+	1	:	C2D::Line3DInit(ID, ?l_7, 1.40)	; Ball_Full.l3d
	ID	+	1	:	C2D::Line3DInit(ID, ?l_8, 0.52)	; KnockKnock.l3d
	
	; *** Border-Copperlines / TextFont
	C2D::CopperInit(0, 1, ?c_silver, C2D::#C2F_Horizontal)
	C2D::FontRawInit(0, ?f_raw, ?e_raw, #C2D_Z * 5, #C2D_Z * 4.3)
	C2D::FontGap(0, #C2D_Z * 2)
	C2D::FontCopper(0, ?c_gold)
	
	; *** Draw Border-Copperlines / Top-/Bottom-Text
	Repeat	:	Until	C2D::Start()	;StartDrawing(CanvasOutput(#C2D_G))
	Box(0, 0, #C2D_W, #C2D_H, $FF2D0100)
	t$	=	"GOLDRUNNER"	:	C2D::TextStringDraw((#C2D_W - Len(t$) * C2D::FontW(0)) * 0.5, (#Y_START - C2D::FontH(0)) * 0.5, t$)
	t$	=	"SOUNDTRACKER"	:	C2D::TextStringDraw((#C2D_W - Len(t$) * C2D::FontW(0)) * 0.5, #C2D_H - #Y_START + (#Y_START - C2D::FontH(0)) * 0.5, t$)
	Box(0, #Y_START, #C2D_W, #Y_HEIGHT, $FF000000)
	C2D::CopperDraw(0, #Y_START - 1)
	C2D::CopperDraw(0, #Y_START + #Y_HEIGHT)
	C2D::BufferBackGrab()	; get full canvasbuffer
	C2D::BufferClear()		; start with black screen
	C2D::Stop()	;StopDrawing()
	
	; *** Movetext font (frees big goldfont)
	C2D::FontRawInit(0, ?f_raw, ?e_raw, #C2D_Z, #C2D_Z * 2)
	C2D::FontCopper(0, ?c_silver)
	C2D::FontGap(0, #C2D_Z, #C2D_Z * 3)
	
	; *** Movetext markerfont
	C2D::FontRawInit(1, ?f_raw, ?e_raw, #C2D_Z, #C2D_Z * 2)
	C2D::FontCopper(1, ?c_gold)
	
	; *** Set default movetext font
	C2D::FontSelect(0)
	
	; *** Init movetext
	C2D::MoveTextInit(0, ?t_text, #C2D_W * 0.58, #Y_START, #C2D_W * 0.38, #Y_HEIGHT, C2D::#C2F_Center);, C2D::#C2F_Right)
	C2D::MoveTextSpeed(0, -0.2 * #C2D_Z)
	;C2D::MoveTextColor(0, $FFFF0000)	; <- for test only
	
	; *** Blittercopper for objects (sized for less rgb-calculations)
	C2D::CopperInit(0, #Y_HEIGHT, ?c_blit)	;, C2D::#C2F_HORIZONTAL)
	With	C2D::RS_Copper()
		\w	=	#C2D_W * 0.51	:	\hImage	=	ResizeImage(\Image, \w, #PB_Ignore)
	EndWith
	C2D::CopperBlitProc(@Copper_Color())	; Custom

	ID		=	#Null	;Random(#ID_MAX)
	Time	=	C2D::MA_TIME()	+	#TIME_WAIT

	; *** Playing music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_mod, ?e_mod)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()
	
	Static.f	rx=1.1, ry=1.2, rz=-1.3
	
	Protected	z.f = 6 * #C2D_Z + MA_GCos(C2D::C2D\Time * 0.45) * 5.90 * #C2D_Z
	
	; ***  Clear buffer with static background & wobble text
	C2D::BufferBackDraw()
	C2D::BufferSinX(0.10 * #C2D_W, 0.035 * #C2D_H, 0.8 * #C2D_W, 0.12 * #C2D_H, 18 * #C2D_Z, (30.0 / #C2D_Z) * MA_GCosI(C2D::C2D\Count), 18)
	C2D::BufferSinX(0.05 * #C2D_W, 0.835 * #C2D_H, 0.9 * #C2D_W, 0.12 * #C2D_H, 18 * #C2D_Z, (30.0 / #C2D_Z) * MA_GSinI(C2D::C2D\Count), 18)
	
	C2D::Line3DRotate(ID, rx, ry, rz)	; Rotate object

	ClipOutput(0, #Y_START, #C2D_W, #Y_HEIGHT)
	C2D::Line3DDraw(ID, -0.25 * #C2D_W, 0, z, z)	; Draw (red) object
	C2D::CopperBlit(0, #Y_START, 1.5 * #C2D_Z)	; Draw copper on red color
	UnclipOutput()

	; *** Reset drawingmode - CopperBlit set it's own!
	DrawingMode(IsC2D::#IsC2D_Mode)
	C2D::Stars3DDraw()
	C2D::MoveTextDraw(0)

	If	C2D::C2D\Time	>	Time	And	z	<	0.111	*	#C2D_Z
		
		; *** Next object
		ID		+	1
		If	ID	>	#ID_MAX
			ID	=	#ID_MIN
		EndIf

		;ID	=	8	; object-test

		; *** Random ± Object-Rotation
		rx	=	C2D::MA_RMP(798)	*	0.0031
		ry	=	C2D::MA_RMP(798)	*	0.0033
		rz	=	C2D::MA_RMP(798)	*	0.0035
		
		; *** Random Object-Angles
		C2D::Line3DAngle(ID, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))
		
		; *** Update Wait-Time (2 x zoom)
		Time	=	C2D::MA_TIME()	+	#TIME_WAIT
		
	EndIf

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
	
	; Protracker-Module?
	CompilerIf	IsC2D::#IsC2D_Music
		m_mod:	:	IncludeBinary	"..\Data\Music\MOD\Timo Vehmaa - Goldrunner.mod"	:	e_mod:
	CompilerEndIf
	
	; Rawfont
	f_raw:	:	IncludeBinary	"..\Data\Font\RAW\Pixelite_7x7.rf"	:	e_raw:
	
	; Objects
	IncludePath	"..\Data\Object\L3D\"
	l_0:	:	IncludeBinary	"TST.l3d"
	l_1:	:	IncludeBinary	"Flugzeug.l3d"
	l_2:	:	IncludeBinary	"911.l3d"
	l_3:	:	IncludeBinary	"113.l3d"
	l_4:	:	IncludeBinary	"Question_Double.l3d"
	l_5:	:	IncludeBinary	"Rocket.l3d"
	l_6:	:	IncludeBinary	"Skull&Bones.l3d"
	l_7:	:	IncludeBinary	"Ball_Rule.l3d"
	l_8:	:	IncludeBinary	"KnockKnock!.l3d"

	c_blit:	; Object-Copper
	Data.l	7,
	      	$FF000000|#Magenta,
	      	$FF000000|#Blue,
	      	$FF000000|#Cyan,
	      	$FF000000|#Green,
	      	$FF000000|#Yellow,
	      	$FF000000|#Red,
	      	$FF000000|#Magenta
	
	; Text/Border-Copper
	c_gold:		:	Data.l	3,	$FF001060,$FF00FFFF,$FF001060
	c_silver:	:	Data.l	3,	$FF303030,$FFFFFFFF,$FF303030

	t_text:	; Movetext
	Data.s	"{1,1}GOLDRUNNER{1}||"		+
	      	"THIS MOD IS ONE OF|"		+
	      	"THE FIRST MODULES EVER||"	+
	      	"IT ALL STARTED IN {1,1}1987{1}|"		+
	      	"WHEN {1,1}KARSTEN OBARSKI{1} MADE|"	+
	      	"THE ULTIMATE SOUNDTRACKER|"				+
	      	"({1,1}SOUNDTRACKER I{1})||"				+
	      	"AFTER THAT MANY|"			+
	      	"PEOPLE/GROUPS FROM|"		+
	      	"{1,1}AMIGA{1} SCENE HAVE|"+
	      	"CONTRIBUTED IN THE|"		+
	      	"MAKING OF THESE|"	+
	      	"TRACKERS LIKE:|||"	+
	      	"THE EXTERMINATOR|"	+
	      	"/ JUNGLE COMMAND||"	+
	      	"IL SCURO||"			+
	      	"ALPHA FLIGHT||"		+
	      	"D.O.C||"				+
	      	"MAHONEY & KAKTUS||"	+
	      	"AMIGA FREELANCERS||"+
	      	"CRYPTOBURNERS|||"	+
	      	"I AM SURE THAT|"				+
	      	"ANYONE WHO WAS THERE|"		+
	      	"BACK THEN APPRECIATES|"	+
	      	"THESE TUNES AND THE|"		+
	      	"MEMORIES THEY BRING||"		+
	      	"{1,1}TIMO VEHMAA{1}|||"	+
	      	"CODED IN|{1,1}PUREBASIC{1} V"	+	MA_XPB()		+
	      	"||INCLUDE|{1,1}CANVAS 2D{1} V"	+	MA_XC2D()	+
	      	"||PEACE 2K20"

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A+
; Executable = ..\Executables\C2D_Line3D_Goldrunner_x86.exe
; DisableDebugger
; CompileSourceDirectory