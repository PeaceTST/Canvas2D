; C2D::Ball3D / Solar - Purebasic v6.30 (x86)

; No sound? -> Install AmpMaster -> ..\Tools\AmpInstaller\C2D_AmpMaster_x86.exe

; 0 - Pluto
; 1 - Merkur
; 2 - Sun
; 3 - Venus
; 4 - Earth
; 5 - Mars
; 6 - Saturn
; 7 - Neptune

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

IncludePath	"..\Include\"

DeclareModule	IsC2D
	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x86
		XIncludeFile	"C2D_Types.pbi"
		#IsC2D_Music	=	#XMU_AMP
	CompilerElse
		#IsC2D_Guru		=	1
		#IsC2D_Buffer	=	1
	CompilerEndIf
	#IsC2D_Clear		=	0	; no clear backbuffer (star tails)
	#IsC2D_Bitmap		=	0	; no bitmaps
	#IsC2D_Ball3D		=	1	; no explode, no merge, no starfield
	#IsC2D_Stars3D		=	2	; fast stars 1px
	#IsC2D_Copper		=	1
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_MoveText	=	1
	#IsC2D_File			=	2	; 2 -> parent for music
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	XIncludeFile	"C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"	; always include after module IsC2D

#C2D_G	=	0		; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Procedure	C2D_Init()

	Protected	i, t$

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Ball3D - LoadTheme / Solar + AMP"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)

	C2D::FontRawInit(0, ?f_font, 0, #C2D_Z, 2 * #C2D_Z)
	C2D::FontCopper(0, ?c_font)
	C2D::FontShadow(0, 1, 1, $FF)
	C2D::FontGap(0, 1, 4)

	C2D::FontSelect(0)
	C2D::MoveTextInit(0, ?t_text, 0, 0, #C2D_W, #C2D_H, C2D::#C2F_Center)
	C2D::MoveTextSpeed(0, -0.20 * #C2D_Z)

	C2D::Quality(#PB_Image_Smooth)	; remark and see why (Pluto)

	C2D::Ball3DLoadTheme("..\Data\Ball\Solar\")	; Path of Theme!
	C2D::Ball3DInit(0, @"..\Data\Object\B3D\SolarSystem.b3d", 18 * #C2D_Z)

	For	i	=	0	To	C2D::Ball3DCount(0)
		C2D::Ball3DSpin(0, 0.5 + 0.01 * Random(150), i)
	Next

	C2D::Stars3DSpread(600 * #C2D_Z)
	C2D::Stars3DInit(200 * #C2D_Z, 1, 0, #C2D_H * 0.1, #C2D_W, #C2D_H * 0.8, 3.7)

	C2D::CopperInit(0, #C2D_H, ?c_back)

	CompilerIf	IsC2D::#IsC2D_Music
		t$	=	C2D::FileParent()	+	"Data\Music\AMP\Legend12.bp"
		C2D::MusicPlay(@t$)
	CompilerElseIf	IsC2D::#IsC2D_Guru
		t$	=	"|MUSIC FAILURE.	PRESS LEFT MOUSE BUTTON TO CONTINUE.|"	+
		  	 	"|#C2D_MUSIC_AMP NOT SUPPORTED IN X64|"
		C2D::GuruInit(@t$)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	CompilerIf	IsC2D::#IsC2D_Guru
		If	C2D::IsGuru()
			C2D::BufferClear()
		EndIf
	CompilerEndIf

	C2D::Stars3DDraw()

	C2D::Ball3DRotate(0, 0, 0.1, 0)
	C2D::Ball3DDraw(0, 0, 0, 235, 20)

	C2D::MoveTextDraw(0)

	C2D::CopperDraw(0, 0)	; clears as smooth blurry background for star tails

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf
		CompilerIf	IsC2D::#IsC2D_Guru
		Case	#WM_LBUTTONDOWN
			C2D::GuruFree()
		CompilerEndIf
		Default
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection

	c_back:	:	Data.l	4, $FFFF0000, $1F000000, $1F000000, $FFFF00FF
	c_font:	:	Data.l	4,	$FFFF00FF, $FFFFFFFF, $FFFFFF00, $FFFF0000
	
	f_font:	:	Data.s	"..\Data\Font\RAW\Amiga_Spherix_8U.rw"

	t_text:	; palaver
	Data.s	"Dream Tear Down|"			+
	      	"||"								+
	      	"I had a dream.|"				+
	      	"I could really feel|"		+
	      	"the reality.|"				+
	      	"I could touch the|"			+
	      	"reality.|"						+
	      	"|"								+
	      	"I could see the light.|"	+
	      	"I was out of the|"			+
	      	"everlasting darkness.|"	+
	      	"I had never been so|"		+
	      	"happy.|"						+
	      	"|"								+
	      	"I felt I could do|"			+
	      	"anything anywhere.|"		+
	      	"There were no limits.|"	+
	      	"The world was mine|"		+
	      	"to take.|"						+
	      	"|"								+
	      	"I was so happy.|"			+
	      	"While expressing|"			+
	      	"myslef, in this|"			+
	      	"strange new world I|"		+
	      	"had discovered,|"			+
	      	"I must'v gone too far.|"	+
	      	"|"								+
	      	"In a split second I|"		+
	      	"lost all my feelings'n|"	+
	      	"sense of happiness...|"	+
	      	"|"								+
	      	"My dream was torn down|"	+
	      	"Back to the industrial|"	+
	      	"style...|"						+
	      	"||"								+
	      	"by Teque/Trauma|"			+
	      	"november 1997"

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A9
; Executable = ..\Executables\C2D_Ball3D_Solar_x86.exe
; CompileSourceDirectory