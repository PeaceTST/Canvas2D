; C2D::Paranoimia / Shufflepuck Cafe - 1989
; Purebasic v6.04 (x86/x64) / 29.04.2018

; http://janeway.exotica.org.uk/release.php?id=20269

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	
	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_TPT

	#IsC2D_Clear		=	0
	#IsC2D_Topaz		=	0
	
	#IsC2D_Buffer		=	1
	#IsC2D_Line3D		=	1
	#IsC2D_Stars3D		=	1
	#IsC2D_Text			=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_FontRaw		=	1
	
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; Width
#C2D_H	=	240	*	#C2D_Z	; Height

#SY	=	45	*	#C2D_Z
#BH	=	13	*	#C2D_Z

Procedure	Paranoimia_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Paranoimia - Shufflepuck Cafe - 1989"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G)

	C2D::FontRawInit(0, ?f_raw, ?e_raw, 1, 1, #White, 7)
	C2D::FontScale(0, #C2D_Z * 0.5)
	
	C2D::TextInit(0, ?t_ea)
	
	; create static background (even for clear canvas)
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, #SY - #BH, #C2D_W, #BH, $FFAA0000)
	Box(0, #SY - #BH + #C2D_Z, #C2D_W, #BH - #C2D_Z * 2, $FFCC0000)
	C2D::TextDraw(0, -4, #C2D_H - #SY - 5 * #C2D_Z, 160, C2D::#C2F_Right)
	C2D::BufferBackGrab()
	StopDrawing()
	
	C2D::TextFree(0)
	
	C2D::Stars3DSpread(0)
	C2D::Stars3DInit(40 * #C2D_Z, #C2D_Z, 0, #SY, #C2D_W, #C2D_H - #SY * 2, 2.5)
	
	C2D::Line3DInit(0, ?o_l3d, 8.0 * #C2D_Z)
	C2D::Line3DColor(0, $FFFFFFFF)
	C2D::Line3DFog(0, 2.6 / #C2D_Z)
	
	C2D::FontRawInit(0, ?f_raw, ?e_raw, 1, 1, #White, 7)
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, #C2D_Z)
	
	C2D::ScrollTextInit(0, ?t_text)
	C2D::ScrollTextSpeed(0, 0.33 * #C2D_Z)

	C2D::MusicPlay(?m_mus, ?e_mus)
	
EndProcedure
Procedure	Paranoimia_Update()
	
	C2D::BufferBackDraw()
	
	C2D::Stars3DDraw()

	C2D::Line3DRotate(0, 2.0, 1.0, 0)
	C2D::Line3DDraw(0)

	C2D::ScrollTextDraw(0, #SY - #BH + 3 * #C2D_Z)
	
	C2D::BufferCloneY(#SY - #BH, #C2D_H - #SY, #BH)
	
EndProcedure

Paranoimia_Init()

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
				Paranoimia_Update()
				C2D::Stop()
			EndIf

	EndSelect
ForEver

C2D::Free()

DataSection
	
	o_l3d:	:	IncludeBinary	"obj\Paranoimia.l3d"
	f_raw:	:	IncludeBinary	"gfx\Paranoimia_Font_7.rw"			:	e_raw:
	m_mus:	:	IncludeBinary	"mus\Estrayk - Paranoimia.mod"	:	e_mus:
	
	t_ea:		:	Data.s	"ELECTRONIC ARTISTS"

	t_text:	:	Data.s	"PARANOIMIA PRESENTS ... SHUFFLEPUCK CAFE !!!  .... "	+
	       	 	      	"HEY YOU LAME ASSES IN QUARTEX, WHY DIDN'T YOU SHITHEADS RELEASE IT ??? "	+
	       	 	      	"MAYBE YOU GET THE ORIGINAL IN A FEW WEEKS .... "	+
	       	 	      	"OR CALL US ROBIN, WE WILL GIVE IT TO YOU FOR A SPECIAL PRICE AND WITHOUT PROTECTION, SO YOU CAN'T FUCK IT UP !!!!   ........ .....  "	+
	       	 	      	"PARANOIMIA IS CONTACTABLE AT  P.O. BOX 10 ..  4140 AMAY .. BELGIUM !!  ITALIANS WRITE TO  P.O. BOX 127 , BARI , ITALY!! ...."
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = w
; Executable = C2D_Paranoimia_x86.exe
; DisableDebugger
; CompileSourceDirectory