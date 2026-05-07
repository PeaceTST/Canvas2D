; C2D::PageText-Example simple - Purebasic v5.72

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_GdiPlus		=	1	; when off use a native image-decoder
	#IsC2D_File			=	1
	#IsC2D_PageText	=	1
	#IsC2D_Bitmap		=	1
	#IsC2D_BitmapColor=	1
	#IsC2D_Clear		=	0
	XIncludeFile	"..\Include\C2D_Defaults.pbi"	; adapt path of include
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"		; adapt path of include

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#FX_Speed	=	5		; fadespeed
#FX_Delay	=	35		; delay
#FX_Wait		=	6000	; ms

#W	=	#C2D_W	*	0.75
#H	=	#C2D_H	*	0.39

Procedure	C2D_Init()
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("PageText / Simple"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G)
	
	C2D::Quality(#PB_Image_Smooth)
	
	C2D::BitmapInit(0, @"..\Data\Font\PNG\16x23_CoolFont.png", 0, #Black)
	
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontScale(0, 0.6 * #C2D_Z)
	C2D::FontGap(0, 0, 2)
	
	C2D::PageTextInit(?t_text, Random(#C2D_W - #W), Random(#C2D_H - #H), #W, #H, C2D::#C2F_Center)

	C2D::PageTextColor($FF001F00)
	C2D::PageTextWait(2000)

	C2D::PageTextEffect(1, C2D::#PFX_Random, #FX_Speed, #FX_Delay)	; 1 = show page fx
	C2D::PageTextEffect(0, C2D::#PFX_Random, #FX_Speed, #FX_Delay)	; 0 = hide page fx

EndProcedure
Procedure	C2D_Update()

	Protected	x.f	;=	Cos(C2D::C2D\Time * 0.0016)	*	64
	Protected	y.f	;=	Sin(C2D::C2D\Time * 0.0016)	*	64

	C2D::PageTextDraw(x, y)

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
	t_text:
	Data.s	"1.Das ist ein Text zum anzeigen!|"			+
	      	"Mal sehen ob es klappt mit dem text?||"	+
	      	"hier ein tab:*	* bis hierher.|||"		+
	      	"das eben war'n nen paar Freizeilen."		+
	      	"~"	+
	      	"2.huch ein seitenwechsel|"	+
	      	"das hat also geklappt * hoffentlich *"	+
	      	"~"	+
	      	"3.Klasse, aber warum beginnt er nicht mit|"	+
	      	"Seite 1 des PageText?||"							+
	      	"Habe da wohl was uebersehen.||"					+
	      	"ahh *** resetlist benoetigt nextelement|"	+
	      	"boa ey... man man!"									+
	      	"~"	+
	      	"4.jetzt aber...||"							+
	      	"* der text wird zentriert angezeigt|"	+
	      	"* und auch ohne  diese  freizeichen|"	+
	      	"* ordentlich  dargestellt   werden!"	+
	      	"~"	+
	      	"5.ok... alles von vorn|"	+
	      	"zuvor aber alle buchstaben"+
	      	"~"	+
	      	" !" + #DQUOTE$ + "#$%&'|"	+
	      	"()*+,-./|"	+
	      	"01234567|"	+
	      	"89:;<=>?|"	+
	      	"@ABCDEFG|"	+
	      	"HIJKLMNO|"	+
	      	"PQRSTUVW|"	+
	      	"XYZ[\]^_"
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = w
; Executable = ..\Executables\C2D_PageText_Simple_x86.exe
; CompileSourceDirectory