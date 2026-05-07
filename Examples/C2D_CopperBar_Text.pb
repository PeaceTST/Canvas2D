; C2D::CopperBar / Text - Purebasic v5.72 (x86-64)

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

IncludePath	"..\Include\"

DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"	; include music #F_(Formats)

	#IsC2D_Music		=	#XMU_FC4	; AV - Alarm? -> try FCP, AMP

	#IsC2D_Copper		=	1
	#IsC2D_Stars2D		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_Topaz		=	1	; includes default topaz.font

	#IsC2D_Clear		=	2
	#IsC2D_File			=	2

	XIncludeFile	"C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#COP_H	=	54 * #C2D_Z
#FONT_H	=	#COP_H - 12

Enumeration
	#ID_0
	#ID_1
	#ID_2
EndEnumeration

Enumeration
	#ID_SCROLL
EndEnumeration

Enumeration
	#ID_FONT
EndEnumeration

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("CopperBar / Text + FC4"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G)

C2D::Stars2DInit(64 * #C2D_Z, 2, 0, #COP_H, #C2D_W, #C2D_H - #COP_H * 2, 2.5)

C2D::FontRawInit(#ID_FONT)	:	C2D::FontZoom(#ID_FONT, #FONT_H-8, #FONT_H)	:	C2D::FontCopper(#ID_FONT, ?c_t)

C2D::CopperInit(#ID_0,	#COP_H,	?c_0)	:	C2D::CopperText(#ID_0, @"COPPERTEXT")
C2D::CopperInit(#ID_1,	#COP_H,	?c_1)	:	C2D::CopperText(#ID_1, @"CANVAS 2D:MO")
C2D::CopperInit(#ID_2,	#COP_H,	?c_2)

C2D::ScrollTextInit(#ID_SCROLL, ?l_Text)	:	C2D::ScrollTextSpeed(#ID_SCROLL, 1.0)

CompilerIf	IsC2D::#IsC2D_Music
	Define	Music$	=	C2D::FileParent()	+	"Data\Music\FC\Fraxion.fc14"
	C2D::MusicPlay(@Music$)
CompilerEndIf

Repeat
	Select	WindowEvent()
		Case	#Null
			
			If	C2D::Start()

				C2D::Stars2DDraw()
				
				C2D::CopperDraw(#ID_0,	0)
				C2D::CopperDraw(#ID_1,	#C2D_H - #COP_H)
				
				C2D::CopperDraw(#ID_2, (#C2D_H - #COP_H) * 0.5)
				C2D::ScrollTextDraw(#ID_SCROLL, (#C2D_H - #FONT_H) * 0.5)
				
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
	c_t:	:	Data.l	3, $00FFFFFF, $C0FFFFFF, $00FFFFFF
	c_0:	:	Data.l	3, $000000FF, $FF0070FF, $000000FF
	c_1:	:	Data.l	3, $0000FF00, $FF70FF70, $0000FF00
	c_2:	:	Data.l	3, $00FFF000, $FFFFF000, $00FFF000
	l_Text:	:	Data.s	"EXAMPLE USING THE TINY C2D MODULE V" + MA_XC2D() + " CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + ") ... VISIT:TESTAWARE.WORDPRESS.COM"
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = C-
; Executable = ..\Executables\C2D_CopperBar_Text_x86.exe
; DisableDebugger
; CompileSourceDirectory