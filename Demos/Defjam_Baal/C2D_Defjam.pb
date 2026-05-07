; C2D::Defjam & CSS / Baal - 1989
; Peace^TST - 16.03.2018 23:07
; Purebasic v6.04 (x86-64)

; http://janeway.exotica.org.uk/release.php?id=23667

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	
	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictype #XMU_[Type]

	#IsC2D_Mode			=	0	; do nothing
	
	#IsC2D_Clear		=	0	; no clear canvas
	#IsC2D_Topaz		=	0	; use own rawfont
	
	#IsC2D_FontRaw		=	1
	#IsC2D_FontColor	=	1	; needed for font, shadow & copper
	#IsC2D_FlatBar		=	1
	#IsC2D_ScrollText	=	1
	
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width
#C2D_H	=	240	*	#C2D_Z	; Height

#BAR_H	=	20.0	*	#C2D_Z	; FlatBar-Height
#POS_Y	=	0.835	*	#C2D_H	; Pos of FlatBar + Scroller

#FNT_W	=	9.00	*	#C2D_Z	; Font-Width
#FNT_H	=	0.68	*	#BAR_H	; Font-Height

Procedure	Defjam_Init()
	
	Protected	y	; y start of flatbars
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Defjam & CSS - Baal - 1989"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 7)
	
	; create font from rawfont for flatbars + scroller
	C2D::FontRawInit(0, ?i_raw, ?e_raw, 1, 1, #White, 9)	; <- 9 = pixelwidth in word
	C2D::FontZoom(0, #FNT_W, #FNT_H)
	C2D::FontCopper(0, ?c_text)
	C2D::FontShadow(0, #C2D_Z, #C2D_Z, 160)
	
	; create scroller
	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, #C2D_Z)
	
	; create static flatbars with text
	C2D::FlatBarInit(0, #BAR_H, $5555AA, #C2D_Z)	:	C2D::FlatBarText(0, @"DEFJAM & CCS PROUDLY PRESENT:")
	C2D::FlatBarInit(1, #BAR_H, $5555AA, #C2D_Z)	:	C2D::FlatBarText(1, @"---    B A A L    ---")
	C2D::FlatBarInit(2, #BAR_H, $449944, #C2D_Z)	:	C2D::FlatBarText(2, @"THIS GAME WAS CRACKED BY")
	C2D::FlatBarInit(3, #BAR_H, $449944, #C2D_Z)	:	C2D::FlatBarText(3, @"IL SCURO OF DEFJAM")
	C2D::FlatBarInit(4, #BAR_H, $AA55AA, #C2D_Z)	:	C2D::FlatBarText(4, @"LEFT MOUSEBUTTON FOR NORMAL!")
	C2D::FlatBarInit(5, #BAR_H, $AA55AA, #C2D_Z)	:	C2D::FlatBarText(5, @"RIGHT MOUSEBUTTON FOR TRAINER!")
	
	; need to draw on canvas once only, coz no clearbuffer
	StartDrawing(CanvasOutput(#C2D_G))
	y	=	16 * #C2D_Z			:	C2D::FlatBarDraw(0,	y)
	y	+	#BAR_H	*	1.2	:	C2D::FlatBarDraw(1,	y)
	y	+	#BAR_H	*	2.2	:	C2D::FlatBarDraw(2,	y)
	y	+	#BAR_H	*	1.1	:	C2D::FlatBarDraw(3,	y)
	y	+	#BAR_H	*	1.7	:	C2D::FlatBarDraw(4,	y)
	y	+	#BAR_H	*	1.1	:	C2D::FlatBarDraw(5,	y)
	StopDrawing()

	C2D::FlatBarFree(#PB_All)	; static flatbars not needed any more
	
	; create one new back-flatbar for scroller only
	C2D::FlatBarInit(0, #BAR_H, $BB6666, #C2D_Z)
	
EndProcedure
Procedure	Defjam_Update()

	C2D::FlatBarDraw(0, #POS_Y)	; one flatbar for scrolltext only
	C2D::ScrollTextDraw(0, #POS_Y + (#BAR_H - #FNT_H) * 0.5)

EndProcedure

Defjam_Init()

Repeat
	Select	WindowEvent()
		Case	#WM_LBUTTONUP,
		    	#WM_RBUTTONUP
			Break
		Case	#WM_KEYDOWN
			If	EventwParam()	=	#VK_ESCAPE
				Break
			EndIf
		Case	#PB_Event_CloseWindow
			Break
		Default
			If	C2D::Start()
				Defjam_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection

	i_raw:	:	IncludeBinary	"gfx\Defjam_Font_9.rw"	:	e_raw:	; Amiga_Topaz_9
	
	c_text:	:	Data.l	2, $FFDDDDDD, $FF999999
	
	t_text:	:	Data.s	"YEEAAH, ANOTHER CRACK FROM US. THIS GAME WAS CRACKED, TRAINED AND NORMALIZED BY IL SCURO FOR DEFJAM - C.C.S. "	+
	       	 	      	"SPECIAL DEFJAM-REGARDS TO RED SECTOR, VISION FACTORY AND BEYONDERS, BAMIGA SECTOR ONE, HQC, THRUST, UNIT A AND FREAKERS INTERNATIONAL"	
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = w
; Executable = C2D_Defjam_x86.exe
; CompileSourceDirectory