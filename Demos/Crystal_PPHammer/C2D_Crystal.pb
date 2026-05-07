; C2D::Crystal - PP Hammer And His Pneumatic Weapon - 1991
; Purebasic v6.30 (x86-64) / 17.04.2026
; Purebasic v6.04 (x86-64) / 09.05.2024

; http://janeway.exotica.org.uk/release.php?id=7426

; Note: kewl & fast c2d plasma (turn debugger off!), but...
; far,far...far away from the legendary N.O.M.A.D. original!

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musicformats #C2DF_(Format)

	#IsC2D_Music		=	#XMU_TPT ; Amiga Protracker x86-64 (TinyPT2)

	#IsC2D_Clear		=	0	; no need, cleared by fast BufferBackGrab()/BufferBackDraw()
	#IsC2D_Topaz		=	0	; own rawfont

	#IsC2D_Buffer		=	1
	#IsC2D_Copper		=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_FontColor	=	1	; need for font-copper

	#IsC2D_PageText	=	2	; 2 -> ControlCodes "{Mode,Param.f}"
	
	;#IsC2D_Help	=	1

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#HIDE_LR	=	40	*	#C2D_Z		; l&r hide pitchcrap

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	+	#HIDE_LR	; Width + hide l&r pitchcrap
#C2D_H	=	240	*	#C2D_Z	; Height of canvas

#C_H		=	#C2D_H	*	1.0	; height of copper (plasma)

#SIN_X	=	12	*	#C2D_Z		; Buffer horizontal sinuswidth
#SIN_Y	=	38	*	#C2D_Z		; Buffer vertical sinusheight

#WAIT_SWAP	=	4000	; Time between sideswap
#MAIN_PAGE	=	6		; Set trainer

#MAIN_YS	=	0.410	*	#C2D_H	; ON/OFF ystart
#MAIN_YE	=	0.578	*	#C2D_H	; ON/OFF yend

Global	Y_MK, IsCrack
Define	n, i, i_0, i_1, i_2

Procedure	Crystal_Init()

	Protected	i

	OpenWindow(0, 0, 0, #C2D_W - #HIDE_LR, #C2D_H, MA_C2DPB("Crystal - PP Hammer And His Pneumatic Weapon - 1991"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	; center oversized canvas-width to hide l&r pitchcrap
	CanvasGadget(#C2D_G, -#HIDE_LR * 0.5, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 13)
	C2D::Quality(1)

	; create fonts with copper
	For	i	=	0	To	7
		;If	i	<>	3	And	i	<>	7	; Font 3 & 7 not used in intro
			C2D::FontRawInit(i, ?f_raw, ?e_raw, 1, 1, #White, 14)
			C2D::FontScale(i, #C2D_Z)
			C2D::FontCopper(i, ?c_font + i * 4 * SizeOf(Long))
			C2D::FontGap(i, #C2D_Z, 4 * #C2D_Z)
		;EndIf
	Next

	i	=	C2D::FontH(0)	*	11	; Number of max. textlines / 11 per page

	; create pagetext in center of canvas
	C2D::PageTextWait(#WAIT_SWAP)
	C2D::PageTextInit(?t_text, #HIDE_LR * 0.5, (#C2D_H - i) * 0.5, #C2D_W - #HIDE_LR, i, C2D::#C2F_Center)
	C2D::PageTextEffect(1, C2D::#PFX_FadeStep, 255, 2400)

	; create blue copper for background plasma
	C2D::CopperInit(0, #C_H, ?c_blue)
	;C2D::CopperInit(0, 10*5, ?c_blue)	: C2D::CopperZoom(0, #C_H)

	; create backbuffer for fastest clear (4-7% less cpu)
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::CopperDraw(0, 0, 255, C2D::#C2F_CenterY)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()

	; no longer needed
	C2D::CopperFree(0)

	; play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	Crystal_Update()
	
	Protected	y

	; 1. clear canvasbuffer with copper (fast)
	C2D::BufferBackDraw()

	; 2. a bit of chaotic sin/cos for (bad clone of) plasma-fx
	C2D::BufferSinY(0,
	                40		*	#C2D_Z,
	                #C2D_W,
	                #C2D_H	-	80 * #C2D_Z,
	                0.800	*	#SIN_Y,
	                2.640	/	#C2D_Z,
	                3.525	*	#C2D_Z)

	C2D::BufferSinX(#SIN_X,
	                0,
	                #C2D_W	-	#SIN_X	*	2,
	                #C2D_H,
	                #SIN_X,
	                30.60	/	#C2D_Z,
	                8.450	/	#C2D_Z)

	; 3. more chaotic sin/cos for plasma-fx ;)
	C2D::BufferSinY(0,
	                15		*	#C2D_Z,
	                #C2D_W,
	                #C2D_H	-	30	*	#C2D_Z,
	                0.30	*	#SIN_Y,
	                3.80	/	#C2D_Z	+	MA_GSinI(C2D::C2D\Time>>3),
	                0.37	*	#C2D_Z)

	C2D::BufferSinX(#SIN_X,
	                0,
	                #C2D_W	-	#SIN_X	*	2,
	                #C2D_H,
	                #SIN_X,
	                24.48	/	#C2D_Z,
	                24.14	/	#C2D_Z)

	; 4. draw text in front of plasma
	C2D::PageTextDraw()
	
	; 5. if left MB was clicked, show trainer
	With	C2D::RS_Page
		If	IsCrack	And	\Status	; LMB & Sidestate is completed?
			y	=	WindowMouseY(0)
			If	y	>=	#MAIN_YS	And	y	<	#MAIN_YE
				y	=	(y	-	(\ClipY	+	\ChrH	*	4))	/	\ChrH
				If	y	>=	0	And	y	<=	2
					Y_MK	=	y
					C2D::FontSelect(4 + Y_MK)	; copperfont
					DrawAlphaImage(ImageID(C2D::FontImage(32)), \ClipX	+	\ChrW *	16, \ClipY	+	\ChrH	*	4	+	Y_MK	*	\ChrH, 255)
				EndIf
			EndIf
		EndIf
	EndWith

EndProcedure

Crystal_Init()

Repeat
	Select	WindowEvent()
		Case	#WM_LBUTTONUP
			
			If	IsCrack	=	#Null	And	C2D::PageTextID()	<>	#MAIN_PAGE
				
				IsCrack	=	#True

				C2D::RS_Page\Status	=	#True
				C2D::RS_Page\Time		=	0
				C2D::PageTextID(#MAIN_PAGE)
				C2D::PageTextWait(-1)
				C2D::PageTextWait(500000, #MAIN_PAGE)
				
			ElseIf	IsCrack	And	Y_MK	>=	0	And	Y_MK	<=	2	And	C2D::RS_Page\Status
				
				i	=	WindowMouseY(0)
				
				If	i	>=	#MAIN_YS	And	i	<	#MAIN_YE
					
					Select	Y_MK
						Case	0	:	i_0	!	1	:	n	=	i_0
						Case	1	:	i_1	!	1	:	n	=	i_1
						Case	2	:	i_2	!	1	:	n	=	i_2
					EndSelect
					
					i	=	42	+	Y_MK	*	15
					
					With	C2D::RS_PageText()
						
						;PushListPosition(\Char())
						
						If	n	; OFF
							SelectElement(\Char(), i + 0)	:	\Char()\i	=	ImageID(C2D::FontImage(47))	; O
							SelectElement(\Char(), i + 1)	:	\Char()\i	=	ImageID(C2D::FontImage(38))	; F
							SelectElement(\Char(), i + 2)	:	\Char()\i	=	ImageID(C2D::FontImage(38))	; F
						Else																										; _ON
							SelectElement(\Char(), i + 0)	:	\Char()\i	=	ImageID(C2D::FontImage(63))	; _
							SelectElement(\Char(), i + 1)	:	\Char()\i	=	ImageID(C2D::FontImage(47))	; O
							SelectElement(\Char(), i + 2)	:	\Char()\i	=	ImageID(C2D::FontImage(46))	; N
						EndIf
						
						;PopListPosition(\Char())
						
					EndWith
					
				EndIf

			EndIf

		Case	#PB_Event_CloseWindow
			Break
			
		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE,
				    	#VK_SPACE
					Break
			EndSelect
			
		Default	; the intro!
			
			If	C2D::Start()
				Crystal_Update()
				C2D::Stop()
			EndIf
			
	EndSelect
	
ForEver

C2D::Free()

DataSection

	c_blue:	; Blue copper for plasma
	Data.l	10, 0, 0, $7F500000, $A0FF0000, $FFFF0000, $FFFF0000, $A0FF0000, $7F500000, 0, 0

	c_font:	; Copper-Colors for font
	Data.l	3,	$FF554422, $FFDDCC66, $FF554422,
	      	3, $FF553388, $FFCCAAFF, $FF553388,
	      	3, $FF224422, $FF66DD66, $FF224422,
	      	3, $FF335588, $FFAACCFF, $FF335588,
	      	3, $FF888888, $FFFFFFFF, $FF888888,
	      	3, $FF888800, $FFFFFF00, $FF888800,
	      	3, $FF883333, $FFFFAAAA, $FF883333,
	      	3, $FF003388, $FF00AAFF, $FF003388

	f_raw:	; Amiga Raw-Font 14 bit width
	IncludeBinary	"gfx\Crystal_Font_14.rw"
	e_raw:

	CompilerIf	IsC2D::#IsC2D_Music
		m_music:
		IncludeBinary	"mus\introfronty_fixed.mod"
		e_music:
	CompilerEndIf

	t_text:	; Change font {1,#FontID}
	Data.s	"{2,2500}"	+
	      	"~"			+
	      	"{1,4}CRYSTAL|"			+
	      	"{1,5}PRESENT|"			+
	      	"{1,6}PP HAMMER TRAINER"+
	      	"~"	+
	      	"{1,4}CRACKED AND TRAINED|"+
	      	"{1,5}BY|"						+
	      	"{1,6}NOMAD"					+
	      	"~"	+
	      	"{1,4}ORIGINAL|"		+
	      	"{1,5}SUPPLIED BY|"	+
	      	"{1,6}GIZAM"			+
	      	"~"	+
	      	"{1,4}INTRO|"		+
	      	"{1,5}CODED BY|"	+
	      	"{1,6}NOMAD"		+
	      	"~"	+
	      	"{1,4}ACCEPT NO IMITATIONS|"	+
	      	"{1,5}WE ARE THE|"				+
	      	"{1,6}WORLD NUMBER ONE"			+
	      	"~{2,-1}"	+
	      	"{1}C R Y S T A L|"			+
	      	"{1,1}PRESENT|"				+
	      	"{1,2}PP HAMMER TRAINER|"	+
	      	"|"	+
	      	"{1,4}INFINITE LIVES  _ON|"+
	      	"{1,5}INFINITE TIME   _ON|"+
	      	"{1,6}ONLY ONE JEWEL  _ON|"+
	      	"|"	+
	      	"{1}CRACKED AND TRAINED|"	+
	      	"{1,1}BY NOMAD|"				+
	      	"{1,2}PRESS SPACE TO EXIT"	+
	      	"~"	+
	      	"{1,3}RETRO|"		+
	      	"{1,4}CODED BY|"	+
	      	"{1,5}PEACE|"		+
	      	"|"	+
	      	"{1,7}PRESS THE LEFT ONE"

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A-
; Executable = C2D_Crystal_x86.exe
; DisableDebugger
; CompileSourceDirectory