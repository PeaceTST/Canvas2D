; C2D::Paradox / Warrirors Of Might And Magic - PS1 - Trainer2 - 2000
; Purebasic v6.04 (x86) - 05.05.2024

; https://demozoo.org/productions/169181/

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_TPT

	#IsC2D_Bitmap		=	1
	#IsC2D_Copper		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_PageText	=	1
	#IsC2D_Text			=	1
	
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_Ball3D		=	2	; 2 -> include starfield, explode, merge
	#IsC2D_Clear		=	2	; 2 -> fast clear backbuffer
	
	#IsC2D_Help	=	0

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"	; adapt path of include

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"		; adapt path of include

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width
#C2D_H	=	240	*	#C2D_Z	; Height

Enumeration
	#ID_LOGO
	#ID_STAR
	#ID_FONT
	#ID_TEXT
	#ID_SCRL
	#ID_COP0
	#ID_COP1
EndEnumeration

Global	RetVal, Fnt_H

Procedure	Blit_Copper(x, y, PenColor, PaperColor)
	If	PaperColor=$FFFFFFFF
		ProcedureReturn	PenColor
	EndIf
	ProcedureReturn	PaperColor
EndProcedure

Procedure	C2D_Init()
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Paradox - Warrirors Of Might And Magic - PS1 - Trainer2 - 2000"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 11)

	C2D::BitmapInit(#ID_LOGO,	?i_logo,	?e_logo)
	C2D::BitmapScale(#ID_LOGO,#C2D_Z)

	C2D::BitmapInit(#ID_FONT,	?i_font,	?e_font)
	C2D::FontInit(#ID_FONT,		C2D::BitmapImage(#ID_FONT))
	C2D::FontScale(#ID_FONT,	0.5 * #C2D_Z)
	C2D::FontGap(#ID_FONT,		0, 2)
	Fnt_H	=	C2D::FontH(#ID_FONT)

	;C2D::FontSelect(#ID_FONT)
	C2D::PageTextInit(?t_info, 0, 0.46 * #C2D_H, #C2D_W, 3 * C2D::FontH(#ID_FONT), C2D::#C2F_CenterX)
	C2D::PageTextEffect(1, C2D::#PFX_FadeStep, 255, 1250)

	C2D::TextInit(#ID_TEXT, ?t_text, C2D::#C2F_CenterX)

	C2D::ScrollTextInit(#ID_SCRL,	?t_scroll)
	C2D::ScrollTextSpeed(#ID_SCRL,0.5 * #C2D_Z)

	C2D::CopperInit(#ID_COP0, 9 * C2D::FontH(#ID_FONT) + #C2D_Z, ?c_0, C2D::#C2F_Horizontal)
	C2D::CopperInit(#ID_COP1, C2D::ScrollTextH(#ID_SCRL), ?c_0, C2D::#C2F_Horizontal)
	C2D::CopperBlitProc(@Blit_Copper())

	; Starfield
	C2D::Quality(0)
	C2D::Ball3DStars(#ID_STAR, 600, 107, 1+#C2D_Z, -1, 11.3)
	C2D::Ball3DAngle(#ID_STAR, C2D::MA_RMP(798),  C2D::MA_RMP(798),  C2D::MA_RMP(798))

	; at last play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf
	
EndProcedure
Procedure	C2D_Update()
	
	Protected	y	=	WindowMouseY(0)
	Protected	Time.f	=	C2D::C2D\Time	*	0.00001

	C2D::Ball3DRotate(#ID_STAR, Sin(Time * 2.1), Sin(Time * 3.3), Cos(Time * 4.1))
	C2D::Ball3DDraw(#ID_STAR, 0, 0, 255, 3)
	
	C2D::BitmapDraw(#ID_LOGO, 0, 0.08 * #C2D_H, 255, C2D::#C2F_CenterX)
	
	C2D::PageTextDraw()
	
	C2D::TextDraw(#ID_TEXT, 0, 0.63 * #C2D_H)
	
	C2D::ScrollTextDraw(#ID_SCRL, 0.87 * #C2D_H)
	
	; at last: text-copper!
	C2D::CopperBlit(#ID_COP0, 0.46 * #C2D_H,-1.0)
	C2D::CopperBlit(#ID_COP1, 0.87 * #C2D_H, 1.0)
	
	If	y	>	0.627 * #C2D_H	And	y	<	0.665 * #C2D_H	+	Fnt_H
		If	y	>	0.665 * #C2D_H
			y	=	0.665 * #C2D_H
			RetVal	=	2
		Else
			RetVal	=	1
			y	=	0.627 * #C2D_H
		EndIf
		DrawingMode(#PB_2DDrawing_Outlined)
		Box(-1, y, #C2D_W + 2, Fnt_H, $FFFFFFFF)
	ElseIf	RetVal
		RetVal	=	0
	EndIf

EndProcedure

C2D_Init()

Define	IsOn1, IsOn2, t$, x

Repeat
	Select	WindowEvent()
		Case	#WM_LBUTTONDOWN
			If	RetVal
				t$	=	"OFF"
				Select	RetVal
					Case	1	:	IsOn1	!	1	:	If	IsOn1	:	t$	=	" ON"	:	EndIf	:	x	=	27
					Case	2	:	IsOn2	!	1	:	If	IsOn2	:	t$	=	" ON"	:	EndIf	:	x	=	58
				EndSelect
				PokeS(?t_text + x * SizeOf(Character), t$, -1, #PB_String_NoZero)
				C2D::TextInit(#ID_TEXT, ?t_text, C2D::#C2F_CenterX)
			EndIf
		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_X,
				    	#VK_O,
				    	#VK_ESCAPE
					Break
			EndSelect
		Case	#PB_Event_CloseWindow
			Break
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
		m_music:	:	IncludeBinary	"mus\Estrayk PDX - Trainer2_fixed.mod"	:	e_music:
	CompilerEndIf

	i_logo:	:	IncludeBinary	"gfx\Paradox_Logo.png"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\Paradox_Font.png"	:	e_font:

	c_0:		:	Data.l	7,	$FFFF6611, $FF3333FF, $FF11AA44, $FFC1F5FF, $FFFF88FF, $FF33FFFF, $FFFF6611

	t_info:	:	Data.s	"PROUDLY PRESENTS|"					+
	       	 	      	"WARRIORS OF MIGHT AND MAGIC!|"	+
	       	 	      	"TRAINER AND PAL/NTSC SELECTOR!"	+
	       	 	      	"~|"	+
	       	 	      	"PATCHED BY DEATURE/PARADOX|"+
	       	 	      	"~|"	+
	       	 	      	"CREDITS FOR THIS INTRO:|"	+
	       	 	      	"~|"	+
	       	 	      	"PROGRAMMING:   DEATURE/PDX|"+
	       	 	      	"~|"	+
	       	 	      	"LOGO:           ALIEN/PDX|"	+
	       	 	      	"FONT:   SECTOR 9/RZR 1911"	+
	       	 	      	"~|"	+
	       	 	      	"SUPERB MUSIC:  ESTRAYK/PDX"	+
	       	 	      	"~|"	+
	       	 	      	"C2D RETRO:  PEACE/TST"

	t_text:	:	Data.s	"UNLIMITED ENERGY           OFF|"	+
	       	 	      	"UNLIMITED MAGIC            OFF|"	+
	       	 	      	#LF$	+
	       	 	      	"(X) PAL   (O) NTSC"

	t_scroll:	:	Data.s	"PARADOX PRESENTS WARRIORS OF MIGHT AND MAGIC TRAINER AND PAL/NTSC SELECTOR... PRESS (X) FOR PAL OR (O) FOR NTSC... PATCHED BY DEATURE...     GREETINGS TO: LIGHTFORCE, KALISTO, DUAL CREW-SHINING, STATIC, DIVINE, FAIRLIGHT, MYTH, UTOPIA, CLASS, X-PRESSION, KINGDOM, COMPLEX, CAPITAL, EURASIA AND THE REST OF THE GANG ... SPECIAL GREETINGS FROM DEATURE TO: * WAYNEKERR * ROTOX * MR.BATMAN * FONJI * SDC * ZWEIFIELD * OUTSTA * GILLIGAN * SEFFREN * SC0RPIO * XOR37H * ONER * SENSI * ALIEN * ESTRAYK * SPEEDEVIL * ROCCO * SWEED * PETER * SOLAR * CINIC * ARCANUM * DDT * LIBERATOR * SM0N * MDT * SCREEM * N01 * ZNOOPY * ZIPE * DRONE * THORSTEN * CRAFT * ECHO * NOCTURNE * JULES * B * ZECMASTER * MFM * MMX * FURY * TCB * SAL-ONE * JBM * MADBOY * SKYWALKER *"

EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = A9
; Executable = C2D_Paradox_x86.exe
; DisableDebugger
; CompileSourceDirectory