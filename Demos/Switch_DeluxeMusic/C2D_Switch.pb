; C2D::Switch - Deluxe Music II 100% - 12.1993
; Purebasic v5.72 (x86-64) / 17.02.2020

; http://janeway.exotica.org.uk/release.php?id=90000

; SWITCH ;) DEBUGGER OFF!

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"
	#IsC2D_Music	=	#XMU_TPT

	#IsC2D_Poly3D	=	1
	#IsC2D_Stars2D	=	1
	#IsC2D_Text		=	1
	#IsC2D_Buffer	=	1	; need for fast background
	#IsC2D_Copper	=	1
	#IsC2D_GdiPlus	=	2
	#IsC2D_Clear	=	0	; no clear (using BufferBackDraw)
	#IsC2D_Help		=	0
	#IsC2D_Mode		=	0
	#IsC2D_Bitmap	=	0
	#IsC2D_Topaz	=	0

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Canvas ***
#C2D_G	=	0	; #ID of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth (zoomed)
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight (zoomed)

; Dark-Blue-Center
#Y0	=	40 * #C2D_Z
#Y1	=	#C2D_H	-	#Y0	*	2

Procedure	Blit_Magenta(x, y, Front, Back)
	If	Back	<>	$FFFF00FF
		ProcedureReturn	Back
	EndIf
	ProcedureReturn	Front
EndProcedure

Procedure	Switch_Init()
	
	Protected	*a	=	?t_text
	Protected	*t.String	=	@*a
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Switch - Deluxe Music II 100% - 1993"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	; initialze c2d
	C2D::Init(#C2D_G, 8)

	; 2d-starfield
	C2D::Stars2DInit(80, #C2D_Z, 0, #Y0, #C2D_W, #Y1, 2.5 * #C2D_Z)

	; create text-font
	C2D::GdipCatch(0, ?i_font, ?e_font)
	C2D::FontInit(0, 0)
	C2D::FontScale(0, #C2D_Z)

	; create coppers for polygon-brush (filled copper + text)
	C2D::CopperInit(0, #C2D_H - #Y0 * 2, ?p_copper)	; poly-copper
	C2D::CopperInit(1, #C2D_H - #Y0 * 2, ?t_copper)	; text-copper

  	; draw text on poly-copper & set copper text
 	StartDrawing(ImageOutput(C2D::CopperImage(0)))
	C2D::TextStringDraw(0, 0, *t\s)				; text (magenta)
	DrawingMode(#PB_2DDrawing_CustomFilter)	; coppermode
	CustomFilterCallback(@Blit_Magenta())		; copperproc
	C2D::CopperDraw(1, 0)							; draw copper on text (magenta)
	StopDrawing()
 
  	; manually create & grab fast background
 	StartDrawing(CanvasOutput(#C2D_G))
 	Box(0, #Y0, #C2D_W, #Y1, $400000)			; backscene darkblue
	C2D::TextStringDraw(0, #Y0, *t\s)			; text (magenta)
	DrawingMode(#PB_2DDrawing_CustomFilter)	; coppermode
	CustomFilterCallback(@Blit_Magenta())		; copperproc
	C2D::CopperDraw(1, #Y0)							; draw copper on text (magenta)
	C2D::BufferBackGrab()							; grab buffer for fast background
	C2D::BufferClear()								; clear canvas (black)
	StopDrawing()
	
	; create polygon-logo & scale
	C2D::Poly3DInit(0, ?p_logo)
	C2D::Poly3DScale(0, 5.5 * #C2D_Z)
	C2D::Poly3DClip(0, 0, #Y0, #C2D_W, #Y1)
	C2D::Poly3DAngle(0, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))
	C2D::Poly3DBrush(0, C2D::CopperImage(0))

	; create moving border-copper
	C2D::CopperInit(0, #C2D_Z, ?b_copper, C2D::#C2F_Horizontal)

	; no longer needed
	FreeImage(0)			; Gdip
	C2D::FontFree(0)		; Font
	C2D::CopperFree(1)	; Copper-Text

	; play music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	Switch_Update()

	; draw fast background
	C2D::BufferBackDraw()

	; starfield
	C2D::Stars2DDraw()

	; rotate & draw poly3d-logo (simulates tricky backdraw)
	C2D::Poly3DRotate(0, 3.713, 3.131, 1.167)
	C2D::Poly3DDraw(0)
	
	; draw moving copper-borders (cloney faster than draw)
	C2D::CopperMoveDraw(0, #Y0 - #C2D_Z, -3.5 * #C2D_Z)
	C2D::BufferCloneY(#Y0 - #C2D_Z, #Y0 + #Y1, #C2D_Z)

EndProcedure

Switch_Init()

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				Switch_Update()
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

	CompilerIf	IsC2D::#IsC2D_Music
		m_music:	:	IncludeBinary	"mus\Olivier Van Liempt - Synuswavicalistic.mod"	:	e_music:
	CompilerEndIf

	p_logo:	:	IncludeBinary	"gfx\Switch_Logo.p3d"
	i_font:	:	IncludeBinary	"gfx\Switch_Font.png"	:	e_font:

	b_copper:	:	Data.l	3, $FF111100, $FF00FFFF, $FF111100
	p_copper:	:	Data.l	3, $FF0000FF, $FF00FFFF, $FF0000FF
	t_copper:	:	Data.l	9, $FF00FF00, $FF88FF00, $FFFFFF00,
										$FFFFFFCC, $FF8888FF, $FF4444FF,
										$FF0000FF, $FF0044FF, $FF0044FF

	t_text:
	Data.s	"****************************************|"	+
	      	"*                                      *|"	+
	      	"*           SWITCH PRESENTS:           *|"	+
	      	"*                                      *|"	+
	      	"* ------------------------------------ *|"	+
	      	"* >>> DELUXE MUSIC II 100% VERSION <<< *|"	+
	      	"* ------------------------------------ *|"	+
	      	"*                                      *|"	+
	      	"*                                      *|"	+
	      	"*                                      *|"	+
	      	"*                                      *|"	+
	      	"*                                      *|"	+
	      	"*                                      *|"	+
	      	"*                                      *|"	+
	      	"*                                      *|"	+
	      	"*                                      *|"	+
	      	"* 100% CRACKED VERSION DONE BY: JARRE! *|"	+
	      	"*                                      *|"	+
	      	"* GREETINGS TO ALL AMIGAFANS WORLDWIDE *|"	+
	      	"****************************************"

EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A+
; Executable = C2D_Switch_x86.exe
; CompileSourceDirectory