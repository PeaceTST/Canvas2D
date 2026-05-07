; C2D::Text / String - Purebasic v5.70 (x86-64)

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	#IsC2D_Mode		=	0
	#IsC2D_Clear	=	0
	#IsC2D_Bitmap	=	1
	#IsC2D_File		=	1
	#IsC2D_Text		=	1

	XIncludeFile	"..\Include\C2D_Defaults.pbi"	; adapt path of include

EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"		; adapt path of include

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Text / String"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 1000)	; update every second
	
	C2D::Quality(#PB_Image_Smooth)

	C2D::BitmapInit(0, @"..\Data\Font\BMP\48x48_Gold.bmp")
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontScale(0, #C2D_Z)

	C2D::BitmapFree(0)

EndProcedure
Procedure	C2D_Update()
	
	Protected	t$	=	FormatDate("%hh:%ii:%ss",	Date())
	Protected	y$	=	FormatDate("%dd.%mm.%yyyy",Date())
	Protected	d$	=	StringField("SUNDAY,MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY", DayOfWeek(Date()) + 1, ",")

	Protected	y	=	(#C2D_H - C2D::FontH(0)) * 0.5

	C2D::TextStringDraw((#C2D_W - (Len(t$) * C2D::FontW(0)))	*	0.5, y * 0.55,	t$)	; Time
	C2D::TextStringDraw((#C2D_W - (Len(y$) * C2D::FontW(0)))	*	0.5, y,			y$)	; Date
	C2D::TextStringDraw((#C2D_W - (Len(d$) * C2D::FontW(0)))	*	0.5, y * 1.45,	d$)	; Day

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
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = w
; Executable = ..\Executables\C2D_Text_String_x86.exe
; CompileSourceDirectory