; C2D::FontRaw / Amiga - Purebasic v6.04 (x86-64)
; Turn Debugger OFF!

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\Include\C2D_Types.pbi"	; include musicformats #C2F_(Format)
	
	#IsC2D_Music		=	#XMU_SCA	;AHX

	#IsC2D_Topaz		=	0

	#IsC2D_FontRaw		=	1
	#IsC2D_Stars3D		=	2	; Fast 1px stars
	#IsC2D_Text			=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Bounce		=	1

	#IsC2D_Clear		=	2	; Fastclear (Black)
	#IsC2D_ScrollText	=	2	; {code, param.f}
	#IsC2D_File			=	1	; Read/Parent

	XIncludeFile	"..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#FNT_S	=	6	*	#C2D_Z	; Sinusfont size

Procedure	C2D_Init()
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Text / FontRaw + SCAL"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	; Init at first!
	C2D::Init(#C2D_G, 10)
	
	; Create static background
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, 48 * #C2D_Z, #C2D_W, #C2D_H - 96 * #C2D_Z, $3F1000)
	C2D::BufferBackGrab()
	C2D::BufferClear()	; start with black screen
	StopDrawing()

	; Create starfield
	C2D::Stars3DInit(260 * #C2D_Z, #C2D_Z, 0, 48 * #C2D_Z, #C2D_W, #C2D_H - 96 * #C2D_Z, 4.5)
	
	; Create fonts for top/sinus/bottom-text
	C2D::FontRawInit(0, ?f_font)	; Standard Spherix.font/8

	C2D::FontRawInit(1, ?f_font, 0,	#FNT_S, #FNT_S, #Red)	:	C2D::FontGap(1, -2 * #C2D_Z, 0); Sinus
	
	C2D::FontRawInit(2, ?f_font, 0,	4 * #C2D_Z, 4 * #C2D_Z, #Blue)	; Scroller
	C2D::FontRawInit(3, ?f_font, 0,	5 * #C2D_Z, 5 * #C2D_Z,	#Yellow)	; Tools
	
	C2D::FontRawInit(4, ?f_font, 0,	6 * #C2D_Z, 5 * #C2D_Z, #Magenta)	:	C2D::FontGap(4, -3 * #C2D_Z)	; Fox

	C2D::FontRawInit(5, ?f_font, 0,	2 * #C2D_Z, 1 * #C2D_Z, #Green)	; Top
	C2D::FontRawInit(6, ?f_font, 0,	1 * #C2D_Z, 1 * #C2D_Z, #Cyan)	; Sub
	
	; Create top/sinus/scroller-text using selected font as default
	C2D::FontSelect(1)	:	C2D::ScrollTextInit(1, ?t_Sinus)		:	C2D::ScrollTextSpeed(1, 1.5 * #C2D_Z)	; Default Speed Sinus
	C2D::FontSelect(2)	:	C2D::ScrollTextInit(2, ?t_Scroll)	:	C2D::ScrollTextSpeed(2, 2.0 * #C2D_Z)	; Default Speed Scroller
	
	C2D::FontSelect(5)	:	C2D::TextInit(3, @"CANVAS 2D")						; Top
	C2D::FontSelect(6)	:	C2D::TextInit(4, @"SUPPORTS AMIGA RAW FONTS")	; Subtext
	
	C2D::BounceInit(0, 2, 38, 79)
	C2D::BounceInit(1, 2, 38, 83)
	
	; Play music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicInit(#SCAL_PATH$)	; set default-path to SCAL_(x86-64).dll
		C2D::MusicPlay(@"..\Data\Music\AHX\Linde - 601.ahx")
	CompilerEndIf

	;C2D::ScrollTextPos(2,460)

EndProcedure
Procedure	C2D_Update()
	
	Protected	sin_y	=	(#C2D_H - #FNT_S * 8) * 0.51
	
	; 1. Scrolltext for Sinustext
	C2D::ScrollTextDraw(1, sin_y)
	
	; 2. Sinus Canvasbuffer with scrolltext only (Flags = 0 draw at 7.)
	C2D::BufferSinY(0,
	                sin_y,
	                #C2D_W - 1,
	                #FNT_S * 8,
	                100 * #C2D_Z,
	                1.3 * MA_GCosI(C2D::C2D\Count) / #C2D_Z,
	                16,
	                0)
	
	; 3. Fastclear canvas with static & buffered background (remark why)
	C2D::BufferBackDraw()
	
	; 4. Stars
	C2D::Stars3DDraw()
	
	; 5. Bouncing text on top (notice Flag = #C2F_CenterX)
	C2D::TextDraw(3, MA_GSinI(C2D::C2D\Count * 6) * 80 * #C2D_Z, C2D::Bounce(0) * #C2D_Z, 255, C2D::#C2F_CenterX)
	C2D::TextDraw(4, MA_GSinI(C2D::C2D\Count * 7) * 80 * #C2D_Z, C2D::Bounce(1) * #C2D_Z, 255, C2D::#C2F_CenterX)
	
	; 6. Scrolling text on bottom
	C2D::ScrollTextDraw(2, #C2D_H - 1.16 * 4 * 8 * #C2D_Z)
	
	; 7. Draw buffered SinusText (switch debugger off)
	C2D::BufferSinDraw()
	
EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf
		Default
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection
	
	f_font:
	Data.s	"..\Data\Font\RAW\Amiga_Spherix_8U.rw"

	t_Sinus:
	Data.s	"EXAMPLE USING THE TINY C2D MODULE V" + MA_XC2D() + " CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + ") ... VISIT US AT ... TESTAWARE.WORDPRESS.COM"

	; 	#FC_Bitmap	; 0 -> BitmapImage	{0,#ID}
	; 	#FC_Font		; 1 -> Change font	{1,#ID}
	; 	#FC_Pause	; 2 -> Pause text		{2,ms}
	; 	#FC_Space	; 3 -> 100%=C2D_W		{3,%percent.f}
	; 	#FC_Speed	; 4 -> Scrollspeed	{4,speed.f}
	; 	#FC_Center	; 5 -> {5}Center{5}	{5,%offset.f}
	; 	#FC_Return	; 6 -> Returns Param	{6,value}
	;  #FC_MoveY	; 7 -> 50%=y+C2D_H/2	{7,%percent.f}

	t_Scroll:
	Data.s	"{4}YEEP ... THIS FONT IS CALLED:{3,50}{1,3}{5}SPHERIX.FONT{5}{1,2}{2,3000}{3,50}IT WAS MY VERY FIRST {1,3}AMIGA{1,2} MONOSPACE FONT ... CREATED FOR MY OLD GAME FROM 1991 CALLED:{3}"	+
	      	"{4,3}TAM...{3,50}TAM...{3}{4}{1,3}{5}* SPHERIX *{5}{1,2}{2,3000}{3}"	+
	      	"{4,2}THERE WAS MUCH FUN & PRIDE THEN BECAUSE I ONLY OFFER {1,3}AMOS{1,2} BOUGHT FROM MY MONTHLY SAVED LITTLE POCKET MONEY, HAVE HAD THE {1,3}WORKBENCH{1,2} AND {1,3}EXTRAS DISK{1,2} ONLY ... "	+
	      	"OK, A HERBED WORN MAYFAIR-MAGAZINE TOO WITH ...	{1,4}{5}SAMANTHA FOX{5}{2,3000}{1,2}	... SO I MUST HAVE TO CREATE MY OWN GAMES AND FONTS.{3}"	+
	      	"A VERY LAME BUT TRUE STORY ... WHAT AN IMPORTANT ... BLAH BLAH ... YOU KNOW ... TEXT ONLY FOR THE SCROLLER ...{3}"	+
	      	"NOW LET'S GO ON & SHOW THE ORIGINAL RAW FONT:{3}"	+
	      	"{4,0.5}{1,0}{5}!" + #DQUOTE$ + "#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_{5}{2,3000}{3}{1,2}"	+
	      	"{4,5}{5}9{5}{2}{5}8{5}{2}{5}7{5}{2}{5}6{5}{2}{5}5{5}{2}{5}4{5}{2}{5}3{5}{2}{5}2{5}{2}{5}1{5}{2}{5}0{5}{2}{5}-1{5}{2}{5}-2{5}{2}{3,60}"	+
	      	"{4,0.5}ZZZ ZZZ ZZZ{3}{4,3}{1,4}OOPS!{3}{1,2}YOU ARE STILL PRESENT? ...{3}"	+
	      	"{4,2}HAPPY NEW CONTINUE!"
	
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = g
; Executable = ..\Executables\C2D_FontRaw_Amiga_x86.exe
; DisableDebugger
; CompileSourceDirectory