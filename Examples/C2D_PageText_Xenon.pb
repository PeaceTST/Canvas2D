; C2D::PageText / Xenon + NetWork + XUnPack + TPT - Purebasic v6.30 (x86-64)

; Name				Role				Protocol				Address
; ------------------------------------------------------------------------------------------
; 1 - Modland		Main server		ftp,http,https		ftp.modland.com
; 2 - Scenesat		Mirror			ftp,http,https		modland.ziphoid.com
; 3 - Amigascne	Mirror			ftp					ftp.amigascne.org/mirrors/ftp.modland.com
; 4 - Antarctica	Mirror			http					modland.antarctica.no
; 5 - Obarski		Inofficial		http					obarski.modland.com (closed!)

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

#IsMod	=	1	; xenom ii hoster (0, 1 - 5)

IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D
	XIncludeFile	"C2D_Types.pbi"	; music constants #XMU_[Type]
	#IsC2D_Music		=	#XMU_TPT		; PT2,FT2,MOD
	#IsC2D_XUnPack		=	#XUP_SQSH	; only for #IsMod = 0 (packed + fakeheader)
	#IsC2D_Bitmap		=	1
	#IsC2D_Stars3D		=	1
	#IsC2D_File			=	1
	#IsC2D_NetWork		=	1
	#IsC2D_Clear		=	2	; fast clear
	#IsC2D_PageText	=	2	; change font
	#IsC2D_GdiPlus		=	2	; small png encoder
	XIncludeFile	"C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#FILE_TOTAL	=	0.01	/	3

Global	FileCount

Procedure	C2D_CallBack(Param)
	
	; NO! StartDrawing()/StopDrawing()

	; Param = download-status in percent

	Protected	x = 32 * #C2D_Z, y = 16 * #C2D_Z, i = 3 * #C2D_Z

	Box(x, #C2D_H / 2 - y, #C2D_W - 2 * x, 2 * y, $FFFFFFFF)	:	x	+	i	:	y	-	i
	Box(x, #C2D_H / 2 - y, #C2D_W - 2 * x, 2 * y, $FF000000)	:	x	+	i	:	y	-	i

	;Box(x, #C2D_H / 2 - y, ((#C2D_W - 2 * x) * 0.01) * Param, 2 * y, $FFFFFFFF)
	
	Box(x, #C2D_H / 2 - y, ((#C2D_W - 2 * x) * #FILE_TOTAL) * (Param + FileCount * 100), 2 * y, $FFFFFFFF)

	If	WindowEvent()	=	#Null
		Delay(3)
	EndIf

EndProcedure

Procedure	C2D_Init()
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("PageText / Xenon + NetWork + XUnPack + TPT"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	; initialze c2d
	C2D::Init(#C2D_G)
	
	; set image size-quality
	;C2D::Quality(#PB_Image_Smooth)
	
	; main path (online)
	C2D::FilePath("https://testaware.files.wordpress.com/2019/04/")
	
	; network defaults
	C2D::NetWorkCallBack(@C2D_CallBack())
	;C2D::NetWorkBytes(1024)
	
	; main font
	C2D::BitmapInit(0, @"xenon_16x22.png")	:	FileCount	+	1
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontScale(0, 1.3 * #C2D_Z)
	C2D::FontGap(0, 0, 3)
	
	; highscore font
	C2D::FontInit(1, C2D::BitmapImage(0))
	C2D::FontScale(1, 1.1 * #C2D_Z)
	
	; logo
	C2D::BitmapInit(0, @"xenon_2.png")	:	FileCount	+	1
	C2D::BitmapScale(0, 1.6 * #C2D_Z)
	
	; starfield
	C2D::Stars3DSpread(-325 * #C2D_Z)
	C2D::Stars3DInit(100, 2 * #C2D_Z, 0, 0, #C2D_W, #C2D_H, 3.0)
	C2D::Stars3DDistance(25)
	
	; pagetext
	C2D::PageTextInit(?t_text, 0, 60 * #C2D_Z, #C2D_W, 6.8 * C2D::FontH(0), C2D::#C2F_CenterX)
	C2D::PageTextWait(3500)
	C2D::PageTextEffect(1, C2D::#PFX_Random, 5, 35)	; show
	C2D::PageTextEffect(0, C2D::#PFX_Random, 5, 35)	; hide
	
	;C2D::PageTextColor($70FFFF0F)
	;C2D::PageTextID(9)	
	
	; Play online-music?
	CompilerIf	IsC2D::#IsC2D_Music
		CompilerSelect	#IsMod
			CompilerCase	1
				C2D::MusicPlay(@"http://ftp.modland.com/pub/modules/Protracker/Mercy/xenon ii.mod")
			CompilerCase	2
				C2D::MusicPlay(@"https://modland.ziphoid.com/pub/modules/Protracker/Mercy/xenon ii.mod")
			CompilerCase	3
				C2D::MusicPlay(@"http://ftp.amigascne.org/mirrors/ftp.modland.com/pub/modules/Protracker/Mercy/xenon ii.mod")
			CompilerCase	4
				C2D::MusicPlay(@"http://modland.antarctica.no/pub/modules/Protracker/Mercy/xenon ii.mod")
			CompilerCase	5
				C2D::MusicPlay(@"http://obarski.modland.com/pub/modules/Protracker/Mercy/xenon ii.mod")
			CompilerDefault
				C2D::NetWorkSkip(6)	; skip 6 bytes of fake gif-header (sorry wordpress! but offers limited filetypes)
				Protected	*Memory	=	C2D::FileLoad("mercy-xenon-ii_mod.gif")
				If	*Memory	And	XUP::Unpack(*Memory, MemorySize(*Memory))
					C2D::MusicPlay(XUP::Buffer(), XUP::Size())
				EndIf
				C2D::NetWorkSkip()
		CompilerEndSelect
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Static	Fade, y

	C2D::Stars3DDraw()
	
	Select	C2D::PageTextDraw(0, y)
		Case	0
			If	y	=	0			; default y-offset for pagetext
				y	=	130 * #C2D_Z
				C2D::PageTextWait(3500)
			EndIf
			If	Fade	<	255	; start page #0 fade logo in
				Fade	+	3
			EndIf
		Case	9
			If	y					; no y-offset for pagetext
				y	=	0
				C2D::PageTextWait(15000)
			EndIf
			If	Fade	>	0		; highscore page #9 fade logo out
				Fade	-	3
			EndIf
	EndSelect

	If	Fade
		C2D::BitmapDraw(0, 0, 64 * #C2D_Z, Fade, C2D::#C2F_CenterX)
	EndIf

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
	t_text:
	Data.s	"{1}DESIGNED BY|"	+
	      	"THE BITMAP BROTHERS"+
	      	"~"	+
	      	"TRAINED BY|"			+
	      	"BAMIGA SECTOR ONE"	+
	      	"~"	+
	      	"PROGRAMMING|"		+
	      	"THE ASSEMBLY LINE"	+
	      	"~"	+
	      	"GRAPHICS|"	+
	      	"MARC COLEMAN"	+
	      	"~"	+
	      	"MUSIC|"		+
	      	"BOMB THE BASS"+
	      	"~"	+
	      	"MUSIC PROGRAMMING|"+
	      	"DAVID WHITTAKER"		+
	      	"~"	+
	      	"FX|"				+
	      	"DAVID WHITTAKER"	+
	      	"~"	+
	      	"AMIGA MODULE|"				+
	      	"MERCY OF EXELLENCE 1991"	+
	      	"~"	+
	      	"C2D|"					+
	      	"PEACE OF TESTAWARE"	+
	      	"~"	+
	      	"HIGHSCORE||{1,1}"+
	      	"1. 1000000 BS1|"	+
	      	"2. 0100000 BS1|"	+
	      	"3. 0010000 BS1|"	+
	      	"4. 0001000 BS1|"	+
	      	"5. 0000100 BS1"
EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A+
; Executable = ..\Executables\C2D_PageText_Xenon_x86.exe
; CompileSourceDirectory