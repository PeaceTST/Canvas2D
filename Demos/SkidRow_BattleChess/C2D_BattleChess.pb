; C2D::Skid Row / BattleChess II - 17.07.1991
; Purebasic v5.72 (x86-64) / 18.02.2022

; http://janeway.exotica.org.uk/release.php?id=7552

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2
CompilerEndIf

IncludePath	"..\..\Include\"	; adapt path of include

DeclareModule	IsC2D	; Used FX

	XIncludeFile	"C2D_Types.pbi"	; predefined #Types

	#IsC2D_Music	=	#XMU_TPT

	#IsC2D_Mode		=	0
	#IsC2D_Clear	=	0
	#IsC2D_Buffer	=	1
	#IsC2D_PageText=	1
	#IsC2D_Copper	=	1
	#IsC2D_Poly3D	=	1
	#IsC2D_Stars2D	=	1
	#IsC2D_GdiPlus	=	2

	XIncludeFile	"C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;***************************************************

IncludePath	""

; CanvasGadget, Width & Height
#C2D_G	=	0						; #Gadget
#C2D_W	=	320	*	#C2D_Z	; Zoomed width
#C2D_H	=	240	*	#C2D_Z	; Zoomed height

#X	=	#C2D_W	*	0.345	; x-pos of pixel3d

Procedure	C2D_Init()

	Protected	i, *p.Integer

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Skid Row - BattleChess II - 1991"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 10)	; update every 10ms

	; stars
	C2D::Stars2DColor($CCAABB)
	C2D::Stars2DInit(28 * #C2D_Z, #C2D_Z, 0, 22 * #C2D_Z, #C2D_W, #C2D_H - 44 * #C2D_Z, 2.5 * #C2D_Z)

	; font
	C2D::GdipCatch(0, ?i_font, ?e_font)
	C2D::FontInit(0, 0)
	C2D::FontScale(0, #C2D_Z)
	C2D::FontGap(0, 1, 2 * #C2D_Z)

	; text
	C2D::PageTextInit(?t_text, #C2D_Z, 22 * #C2D_Z, 252 * #C2D_Z, 198 * #C2D_Z, C2D::#C2F_Center)
	C2D::PageTextWait(9000)
	C2D::PageTextEffect(1, C2D::#PFX_Fade,	8, 0)	; 1 = show page fx
	C2D::PageTextEffect(0, C2D::#PFX_Fade,	8, 0)	; 0 = hide page fx

	; skid (0-3) & row (4-6)
	*p	=	?l_p
	For	i	=	0	To	6
		C2D::Poly3DInit(i, *p\i)
		C2D::Poly3DScale(i, 4.1 * #C2D_Z)
		C2D::Poly3DAngle(i, 150, 0, 0)
		*p	+	SizeOf(Integer)
	Next

	; create copper for top/bottom line
	C2D::CopperInit(0, #C2D_Z, ?c_t, C2D::#C2F_Horizontal)
	C2D::CopperInit(1, #C2D_Z, ?c_b, C2D::#C2F_Horizontal)

	;********************************
	;*** create static backbuffer ***
	StartDrawing(CanvasOutput(#C2D_G))
	FrontColor($FF332222)
	Box(0, 0, #C2D_W, 20 * #C2D_Z)
	Box(0, #C2D_H - 20 * #C2D_Z, #C2D_W, 20 * #C2D_Z)
	C2D::CopperDraw(0, 20 * #C2D_Z)
	C2D::CopperDraw(1, #C2D_H - 20 * #C2D_Z)
	C2D::BufferBackGrab()
	StopDrawing()
	;********************************

	C2D::CopperFree(#PB_All)
	FreeImage(0)	; font

	; play music
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_mus, ?e_mus)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Static	Time, f.f, IsSwap=1, p0, p1=3
	Static	c0.l, c1.l, c2.l

	Protected	IsFade, b, g, r, i

	; clear with buffered background
	C2D::BufferBackDraw()

	; stars2d
	C2D::Stars2DDraw()

	; swap skid & row?
	If	C2D::MA_Time()	>=	Time
		Time	=	C2D::MA_Time()	+	6000
		IsSwap	!	1
	EndIf

	; fade in & out
	If	IsSwap	And	f	>	0

		f	-	0.025

		If	f	<=	0

			f			=	0
			IsSwap	=	0

			If	p0	; skid (0-3)
				p0	=	0
				p1	=	3
			Else	; row (4-6)
				p0	=	4
				p1	=	6
			EndIf

		EndIf

		IsFade	=	#True

	ElseIf	IsSwap	=	0	And	f	<	1.0

		f	+	0.025

		If	f	>=	1.0
			f	=	1.0
		EndIf

		IsFade	=	#True

	EndIf

	; color fade of skid & row
	If	IsFade

		b	=	$44	*	f
		g	=	$22	*	f
		r	=	$33	*	f
		c2	=	b<<16	|	g<<8	|	r

		b	=	$55	*	f
		g	=	$33	*	f
		r	=	$44	*	f
		c1	=	b<<16	|	g<<8	|	r

		b	=	$99	*	f
		g	=	$77	*	f
		r	=	$88	*	f
		c0	=	b<<16	|	g<<8	|	r

	EndIf

	; rotate & draw poly3d-logo (simulated fade in&out)
	For	i	=	p0	To	p1
		C2D::Poly3DRotate(i, 0, -11, 0)
		C2D::Poly3DColor(i, c2)	:	C2D::Poly3DDraw(i, #X - 30 * #C2D_Z)
		C2D::Poly3DColor(i, c1)	:	C2D::Poly3DDraw(i, #X - 15 * #C2D_Z)
		C2D::Poly3DColor(i, c0)	:	C2D::Poly3DDraw(i, #X )
	Next

	; message text
	C2D::PageTextDraw()

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
				Break
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection

	CompilerIf	IsC2D::#IsC2D_Music
		m_mus:	:	IncludeBinary	"mus\Jugi - Crack Or Die!.mod"	:	e_mus:
	CompilerEndIf

	l_p:	:	Data.i	?p_s, ?p_k, ?p_i, ?p_d, ?p_r, ?p_o, ?p_w

	p_s:	:	IncludeBinary	"obj\s.p3d"
	p_k:	:	IncludeBinary	"obj\k.p3d"
	p_i:	:	IncludeBinary	"obj\i.p3d"
	p_d:	:	IncludeBinary	"obj\d.p3d"

	p_r:	:	IncludeBinary	"obj\r.p3d"
	p_o:	:	IncludeBinary	"obj\O.p3d"
	p_w:	:	IncludeBinary	"obj\w.p3d"

	i_font:	:	IncludeBinary	"gfx\SkidRow_Font.png"	:	e_font:

	c_t:		:	Data.l	6, $FFFFFFFF, $FFBBAAAA, $FFBB99AA, $FF8855CC, $FF221133, $00221133	; top copper-line
	c_b:		:	Data.l	6, $00221133, $FF221133, $FF8855CC, $FFBB99AA, $FFBBAAAA, $FFFFFFFF	; bottom copper-line

	t_text:
	Data.s	"-*-*-*-*-*-*-*|"		+
	      	"SKID ROW|"				+
	      	"-*-*-*-*-*-*-*||"	+
	      	"PRESENTS||"			+
	      	"*BATTLE CHESS*|"		+
	      	"*II*|"					+
	      	"~"	+
	      	"**************|"		+
	      	"GREETINGS TO OUR|"	+
	      	"NEW MEMBER||"			+
	      	"HARVESTER OF|"		+
	      	"SORROW|"				+
	      	"**************|"		+
	      	"~"	+
	      	"CONTACT US AT:|"	+
	      	"P*O* BOX 10|"		+
	      	"4540 AMAY|"		+
	      	"BELGIUM|"			+
	      	"OR|"					+
	      	"SKID ROW|"			+
	      	"POSTE RESTANTE|"	+
	      	"8450 HAMMEL|"		+
	      	"DENMARK"			+
	      	"~"	+
	      	"OR CALL||"			+
	      	"DARK DUNGEON|"	+
	      	"49-4173-7832||"	+
	      	"LIGHT HOUSE|"		+
	      	"49-2125-92543|"	+
	      	"~"	+
	      	"ALCATRAZ|"			+
	      	"703-323-5997||"	+
	      	"AMIGA EAST|"		+
	      	"804-499-2266||"	+
	      	"INQUISITION|"		+
	      	"805-967-8833"		+
	      	"~"	+
	      	"MOTHERBOARD I|"	+
	      	"516-783-1450||"	+
	      	"CELTIC CIRCLE|"	+
	      	"314-781-5539|"	+
	      	"~"	+
	      	"C2D RETRO   ||"	+
	      	"BY   ||"			+
	      	"PEACE   |"

EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A-
; Executable = C2D_BattleChess_x86.exe
; DisableDebugger
; CompileSourceDirectory