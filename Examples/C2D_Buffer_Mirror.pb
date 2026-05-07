; C2D::Buffer / Mirror - Purebasic v5.70

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Bitmap		=	0
	#IsC2D_Buffer		=	1
	#IsC2D_Topaz		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_Clear		=	2
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

UseModule	C2D

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#TEXT_Z	=	50		*	#C2D_Z
#TEXT_Y	=	(#C2D_H	-	#TEXT_Z)	*	0.5

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Buffer / Mirror"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

Init(#C2D_G, 8)

FontRawInit(0)
FontZoom(0, #TEXT_Z, #TEXT_Z)
FontCopper(0, ?c_blit)

ScrollTextInit(0, ?l_text)
ScrollTextSpeed(0, 2)

Repeat
	Select	WindowEvent()
		Case	#Null
			
			If	Start()

				ScrollTextDraw(0, #TEXT_Y)
				
				h = BufferMirror(0, #TEXT_Y + #TEXT_Z, #C2D_W, #TEXT_Z, %1)
				Box(0, #TEXT_Y + #TEXT_Z, #C2D_W, h, $8F6F0000)

				Stop()
 				
 			EndIf
			
		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf

	EndSelect
ForEver

Free()

DataSection	
	c_blit:	:	Data.l	3,	$FF000000|#Magenta, $FF000000|#White, $FF000000|#Cyan
	l_text:	:	Data.s	"EXAMPLE USING THE TINY C2D MODULE V" + MA_XC2D() + " CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + ") ... VISIT US AT TESTAWARE.WORDPRESS.COM"
EndDataSection
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = 9
; Executable = ..\Executables\C2D_Buffer_Mirror_x86.exe
; CompileSourceDirectory