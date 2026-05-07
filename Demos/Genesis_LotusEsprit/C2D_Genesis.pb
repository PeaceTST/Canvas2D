; C2D::Genesis & Angles / Lotus Esprit - 1990
; Purebasic v6.04 (x86-64) / 09.05.2024

; http://janeway.exotica.org.uk/release.php?id=14443

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_TPT	; TinyPT2

	#IsC2D_Clear		=	0	; clear by buffer()
	#IsC2D_Mode			=	0
	#IsC2D_ScreenShot	=	0	; 1 = F1-Key coppy to clipboard

	#IsC2D_Buffer		=	1
	#IsC2D_PageText	=	1

	#IsC2D_Bitmap		=	1
	#IsC2D_GdiPlus		=	2	; API-Decoder PNG only!

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width zoomed
#C2D_H	=	240	*	#C2D_Z	; Height zoomed

Enumeration
	#GEM_1
	#GEM_2
	#GEM_3
	#FONT
EndEnumeration

#GEM_W	=	23.5	*	#C2D_Z
#GEM_H	=	31		*	#C2D_Z
#GEM_Y	=	4		*	#C2D_Z
#GEM_X	=	4		*	#C2D_Z	; original = 0

#GEM_MX	=	12	; original = 13
#GEM_MY	=	6

Procedure	C2D_Init()
	
	Protected	i, x, y, ix, iy
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Genesis & Angles - Lotus Esprit - 1990"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 12, $FF220000)
	C2D::Quality(Bool(#C2D_Z = Int(#C2D_Z)))
	
	; create font
	C2D::BitmapInit(0, ?i_font, ?e_font)
	C2D::FontInit(#FONT, C2D::BitmapImage(0), 2, 2)
	C2D::FontScale(#FONT, #C2D_Z)
	C2D::FontGap(#FONT, 2 * #C2D_Z, 5 * #C2D_Z)
	
	; create pagetext
	C2D::PageTextWait(3800)
	C2D::PageTextInit(?t_text, 0, 0, #C2D_W, #C2D_H, C2D::#C2F_Center)
	C2D::PageTextEffect(1, C2D::#PFX_FadeStep, 50, 150)	; show
	C2D::PageTextEffect(0, C2D::#PFX_FadeStep, 50, 150)	; hide
	
	; get & zoom the gems
	C2D::BitmapInit(#GEM_1, ?i_gem1, ?e_gem1)	:	C2D::BitmapScale(#GEM_1, #C2D_Z)
	C2D::BitmapInit(#GEM_2, ?i_gem2, ?e_gem2)	:	C2D::BitmapScale(#GEM_2, #C2D_Z)
	C2D::BitmapInit(#GEM_3, ?i_gem3, ?e_gem3)	:	C2D::BitmapScale(#GEM_3, #C2D_Z)
	
	; generate gem-frame & fast backbuffer
	StartDrawing(CanvasOutput(#C2D_G))
	For	y	=	0	To	#GEM_MY
		For	x	=	0	To	#GEM_MX
			If	(y	=	0	Or	y	=	#GEM_MY)	Or	(x	=	0	Or	x	=	#GEM_MX)
				i	=	Random(#GEM_3 * 3)
				i	*	Bool(i	<=	#GEM_3)
				ix	=	#GEM_X	+	x * #GEM_W
				iy	=	#GEM_Y	+	y * #GEM_H	+	(#GEM_H	*	0.5	*	Bool(x & 1))
				C2D::BitmapDraw(i, ix, iy)
			EndIf
		Next
	Next
	C2D::BufferBackGrab()
	StopDrawing()
	
	; we need the font only, so...
	C2D::BitmapFree(#PB_All)

	; at last play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf
	
EndProcedure
Procedure	C2D_Update()
	
	C2D::BufferBackDraw()	; clear & update background
	C2D::PageTextDraw()		; draw text, thats all folks ;)

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			Select	EventwParam()
 				;Case	#VK_F1	:	C2D::ScreenShot()
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
		m_music:	:	IncludeBinary	"mus\Suleiman - Gonads Cracks.mod"	:	e_music:
	CompilerEndIf

	i_font:	:	IncludeBinary	"gfx\Genesis_Font.png"	:	e_font:
	i_gem1:	:	IncludeBinary	"gfx\gem1.png"				:	e_gem1:
	i_gem2:	:	IncludeBinary	"gfx\gem2.png"				:	e_gem2:
	i_gem3:	:	IncludeBinary	"gfx\gem3.png"				:	e_gem3:

	t_text:
	Data.s	"G E N E S I S||"	+
	      	"AND||"				+
	      	"A N G E L S"		+
	      	"~"	+
	      	"PRESENTS||"			+
	      	"LOTUS ESPRIT|"		+
	      	"TURBO CHALLENGE||"	+
	      	"RELEASE VERSION"		+
	      	"~"	+
	      	"CRACKED BY|"		+
	      	"MR.E / GENESIS"	+
	      	"~"	+
	      	"TO CONTACT US"+
	      	"~"	+
	      	"WRITE TO||"	+
	      	"P.O BOX 2|"	+
	      	"8330 BEDER|"	+
	      	"DENMARK"		+
	      	"~"	+
	      	"OR WRITE TO||"+
	      	"POSTBUS 3|"	+
	      	"6040 JUMET|"	+
	      	"BELGIUM"		+
	      	"~"	+
	      	"C2D RETRO||"	+
	      	"BY||"			+
	      	"P E A C E"

EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = A+
; Executable = C2D_Genesis_x86.exe
; DisableDebugger
; CompileSourceDirectory