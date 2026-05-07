; C2D::URL Player / SCAL + CallBack + SysFont - Purebasic v6.30

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"	; musictypes #XMU_(Type)
	#IsC2D_Music	=	#XMU_SCA
	
	#IsC2D_Buffer	=	1
	#IsC2D_Stars2D	=	1
	#IsC2D_SysFont	=	1

	#IsC2D_Clear	=	0	; not needed, turn off

	XIncludeFile	"C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#DWN_Y	=	#C2D_H * 0.5

#MODLAND$	=	"http://ftp.modland.com/pub/modules/"	; do not use https!

Global	t$

Procedure	Proc_Callback(Param)
	
	; Callback by SCAL_x86-64.dll
	; Param = 0 -100 % downloaded
	
	StartDrawing(CanvasOutput(#C2D_G))
	Box( 8 * #C2D_Z, #DWN_Y - 16, #C2D_W - 2 *  8 * #C2D_Z, 2 * 16, $FFFFFFFF)
	Box(12 * #C2D_Z, #DWN_Y - 12, #C2D_W - 2 * 12 * #C2D_Z, 2 * 12, $FF000000)
	
	Box(16 * #C2D_Z, #DWN_Y -  8, Param * 0.01 * (#C2D_W - 2 * 16 * #C2D_Z), 2 * 8, $FFFFFFFF)	; Param = State (0 - 100)
	
	If	Param	>=	99
		Box(16 * #C2D_Z, #DWN_Y -  8, #C2D_W - 2 * 16 * #C2D_Z, 2 * 8, $FFFFFFFF)
	EndIf
	
	C2D::SysFontSet(1)
	DrawText((#C2D_W - TextWidth(t$)) * 0.5, #C2D_H * 0.88, t$, $FF00FF00)
	
	StopDrawing()
	
	Delay(20)

	ProcedureReturn	0	; <> 0 aborts download

EndProcedure
Procedure	URL_Player(i)
	
	; Load & play onlie music with mmp only!
	
	Protected	i$
	
	If	i	<	#VK_1	Or	i	>	#VK_5
		ProcedureReturn
	EndIf

	i	-	#VK_1
	
	i$	=	#MODLAND$	+	PeekS(PeekI(?l_url + SizeOf(Integer) * i))
	
	t$	=	Space(8)	+	"SCAL download: " + GetFilePart(i$)	+	Space(8)	; see callback()
	
	C2D::MusicFree()
	C2D::MusicInit(#SCAL_PATH$, @Proc_Callback())	; try to set callback to #Null
	C2D::MusicPlay(@i$)
	
	t$	=	"playing: " + GetFilePart(i$)

EndProcedure

Procedure	C2D_Init()
	
	Protected	*url.Integer = ?l_url, i
	Protected	x.f	=	0.07 * #C2D_W
	Protected	y.f	=	26.0 * #C2D_Z

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("URL Player / SCAL + CallBack + SysFont"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 12)

	C2D::Stars2DInit(100, #C2D_Z, 0, 0, #C2D_W, #C2D_H, 2*#C2D_Z)

	C2D::SysFontInit(0, "A500 Sapphire", ?f_sys, ?e_sys, 28)
	C2D::SysFontInit(1, "A500 Sapphire", ?f_sys, ?e_sys, 12)
	
	; Create buffered background for faster display
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::SysFontSet(0)
	
	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
		t$	=	"URL SCAL_x64.dll Player"
	CompilerElse
		t$	=	"URL SCAL_x86.dll Player"
	CompilerEndIf
	DrawText((#C2D_W - TextWidth(t$)) * 0.5, y, t$, #Yellow)
	
	y	+	30	:	C2D::SysFontSet(1)
	t$	=	"download server " + #MODLAND$
	DrawText((#C2D_W - TextWidth(t$)) * 0.5, y, t$, #Cyan)

	y	+	16	:	C2D::SysFontSet(0)
	While	*url\i
		i	+	1
		DrawText(x, y + i * 30, Str(i) + ": " + LCase(GetFilePart(PeekS(*url\i))))
		*url	+	SizeOf(Integer)
	Wend
	C2D::BufferBackGrab()
	StopDrawing()
	
	; Start-Message
	t$	=	"press key 1 - " + Str(i) + " to listen online-music"

EndProcedure
Procedure	C2D_Update()
	
	Static	a=52, s=4
	
	a	+	s	:	If	a	<	52	Or	a	>	251	:	s	*	-1	:	EndIf

	C2D::BufferBackDraw()
	
	C2D::SysFontSet(1)
	DrawText((#C2D_W - TextWidth(t$)) * 0.5, #C2D_H * 0.88, t$, $0000FF|a<<24)
	
	C2D::Stars2DDraw()

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
 			EndIf

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_1 To #VK_5
					URL_Player(EventwParam())
				Case	#VK_ESCAPE	:	Break
			EndSelect

		Case	#PB_Event_CloseWindow
			Break

	EndSelect
ForEver

C2D::Free()

DataSection

	f_sys:	:	IncludeBinary	"..\Data\Font\FON\A500 Sapphire.fon"	:	e_sys:
	
	; Ptr-Table to example-musicfiles
	l_url:	:	Data.i	?f1, ?f2, ?f3, ?f4, ?f5, #Null

	f1:	:	Data.s	"Fasttracker 2/Apex/condensed rhythm 16.xm"
	f2:	:	Data.s	"AHX/Kam/iceflower.ahx"
	f3:	:	Data.s	"Future Composer 1.4/Pseudolukian/tsb-internpack2.fc"
	f4:	:	Data.s	"Screamtracker 2/Skaven/the evolution.stm"
	f5:
	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
		Data.s	"Screamtracker 3/Laserlore/time tunnel.s3m"
	CompilerElse
		Data.s	"HVSC/MUSICIANS/W/Whittaker_David/Speedball.sid"	; only scal_x86.dll plays sid-files
	CompilerEndIf

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A9
; Executable = ..\Executables\C2D_URL_Player_x86.exe
; CompileSourceDirectory