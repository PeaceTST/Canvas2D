; C2D::Pixel3D / X-Out + FrontGrab + SCAL - Purebasic v6.30 (x86-64)
; Keys 1 - 4 for pixel-rotation

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D
	XIncludeFile	"C2D_Types.pbi"	; music constants #XMU_[Type]
	#IsC2D_Music	=	#XMU_SCA			;PT2, FT2, MOD
	#IsC2D_Bitmap	=	1
	#IsC2D_Pixel3D	=	1
	#IsC2D_Buffer	=	1	; need for fast background
	#IsC2D_File		=	1
	#IsC2D_SysFont	=	1
	#IsC2D_Stars3D	=	2
	#IsC2D_Clear	=	2	; fast clear
	#IsC2D_GdiPlus	=	1
	#IsC2D_Help		=	0
	XIncludeFile	"C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Global	IsRX=1, IsRY=1, IsRZ=1, IsR=1

Procedure	C2D_Init()
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Pixel3D / X-Out + FrontGrab + SCAL"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	; initialze c2d
	C2D::Init(#C2D_G, 8)
	
	C2D::Stars3DInit(80, 1, 0, 0, #C2D_W, 187 * #C2D_Z, 2.3)
	
	; font
	C2D::SysFontInit(0, "A500 2001", @"..\Data\Font\FON\A500 2001.fon", 0, 8)
	
	; logo
	C2D::BitmapInit(0, @"..\Data\Logo\X-Out_Logo.png")
	C2D::BitmapScale(0, #C2D_Z)
	
	; pixel3d
	C2D::Pixel3DInit(0, C2D::BitmapImage(0))
	C2D::Pixel3DAngle(0, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))
	
	; foreground image
	C2D::BitmapInit(0, @"..\Data\Back\X-Out_Ending.png")
	C2D::BitmapZoom(0, #C2D_W, #C2D_H - 12)
	
	; create fast foreground
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::BitmapDraw(0, 0, 0)
	C2D::BufferFrontGrab()
	StopDrawing()
	
	; no longer needed
	C2D::BitmapFree(0)
	
	; Play music?
	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicInit(#SCAL_PATH$)	; set default-path to SCAL_(x86-64).dll
		C2D::MusicPlay(@"..\Data\Music\MOD\Hoffman - X-Out Loading.mod")
	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	Protected	n, Time, t$
	Protected	rx.f, ry.f, rz.f
	
	Time	=	C2D::MA_Time()
	
	C2D::Stars3DDraw(0, -64 * #C2D_Z)
	C2D::BufferFrontDraw()

	If	IsRX	:	rx	=	Sin(Time * 0.000071) * 3.2	:	EndIf
	If	IsRY	:	ry	=	Cos(Time * 0.000073) * 3.5	:	EndIf
	If	IsRZ	:	rz	=	Cos(Time * 0.000072) * 1.9	:	EndIf
	
	If	IsRX	Or	IsRY	Or	IsRZ
		C2D::Pixel3DRotate(0, rx, ry, rz)
	EndIf

	n	=	C2D::Pixel3DDraw(0, 0, -12)
	
	t$	=	"Time:" + Str(C2D::MA_Time() - Time) + "  1 X:" + StrF(rx,2) + "  2 Y:" + StrF(ry,2) + "  3 Z:" + StrF(rz,2) + "  4 On/Off  Pixel:" + Str(n)
	
	C2D::SysFontSet(0)	:	DrawText(4, #C2D_H - 10, t$, $FF0000FF)

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
			Select	EventwParam()
				Case	#VK_1	:	IsRX	!	1
				Case	#VK_2	:	IsRY	!	1
				Case	#VK_3	:	IsRZ	!	1
				Case	#VK_4
					If	IsRX	Or	IsRY	Or	IsRZ
						IsR	=	0
					Else
						IsR	!	1
					EndIf
					IsRX	=	IsR
					IsRY	=	IsR
					IsRZ	=	IsR
					C2D::Pixel3DAngle(0, 0, 0, 0)
				Case	#VK_ESCAPE
					Break
			EndSelect
	EndSelect
ForEver

C2D::Free()
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = g
; Executable = ..\Executables\C2D_Pixel3D_X-Out_x86.exe
; DisableDebugger
; CompileSourceDirectory
; Compiler = PureBasic 6.30 - C Backend (Windows - x64)