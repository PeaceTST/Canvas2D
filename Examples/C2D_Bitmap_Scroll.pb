; C2D::Bitmap / Scroll - Purebasic v5.72 (x86)

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	
	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x86
		XIncludeFile	"..\Include\C2D_Types.pbi"
		#IsC2D_Music	=	#XMU_V2M
		#IsC2D_Clear	=	0
	CompilerElse	; Ooops, error - can't play v2m in x64!
		#IsC2D_FontRaw	=	1	; includes default topaz.font
		#IsC2D_Guru		=	1
		#IsC2D_Clear	=	2
	CompilerEndIf

	#IsC2D_FontColor	=	1
	#IsC2D_File			=	1
	#IsC2D_GdiPlus		=	1
	#IsC2D_Anim			=	1

	#IsC2D_Bitmap		=	2	; 2 -> BitmapScroll()
	#IsC2D_ScrollText	=	2	; 2 -> {Code,Param}

	;#IsC2D_Help	=	1

	XIncludeFile	"..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Enumeration	1
	#ID_ANIM0
	#ID_ANIM1
	#ID_BACK0
	#ID_BACK1
	#ID_BACK2
	#ID_LOGO	=	255
EndEnumeration

#X_Speed	=	0.45	*	#C2D_Z
#X_Fade	=	255

Global	y.f, x.f, anim_w, anim_x.f

Procedure	C2D_Init()
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Bitmap / Scroll + V2M"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 8)
	
	; FIRST! Init bitmaps wich will be used in scroller {0,5}!
	C2D::Quality(#PB_Image_Smooth)
	
	C2D::BitmapInit(#ID_LOGO, @"..\Data\Logo\PsyNew.png")
	C2D::BitmapScale(#ID_LOGO, 0.5 * #C2D_Z)
	
	; Bitmaps in pixel-quality (remark why)
	C2D::Quality(#PB_Image_Raw)
	
	; Small font(0)
	C2D::BitmapInit(0, @"..\Data\Font\PNG\GarnetLcase.png")
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontZoom(0, 28 * #C2D_Z, 22 * #C2D_Z)
	C2D::FontCopper(0, ?c_r)
	C2D::FontShadow(0, 2, 2, 90)
	C2D::FontGap(0, -6 * #C2D_Z)
	
	; Big font(1)
	C2D::BitmapInit(0, @"..\Data\Font\PNG\GarnetUcase.png")
	C2D::FontInit(1, C2D::BitmapImage(0))
	C2D::FontZoom(1, 28 * #C2D_Z, 22 * #C2D_Z * 3)
	C2D::FontCopper(1, ?c_r)
	C2D::FontShadow(1, 2, 2, 90)
	C2D::FontGap(1, -8 * #C2D_Z)
	
	; Scrolltext with smaller font(0) as default
	C2D::FontSelect(0)

	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, 2.0 * #C2D_Z)
	
	; Owl-Anim
	C2D::BitmapInit(0, @"..\Data\Anim\Anim_AgonyOwl_16x1.png")
	C2D::AnimInit(#ID_ANIM0, C2D::BitmapImage(0), 16, 1)	:	C2D::AnimScale(#ID_ANIM0, #C2D_Z)
	
	; Ghost-Anim
	C2D::BitmapInit(0, @"..\Data\Anim\Anim_GhostOwl_16x1.png")
	C2D::AnimInit(#ID_ANIM1, C2D::BitmapImage(0), 16, 1)	:	C2D::AnimScale(#ID_ANIM1, #C2D_Z)

	; Forest
	C2D::BitmapInit(#ID_BACK0, @"..\Data\Back\Forest_Tree.png")		:	C2D::BitmapScale(#ID_BACK0, #C2D_Z * 0.7)
	C2D::BitmapInit(#ID_BACK1, @"..\Data\Back\Forest_Light.png")	:	C2D::BitmapZoom(#ID_BACK1, #C2D_W, 0.7 * C2D::BitmapH(#ID_BACK0))
	C2D::BitmapInit(#ID_BACK2, @"..\Data\Back\Forest_Blur.jpg")		:	C2D::BitmapZoom(#ID_BACK2, #C2D_W, 0.7 * C2D::BitmapH(#ID_BACK0))
	
	C2D::BitmapFree(0)
	
	;C2D::ScrollTextPos(0, 264)	; <- start with charpos, only for test
	
	anim_w	=	C2D::AnimW(#ID_ANIM0)
	anim_x	=	-anim_w	; left out startpos for moving owl

	; CenterY forest in canvas
	y	=	(#C2D_H - C2D::BitmapH(#ID_BACK0))	*	0.5
	
	; Play music?
	CompilerIf	IsC2D::#IsC2D_Music
		Protected	File$	=	"..\Data\Music\V2M\505 - No Exit.v2m"
		C2D::MusicPlay(@File$)
	CompilerElseIf	IsC2D::#IsC2D_Guru
		Protected	t$
		t$	=	"|SOFTWARE FAILURE.	PRESS LEFT MOUSE BUTTON TO CONTINUE.|"	+
		  	 	"|MUSICFORMAT *.V2M NOT SUPPORTED IN X64|"
		C2D::GuruInit(@t$)
	CompilerEndIf
	
EndProcedure
Procedure	C2D_Update()
	
	Static	Alpha0=#X_Fade, Alpha1=0, ID=#ID_ANIM0, IX=2
	
	; 1. draw Background_Blur
	C2D::BitmapDraw(#ID_BACK2, 0, y)
	
	; 2. fade anims in/out
	If	Alpha0	<	#X_Fade	And	ID	=	#ID_ANIM0	; owl
		Alpha0	+	1
		Alpha1	-	1
	ElseIf	Alpha1	<	#X_Fade	And	ID	=	#ID_ANIM1	; ghost
		Alpha1	+	1
		Alpha0	-	1
	EndIf
	
	; 3. move owl in(2)/out(1)?
	If	IX
		Select	IX
			Case	1
				anim_x	+	#X_Speed
				If	anim_x	>=	#C2D_W	+	anim_w
					IX	=	2	:	anim_x	=	-anim_w
				EndIf
			Case	2
				anim_x	+	#X_Speed
				If	anim_x	>=	(#C2D_W	-	anim_w)	*	0.5
					IX	=	0	:	anim_x	=	(#C2D_W - anim_w)	*	0.5
				EndIf
		EndSelect
	EndIf
	
	; 4. draw Anim_Owls
	If	Alpha0	>	0
		C2D::AnimDraw(#ID_ANIM0, anim_x, #C2D_H * 0.225, Alpha0)
	EndIf
	If	Alpha1	>	0
		C2D::AnimDraw(#ID_ANIM1, anim_x, #C2D_H * 0.225 - 7 * #C2D_Z, Alpha1)
	EndIf
	
	; 5. draw Background_Light & Forest
	C2D::BitmapDraw(#ID_BACK1, 0, y)
	C2D::BitmapDraw(#ID_BACK0, 0, y)
	
	; 6. draw Scrolltext in front of all & check return parameter {6,param}
	Select	C2D::ScrollTextDraw(0, #C2D_H * 0.43)
		Case	1	:	ID	=	#ID_ANIM0	:	C2D::AnimFrame(#ID_ANIM0, C2D::AnimFrame(#ID_ANIM1)) ; owl frame = ghost
		Case	2	:	ID	=	#ID_ANIM1	:	C2D::AnimFrame(#ID_ANIM1, C2D::AnimFrame(#ID_ANIM0)) ; ghost frame = owl
		Case	3	:	IX	=	1																						  ; start moving owl
		Case	4	:	C2D::ScrollTextSinus(0, 16.0 * #C2D_Z, 16.0 / #C2D_Z, 16 * #C2D_Z)	; start sinustext
		Case	5	:	C2D::ScrollTextSinus(0)	; pause sinustext
	EndSelect

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
				Break
			EndIf
		CompilerIf	IsC2D::#IsC2D_Guru
		Case	#WM_LBUTTONDOWN
			C2D::GuruFree()
		CompilerEndIf

		Default
			
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
				
				; Scroll bitmaps time delayed -> NEVER! within Start() / Stop()
				C2D::BitmapScroll(#ID_BACK0, #C2D_Z * 2,	0, 3)
				C2D::BitmapScroll(#ID_BACK1, #C2D_Z,		0, 3)
				C2D::BitmapScroll(#ID_BACK2, #C2D_Z,		0, 6)
				
			EndIf
			
	EndSelect
ForEver

C2D::Free()

DataSection
	c_r:		:	Data.l	3,	$FF000030, $FF1212FF, $FF000030
	t_text:	:	Data.s	"{4,.6}{1,1}B{1}ITMAP{1,1}S{1}CROLL EXAMPLE USING THE...{3}{6,2}{4,2}{6,4}{5}CUSTOM {1,1}C2D{1} MODULE{5}{2,5700} {6,1}{3}{6,5}"	+
	       	 	      	"{4,.6}{1,1}C{1}ODED IN...{3}{6,2}{4,2}{6,4}{5}{1,1}P{1}URE{1,1}B{1}ASIC V" + MA_XPB() + " (" + MA_XOS() + "){5}{2,5700} {6,1}{3}{6,5}"	+
	       	 	      	"{4,.6}{1,1}G{1}RAPHICS BY THE ARTISTS OF...{3}{6,3}{4,2}{5}{0,255}{5}{2,5000}{3}"												+
	       	 	      	"{4,.6}{1,1}S{1}UPERB {1,1}L{1}IBV2 MUSIC BY THE COMPONIST...{3}{6,2}{4,2}{6,4}{5}{1,1}5{1}0{1,1}5{1} - {1,1}N{1}O {1,1}E{1}XIT{1,1}!{1}{5}{2,5700} {6,1}{3}{6,5}"		+
	       	 	      	"{4,.6}{1,1}V{1}ISIT US AT...{3}{4,2}{6,3}{5}TESTAWARE.WORDPRESS.COM{5,1.5}{2,3700}{3}"
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = A+
; Executable = ..\Executables\C2D_Bitmap_Scroll_x86.exe
; CompileSourceDirectory