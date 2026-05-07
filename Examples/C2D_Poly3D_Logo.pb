; C2D::Poly3D / Logo + Brush + Gui - Purebasic v5.72

EnableExplicit

;*******************************************************************
; *** IsC2D the Init-Module, always needed! ************************
;*******************************************************************
IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D	; Defaults -> all on!
	XIncludeFile	"C2D_Types.pbi"
	#IsC2D_Brush	=	1
	#IsC2D_Poly3D	=	1
	#IsC2D_Copper	=	1
	#IsC2D_Gui		=	#Gui_GadgetButton|#Gui_GadgetTrack
	#IsC2D_Clear	=	0
	XIncludeFile	"C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;*******************************************************************

; Zoom-Factor (Or set in Compile)

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1
CompilerEndIf

; CanvasGadget, Width & Height
#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; zoomed width
#C2D_H	=	340	*	#C2D_Z	; zoomed height

#CLIP	=	40	*	#C2D_Z	; Top/Bottom borderheight
#W		=	64	; Buttonwidth
#H		=	24	; Buttonheight
#Y		=	#C2D_H	-	(#CLIP	+	#H)	/	2	; Y-Pos of Gadgets
#SIZE	=	160	*	#C2D_Z	; Rect-Size of backgroundbrush

Enumeration
	#G_SCALE	=	#C2D_G	+	1
	#G_ROTATE
	#G_LOGO
	#G_STAR
	#G_BACK
EndEnumeration

Global	IsRotate=1

Procedure	Checkbord(w, h, Color0.l, Color1.l)
	
	Protected	i, x, y
	
	h	=	w	; make square
	
	; background brush
	i	=	CreateImage(#PB_Any, w * 2, h * 2, 32, $FF000000|Color0)
	
	StartDrawing(ImageOutput(i))
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	
	While	x	<=	w
		While	y	<=	h
			
			If	x	<>	y
			;If	(x	=	w	And	y	=	0)	Or	(x	=	0	And	y	=	h)
				Box(x, y, w, h, $FF000000|Color1)
			EndIf
			
			; highleight left/top
			FrontColor($80FFFFFF)	:	LineXY(x,   y,   x+w,   y)		:	LineXY(x,   y,   x,   y+h)
			FrontColor($60FFFFFF)	:	LineXY(x+1, y+1, x+w-1, y+1)	:	LineXY(x+1, y+1, x+1, y+h-1)
			
			; darken right/bottom
			FrontColor($60000000)	:	LineXY(x,	y+h-1, x+w-1, y+h-1)	:	LineXY(x+w-1, y, x+w-1, y+h)
			FrontColor($40000000)	:	LineXY(x+1,	y+h-2, x+w-1, y+h-2)	:	LineXY(x+w-2, y, x+w-2, y+h)
			
			y	+	h
			
		Wend
		
		x	+	w
		y	=	#Null
		
	Wend
	
	StopDrawing()
	
	C2D::BrushInit(0, i, 0, #CLIP, #C2D_W, #C2D_H - 2 * #CLIP)
	FreeImage(i)
	
EndProcedure

Procedure	Poly_Create(*Memory)
	
	Protected	z	=	C2D::GuiGetState(#G_SCALE)

	; init center-polygon (once)
	C2D::Poly3DInit(0, *Memory)	:	C2D::Poly3DScale(0, z)	:	C2D::Poly3DBrush(0, C2D::CopperImage(0))
	
	; init x/y-rotate-polygon
	C2D::Poly3DInit(1, *Memory, 0, #Black)	:	C2D::Poly3DScale(1, z)	:	C2D::Poly3DBrush(1, C2D::CopperImage(1))
	C2D::Poly3DInit(2, *Memory, 0, #Black)	:	C2D::Poly3DScale(2, z)	:	C2D::Poly3DBrush(2, C2D::CopperImage(2))

	; polygon red/white & line black
	C2D::Poly3DInit(3, *Memory, #Red, #White)	:	C2D::Poly3DScale(3, z)
	
	; borders for all polygons (same as brush)
	C2D::Poly3DClip(#PB_All, 0, #CLIP, #C2D_W, #C2D_H - 2 * #CLIP)

EndProcedure
Procedure	Poly_Zoom(z)
	C2D::Poly3DScale(0, z)
	C2D::Poly3DScale(1, z)
	C2D::Poly3DScale(2, z)
	C2D::Poly3DScale(3, z)
EndProcedure

Procedure	C2D_Init()
	
	Protected	*Memory, x=(#C2D_W - 6 * #W) * 0.5
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Poly3D / Logo + Brush + Gui"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H, #PB_Canvas_Container)
	C2D::Init(#C2D_G, 8, $BAAAAA)

	C2D::GuiFrame(C2D::#Gui_FrameFine)
	C2D::GuiButtonGadget(#G_BACK,		x,						#Y, #W, #H, "Back")
	C2D::GuiButtonGadget(#G_LOGO,		C2D::GuiPosX(),	#Y, #W, #H, "Logo",		C2D::#Gui_FlagToggle)
	C2D::GuiButtonGadget(#G_STAR,		C2D::GuiPosX(),	#Y, #W, #H, "Star",		C2D::#Gui_FlagToggle)
	C2D::GuiButtonGadget(#G_ROTATE,	C2D::GuiPosX(),	#Y, #W, #H, "Rotate",	C2D::#Gui_FlagToggle)
	
	C2D::GuiCopper(?c_s, 1)
	C2D::GuiFrame(C2D::#Gui_FrameRised)
	C2D::GuiTrackGadget(#G_SCALE, C2D::GuiPosX(), #Y, #W * 2, #H, 0, 10, C2D::#Gui_FlagNumber)
	
	CloseGadgetList()	; Canvas Container
	
	C2D::GuiSetState(#G_LOGO,	1)
	C2D::GuiSetState(#G_ROTATE,1)
	
	Checkbord(Random(#SIZE, 16), Random(#SIZE, 16), Random(#White), Random(#White))

	C2D::CopperInit(0, #C2D_H - 2 * #CLIP, ?c_y)	; copper yellow
	C2D::CopperInit(1, 128 * #C2D_Z, ?c_p)			; copper psygnosis
	C2D::CopperInit(2, 128 * #C2D_Z, ?c_g)			; copper green

EndProcedure
Procedure	C2D_Update()
	
	Static	r.f = $F, rn.f = 1.25
	Static	g.f = $C, gn.f = 1.34
	Static	b.f = $7, bn.f = 1.43

 	Protected	x.f	=	Sin(C2D::C2D\Time * 0.0007)
 	Protected	y.f	=	Cos(C2D::C2D\Time * 0.0010)
 	
 	C2D::BrushMove(0, x, y)	:	C2D::BrushDraw(0)
 	
 	x	*	200
 	y	*	80
	
	If	IsRotate
		C2D::Poly3DRotate(0, 2.3, 2.1, -1.3)
		C2D::Poly3DRotate(1, 7, 0, 0)
		C2D::Poly3DRotate(2, 0, 7, 0)
		C2D::Poly3DRotate(3, 0, 0, 5)
	EndIf
	
	C2D::Poly3DBrushMove(0, 0, -3)	:	C2D::Poly3DDraw(0)
	
	C2D::Poly3DBrushMove(1, 0, 0.8)	:	C2D::Poly3DDraw(1, -x, y)
	C2D::Poly3DBrushMove(2, 0,-0.8)	:	C2D::Poly3DDraw(2, x, -y)

	C2D::Poly3DDraw(3, x, y)
	C2D::Poly3DDrawLine(3, -x, -y, RGB(r, g, b))	; blink

	If	r	<	2	Or	r	>	253	:	rn	*	-1	:	EndIf
	If	g	<	2	Or	g	>	253	:	gn	*	-1	:	EndIf
	If	b	<	2	Or	b	>	253	:	bn	*	-1	:	EndIf
	
	r	+	rn
	g	+	gn
	b	+	bn

EndProcedure

C2D_Init()	; Must always called before Update

Define	z, z_star=6, z_logo=2, Gadget

C2D::GuiSetState(#G_SCALE, z_logo)
Poly_Create(?p_tst)

Repeat
	Select	WindowEvent()
			
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf

		Case	#PB_Event_Gadget
			Gadget	=	EventGadget()
			Select	C2D::GuiEvent(Gadget)	; check C2D-Gadgets
				Case	#G_BACK
					Checkbord(Random(#SIZE, 16), Random(#SIZE, 16), Random(#White), Random(#White))
				Case	#G_LOGO
					C2D::GuiSetState(#G_STAR, 0)
					C2D::GuiSetState(#G_LOGO, 1)
					C2D::GuiSetState(#G_SCALE, z_logo)
					Poly_Create(?p_tst)
				Case	#G_STAR
					C2D::GuiSetState(#G_LOGO, 0)
					C2D::GuiSetState(#G_STAR, 1)
					C2D::GuiSetState(#G_SCALE, z_star)
					Poly_Create(?p_star)
				Case	#G_ROTATE
					IsRotate	=	C2D::GuiGetState(#G_ROTATE)
				Case	#G_SCALE
					z	=	C2D::GuiGetState(#G_SCALE)
					If	C2D::GuiGetState(#G_LOGO)
						z_logo	=	z
					Else
						z_star	=	z
					EndIf
					Poly_Zoom(z)
			EndSelect

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE	:	Break
			EndSelect

	EndSelect
ForEver

C2D::Free()

DataSection
	
	; Copper
	c_g:	:	Data.l	3, $FF000000, $FF00FF00, $FF000000
	c_p:	:	Data.l	4, $FFFF00FF, $FFFF0000, $FFFFFFFF, $FFFF00FF
	c_s:	:	Data.l	3, $FF00FF00, $FF00FFFF, $FF0000FF
	c_y:	:	Data.l	3, $FF00FFFF, $FF0000FF, $FF00FFFF
	
	p_tst:	; Polygon-TST Logo: 33
	Data.l	C2D::#ID_P3D0, 132
	Data.b	-31,-13,-4,-13,-4,-13,-12,-5,-12,-5,-4,-5,-4,-5,-7,-8,
				-7,-8,-3,-12,-3,-12,1,-12,1,-12,2,-13,2,-13,7,-8,
				7,-8,-2,-8,-2,-8,1,-5,1,-5,12,-5,12,-5,4,-13,
				4,-13,31,-13,31,-13,26,-8,26,-8,16,-8,16,-8,30,6,
				30,6,30,13,30,13,14,-3,14,-3,7,-3,7,-3,17,7,
				17,7,17,11,17,11,13,13,13,13,-23,13,-23,13,-10,0,
				-10,0,-10,7,-10,7,8,7,8,7,-2,-3,-2,-3,-14,-3,
				-14,-3,-30,13,-30,13,-30,6,-30,6,-16,-8,-16,-8,-26,-8,
				-26,-8,-31,-13
	
	p_star:	; Plygon-Vertices: 10
	Data.l	C2D::#ID_P3D0, 40
	Data.b	0,-7, 2,-2,	 2,-2, 8,-2,	 8,-2, 3, 1,	 3, 1, 5, 6,	 5, 6,0, 3,
				0, 3,-5, 6,	-5, 6,-3, 1,	-3, 1,-8,-2,	-8,-2,-2,-2,	-2,-2,0,-7

EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = B9
; Executable = ..\Executables\C2D_Poly3D_Logo_x86.exe
; DisableDebugger
; CompileSourceDirectory