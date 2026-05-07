; C2D::Ackerlight - Speedball - 01.11.1988
; Purebasic v5.72 (x86-64) / 20.01.2020

; http://janeway.exotica.org.uk/release.php?id=14555

; TURN DEBUGGER OFF!

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictype #XMU_[Type]
	#IsC2D_Music		=	#XMU_TPT	;PT2,SCA	; x86-64
	
	#IsC2D_Bitmap		=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Stars2D		=	1
	#IsC2D_Copper		=	1
	#IsC2D_Bounce		=	1

	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_ScrollText	=	2	; 2 -> ControlCodes "{Code,Param.f}"
	#IsC2D_Pixel3D		=	1
	#IsC2D_Clear		=	2	; 2 -> fast clear canvasbuffer -> fillmemory(#Black)
	
	#IsC2D_Help	=	0

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"	; must include unused #IsC2D_(Effect)

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Canvas ***
#C2D_G	=	0	; #ID of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth (zoomed)
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight (zoomed)
#C2D_A	=	21		*	#C2D_Z	; Left/Right add

; Copperbars
#H_COP	=	14	*	#C2D_Z
#COP_Y	=	10	*	#C2D_Z
#C_BOUNCE=	95	*	#C2D_Z
#C_SPEED	=	7	*	#C2D_Z

; Copperborder
#Y0_BORDER	=	144	*	#C2D_Z
#Y1_BORDER	=	228	*	#C2D_Z

; Logo
#H_LOGO	=	88		*	#C2D_Z
#C2DF_LOGO	=	0.8	*	(36.0	/	#C2D_Z)
#Y_LOGO	=	0.10	*	#C2D_H

; Scroller
#H_FONT		=	41	*	#C2D_Z
#Y_TEXT		=	#Y0_BORDER	+	(#Y1_BORDER	-	#Y0_BORDER	-	#H_FONT	+	2)	/	2	; middle between borders
#Y_Height	=	37	*	#C2D_Z	; height of bounce
#Y_Speed		=	5	*	#C2D_Z

Procedure	Ackerlight_Init()
	
	Protected	t$, i, p
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Ackerlight - Speedball Trainer - 1988"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, -#C2D_A, 0, #C2D_W + #C2D_A * 2, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 6)	; update every 6ms

	; 2d-starfield
	C2D::Stars2DInit(64, #C2D_Z, #C2D_A, 0, #C2D_W, 0.60 * #C2D_H, 3.1 * #C2D_Z)
	
	; bitmapfont
	C2D::BitmapInit(0, ?i_font, ?e_font)
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, -8 * #C2D_Z)
	
	; font-chars to pixel3d (uppercase only)
	t$	=	PeekS(?t_turn)
	For	i	=	'A'	To	'Z'
		If	FindString(t$, Chr(i))
			t$	=	ReplaceString(t$, Chr(i), "{8," + Str(p) + "}")
			C2D::Pixel3DInit(p, C2D::FontImage(33 + i - 'A'))
			p	+	1
		EndIf
	Next
	t$	=	PeekS(?t_al)	+	t$	+	PeekS(?t_text)
	
	; logo
	C2D::BitmapInit(0, ?i_logo, ?e_logo)
	C2D::BitmapScale(0, #C2D_Z)

	; scroller
	C2D::ScrollTextInit(0, @t$)
	C2D::ScrollTextSpeed(0, 2.0 * #C2D_Z)
	
	; bouncing coppers
	C2D::CopperInit(0, 14 * #C2D_Z, ?c_b)
	C2D::CopperInit(1, 14 * #C2D_Z, ?c_w)
	C2D::CopperInit(2, 14 * #C2D_Z, ?c_r)
	
	; copper-borders
	C2D::CopperInit(3, #C2D_Z, ?c_border, C2D::#C2F_Horizontal)
	C2D::CopperInit(4, #C2D_Z, ?c_border, C2D::#C2F_Horizontal)

	C2D::BounceInit(0, #COP_Y, #C_BOUNCE, #C_SPEED)
	C2D::BounceInit(1, #Y_TEXT - 17 * #C2D_Z, #Y_Height, #Y_Speed)
	
	; play music?
	CompilerIf	IsC2D::#IsC2D_Music
		CompilerSelect	IsC2D::#IsC2D_Music
			CompilerCase	IsC2D::#XMU_SCA
				C2D::MusicInit("..\..\Tools\SCAL_DLL\")	; set default-path to scal.dll (x86-64)
		CompilerEndSelect
		C2D::MusicPlay(?m_mus, ?e_mus)
	CompilerEndIf

EndProcedure
Procedure	Ackerlight_Update()

	Protected	y_c

	Static	c_0=0, y_c0.f,	y_p0.f
	Static	c_1=1, y_c1.f,	y_p1.f = #H_COP * 24
	Static	c_2=2, y_c2.f,	y_p2.f = #H_COP * 48
	
	Static	Time, IsMove = #True, y_logo.f = -258 * #C2D_Z, w_logo.f
	
	Static	B_ON, R_ON, y_t = #Y_TEXT
	
	;{ *** Copper Bounce & Spin ***
	y_c	=	C2D::Bounce(0)
	
	; fast cos-step
	y_p0	+	8
	y_p1	+	8
	y_p2	+	8
	
	y_c0	=	y_c + MA_GCos(y_p0)	*	#H_COP
	y_c1	=	y_c + MA_GCos(y_p1)	*	#H_COP
	y_c2	=	y_c + MA_GCos(y_p2)	*	#H_COP

	C2D::CopperDraw(c_0, #COP_Y + y_c0)	; Blau
	C2D::CopperDraw(c_1, #COP_Y + y_c1)	; Weiß
	C2D::CopperDraw(c_2, #COP_Y + y_c2)	; Rot
	;}
	
	; *** Stars ******
	C2D::Stars2DDraw()
	
	;{ *** Logo MoveY ***
	If	IsMove
		If	Time	And	C2D::C2D\Time	>	Time
			If	w_logo	<	8	*	#C2D_Z
				w_logo	+	0.012
			Else
				w_logo	=	8	*	#C2D_Z
				IsMove	=	#False
			EndIf
		ElseIf	Time	=	0
			If	y_logo	<	#Y_LOGO
				y_logo	+	0.6 * #C2D_Z
			Else
				y_logo	=	#Y_LOGO
				Time		=	C2D::C2D\Time	+	3000
			EndIf
		EndIf
	EndIf

	C2D::BitmapDraw(0, 0, y_logo, 255, C2D::#C2F_CenterX)
	If	w_logo
		C2D::BufferSinX(#C2D_A + 8 * #C2D_Z, #Y_LOGO, #C2D_W - 16 * #C2D_Z, #H_LOGO, w_logo, #C2DF_LOGO, 9)
	EndIf
	;}
	
	;{ *** Scroller ***
	Select	C2D::ScrollTextDraw(0, y_t)	; {6,#?}
		Case	1	:	B_ON	=	1	; Bounce On
		Case	2	:	B_ON	=	0	:	y_t	=	#Y_TEXT	; Bounce Off & Reset y-pos
		Case	3	:	R_ON	=	1	; Rotate On
		Case	4	:	R_ON	=	0	; Rotate Off
 	EndSelect
 	
 	If	B_ON	; Bounce?
 		y_t	=	C2D::Bounce(1)
	EndIf
	
	If	R_ON	; Rotate? -> Slows down if debugger is enabled!
		ForEach	C2D::RS_Pixel3D()
			PushListPosition(C2D::RS_Pixel3D())
			C2D::Pixel3DRotate(ListIndex(C2D::RS_Pixel3D()), -8.75, 0, 0)
			PopListPosition(C2D::RS_Pixel3D())
		Next
	EndIf
	;}

	; *** Copper Border
	C2D::CopperMoveDraw(3, #Y0_BORDER, 3)
	C2D::CopperMoveDraw(4, #Y1_BORDER + #C2D_Z, -3)
	C2D::BufferCloneY(#Y0_BORDER, #Y1_BORDER, #C2D_Z * 2)

EndProcedure

Ackerlight_Init()

Repeat
	Select	WindowEvent()
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
				Break
			EndIf
		Default
			If	C2D::Start()
				Ackerlight_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection
	
	CompilerIf	IsC2D::#IsC2D_Music
		m_mus:	:	IncludeBinary	"mus\Pat - Spacetravelling.mod"	:	e_mus:	; fixed with Portracker 2.3
	CompilerEndIf
	
	i_logo:	:	IncludeBinary	"gfx\Ackerlight_Logo.png"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\Ackerlight_Font.png"	:	e_font:
	
	c_border:	:	Data.l	3,	$FF110000,$FFFF0000,$F1140000
	c_b:			:	Data.l	3, $FF440000,$FFFF0000,$FF440000
	c_r:			:	Data.l	3, $FF000044,$FF0000FF,$FF000044
	c_w:			:	Data.l	3, $FF444444,$FFFFFFFF,$FF444444
	
	t_al:		:	Data.s	"{6,1}ACKERLIGHT{3}{6,3}"
	t_turn:	:	Data.s	"THE FRENCH LIGHT PRESENT"
	t_text:	:	Data.s	"{3}{6,4}SPEEDBALL TRAINER{3}{6,2}CRACKED BY H.SYL - INTRO CODED BY OVER LOADER - MUSIC BY PAT - LOGO BY DARK ANGEL - CHARSET BY C-DRYK.... BYE..BYE....."

EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = Aw
; Executable = C2D_Ackerlight_x86.exe
; DisableDebugger
; CompileSourceDirectory