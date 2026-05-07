; C2D::StarsZ3D / Simple - Purebasic v6.01

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	
	;XIncludeFile	"..\Include\C2D_Types.pbi"
	;#IsC2D_Music	=	#XMU_TPT
	
	#IsC2D_StarsZ3D=	2	; 2 = sort stars by alpha
	
	#IsC2D_Anim		=	1
	#IsC2D_Clear	=	0
	#IsC2D_GdiPlus	=	1
	#IsC2D_File		=	1
	#IsC2D_Buffer	=	1
	#IsC2D_Copper	=	1
	
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#S_W	=	0	*	#C2D_Z
#S_H	=	40	*	#C2D_Z

Global	IsAnim=1, IsRotate=1, x=1, y=1, z=1, EventID, Ball, Path$="Pearl"

Procedure	C2D_StarsZ(Mode)
	
	Protected	*Memory, s

	If	Mode	>=	1	And	Mode	<=	8
		Mode	-	1	; Balls 0 - 7
		*Memory	=	C2D::FileLoad("..\Data\Ball\" + Path$ + "\" + Str(Mode) + ".png")
	ElseIf	Mode	=	9
		*Memory	=	C2D::FileLoad("..\Data\Misc\StarBig.png")
		;*Memory	=	C2D::FileLoad("..\Data\Misc\SnowFlake.png")
	Else
		Mode	=	-1	; default
	EndIf
	
	s	=	Random(64, 5)	*	#C2D_Z

	Select	Mode
		Case	0	To	9

			C2D::GdipCatch(0, *Memory, MemorySize(*Memory))
			C2D::StarsZ3DInit(400, #S_W, #S_H, #C2D_W - #S_W * 2, #C2D_H - #S_H * 2, s, 0)
			
			FreeImage(0)

		Default
			
			C2D::StarsZ3DInit(400, #S_W, #S_H, #C2D_W - #S_W * 2, #C2D_H - #S_H * 2, s)

	EndSelect

EndProcedure

Procedure	C2D_Init()
	
	Protected	*Memory
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("StarsR3D / Simple - Press Spacebar | F1-F9 | 0-9 | a, f, x, y, z"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 12)
	C2D::Quality(#PB_Image_Raw)
	
	; logo-anim
	*Memory	=	C2D::FileLoad("..\Data\Anim\Anim_TRS_17x3_51.png")
	C2D::GdipCatch(0, *Memory, MemorySize(*Memory))
	C2D::AnimInit(0, 0, 17, 3)
	C2D::AnimScale(0, #C2D_Z)
	C2D::AnimPingPong(0)
	C2D::AnimDelay(0, 64)
	C2D::AnimDelay(0, 1800, 0) 
	C2D::AnimDelay(0, 1800, C2D::AnimCount(0)-1)
	C2D::AnimFrame(0, 0)

	; 3dz-starfield
	C2D::Quality(#PB_Image_Smooth)
	C2D_StarsZ(Random(10)-1)
	
	; copper-background
	C2D::CopperInit(0, #C2D_H - #S_H * 2, ?c_back)
	
	; fast background
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::CopperDraw(0, #S_H)
	C2D::BufferBackGrab()
	C2D::BufferClear()	; start with black screen
	StopDrawing()
	
	C2D::CopperFree(0)
	
	; music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(@"..\Data\Music\MOD\Estrayk - Mirror Intro.mod")
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Protected	xr.f	=	(MA_GCos(C2D::C2D\Time * 0.071) * 18 * #C2D_Z)	*	x
	Protected	yr.f	=	(MA_GCos(C2D::C2D\Time * 0.083) * 14 * #C2D_Z)	*	y
	Protected	zr.f	=	(MA_GCos(C2D::C2D\Time * 0.115) * 0.15)			*	z

	C2D::BufferBackDraw()
	
	If	IsRotate
		C2D::StarsZ3DDraw(xr, yr, zr)
	Else
		C2D::StarsZ3DDraw(0, 0, 0)
	EndIf
	
	If	IsAnim
		C2D::AnimDraw(0, (#C2D_W - C2D::AnimW(0)) * 0.5, (#C2D_H - C2D::AnimH(0)) * 0.5)
	EndIf

; 	Protected	x
; 	For	i	=	0	To	15
; 		DrawAlphaImage(C2D::RS_StarZ3DField\hImage[i], x , 0, 255)
; 		x	+	ImageWidth(C2D::RS_StarZ3DField\i[i])
; 	Next
	
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
			
			EventID	=	EventwParam()
			
			Select	EventID
					
				Case	#VK_A	:	IsAnim	!	1
					
				Case	#VK_SPACE	:	IsRotate	!	1
				Case	#VK_F			:	C2D::RS_StarZ3DField\IsFade	!	1
				Case	#VK_X			:	x	!	1
				Case	#VK_Y			:	y	!	1
				Case	#VK_Z			:	z	!	1
					
				Case	#VK_0 To #VK_9
					Ball = EventID - #VK_0
					C2D_StarsZ(Ball)
					
				Case	#VK_F1	To	#VK_F9
					Path$	=	PeekS(PeekI(?p + (EventID - #VK_F1) * SizeOf(Integer)))
					C2D_StarsZ(Ball)
					
				Case	#VK_ESCAPE
					Break
					
			EndSelect
			
	EndSelect
ForEver

C2D::Free()

DataSection
	
	c_back:	:	Data.l	3, $FFC00000, $FF010101, $FFA000A0
	
	p:		:	Data.i	?p1, ?p2, ?p3, ?p4, ?p5, ?p6, ?p7, ?p8, ?p9
	p1:	:	Data.s	"Amiga"
	p2:	:	Data.s	"Bubble"
	p3:	:	Data.s	"Chrom"
	p4:	:	Data.s	"Cube"
	p5:	:	Data.s	"Gray"
	p6:	:	Data.s	"Pearl"
	p7:	:	Data.s	"Plastic"
	p8:	:	Data.s	"Solar"
	p9:	:	Data.s	"Test"
	
EndDataSection
; IDE Options = PureBasic 6.01 LTS (Windows - x86)
; Folding = A-
; Executable = ..\Executables\C2D_StarsZ3D_Simple_x86.exe
; CompileSourceDirectory