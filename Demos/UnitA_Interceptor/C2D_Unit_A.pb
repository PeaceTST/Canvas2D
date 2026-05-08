;***********************************************************
; C2D::UnitA / Crack 41 - 1988
; Peace^TST - 28.10.2017 / 10:50 (very first C2D::Retro)
; Purebasic v5.72 (x86-64)
; http://janeway.exotica.org.uk/release.php?id=1783
;***********************************************************

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

;- *** C2D SWITCHES ****************************************
DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_TPT	; if is a damn false/true, try #XMU_MOD instead
	
	#IsC2D_Bitmap		=	1
	#IsC2D_Anim			=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Copper		=	1
	#IsC2D_Stars3D		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_Pixel3D		=	1
	#IsC2D_GdiPlus		=	2	; 2 -> API-Decoder PNG only!
	
	#IsC2D_DrawingMode=	0
	#IsC2D_Clear		=	0
	#IsC2D_Help			=	0

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_W	=	320	*	#C2D_Z	; Width (zoomed)
#C2D_H	=	240	*	#C2D_Z	; Height (zoomed)

#ID_ANIM_LOGO	=	0
#ID_ANIM_STAR	=	1

#Y_LOGO	=	-(#C2D_H	*	0.5	-	106	*	#C2D_Z)

#STARS_NUM	=	32	+	32	+	463	; Static stars

Global	i, x.f, y.f

Procedure	Blit_Copper(x, y, PenColor, PaperColor)
	If	PaperColor=$FFFFFFFF
		ProcedureReturn	PenColor
	EndIf
	ProcedureReturn	PaperColor
EndProcedure

Procedure	UnitA_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("UnitA - Crack 41 - Interceptor - 1988"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(0, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(0, #True)

	C2D::Init(0, 10)
	
	; UnitA Copper
	C2D::CopperInit(0,  48 * #C2D_Z, ?l_ct)	; Blue-Top
	C2D::CopperInit(1, 130 * #C2D_Z, ?l_cb)	; Blue-Bottom

	; UnitA Stars3D yellow
	C2D::BitmapInit(0, ?i_stary, ?i_staryE)
	C2D::Stars3DSpread(-50 * #C2D_Z)
	C2D::Stars3DDistance(25)
	C2D::Stars3DInit(24, 5 * #C2D_Z, 0, 20 * #C2D_Z, #C2D_W, #C2D_H * 0.80, 4.5, C2D::BitmapImage(0))
	
	; UnitA Font/Scrolltext
	C2D::BitmapInit(0, ?i_font, ?i_fontE)
	C2D::FontInit(0, C2D::BitmapImage(0))	:	C2D::FontScale(0, #C2D_Z)
	C2D::ScrollTextInit(0, ?l_text)			:	C2D::ScrollTextSpeed(0, 0.5 * #C2D_Z)

	; UnitA Logo Pixel3D
	C2D::BitmapInit(0, ?i_logo, ?i_logoE)
	C2D::BitmapScale(0, #C2D_Z)
	C2D::Pixel3DInit(0, C2D::BitmapImage(0))

	; UnitA StarAnim
	C2D::BitmapInit(0, ?a_star, ?a_starE)
	C2D::AnimInit(#ID_ANIM_STAR,	C2D::BitmapImage(0), 8, 4)
	C2D::AnimScale(#ID_ANIM_STAR, 0.72 * #C2D_Z)
	C2D::AnimDelay(#ID_ANIM_STAR,	70)
	C2D::AnimDelay(#ID_ANIM_STAR,	0, 31)

	; UnitA Cleric
	C2D::BitmapInit(0, ?i_cleric, ?i_clericE)	:	C2D::BitmapScale(0, #C2D_Z)

	; UnitA LogoSign
	C2D::BitmapInit(1, ?i_sign, ?i_signE)		:	C2D::BitmapScale(1, #C2D_Z)

	; UnitA Stars2D blue
	C2D::BitmapInit(2, ?i_starb, ?i_starbE)	:	C2D::BitmapScale(2, #C2D_Z)
	C2D::BitmapInit(3, ?i_starb, ?i_starbE)	:	C2D::BitmapScale(3, 0.5 * #C2D_Z)
	C2D::BitmapInit(4, ?i_starb, ?i_starbE)	:	C2D::BitmapScale(4, 0.2 * #C2D_Z)

	;_________________________________________________
	;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	; *** Create fast backbuffer ( ~12% less cpu ) ***
	;_________________________________________________
	;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	StartDrawing(CanvasOutput(0))

	; Clerics
	C2D::BitmapDraw(0, 0, #C2D_H * 0.35)
	C2D::BitmapDraw(0, 0, #C2D_H * 0.12, 200, C2D::#C2F_CenterX)
	C2D::BitmapDraw(0, 0, #C2D_H * 0.35, 255, C2D::#C2F_Right)

	; Blue top + bottom copper
	C2D::CopperDraw(0, 0)
	C2D::CopperDraw(1, 0, 255, C2D::#C2F_Bottom)

	; LogoSign
	C2D::BitmapDraw(1, 0, #C2D_H * 0.80, 255, C2D::#C2F_CenterX)

	; Static stars
	For	i	=	0	To	#STARS_NUM
		x	=	0.98	*	Random(#C2D_W)
		y	=	0.77	*	Random(#C2D_H)	+	0.08	*	#C2D_H
		If	i	<=	31
			C2D::BitmapDraw(2, x, y, 232)					; big
		ElseIf	i	<=	63
			C2D::BitmapDraw(3, x, y, Random(200, 80))	; medium
		Else
			C2D::BitmapDraw(4, x, y, Random(200, 32))	; small
		EndIf
	Next

	; Now grab backbuffer for fast restore
	C2D::BufferBackGrab()
	C2D::BufferClear()

	StopDrawing()
	;_________________________________________________
	;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

	; Free unused stuff
	C2D::BitmapFree(#PB_All)
	C2D::CopperFree(#PB_All)
	
	; Create copper for scroller
	C2D::CopperInit(0, C2D::ScrollTextH(0), ?l_cf)	; Scroll-Text
	C2D::CopperBlitProc(@Blit_Copper())					; Scroll-Text-Copper

	; Precalculate 1. position of turning star
	i	=	1
	x	=	0.440	*	#C2D_W	-	C2D::AnimW(#ID_ANIM_STAR)	*	0.5
	y	=	0.375	*	#C2D_H	-	C2D::AnimH(#ID_ANIM_STAR)	*	0.5

	; Play music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	UnitA_Update()
	
	Static	Count, R_ON = 1
	
	; restore static background
	C2D::BufferBackDraw()
	
	; draw pixel3d logo
	C2D::Pixel3DDraw(0, 0, #Y_LOGO)

	If	R_ON	; rotate logo?
		
		C2D::Pixel3DRotate(0, 0, 4, 0)
		
		Count	+	1
		
		If	Count	>=	500
			R_ON	=	0
			Count	=	0
			C2D::Pixel3DAngle(0, 0, 0, 0)
		EndIf
		
	Else	; star-anim on logo
		
		Select	C2D::AnimDraw(#ID_ANIM_STAR, x, y)	; return frameID
				
			Case	31
				Select	i
					Case	0,3
						x	=	0.440	*	#C2D_W
						y	=	0.375	*	#C2D_H
					Case	1,4
						x	=	0.477	*	#C2D_W
						y	=	0.497	*	#C2D_H
					Case	2,5
						x	=	0.532	*	#C2D_W
						y	=	0.415	*	#C2D_H
				EndSelect
				
				x	-	C2D::AnimW(#ID_ANIM_STAR)	*	0.5
				y	-	C2D::AnimH(#ID_ANIM_STAR)	*	0.5
				
				i	+	1	:	If	i	>	5	:	i	=	0	:	R_ON	=	1	:	EndIf
				
		EndSelect
		
	EndIf

	; yellow stars3d
	C2D::Stars3DDraw(0, -#C2D_H * 0.50)

	; scrolltext + copper
	C2D::ScrollTextDraw(0, #C2D_H * 0.74)
	C2D::CopperBlit(0, #C2D_H * 0.74, -0.14 * #C2D_Z)

EndProcedure

UnitA_Init()

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				UnitA_Update()
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
		m_music:	:	IncludeBinary	"mus\Unit5_fixed.mod"	:	e_music:
	CompilerEndIf

	IncludePath	"gfx\"
	a_star:		:	IncludeBinary	"UA_Anim_B26.png"		:	a_starE:
	i_logo:		:	IncludeBinary	"UA_Logo.png"			:	i_logoE:
	i_stary:		:	IncludeBinary	"UA_Star.png"			:	i_staryE:
	i_starb:		:	IncludeBinary	"UA_StarBlue.png"		:	i_starbE:
	i_cleric:	:	IncludeBinary	"UA_ClericFade.png"	:	i_clericE:
	i_sign:		:	IncludeBinary	"UA_SignFade.png"		:	i_signE:
	i_font:		:	IncludeBinary	"UA_Font.png"			:	i_fontE:

	l_ct:	:	Data.l	2, $FF660000, $00660000	; Copper top
	l_cb:	:	Data.l	2, $00660000, $FF660000	; Copper bottom
	l_cf:	:	Data.l	3, $FF0000EE, $FF8800BB, $FF0000EE	; Copper Text

	l_text:
	Data.s	"SCANDAL, SCANDAL!!!! "	+
	      	"YOU KNOW GUENTHER KRAEMER (BLADERUNNER) THE AUTHOR OF THE COPYPROGRAM FAST'EM? "	+
	      	"HE IS A THIEF, BECAUSE HE USES IN HIS FAST'EM THE ORIGINAL FAST LIGHTING COPYROUTINES, THEY ARE EXACTLY THE SAME BYTE FOR BYTE. GIVE HIM A KICK, IF YOU MEET HIM ............. "	+
	      	"BUT NOW ........ UNIT A AND RAGE & DYNAMIC SYSTEMS PROUDLY PRESENTS INTERCEPTOR! ORIGINAL BY RAGE, CRACKED BY UNIT A ON 02/06/88."	+	#TAB$	+
	      	"THANKS TO THE NEXT GENERATION."	+	#TAB$	+	#TAB$	+
	      	"NOTE: THIS WAS CRACK NUMBER 41 OF 50 IN ALL, CRACK NUMBER 50 IS THE END OF UNIT A AND OUR LAST ONE !!! "	+
	      	"FAST LIGHTNINGS TO: ABC, AXXESS, BITSTOPPERS, BITKILLERSOFT, BAMIGA SECTOR ONE &  KENT TEAM, CHAMPS, DEFJAM, HQC, HOTLINE, KNIGHT HAWKS, LORD BLITTER, LIGHTFORCE, MAJOR ROM AND QUADLITE, "	+
	      	"MOVERS, MR ZERO PAGE, MR RAM & EXECUTER, PHR-CREW, PARAMOUNT, RSI & MZP, STEEL PULSE, TLC, THE NEW MASTERS, THE WEB INC., VISITORS, WARRIORS OF DARKNESS AND ALL THE OTHERS WE KNOW ........ "	+
	      	"DIZ SAYS, THAT MARK II'S MUSIC IS ALWAYS THE BEST !!!"	+
	      	#TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$ + #TAB$	+
	      	"PRESS RIGHT MOUSEBUTTON TO EXIT!"

EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A+
; Executable = C2D_Unit_A_x86.exe
; CompileSourceDirectory