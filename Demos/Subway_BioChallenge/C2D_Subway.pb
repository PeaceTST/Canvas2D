; C2D::Subway - Bio Challenge - ??.04.1989
; Purebasic v6.04 (x86-64) / 13.08.2021

; http://janeway.exotica.org.uk/release.php?id=14952

;***************************************************
; *** IsC2D the MUST Init-Module, always needed! ***
DeclareModule	IsC2D	; Defaults -> all on!

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; Music, Gui, XUnPack predefined #Types

	#IsC2D_Music		=	#XMU_TPT
	#IsC2D_Buffer		=	1
	#IsC2D_Clear		=	0
	#IsC2D_Checker		=	2
	#IsC2D_Copper		=	1
	#IsC2D_GdiPlus		=	2
	#IsC2D_Line3D		=	2
	#IsC2D_ScrollText	=	2	; 2 -> ControlCodes "{Code,Param.f}"
	#IsC2D_Stars3D		=	1
	
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"
;***************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2
CompilerEndIf

#C2D_G	=	0	; #ID of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth (zoomed)
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight (zoomed)

#Z_VP		=	106	*	#C2D_Z	; viewpoint

#H_CHECK		=	58	*	#C2D_Z
#Y_SCROLL	=	#H_CHECK + 74 * #C2D_Z

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Subway - Bio Challenge - 1989"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)	; update every 8ms
	
	; font
	C2D::GdipCatch(0, ?i_font, ?e_font)
	C2D::FontInit(0, 0)
	C2D::FontScale(0, #C2D_Z)

	; scroller
	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, 2.0 * #C2D_Z)

	; checkboard
	C2D::CheckerInit(0, #H_CHECK, #Z_VP, 5 + #C2D_Z)
	C2D::CheckerColor($20BF00)
	
	; starfield
	C2D::Stars3DInit(80 * #C2D_Z, #C2D_Z, 0, 0, #C2D_W, #C2D_H, 2.0 + #C2D_Z)
	C2D::Stars3DSpread(-128 * #C2D_Z)
	
	; line3d
	C2D::Line3DInit(0, ?l_subway,	4 * #C2D_Z)
	C2D::Line3DInit(1, ?l_dteam,	4 * #C2D_Z)
	C2D::Line3DFog(#PB_All, 1.8 / #C2D_Z)
	
	; checkerfog & border
	C2D::CopperInit(0, #H_CHECK,		?c_fog)
	C2D::CopperInit(1, 16 * #C2D_Z,	?c_border)
	
	; fast background
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, 0, #C2D_W, #H_CHECK, $FF206F00)
	C2D::CopperDraw(0, 0, 128)
	C2D::CopperDraw(1, #H_CHECK)
	C2D::BufferBackGrab()
	StopDrawing()
	
	; some cleanups
	C2D::CopperFree(1)
	FreeImage(0)
	
	; play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_mus, ?e_mus)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()
	
	Static	Time, IsNext=1, ID=1
	
	C2D::BufferBackDraw()

	C2D::CheckerDraw(-6 * #C2D_Z)
	C2D::CopperDraw(0, 0)

	C2D::BufferMirror(0, #C2D_H / 2 + 1, #C2D_W, #C2D_H / 2 - 1)
	
	C2D::Stars3DDraw()
	
	C2D::Line3DRotate(ID, 3.2, 1.8, 0)
	C2D::Line3DDraw(ID, 0, -24 * #C2D_Z)
	
	C2D::ScrollTextDraw(0, #Y_SCROLL)

	If	C2D::C2D\Time	>=	Time	And	IsNext	=	#False
		IsNext	=	#True
		C2D::Line3DFade(ID, -5)
	ElseIf	IsNext	And	C2D::Line3DIsFade(ID)	=	#Null
		IsNext	=	#False
		ID	!	1
		C2D::Line3DFade(ID, 5)
		Time	=	C2D::MA_TIME()	+	4500
	EndIf

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE	:	Break
			EndSelect

		Default
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf

	EndSelect
ForEver

C2D::Free()

DataSection

	CompilerIf	IsC2D::#IsC2D_Music
		m_mus:	:	IncludeBinary	"mus\Bug - Drums_fixed.mod"	:	e_mus:
	CompilerEndIf
	
	i_font:		:	IncludeBinary	"gfx\Subway_Font.png"	:	e_font:
	
	l_subway:	:	IncludeBinary	"obj\Subway_Logo.l3d"
	l_dteam:		:	IncludeBinary	"obj\DreamTeam_Logo.l3d"
	
	c_fog:		:	Data.l	2,	$00000000, $DF000000
	c_border:	:	Data.l	2, $FF555500, $00555500

	t_text:		:	Data.s	"$%&&&&&&&&&&&&&&&&&{3}{5}SUBWAY{5}{2,5000}{3}AND THE{3}{5}DREAM{3,5}TEAM{5}{2,5000}{3}PRESENT BIO CHALLENGE MEGATRAINER!{3}C{3,5}U...{3}RETRO BY PEACE"
	
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = A-
; Executable = C2D_Subway_x86.exe
; DisableDebugger
; CompileSourceDirectory