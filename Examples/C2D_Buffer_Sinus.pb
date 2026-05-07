; C2D::Buffer / Sinus - Purebasic v5.70 x86-64

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Bitmap		=	1
	#IsC2D_Buffer		=	1
	#IsC2D_File			=	1
	#IsC2D_ScrollText	=	2
	#IsC2D_Clear		=	2
	#IsC2D_Fps			=	0
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget

#SIN_X	=	20	*	#C2D_Z	; Horizontal sinuswidth

#C2D_C	=	#SIN_X	*	2
#C2D_W	=	550	*	#C2D_Z	+	#C2D_C	; Width
#C2D_H	=	340	*	#C2D_Z					; Height

#ID_FONT	=	0
#ID_TEXT	=	0
#ID_BLIT	=	0

#TEXT_Z	=	50		*	#C2D_Z
#TEXT_Y	=	(#C2D_H	-	#TEXT_Z)	*	0.5

OpenWindow(0, 0, 0, #C2D_W - #C2D_C, #C2D_H, MA_C2DPB("Buffer / Sinus"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, -(#C2D_C / 2), 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

UseModule	C2D

Init(#C2D_G, 7)

BitmapInit(#ID_FONT, @"..\Data\Font\BMP\48x48_Gold.bmp")

FontInit(#ID_FONT, BitmapImage(#ID_FONT))
FontZoom(#ID_FONT, #TEXT_Z, #TEXT_Z)

ScrollTextInit(#ID_TEXT, ?l_text)
ScrollTextSpeed(#ID_TEXT, 2)

Repeat
	Select	WindowEvent()

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
				Break
			EndIf
			
		Default
			
			If	Start()
				
				; avoid artifacts on left/right
				ClipOutput(#SIN_X, 0, #C2D_W - #SIN_X * 2, #C2D_H)
				ScrollTextDraw(#ID_TEXT, #TEXT_Y)
				UnclipOutput()
				
				; make some sin/cos noise
				x_wave.f	=	(Sin(C2D\Time * 0.0027) * Cos(C2D\Time * 0.0009) + 0.2) * 2		*	#SIN_X
				y_wave.f	=	(Cos(C2D\Time * 0.0049) * Sin(C2D\Time * 0.0019) + 0.1) * 110	*	#C2D_Z
				
				BufferSinX(#SIN_X, #TEXT_Y, #C2D_W - #SIN_X * 2, #TEXT_Z, x_wave, 18.8, 9.2)
				BufferSinY(#SIN_X, #TEXT_Y, #C2D_W, #TEXT_Z, y_wave, 1.91, 1.9, #True)
				
				CompilerIf	IsC2D::#IsC2D_Fps
					DrawText(#SIN_X, 0, Str(C2D\FPS))
				CompilerEndIf
				
				Stop()
 				
 			EndIf
			
	EndSelect
ForEver

Free()

DataSection
	l_text:	:	Data.s	"EXAMPLE USING THE TINY  {5}C2D V" + MA_XC2D() + "{5}{2,8000} CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + ") ... VISIT US AT TESTAWARE.WORDPRESS.COM"
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = 5
; Executable = ..\Executables\C2D_Buffer_Sinus_x86.exe
; DisableDebugger
; CompileSourceDirectory