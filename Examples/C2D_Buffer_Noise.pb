; C2D::Buffer / Noise - Purebasic v6.30

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"	; musictypes #XMU_[Type]

	#IsC2D_Music		=	#XMU_SCA	;PT2

	#IsC2D_Bitmap		=	0
	#IsC2D_Clear		=	0

	#IsC2D_Line3D		=	1
	#IsC2D_Stars2D		=	1
	#IsC2D_Copper		=	1
	#IsC2D_FontRaw		=	1

	#IsC2D_Buffer		=	2	; -> Noise
	#IsC2D_File			=	1
	#IsC2D_ScrollText	=	2	; -> {Code,Param}
	#IsC2D_Bounce		=	1
	
	;#IsC2D_Help	=	1

	XIncludeFile	"C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#FONT_H	=	50		*	#C2D_Z	; FontHeight

; Bouncing scroller/copper
#Y_Top	=	0.76	*	(#C2D_H	-	#FONT_H)
#Y_Height=	1.2	*	#FONT_H
#Y_Speed	=	66		*	#C2D_Z

; TV-View
#SCR_Y	=	0.04	*	#C2D_H
#SCR_H	=	0.59	*	#C2D_H

Global	TimeObject

Procedure	Copper_Color(x, y, PenColor, PaperColor)
	If	PaperColor	&	#White
		ProcedureReturn	PenColor
	EndIf
	;ProcedureReturn	PaperColor
EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Buffer / Noise + SCAL"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G)

	C2D::Stars2DInit(90 * #C2D_Z, #C2D_Z, 0, #SCR_Y+1, #C2D_W, #SCR_H-3, 2.4 * #C2D_Z)

	C2D::FilePath("..\Data\Object\L3D\")	; Set path to objects
	C2D::Line3DInit(0, @"Canvas2D.l3d",				7.5	*	#C2D_Z)
	C2D::Line3DInit(1, @"CubeNumber_Fog.l3d",		6.6	*	#C2D_Z)
	C2D::Line3DInit(2, @"Xenon3D.l3d",				5.0	*	#C2D_Z)
	C2D::Line3DInit(3, @"Amiga_Hand3D_Fog.l3d",	9.0	*	#C2D_Z, 0.5)
	C2D::Line3DInit(4, @"Ball_Full.l3d",			17.0	*	#C2D_Z)
	C2D::Line3DInit(5, @"Rocket.l3d",				3.9	*	#C2D_Z, 1.3)
	C2D::Line3DInit(6, @"StarWars3D.l3d",			6.0	*	#C2D_Z)
	C2D::Line3DInit(7, @"Testaware_First.l3d",	7.0	*	#C2D_Z)
	C2D::Line3DFog(#PB_All, 2.3 / #C2D_Z)

	C2D::Quality(0)
	C2D::FontRawInit(0, @"..\Data\Font\Raw\16x34_Font0.rf")
	C2D::FontZoom(0, #FONT_H * 0.5, #FONT_H)
	C2D::FontGap(0, 1)
	C2D::ScrollTextInit(0, ?l_text)
	C2D::ScrollTextSpeed(0, #C2D_Z)

	C2D::CopperInit(0, 1, ?c_white, C2D::#C2F_Horizontal)
	
	; Background
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, #SCR_Y, #C2D_W, #SCR_H, $FF370000)
	C2D::CopperDraw(0, #SCR_Y-2)
	C2D::CopperDraw(0, #SCR_Y+#SCR_H-1)
	C2D::CopperDraw(0, #C2D_H - #SCR_Y+1)
	C2D::BufferBackGrab()
	C2D::BufferClear()	; start with black screen
	StopDrawing()
	
	C2D::CopperInit(0, #FONT_H, ?c_blit, C2D::#C2F_Horizontal)
	C2D::CopperBlitProc(@Copper_Color())
	
	; Bounce for scroller + copper
	C2D::BounceInit(0, #Y_Top-5*#C2D_Z, #Y_Height, #Y_Speed)

	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicInit(#SCAL_PATH$)	; set default-path to SCAL_(x86-64).dll
		C2D::MusicPlay(@"..\Data\Music\MOD\Front - 438.mod")
	CompilerEndIf

	TimeObject	=	C2D::MA_Time()	+	5000

EndProcedure
Procedure	C2D_Update()

	Protected	y
	Static	ID, TimeNoise, IsSinX, SinX.f, rx.f, ry.f, rz.f
	
	; *** Clear back with static buffered background
	C2D::BufferBackDraw()

	If	C2D::C2D\Time	<=	TimeNoise
		
		; *** TV-Noise
		C2D::BufferNoise(0, #SCR_Y, #C2D_W, #SCR_H)

	ElseIf	C2D::C2D\Time	<=	TimeObject
		
		; *** Rotate & draw clipped L3D object
		ClipOutput(0, #SCR_Y, #C2D_W, #SCR_H)
		C2D::Line3DRotate(ID, MA_GSin(C2D::C2D\Time * rx), MA_GCos(C2D::C2D\Time * ry), MA_GCos(C2D::C2D\Time * rz))
		C2D::Line3DDraw(ID, 0, (#SCR_Y - #SCR_H) * 0.31)
		UnclipOutput()
		
		; *** Wobble object?
		If	IsSinX
			C2D::BufferSinX(30 * #C2D_Z, #SCR_Y, #C2D_W - 60 * #C2D_Z, #SCR_H, 30 * #C2D_Z, 10 / #C2D_Z, SinX)
		EndIf
		
		; *** Draw 2d starfield
		C2D::Stars2DDraw()

	Else
		
		; *** Swap wobble on/off
		IsSinX	!	1
		SinX	=	0.1	*	Random(120,22)
		
		; *** Time of noise  & object
		TimeNoise	=	C2D::C2D\Time	+	Random(800,100)
		TimeObject	=	C2D::C2D\Time	+	Random(10000,5000)
		
		; *** Object rotation
		rx	=	0.0016	*	Random(100,19)
		ry	=	0.0017	*	Random(100,18)
		rz	=	0.0018	*	Random(100,17)

		; *** Random sort Line3D Object (0..7) & colorchange
		ID	+	1
		If	ID	>	7
			For	ID	=	0	To	7
				Swap	C2D::ID_Line3D\ID[Random(7)],C2D::ID_Line3D\ID[Random(7)]
			Next
			ID	=	0
		EndIf
		C2D::Line3DColor(ID, PeekL(?c_blit + SizeOf(Long) * Random(9, 1)))
		C2D::Line3DAngle(ID, C2D::MA_RMP(798),C2D::MA_RMP(798),C2D::MA_RMP(798))

		; *** Stars direction
		Select	Random(3)
			Case	0	:	C2D::Stars2DDirection(C2D::#C2F_Right)
			Case	1	:	C2D::Stars2DDirection(C2D::#C2F_Up)
			Case	2	:	C2D::Stars2DDirection(C2D::#C2F_Left)
			Case	3	:	C2D::Stars2DDirection(C2D::#C2F_Down)
		EndSelect

	EndIf
	
	; *** Bounce scroller + copper
	y	=	C2D::Bounce(0)

	C2D::ScrollTextDraw(0, y)
	C2D::CopperBlit(0, y, 0.8 * #C2D_Z)

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

	c_blit:	; scroller
	Data.l	7,
	      	$FF000000|#Red,
	      	$FF000000|#Magenta,
	      	$FF000000|#Blue,
	      	$FF000000|#Cyan,
	      	$FF000000|#Green,
	      	$FF000000|#Yellow,
	      	$FF000000|#Red,
	      	$FF000000|#White,
	      	$FF000000|C2D::#Orange
	
	c_white:	; lines
	Data.l	3,	$FF303030,$FFFFFFFF,$FF303030

	l_text:
	Data.s	"{4}THE KRICKEL KRAKEL BOUNCING COPPER WOBBLE NOISE - MEGADEMO ... "	+
	      	"HEHEHE ... OK OK OK ... WILL COMMIN'UP SHORT TO THIS FREAKY WORLD AND CODING THE ...{3}{5}CANVAS 2D V" + MA_XC2D() + "{5}{2,3000}"	+
	      	"SOURCE DEVELOPED WITH THE EXCELLENT ...{3}{5}PUREBASIC V" + MA_XPB() + "{5}{2,3000}"	+
	      	"MINDBREAK IN ...{3}{4,3}{5}3.{5}{2}{5}2.{5}{2}{5}1.{5}{2}{3,50}{4}{5}NO TV MAKES HEALTHY!{5}{2}{3}"	+	      	
				"KEWL NOISETRACKER-SONG BY ...{3}{5}FRONT{5}{2,3000}{5}438.MOD{5}{2,3000}PLAYED WITH THE ...{3}{5}SCAL_" + MA_XOS() + ".DLL{5}{2,3000}"	+
	         "SCROLLTEXT-EFFECTS WITH THE CONTROL-CODES ...{3}"	+
	         "IF YOU SEE A WRONG PERSPECTIVE OF OBJECTS - TRY WINKING EYES FOR BRAIN-FX ;){3}PEACE^TST{3}"	+
	      	"{4,3}AND FOREVER THE MARMOT GREETS ..."

EndDataSection
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A-
; Executable = ..\Executables\C2D_Buffer_Noise_x86.exe
; DisableDebugger
; CompileSourceDirectory