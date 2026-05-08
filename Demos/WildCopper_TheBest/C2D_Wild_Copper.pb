; C2D::Wild Copper / The Best - 1988
; Purebasic v6.30 - (x86-64) / 17.04.2026
; Purebasic v5.70 - (x86-64) / 05.04.2018

; http://janeway.exotica.org.uk/release.php?id=21430

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor (try 1, 2 or 3)
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_TPT

	#IsC2D_Clear		=	0	; no clear -> using BufferBackDraw()
	#IsC2D_Time			=	0	; 0 -> use ElapsedMilliseconds()

	#IsC2D_Buffer		=	1
	#IsC2D_Copper		=	1
	#IsC2D_Stars3D		=	1

	#IsC2D_Line3D		=	2	; use build & fade
	#IsC2D_ScrollText	=	2	; use {code,param}

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width (zoomed)
#C2D_H	=	240	*	#C2D_Z	; Height (zoomed)

#RX	=	 0.493	*	1.60
#RY	=	-0.867	*	1.60
#RZ	=	-0.299	*	1.60

Enumeration		; Line3D-Objects
	#ID_QUESTION	; "?" always first!	
	#ID_WILDCOPPER
	#ID_SEB
	#ID_DISK
	#ID_RV
	#ID_KIKO
	#ID_PAT
	#ID_FIST
	#ID_CLOCK
	#ID_DORF
	#ID_ROCKET
 	#ID_SATELITE
	#ID_DIAMOND
EndEnumeration

#L3D_MAX	=	#PB_Compiler_EnumerationValue	-	1
#L3D_MIN	=	#ID_QUESTION
#L3D_TIME=	14000	; swap object in ms 

Procedure	WildCopper_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Wild Copper - The Best - 1988"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 7)

	; Starfield
	C2D::Stars3DInit(64 * #C2D_Z, #C2D_Z, 0, 0, #C2D_W, #C2D_H * 0.4, 1.6 + #C2D_Z)

	; Real Bitmap (no IsC2D_Bitmap needed) font/items
	CatchImage(0, ?i_font)	:	C2D::FontInit(0, 0)	:	C2D::FontScale(0, #C2D_Z)
	CatchImage(0, ?i_item)	:	C2D::FontInit(1, 0)	:	C2D::FontScale(1, #C2D_Z)
	FreeImage(0)

	; Scroller
	C2D::FontSelect(0)
	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, 1.0 * #C2D_Z)

	; Line3d objects
	C2D::Line3DInit(#ID_QUESTION,		?l_0,	8.9 * #C2D_Z)
	C2D::Line3DInit(#ID_WILDCOPPER,	?l_1,	4.1 * #C2D_Z)
	C2D::Line3DInit(#ID_SEB,			?l_2,	5.5 * #C2D_Z)
	C2D::Line3DInit(#ID_DISK,			?l_3,	8.2 * #C2D_Z, 0.75)
	C2D::Line3DInit(#ID_RV,				?l_4,	7.7 * #C2D_Z)
	C2D::Line3DInit(#ID_KIKO,			?l_5,	2.2 * #C2D_Z, 1.2)
	C2D::Line3DInit(#ID_PAT,			?l_6,	5.8 * #C2D_Z)
	C2D::Line3DInit(#ID_FIST,			?l_7,	5.2 * #C2D_Z)
	C2D::Line3DInit(#ID_CLOCK,			?l_8,	8.3 * #C2D_Z)
	C2D::Line3DInit(#ID_DORF,			?l_9,	8.8 * #C2D_Z)
	C2D::Line3DInit(#ID_ROCKET,		?l_A,	2.6 * #C2D_Z, 1.4)
	C2D::Line3DInit(#ID_SATELITE,		?l_B,	6.6 * #C2D_Z)
	C2D::Line3DInit(#ID_DIAMOND,		?l_C,16.2 * #C2D_Z)

	; add fogging on line3d objects
	C2D::Line3DFog(#PB_All, 4.8 / #C2D_Z)

	; Blue ground-copper
	C2D::CopperInit(0, #C2D_H * 0.44, ?c_copper)

	; Fast update with static backbuffer
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::CopperDraw(0, #C2D_H * 0.4)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()

	; Free unused stuff
	C2D::CopperFree(0)

	; Play the music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

 	;C2D::ScrollTextPos(0, 1550)

EndProcedure
Procedure	WildCopper_Update()
	
	Static	ID = #L3D_MIN	; start with first object
	Static	Time = #L3D_TIME - 6400, IsNext
	
	; clear & draw static buffer (blue-copper)
	C2D::BufferBackDraw()
	
	C2D::Stars3DDraw(0, -24 * #C2D_Z)
	
	If	ElapsedMilliseconds()	>	Time
		C2D::Line3DFade(ID, -2)
		IsNext	=	#True
		Time		=	ElapsedMilliseconds()	+	#L3D_TIME
	EndIf
	
	If	IsNext	And	C2D::Line3DIsFade(ID)	=	#False
		IsNext	=	#False
		ID	+	1
		If	ID	>	#L3D_MAX
			ID	=	#L3D_MIN
		EndIf
		C2D::Line3DFade(ID, 1)
		If	ID	<>	#ID_QUESTION	And	ID	<>	#ID_FIST	; rotate all-axis?
			C2D::Line3DAngle(ID, C2D::MA_RMP(798),C2D::MA_RMP(798),C2D::MA_RMP(798))
		EndIf
	EndIf
	
	; rotate "?" & fist about y-axis only?
	Select	ID
		Case	#ID_QUESTION, #ID_FIST
			C2D::Line3DRotate(ID, 0, #RY, 0)
		Default
			C2D::Line3DRotate(ID, #RX, #RY, #RZ)
	EndSelect

	; first draw object-shadow, rotate will set element,
	; so we can change the color direct & fast!
	C2D::RS_Line3DObject()\Color	=	$FF780000
	C2D::Line3DDraw(ID, 0, 48 * #C2D_Z, 1.2, 0.16)
	
	; second draw red object in front of shadow
	C2D::RS_Line3DObject()\Color	=	$FF0000FF
	C2D::Line3DDraw(ID, 0, -25 * #C2D_Z)
	
	C2D::ScrollTextDraw(0, 205 * #C2D_Z)
	
EndProcedure

WildCopper_Init()

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
				WildCopper_Update()
				C2D::Stop()
			EndIf

	EndSelect
	
ForEver

C2D::Free()

DataSection
	
	CompilerIf	IsC2D::#IsC2D_Music
		m_music:	:	IncludeBinary	"mus\Pat - Starscroll.mod"	:	e_music:
	CompilerEndIf

	i_font:	:	IncludeBinary	"gfx\WC_Font16.bmp"	:	e_font:
	i_item:	:	IncludeBinary	"gfx\WC_Item32.bmp"	:	e_item:
	
	IncludePath	"obj\"
	l_0:	:	IncludeBinary	"WC_Question.l3d"
	l_1:	:	IncludeBinary	"WC_WildCopper.l3d"
	l_2:	:	IncludeBinary	"WC_Seb.l3d"
	l_3:	:	IncludeBinary	"WC_Disk.l3d"
	l_4:	:	IncludeBinary	"WC_RV.l3d"
	l_5:	:	IncludeBinary	"WC_Kiko.l3d"
	l_6:	:	IncludeBinary	"WC_PAT.l3d"
	l_7:	:	IncludeBinary	"WC_Fist.l3d"
	l_8:	:	IncludeBinary	"WC_Clock.l3d"
	l_9:	:	IncludeBinary	"WC_Dorf.l3d"
	l_A:	:	IncludeBinary	"WC_Rocket.l3d"
	l_B:	:	IncludeBinary	"WC_Satelite.l3d"
	l_C:	:	IncludeBinary	"WC_Diamond.l3d"

	c_copper:	:	Data.l	2, $FF050000, $FFF20800

	; 	#FC_Bitmap	; 0 -> BitmapImage	{0,#ID}
	; 	#FC_Font		; 1 -> Change font	{1,#ID}
	; 	#FC_Pause	; 2 -> Pause text		{2,ms}
	; 	#FC_Space	; 3 -> 100%=C2D_W		{3,%percent.f}
	; 	#FC_Speed	; 4 -> Scrollspeed	{4,speed.f}
	; 	#FC_Center	; 5 -> {5}Center{5}	{5,%offset.f}
	
	t_text:	; scroller not like the original -> changed & cutted!
	Data.s	"LADIES And GENTLEMEN LET ME PRESENT.{3}POSSIBLY THE MOST IMPORTANT THING   THIS SIDE OF THE WORLD.{3}"	+
	      	"THIS IS.{3}THIS IS.{3}THE WILD COPPER TEAM AND HIS NEW DEMO{3}{4,3}{5}REMEMBER.{5}{2,5000}{3}"	+
	      	"{5}THE BEST ARE {1,1}${1}{5}{2,4000}{3}SO WELCOME TO OUR UNIVERSE !{3}FIRST :{3}THE TEAM :{3}"	+
	      	"{4}{1,1}%{1} {1,1}/{1} SCULPT-3D CREATOR, PROGRAMMER, CODER AND MOTORCYCLE BOY, AUTHOR OF THE SOURCE CODE OF THIS WONDERFUL DEMO{3}"	+
	      	"{1,1}&{1} {1,1}/{1} ALIAS THE {1,1}${1} {1,1}/{1} FOUNDER OF THE TEAM TO WHICH HE GAVE HIS NAME, PROGRAMMER, CODER AND GENIOUS{3}"	+
	      	"{1,1}9{1} {1,1}/{1} GRAPHIST DESIGNER OF THE TEAM{3}( AND SCROLL-TEXT REDACTOR ){3}{1,1}'{1} THE DISKBUSTER {1,1}/{1} CODER, "	+
	      	"PROGRAMMER AND MUSICIAN{3}( GREAT MUSICIAN ){3}{1,1}({1} {1,1}/{1} MUSIC AND NOISE MAKER WHO PREVENT US FROM "	+
	      	"SLEEPING AFTER LONG NIGHTS OF PROGRAMMATION.{3}OF COURSE WE ARE ALWAYS IN THE BEST COMPUTER SHOP IN {1,1}2{1} :{3,40}"	+
	      	"{1,1}5{1}	TECSOFT		18 RUE DU PONT DES MORTS	57 000 METZ		FRANCE		{1,1}4{1} 87 32 16 43		AND	55 RUE DES QUATRE EGLISES	54 000 NANCY	FRANCE "	+
	      	"TOO		{1,1}4{1} 83 37 06 47{3}INDEED WE HAVE ALWAYS  ( AND SALE )  THE FATEST AMIGA IN FRANCE WITH A 68030, A 68882 AND 2 MEGA OF FAST "	+
	      	"ACCESS STATIC RAM{3}{4,3}BIP BIP{3}{4}BUT WARNING :{3}{4,0.4}CODING BUT NO SWAPPING !{3}"	+
	      	"{4}NOW, WE WANT TO TELL YOU A LITTLE STORY.{3}{5}HUM{5}{2,3000}{3}"	+
	      	"YEP HERE WE STOPP THE {1,1}${1} COZ THE {1,1}1{1} WOULD TELL TOO MUCH {1,1}#{1} TO FINISH THE SCROLLER OF.{3}{5}{1,1}${1} THE BEST {1,1}${1}{5}{2,15000}"	+
	      	"{3}C2D {1,1}!{1} RETRO BY {1,1}/{1} PEACE OF TESTAWARE{3}"	+
	      	"{4,5}9{3,48}{2}8{3,48}{2}7{3,48}{2}6{3,48}{2}5{3,48}{2}4{3,48}{2}3{3,48}{2}2{3,48}{2}1{3,48}{2}0{3,48}{2}{3,75}{4}"	+
	      	"{1,1}<=>{1} HAPPY NEW CONTINUE!"

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A+
; Executable = C2D_Wild_Copper_x86.exe
; DisableDebugger
; CompileSourceDirectory