; C2D::Ball3D / Explode - Purebasic v6.30

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D
	XIncludeFile	"C2D_Types.pbi"
	#IsC2D_Music		=	#XMU_TPT
	#IsC2D_Fps			=	0	; 1 = shows fps top/left
	#IsC2D_Clear		=	0	; 0 = do nothing, 1 = ColorClear, 2 = FastClear (black)!
	#IsC2D_Buffer		=	1	; used for fast draw of background
	#IsC2D_Copper		=	1
	#IsC2D_Stars3D		=	1
	#IsC2D_PageText	=	2	; 2 = fontchange
	#IsC2D_ScrollText	=	2	; 2 = control-codes
	#IsC2D_Text			=	1
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_Topaz		=	1
	#IsC2D_Ball3D		=	2	; explode
	#IsC2D_Help			=	0
	XIncludeFile	"C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_S	=	8	; Speed
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#COP_H	=	50	*	#C2D_Z
#FNT_W	=	4	*	#C2D_Z
#FNT_H	=	5	*	#C2D_Z

#B3D_MAX	=	10
#B3D_X	=	#C2D_W * 0.25

#A_X	=	#C2D_S	/	5.09
#A_Y	=	-#C2D_S	/	5.57
#A_Z	=	#C2D_S	/	10.62

#T_TI$	=	"CANVAS 2D"
#T_LEN	=	9	; = Len(#T_TI$)

Global	B3D_0	=	Random(#B3D_MAX - 1)	; start with random object
Global	B3D_1	=	B3D_0	+	1				; next object (fade with)
Global	PageID

Procedure	C2D_Init()
	
	Protected	i

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Ball3D / Explode + TPT"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, #C2D_S)

	; *** top / bottom copperbars ***
	C2D::CopperInit(0, #COP_H, ?c_0)
	C2D::CopperInit(1, #COP_H, ?c_1)

	; *** font / pagetext / scroller ***
	C2D::FontRawInit(0, #PB_Default, 0, #C2D_Z, 2 * #C2D_Z)
	C2D::FontCopper(0, ?c_t0)
	C2D::FontGap(0, 0, 4 * #C2D_Z)

	C2D::FontRawInit(1, #PB_Default, 0, #C2D_Z, 2 * #C2D_Z)
	C2D::FontCopper(1, ?c_t1)
	C2D::FontGap(1, 0, 4 * #C2D_Z)

	C2D::FontRawInit(2, #PB_Default, 0, #C2D_Z, 2 * #C2D_Z)
	C2D::FontCopper(2, ?c_t2)
	C2D::FontGap(2, 0, 4 * #C2D_Z)
	
	; *** pagetext
	C2D::PageTextInit(?t_text, 16 * #C2D_Z, #C2D_H * 0.5 - C2D::FontH(0) * 2.7, #C2D_W * 0.46, C2D::FontH(0) * 6, C2D::#C2F_Center)
	;C2D::PageTextColor($30AFFFAF)
	;
	C2D::PageTextWait(1100 * #C2D_S)
	C2D::PageTextEffect(1, C2D::#PFX_Random, #C2D_S, 6 * #C2D_S)
	C2D::PageTextEffect(0, C2D::#PFX_Random, #C2D_S, 6 * #C2D_S)
	;
	PageID	=	C2D::PageTextID()	; get/set actual page

	; *** ball3d objects ***
	C2D::Quality(#PB_Image_Smooth)

	i	=	0	:	C2D::Ball3DInit(i, ?b3d_cube,			16	* #C2D_Z)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_tst,			4	* #C2D_Z)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_airplane,	13	* #C2D_Z)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_rotor,		13	* #C2D_Z)	:	C2D::Ball3DSpin(i, #C2D_S * 0.1)	; % spin-speed
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_bigman,		10	* #C2D_Z)	:	C2D::Ball3DSpin(i, #C2D_S * 0.1)	; % spin-speed
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_snowman,		10	* #C2D_Z)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_boeing,		9	* #C2D_Z)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_enterprise,	7	* #C2D_Z)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_cross,		12	* #C2D_Z)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_cubespin,	9	* #C2D_Z)	:	C2D::Ball3DSpin(i,-#C2D_S * 0.12)	; % spin-speed
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_circulation,9	* #C2D_Z)	:	C2D::Ball3DSpin(i, #C2D_S * 0.12)	; % spin-speed

	; *** stars 3d ***
	C2D::Stars3DSpread(1200)
	C2D::Stars3DInit(150 * #C2D_Z, 2, 0, #COP_H - 3, #C2D_W, #C2D_H - #COP_H * 2 + 6, 3.8)
	
	; font for header-title
	C2D::FontRawInit(3, #PB_Default, 0, #FNT_W, #FNT_H)
	C2D::FontCopper(3, ?c_t2)
	C2D::FontShadow(3, 2 * #C2D_Z, 2 * #C2D_Z)

	; *** clear canvas with static background ***
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::CopperDraw(0, 0)
	C2D::CopperDraw(1, #C2D_H - #COP_H)
	C2D::TextStringDraw((#C2D_W - #T_LEN * #FNT_W * 8) * 0.5, (#COP_H - #FNT_H * 7) * 0.5, #T_TI$) ; title
	C2D::BufferBackGrab()	; at last!
	C2D::BufferClear()		; black screen
	StopDrawing()

	; scroller
	C2D::FontRawInit(3, #PB_Default, 0, #FNT_W, #FNT_H)
	C2D::FontCopper(3, ?c_t1)
	C2D::FontShadow(3, 2 * #C2D_Z, 2 * #C2D_Z)
	C2D::ScrollTextInit(0, ?t_scrl)
	C2D::ScrollTextSpeed(0,	2.0 * #C2D_Z)

	C2D::CopperFree(#PB_All)

	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?pt2_music, ?pt2_end)
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Static	IsFade, Alpha.f=255

	; clear buffer & draw static background
	C2D::BufferBackDraw()

	; wobble header
	C2D::BufferSinX((#C2D_W - #T_LEN * #FNT_W * 10) * 0.5, 0, #T_LEN * #FNT_W * 10, #COP_H, 12 * #C2D_Z, (30.0 / #C2D_Z) * MA_GCosI(C2D::C2D\Count), 16.0)
	
	; scroller
	C2D::ScrollTextDraw(0, #C2D_H - #COP_H + (#COP_H - #FNT_H * 6.5) * 0.5)

	C2D::Stars3DDraw(MA_GCosI(C2D::C2D\Count) * #C2D_W * 0.3)

	If	IsFade	And	Alpha	<	255
		Alpha	+	0.15 * #C2D_S
		If	Alpha	=>	255
			IsFade	=	#False	:	Alpha		=	255
			C2D::Ball3DAngle(B3D_0, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))	; random angles & reset explode
		Else
			C2D::Ball3DRotate(B3D_0, #A_X, #A_Y, #A_Z)
			C2D::Ball3DDraw(B3D_0, #B3D_X, 0, 255 - Alpha)
		EndIf
	EndIf

	C2D::Ball3DRotate(B3D_1, #A_X, #A_Y, #A_Z)
	C2D::Ball3DDraw(B3D_1, #B3D_X, 0, Alpha)

	; new page? -> next object
	If	C2D::PageTextDraw()	<>	PageID

		PageID	=	C2D::PageTextID()

		B3D_0	=	B3D_1

		B3D_1	+	1	:	If	B3D_1	>	#B3D_MAX	:	B3D_1	=	0	:	EndIf

		C2D::Ball3DExplode(B3D_0, 1)	; factor = 1 or 2 only!
		C2D::Ball3DExplode(B3D_1, 2)

		IsFade	=	#True
		Alpha		=	0

	EndIf

	CompilerIf	IsC2D::#IsC2D_Fps
		DrawText(0, 0, Str(C2D::C2D\FPS), $FFFFFFFF, 0)
	CompilerEndIf

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
		pt2_music:	:	IncludeBinary	"..\Data\Music\MOD\Hri$ - Mozarto.mod"	:	pt2_end:
	CompilerEndIf

	IncludePath	"..\Data\Object\B3D\"
	b3d_cube:			:	IncludeBinary	"CubeNumber.b3d"
	b3d_snowman:		:	IncludeBinary	"Snowman.b3d"
	b3d_cross:			:	IncludeBinary	"Cross.b3d"
	b3d_cubespin:		:	IncludeBinary	"CubeSpinRed.b3d"
	b3d_tst:				:	IncludeBinary	"TST_Logo.b3d"
	b3d_airplane:		:	IncludeBinary	"AirplanePropellar.b3d"
	b3d_bigman:			:	IncludeBinary	"BigmanRotate.b3d"
	b3d_rotor:			:	IncludeBinary	"RotorPilot.b3d"
	b3d_enterprise:	:	IncludeBinary	"Enterprise.b3d"
	b3d_circulation:	:	IncludeBinary	"Circulation.b3d"
	b3d_boeing:			:	IncludeBinary	"Boeing.b3d"

	c_0:	:	Data.l	3,	$FF000000,	$FF9EB7CD,	$FF000000
	c_1:	:	Data.l	3,	$FF000000,	$FFAACD66,	$FF000000
	c_t0:	:	Data.l	3,	$50FFFFFF,	$FFFFFFFF,	$50FFFFFF
	c_t1:	:	Data.l	3,	$50D3EEB9,	$FFD3EEB9,	$50D3EEB9
	c_t2:	:	Data.l	3,	$50B9D3EE,	$FFB9D3EE,	$50B9D3EE
	
	t_scrl:	:	Data.s	"EXAMPLE USING THE TINY C2D MODULE V" + MA_XC2D() +
	       	 	      	" CODED IN PUREBASIC V" + MA_XPB() + " (" + MA_XOS() + ")"	+
	       	 	      	"{3,100}FOR MORE STUFF VISIT US AT"	+
	       	 	      	"{3,100}TESTAWARE.WORDPRESS.COM"
	
	; use #LF$ or "|" for next line & "~" for new page
	t_text:	:	Data.s	"C2D {1,1}BALL3D EXPLODE{1} EXAMPLE"	+
	       	 	      	"~"	+
	       	 	      	"USING THE {1,2}CANVAS 2D V" + MA_XC2D()	+	"{1} MODULE|"	+
	       	 	      	"ALL OBJECTS CREATED WITH THE|"				+
	       	 	      	"{1,1}BALL3D EDITOR{1} INCLUDED IN THE|"	+
	       	 	      	"C2D {1,1}TOOLS{1} PACKAGE"					+
	       	 	      	"~"	+
	       	 	      	"CHANGE BALL3D OBJECT BY USING|"			+
	       	 	      	"THE {1,1}PAGETEXT{1} MODULE AND ITS|"	+
	       	 	      	"{1,1}PAGETEXTDRAW(){1} COMMAND"			+
	       	 	      	"~"	+
	       	 	      	"THAT WAS JUST SOME TEXT||"			+
	       	 	      	"PLEASE VISIT US AT:|"					+
	       	 	      	"{1,2}TESTAWARE.WORDPRESS.COM{1}||"	+
	       	 	      	"PEACE 2K21"								+
	       	 	      	"~"	+
	       	 	      	"HERE WE GO AGAIN..."
EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A+
; Executable = ..\Executables\C2D_Ball3D_Explode_x86.exe
; CompileSourceDirectory