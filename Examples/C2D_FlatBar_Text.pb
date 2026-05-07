; C2D::FlatBar / Text - Purebasic v5.72 (x86-64)

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

IncludePath	"..\Include\"

DeclareModule	IsC2D
	XIncludeFile	"C2D_Types.pbi"	; include music #F_(Formats)
	#IsC2D_Music		=	#XMU_SCA	;PT2
	#IsC2D_FlatBar		=	1
	#IsC2D_Stars2D		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_FontColor	=	1	; shadow
	#IsC2D_FontRaw		=	1
	#IsC2D_Topaz		=	1	; default topaz-rawfont
	#IsC2D_Clear		=	2
	XIncludeFile	"C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#FLAT_H	=	40 * #C2D_Z
#FONT_H	=	#FLAT_H - 16

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

Procedure.l	xRGB()
	ProcedureReturn	(Random($FF) << 16 | Random($FF) << 8 | Random($FF)) | $FF101010
EndProcedure

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("FlatBar / Text + SCAL"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 5)

C2D::Stars2DInit(80, 2, 0, #FLAT_H, #C2D_W, #C2D_H - #FLAT_H * 2, 2.5)

C2D::FontRawInit(#ID_FONT)	:	C2D::FontZoom(#ID_FONT, #FONT_H, #FONT_H)	:	C2D::FontShadow(#ID_FONT, 2, 2, 90)

C2D::FlatBarInit(#ID_0,	#FLAT_H,	xRGB(), 2)	:	C2D::FlatBarText(#ID_0, @"FLATBAR")
C2D::FlatBarInit(#ID_1,	#FLAT_H,	xRGB(), 2)	:	C2D::FlatBarText(#ID_1, @"CANVAS ZWEI DE:MO")
C2D::FlatBarInit(#ID_2,	#FLAT_H,	xRGB(), 2)

C2D::FontRawInit(#ID_FONT)	:	C2D::FontZoom(#ID_FONT, #FONT_H * 0.6, #FONT_H)	:	C2D::FontShadow(#ID_FONT, 2, 2, 90)
C2D::ScrollTextInit(#ID_SCROLL, ?l_Text)
C2D::ScrollTextSpeed(#ID_SCROLL, 1.2)

y.f	=	(#C2D_H	-	#FLAT_H)	*	0.5
f.f	=	(#FLAT_H	-	#FONT_H)	*	0.5

CompilerIf	IsC2D::#IsC2D_Music
	C2D::MusicInit(#SCAL_PATH$)	; set default-path to SCAL_(x86-64).dll
	C2D::MusicPlay(@"..\Data\Music\MOD\Spirou - Warez On.mod")
CompilerEndIf

Repeat
	Select	WindowEvent()
		Case	#Null
			
			If	C2D::Start()
				
				s.f	=	y + Sin(C2D::C2D\Time * 0.004) * #FLAT_H

				C2D::Stars2DDraw()
				
				C2D::FlatBarDraw(#ID_0,	0)
				C2D::FlatBarDraw(#ID_1,	#C2D_H - #FLAT_H)
				
				C2D::FlatBarDraw(#ID_2, s)
				C2D::ScrollTextDraw(#ID_SCROLL, s + f)
				
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
	l_Text:	:	Data.s	"EXAMPLE USING THE TINY C2D MODULE V" + MA_XC2D() + " CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + ") ... VISIT:TESTAWARE.WORDPRESS.COM"
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = C+
; Executable = ..\Executables\C2D_FlatBar_Text_x86.exe
; DisableDebugger
; CompileSourceDirectory