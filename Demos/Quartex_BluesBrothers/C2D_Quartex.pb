; C2D::Quartex - Blues Brothers - 1991
; Purebasic v6.30 (x86-64) / 17.04.2026

; http://janeway.exotica.org.uk/release.php?id=7703

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor -> set 1 or 2
CompilerEndIf

DeclareModule	IsC2D

	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64	Or	#PB_Compiler_Version	>=	610
		#IsC2D_Music	=	#XMU_FT2
	CompilerElse
		#IsC2D_Music	=	#XMU_S68	; x86 only!
	CompilerEndIf

	#IsC2D_Mode		=	0	; reduces ~0.9% cpu
	#IsC2D_Clear	=	0

	#IsC2D_Bitmap	=	1
	#IsC2D_Buffer	=	1
	#IsC2D_Copper	=	1
	#IsC2D_Text		=	1
	
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***
#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width (zoomed)
#C2D_H	=	240	*	#C2D_Z	; Height (zoomed)

#Y0		=	90		*	#C2D_Z	; Y-Pos Text & Copper

Procedure.l	Blit_Copper(x, y, PenColor.l, PaperColor.l)
	If	PaperColor	&	$00FFFFFF
		ProcedureReturn	PenColor
	EndIf
EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Quartex - Blues Brothers - 1991"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 10)

	; Get bitmap for font
	C2D::BitmapInit(0, ?i_font, ?e_font)

	; Create font from bitmap
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, #C2D_Z, 2 * #C2D_Z)

	; Create text with font
	C2D::TextInit(0, ?t_text, C2D::#C2F_CenterX)

	; Create copper for text
	C2D::CopperInit(0, C2D::TextH(0) - 2 * #C2D_Z, ?c_copper)
	C2D::CopperBlitProc(@Blit_Copper())

	; Get bitmap for logo
	C2D::BitmapInit(0, ?i_logo, ?e_logo)
	C2D::BitmapScale(0, #C2D_Z)
	
	; Create buffered background of static gfx (fast restore)
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::BitmapDraw(0, 0, 16 * #C2D_Z, 255, C2D::#C2F_CenterX)
	Box(0, #Y0 - 3 * #C2D_Z,						#C2D_W,	#C2D_Z, $FFFFFFFF)
	Box(0, #Y0 + C2D::CopperH(0) + 2 * #C2D_Z,#C2D_W,	#C2D_Z, $FFFFFFFF)
	C2D::TextDraw(0, 0, #Y0)
	C2D::BufferBackGrab()
	C2D::BufferClear()	; remark to see why
	StopDrawing()

	; Free unused stuff
	C2D::BitmapFree(0)
	C2D::TextFree(0)
	C2D::FontFree(0)

	; Play music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	; Fast restore background (logo + text)
	C2D::BufferBackDraw()

	; Copper on static buffered text
	C2D::CopperBlit(0, #Y0, 0.75 * #C2D_Z)

	; Thats all :)

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#WM_LBUTTONUP,
		    	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	EventwParam()	=	#VK_ESCAPE
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

	m_music:
	CompilerSelect	IsC2D::#IsC2D_Music
		CompilerCase	IsC2D::#XMU_S68	; x86 only
			IncludeBinary	"mus\Jochen Hippel - QTX - Intro (jambala remix).sc68"
		CompilerCase	IsC2D::#XMU_FT2
			;IncludeBinary	"mus\Ampli - 7 Gates Of Jambala (Peace edit x64).xm"
			IncludeBinary	"mus\Ampli - 7 Gates Of Jambala.xm"
	CompilerEndSelect
	e_music:
	
	i_logo:	:	IncludeBinary	"gfx\Quartex_Logo.bmp"	:	e_logo:
	i_font:	:	IncludeBinary	"gfx\Quartex_Font.bmp"	:	e_font:

	c_copper:	:	Data.l	4, $FF00FFFF, $FF002456, $FF000001, $FF00FFFF

	t_text:
	Data.s	"PROUDLY PRESENTS: BLUES BROTHERS!"		+	#LF$	+
	      	"BY TITUS SOFTWARE !!"						+	#LF$	+
	      	"ORIGINAL SUPPLIED BY: S.F.X!"			+	#LF$	+
	      	"CRACKED TO DOS BY: THE SURGE!!"			+	#LF$	+	#LF$	+
	      	"WRITE: 5-7 PLACE DES MARSEILLAISES"	+	#LF$	+
	      	"13001 MARSEILLE, FRANCE!"					+	#LF$	+	#LF$	+
	      	"U.K. WRITE: P.O. BOX 48, SOUTHAMPTON"	+	#LF$	+
	      	"SD9 7DQ, ENGLAND!"							+	#LF$	+
	      	"CALL FREE KUWAIT +95-55-324360"			+	#LF$	+
	      	"LEFT MOUSE TO EXIT ..."

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A9
; Executable = C2D_Quartex_x86.exe
; DisableDebugger
; CompileSourceDirectory
; Compiler = PureBasic 6.30 - C Backend (Windows - x64)