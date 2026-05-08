; ***********************************************************************
; C2D::Tristar & DCS / Rock Star Ate My Hamster - 1990
; http://janeway.exotica.org.uk/release.php?id=15361
; Purebasic v5.72 (x86-64) / 07.06.2018
; ***********************************************************************
; if AV false-positive, turn debugger off or change #IsC2D_Music
; ***********************************************************************

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	
	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_TFC	;FC4	; x86-64

	#IsC2D_Mode			=	0
	#IsC2D_Clear		=	0
	#IsC2D_Help			=	0

	#IsC2D_Bitmap		=	1
	#IsC2D_Buffer		=	1
	#IsC2D_FontColor	=	1
	#IsC2D_Copper		=	1
	#IsC2D_PageText	=	1
	#IsC2D_Text			=	1
	
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width
#C2D_H	=	240	*	#C2D_Z	; Height

#ID_TRI	=	0	; Tristar-Logo
#ID_DCS	=	1	; DCS-Logo

#LOGO_Y	=	18		*	#C2D_Z	; Logo-Ypos
#COP_Y	=	126	*	#C2D_Z	; Copper-Ypos

#TXT_Y	=	128	*	#C2D_Z

#TIME_LOGO	=	5000	; Time to swap logos
#TIME_PAGE	=	8000	; Time to swap pages

Procedure	Blt_Copper(x, y, PenColor, PaperColor)	; text copper
	
	;ProcedureReturn	PenColor

	If	PaperColor&$00FFFFFF
		
		a.f	=	Red(PaperColor)	*	0.0058	; 1.0 / $AA
		
		If	a	>=	0.835
			ProcedureReturn	PenColor
		EndIf
		
		ProcedureReturn	RGBA(Red(PenColor) * a, Green(PenColor) * a, Blue(PenColor) * a, 255)
		
	EndIf
	
EndProcedure

Procedure	TRI_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Tristar & DCS / Rock Star Ate My Hamster - 1990"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)
	
	; bitmap for fonts
	C2D::BitmapInit(0, ?i_fnt, ?e_fnt)

	; font for swapping pages
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontZoom(0, 4 * #C2D_Z, 8 * #C2D_Z)

	; create swapping text pages
	C2D::PageTextInit(?t_text, 0, #TXT_Y, #C2D_W, 11 * C2D::FontH(0), C2D::#C2F_Center)
	C2D::PageTextWait(#TIME_PAGE)
	C2D::PageTextEffect(1, C2D::#PFX_Random, 9, 18)	; show
	C2D::PageTextEffect(0, C2D::#PFX_Random, 9, 18)	; hide

	; font for title
	C2D::FontInit(1, C2D::BitmapImage(0))
	C2D::FontZoom(1, 8 * #C2D_Z, 9 * #C2D_Z)	; bold for title
	C2D::FontShadow(1, #C2D_Z, #C2D_Z)

	; create title of cracked game
	C2D::TextInit(0, @"Rock Star Ate My Hamster")

	; create swapping logos
	C2D::BitmapInit(#ID_TRI, ?i_tri, ?e_tri)	:	C2D::BitmapScale(#ID_TRI, #C2D_Z)
	C2D::BitmapInit(#ID_DCS, ?i_dcs, ?e_dcs)	:	C2D::BitmapScale(#ID_DCS, #C2D_Z)

	; create copper for bottom line
	C2D::CopperInit(0, #C2D_Z, ?c_l, C2D::#C2F_Horizontal)

	;********************************
	;*** Create static backbuffer ***
	StartDrawing(CanvasOutput(#C2D_G))
	;
	; cracked game title here
	Box(0, #C2D_H * 0.458, #C2D_W, 16 * #C2D_Z, $FF0000FF)
	Box(0, #C2D_H * 0.458 + #C2D_Z, #C2D_W, 16 * #C2D_Z - #C2D_Z * 2, $FF660000)
	;
	;C2D::FontSelect(1)	; must set for text only
	C2D::TextDraw(0, 0, #C2D_H * 0.475, 255, C2D::#C2F_CenterX)
	;
	; bottom-line
	C2D::CopperDraw(0, 0.9 * #C2D_H)
	;
	; grab the buffer to clear & update
	C2D::BufferBackGrab()
	;
	; draw logo for smooth start
	C2D::BitmapDraw(#ID_DCS, 0, #LOGO_Y, 255, C2D::#C2F_CenterX)
	;
	StopDrawing()
	;********************************

	; create moving text-copper
	C2D::CopperInit(0, 11 * C2D::FontH(0), ?c_t, C2D::#C2F_Horizontal)
	C2D::CopperBlitProc(@Blt_Copper())	; CopperBlit by custom proc

	; free unused stuff
	C2D::TextFree(0)
	C2D::FontFree(1)

	; play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_fc4, ?e_fc4)
	CompilerEndIf

EndProcedure
Procedure	TRI_Update()

	Static	Alpha, Time, IsFade
	Static	Logo_0=#ID_DCS, Logo_1=#ID_TRI

	; draw static background
	C2D::BufferBackDraw()

	; check blend-time for logos
	If	C2D::C2D\Time	>=	Time
		Swap	Logo_0, Logo_1	; <- swap logos
		IsFade=	#True
		Alpha	=	0
		Time	=	C2D::C2D\Time	+	#TIME_LOGO
	EndIf

	; add alpha if fade is on
	If	IsFade
		Alpha	+	2	:	If	Alpha	>=	255	:	IsFade	=	#False	:	Alpha	=	255	:	EndIf
	EndIf

	; blend logo(s) in/out
	C2D::BitmapDraw(Logo_0, 0, #LOGO_Y, 255, C2D::#C2F_CenterX)
	If	IsFade
		C2D::BitmapDraw(Logo_1, 0, #LOGO_Y, 255 - Alpha, C2D::#C2F_CenterX)
	EndIf

	; text + fading textcopper!
	C2D::PageTextDraw()
	C2D::CopperBlit(0, #COP_Y, 0.88 * #C2D_Z)

EndProcedure

TRI_Init()

Repeat
	Select	WindowEvent()

		Case	#Null

			If	C2D::Start()
				TRI_Update()
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
		m_fc4:	:	IncludeBinary	"mus\Tristar.smod"	:	e_fc4:
	CompilerEndIf

	c_t:		:	Data.l	5,	$FFFFEE11, $FFFF00FF, $FF0066FF, $FF11FF44, $FFFFEE11	; text-copper
	c_l:		:	Data.l	3, $2F0000FF, $FF0000FF, $2F0000FF	; bottom copper-line
	
	i_dcs:	:	IncludeBinary	"gfx\DCS_Logo.png"		:	e_dcs:
	i_tri:	:	IncludeBinary	"gfx\Tristar_Logo.png"	:	e_tri:
	i_fnt:	:	IncludeBinary	"gfx\Tristar_Font.png"	:	e_fnt:

	t_text:
	Data.s	">> RELEASED BY THE COOPERATION TRISTAR & D.C.S ! <<|"	+
				"-------------------------------------------------------|"	+
				"100% ENGLISH VERSION AND OF COURSE ONE PARTED|"	+
				"BY LIMOMACHT (OR WAS IT BEER?) OF TRISTAR|"	+
				"|"	+
				"CALL THE TRILOGY SECTOR 96 BBS (USA):|"	+
				">> 714 @ 897 @ 7562 <<|"	+
				"|"	+
				"OR CALL OUR FAVOURITE BOARD, EAGLE-SOFT (USA):|"	+
				">> 213 @ 836 @ 1346 <<"	+
				"~"	+
				">>> SPECIAL MESSAGE TO ZIKE/FAIRLIGHT: <<<|"	+
				"OUR T-SHIRTS ARE COMING VERY SOON, LOOK OUT !! DIEBELS RULES !!|"	+
				"SIGNED BEERMACHT !!|"	+
				"|"	+
				">>> SPECIAL MESSAGE TO VISION-FACTORY: <<<|"	+
				"MAY THE FORCE BE WITH YOU, WE HOPE THAT YOU WILL NOT SURRENDER !!"	+
				"~"	+
				">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<|"	+
				">>																									 <<|"	+
				">>				CONTACT US IF YOU DARE AND WRITE TO OUR HEADQUARTERS:			  <<|"	+
				">>																									 <<|"	+
				">>					PLK 034695 B @ 5600 WUPPERTAL 2  @ WEST GERMANY				  <<|"	+
				">>					PLK 124889 C @ 4300 ESSEN 1		@ WEST GERMANY				  <<|"	+
				">>					PLK 145579 E @ 4200 OBERHAUSEN 1 @ WEST GERMANY				  <<|"	+
				">>					PLK 023390 B @ 4100 DUISBURG 11  @ WEST GERMANY				  <<|"	+
				">>																									 <<|"	+
				">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"	+
				"~"	+
				"WE WELCOME OUR NEW MEMBERS LEFFTY & TIM TO OUR GROUP !!|"	+
				"WE HOPE IT WILL BE A SUCCESSFULL RELATIONSHIP !!|"	+
				"|"	+
				">>> SPECIAL MESSAGE TO MIKE/SUBWAY: <<<|"	+
				"HOPE TO MEET YOU ON C-BIT TO CONTINUE OUR NICE CHAT !!|"	+
				"SIGNED RICK !!"	+
				"~"	+
				"LIGHTSHININGS (Z-A ORDER) ARE GOING TO FOLLOWING GROUPS:|"	+
				"--------------------------------------------------------------------------------|"	+
				"|"	+
				"|"	+
				"VISION @ VENOM @ TWILIGHT @ TRILOGY @ TOP SWAP @ TITANICS @ THRILL|"	+
				"THE SUPPLY TEAM @ THE SILENTS @ THE MAGIC ARTS @ THE LUNACY @ TEAM-X @ SWITCH|"	+
				"SUPREME @ SUBWAY @ SOFTWARE OF SWEDEN @ SKYLINE @ SETROX|"	+
				"SCOUTS @ SCOOPEX @ RED SECTOR @ REBELS @ RAZOR 1911|"	+
				"QUARTEX @ PRISM @ PRIME EVIL @ POWERSLAVES @ PARANOIMIA @ ORACLE"	+
				"~"	+
				"LIGHTSHININGS (Z-A ORDER) ARE GOING TO FOLLOWING GROUPS:|"	+
				"--------------------------------------------------------------------------------|"	+
				"|"	+
				"|"	+
				"NUKEBUSTERS @ MERCENARY @ M.A.D @ LASER @ KEFRENS @ IT @ FLASH PRODUCTIONS|"	+
				"FLASH CRACKING GROUP @ FRAXION @ FAIRLIGHT @ EXCEL U@K @ EXTERMINATORS|"	+
				"ESCAPE @ EMPIRE @ ECLIPSE @ E & L @ DYNASTY @ DUAL CREW|"	+
				"DREAM VISION @ DRAGONS @ DOMINATORS @ DEFJAM @ D-TECT @ D-MOB|"	+
				"DIGITECH @ CRYPTOBURNERS @ CRUSADERS @ COSA NOSTRA @ COMPLEX @ CLASSIC"	+
				"~"	+
				"LIGHTSHININGS (Z-A ORDER) ARE GOING TO FOLLOWING GROUPS:|"	+
				"--------------------------------------------------------------------------------|"	+
				"|"	+
				"|"	+
				"BYTERAPERS @ BRENT @ BRAINSTORM @ BLACK MONKS @ BLACK MAIL @ BEYOND FORCE|"	+
				"BAMIGA SECTOR ONE @ AUSTRALIAN CRACKERS UNITED @ ARMADA @ ARCANE @ APEX|"	+
				"ANIMATE @ ALPHA FLIGHT @ ACES @ ACCUMULATORS @ ACCESSION|"	+
				"ABAKUS @ A.A.C ...|"	+
				"|"	+
				"AND TO ALL OUR CONTACTS AND FRIENDS 'ROUND THE GLOBE WE HAVE FORGOTTEN !!"	+
				"~"	+
				"! !	 A  T  T  E  N  T  I  O  N	 ! !|"	+
				"|"	+
				"--------------------------------------------------------------------------------|"	+
				"LOOK OUT FOR OUR COOPERATION-PAPER-MAG NAMED  >> STOLEN DATA <<|"	+
				"MORE AND MORE STUNNING ARTICLES ARE ARRIVING OUR MAG-HEADQUARTER IN ENGLAND !!|"	+
				"OUR THIRD ISSUE IS SOON COMING TO AN AMIGA NEAR YOU !!|"	+
				"--------------------------------------------------------------------------------"	+
				"~"	+
				"IF YOU WANT TO GET THE NEWEST ISSUE OR WANT TO READ YOUR ARTICLES IN THIS|"	+
				"FAB MAGAZINE OR JUST WANT TO INFORM US ABOUT THE LATEST NEWS,|"	+
				"|"	+
				"CONTACT NOSAH (D.C.S)|"	+
				"|"	+
				">> 99 ST LUCIA PARK, <<|"	+
				">>	 BORDON,		  <<|"	+
				">>	 HANTS,			<<|"	+
				">>	 GU35 OLD		 <<|"	+
				">>	 ENGLAND.		 <<"	+
				"~"	+
				"THEY WHO REFUSE TO TAKE PART IN MODERN MEDIOCRITY|"	+
				"WILL FOREVER STAND ALONE, AN OUTCAST.|"	+
				"THEY ARE THE BRINGERS OF CHANGE, CHANGES THAT INSTILL|"	+
				"FEAR IN ALL WHO GO WITH FASHION'S FLOW.|"	+
				"THEIR POWER COMES FROM OTHERS, NOT FROM WITHIN.|"	+
				"THEY ARE FALSE!"	+
				"~"	+
				"WOE UNTO THEM FOR THE BRINGERS OF CHANGE HAVE BANDED TOGETHER.|"	+
				"THE TIME IS NOW! WE CANNOT BE STOPPED!|"	+
				"WE ARE RIDING UP, RIDING HARD ON THE WILL OF THE PEOPLE.|"	+
				"THE BATTLE RAGES - CHOOSE YOUR SIDE.|"	+
				"DEATH TO FALSE LAMERS|"	+
				"FOREVER|"	+
				"FIGHTING THE WORLD ..."	+
				"~"	+
				">>>>>>>>>>>>> T R I S T A R <<<<<<<<<<<<<|"	+
				">>												 <<|"	+
				">>	 CODING ... : TRANSFORMER			<<|"	+
				">>	 GRAFIX ... : TERMINATOR			 <<|"	+
				">>	 DESIGN ... : FLYNN/TERMINATOR	 <<|"	+
				">>	 MUSIC .... : LEFFTY				  <<|"	+
				">>												 <<|"	+
				">>>>>>>>>>>>> T R I S T A R <<<<<<<<<<<<<"	+
				"~"	+
				"THIS LITTLE CRACK-INTRO IS ONLY A PRE-RELEASE (SORRY!)|"	+
				">> WE ARE THE ONE ... TRISTAR & D.C.S IN 1990 <<"	+
				"~"	+
				"PLK 017911 D 6086 RIEDSTADT"	+
				"~"	+
				"C2D RETRO BY PEACE/TST"

EndDataSection
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 245
; FirstLine = 85
; Folding = A+
; Executable = C2D_Tristar_x86.exe
; CompileSourceDirectory
; Compiler = PureBasic 6.02 LTS - C Backend (Windows - x64)