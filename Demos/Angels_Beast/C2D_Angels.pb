; C2D::Angels - Shadow Of The Beast II - 20.08.1990
; Purebasic v6.30 (x86-64) / 17.04.2026
; Purebasic v6.04 (x86-64) / 07.05.2018

; http://janeway.exotica.org.uk/release.php?id=17903

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes ##XMU_[Type]

	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64	Or	#PB_Compiler_Version	>=	610	; #Music
		#IsC2D_Music	=	#XMU_FT2	; x86-64
	CompilerElse
		#IsC2D_Music	=	#XMU_S68	; x86 -> #XMU_[FT2,PT2,S68,XM2,V2M,SID,MOD], #XMU_AMP -> custom by Mr.Hippel
	CompilerEndIf
	
	#IsC2D_Bitmap		=	1
	#IsC2D_Buffer		=	1
	#IsC2D_Stars2D		=	1

	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_ScrollText	=	2	; 2 -> ControlCodes "{Code,Param.f}"
	#IsC2D_Clear		=	2	; 2 -> fast clear canvasbuffer -> fillmemory(#Black)
	
	;#IsC2D_Help		=	1

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"	; must include unused #IsC2D_(Effect)

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth (zoomed)
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight (zoomed)

Enumeration
	#ID_LOGO
	#ID_FONT
	#ID_TEXT
EndEnumeration

#RGB_BACK	=	$00330000		; dark-blue for mirror

#SIN_S	=	1.5	*	#C2D_Z	; speed of sinus-scroller
#SIN_Y	=	82		*	#C2D_Z	; vertical startpos of sinus
#SIN_H	=	50		*	#C2D_Z	; height of font (sinus)

Procedure	Angels_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Angels - Beast II - 1990"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)	; update every 9ms

	; create 2d-starfield
	C2D::Stars2DInit(80, #C2D_Z, 0, 20 * #C2D_Z, #C2D_W, (170 + 20 - 40) * #C2D_Z, 3.0 * #C2D_Z)

	; create logo
	C2D::BitmapInit(#ID_LOGO, ?i_logo, ?e_logo)
	C2D::BitmapScale(#ID_LOGO, #C2D_Z)

	; create bitmapfont
	C2D::BitmapInit(#ID_FONT, ?i_font, ?e_font)
	C2D::FontInit(#ID_FONT, C2D::BitmapImage(#ID_FONT))
	C2D::FontZoom(#ID_FONT, 32 * #C2D_Z, #SIN_H)

	; create scroller for sinustext (buffer)
	C2D::ScrollTextInit(#ID_TEXT, ?t_text)
	C2D::ScrollTextSpeed(#ID_TEXT, #SIN_S)
	
	; create buffered background (fast draw, ~5% less cpu)
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, 170 * #C2D_Z, #C2D_W, #C2D_H - (170 + 20) * #C2D_Z, $FF000000|#RGB_BACK)
	C2D::BitmapDraw(#ID_LOGO, 0, 19 * #C2D_Z, 255, C2D::#C2F_Center)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()
	
	; no longer needed (it's buffered)
	C2D::BitmapFree(#ID_LOGO)
	C2D::BitmapFree(#ID_FONT)

	; play music
	CompilerIf	IsC2D::#IsC2D_Music	=	IsC2D::#XMU_AMP

		; "C:\Users\Public\Documents\AmpMaster\" -> must be installed -> \Tools\AmpInstaller\

		Protected	Music$	=	GetCurrentDirectory()	+	"mus\Hippel - Comic Bakery.hip"

		C2D::MusicPlay(@Music$)	; <- must Ptr to @filename, always Length=0

	CompilerElseIf	IsC2D::#IsC2D_Music	<>	#Null

		C2D::MusicPlay(?m_music, ?e_music)

	CompilerEndIf

EndProcedure
Procedure	Angels_Update()

	; 1. draw normal scrolltext
	C2D::ScrollTextDraw(#ID_TEXT, #SIN_Y)

	; 2. create sinustext of scrolltext (don't update canvas-buffer -> flags=0, draw under point 5.)
	C2D::BufferSinY(0,
	                #SIN_Y,
	                #C2D_W - 1,
	                #SIN_H,
	                66.5 * #C2D_Z,
	                0.17 / #C2D_Z * 5,
	                3.9 * 5,
	                0)

	; 3. update background (clear sinus on output)
	C2D::BufferBackDraw()

	; 4. update stars
	C2D::Stars2DDraw()

	; 5. now draw (transparent not alpha) buffered sinus-text in front
	C2D::BufferSinDraw(31 * #C2D_Z, 65 * #C2D_Z)

	; 6. mirror the logo/sinustext
	C2D::BufferMirror(0, 198 * #C2D_Z, #C2D_W, 22 * #C2D_Z)

	; 7. shade mirror with darkblue alphacolor, it's not like the original, but looks good ;)
	Box(0, 198 * #C2D_Z, #C2D_W, 22 * #C2D_Z, $80000000|#RGB_BACK)

EndProcedure

Angels_Init()

Repeat
	Select	WindowEvent()

		Case	#WM_RBUTTONDOWN
			C2D::ScrollTextSpeed(#ID_TEXT, 0)

		Case	#WM_RBUTTONUP
			C2D::ScrollTextSpeed(#ID_TEXT, #SIN_S)

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
				Break
			EndIf
			
		Default

			If	C2D::Start()
				Angels_Update()
				C2D::Stop()
			EndIf

	EndSelect
ForEver

C2D::Free()

DataSection

	m_music:
	CompilerSelect	IsC2D::#IsC2D_Music
		CompilerCase	IsC2D::#XMU_MOD	:	IncludeBinary	"mus\Wire - Comic Bakery_fixed.xm"
		CompilerCase	IsC2D::#XMU_XM2	:	IncludeBinary	"mus\Wire - Comic Bakery_fixed.xm"
		CompilerCase	IsC2D::#XMU_FT2	:	IncludeBinary	"mus\Wire - Comic Bakery_fixed.xm"
		CompilerCase	IsC2D::#XMU_PT2	:	IncludeBinary	"mus\Rez - Comic Bakery.mod"
		CompilerCase	IsC2D::#XMU_S68	:	IncludeBinary	"mus\Hippel - Comic Bakery.sc68"
		CompilerCase	IsC2D::#XMU_V2M	:	IncludeBinary	"mus\Lyzzard - Comic Bakery.v2m"
		CompilerCase	IsC2D::#XMU_SID	:	IncludeBinary	"mus\Martin Galway - Comic Bakery.sid"
	CompilerEndSelect
	e_music:

	i_logo:	:	IncludeBinary	"gfx\Angels_Logo.png"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\Angels_Font.png"	:	e_font:

	t_text:
	Data.s	"{5}ANGELS{5}{2,4000}{3,50}{5}PRESENTS{5}{2,4000}{3,50}{5}BEAST II{5,-1.5}{2,4000}{3,50}{5}2 DISKS{5}{2,4000}{3,50}"	+
	      	"RIGHT BUTTON TO FREEZE SCREEN  GREETINGS TO ALL OUR FRIENDS AND CONTACTS	"					+
	      	"PERSONNAL GREETINGS TO{3,50}{5}LION{5}{2,4000}{3,50}IF YOU WANT TO CONTACT US WRITE TO  "+
	      	"PO BOX 3 6040 JUMET BELGIUM		OR WRITE TO PO BOX 10 4504 OBERCORN LUXEMBURG	"			+
	      	"OR CALL ONE OF OUR INTERNATIONAL BBS AT    AMIGA EAST WORLD HQ 8044992266		"				+
	      	"ESCAPE ZONE 7042546448	DIGITAL EXPRESSION 8133987393	HOUSE OF INSANITY 8135846089		"	+
	      	"INSIDER BBS 39564415697	WORLD TRADE CENTER 4117011323	SKYFOX BBS 49911353571	"			+
	      	"REIGN IN BLOOD 492024060981	CITY LIMITS 44704501091	THE DUTCH PIRATE 31011723666		"	+
	      	"THAT IS ALL FOLKS	SCROLLING RESTARTS{3,50}9	8	7	6	5	4	3	2	1	0{3}"					+
	      	"C2D RETRO BY PEACE"

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A9
; Executable = C2D_Angels_x86.exe
; DisableDebugger
; CompileSourceDirectory