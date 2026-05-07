; C2D::ScrollText / Sinus - Purebasic v5.72

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Bitmap		=	0
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_Topaz		=	1	; default topaz-rawfont
	#IsC2D_ScrollText	=	2
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#SIN_HEIGHT	=	64.0	*	#C2D_Z
#SIN_FREQ	=	10.0	/	#C2D_Z
#SIN_SPEED	=	2.0	*	#C2D_Z
#SIN_Y		=	#C2D_H	*	0.5

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("ScrollText / Sinus"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 8, #White)

C2D::FontRawInit(0)
C2D::FontZoom(0, 20 * #C2D_Z, 32 * #C2D_Z)
C2D::FontColor(0, $0FB9FF)
C2D::FontShadow(0, 3, 3, 112)

C2D::ScrollTextInit(0, ?l_Text)
C2D::ScrollTextSinus(0, #SIN_HEIGHT, #SIN_FREQ, 70 * #C2D_Z)
C2D::ScrollTextSpeed(0, #SIN_SPEED)

Repeat
	Select	WindowEvent()
			
		Case	#Null
			
			If	C2D::Start()
				
				LineXY(0, #SIN_Y - #SIN_HEIGHT, #C2D_W, #SIN_Y - #SIN_HEIGHT, $FF000000)
				LineXY(0, #SIN_Y + #SIN_HEIGHT, #C2D_W, #SIN_Y + #SIN_HEIGHT, $FF000000)
				
				If	C2D::ScrollTextDraw(0, #SIN_Y - 16 * #C2D_Z)	=	C2D::#C2F_End
					C2D::ScrollTextSinus(0, Random(#SIN_HEIGHT), Random(50) / #C2D_Z, Random(50) * #C2D_Z)	
					C2D::ScrollTextSpeed(0, 0.1 * Random(50,10))
				EndIf
				
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

DataSection
	l_Text:	:	Data.s	"EXAMPLE USING{3,20}{5}THE TINY C2D MODULE{5}{2,5000}CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + ") ... VISIT US AT{3,20}{5}TESTAWARE.WORDPRESS.COM{5}{2,5000}"
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = 9
; Executable = ..\Executables\C2D_ScrollText_Sinus_x86.exe
; CompileSourceDirectory