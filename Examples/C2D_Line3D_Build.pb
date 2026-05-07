; C2D::Line3D / Build - Purebasic v6.02 (x86-64)

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_File		=	1
	#IsC2D_Line3D	=	2
	#IsC2D_Clear	=	2
	#IsC2D_Bitmap	=	0
	#IsC2D_Mode		=	0
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

Enumeration
	#ID_CUBE
	#ID_DISKETTE
	#ID_PARANOIMIA
	#ID_PYRAMID
	#ID_QUESTION
	#ID_SEB
	#ID_STARWARS
	#ID_TESTAWARE
	#ID_TORUS
	#ID_WILDCOPPER
EndEnumeration

#ID_MIN	=	0
#ID_MAX	=	#PB_Compiler_EnumerationValue	-	1
#ID_Z		=	264.0	*	#C2D_Z

#TIME_WAIT	=	10000	; ms

Define	ID, IsNext, Time, z.f
Define	ax.f	=	C2D::MA_RMP(798)	*	0.0025
Define	ay.f	=	C2D::MA_RMP(798)	*	0.0028
Define	az.f	=	C2D::MA_RMP(798)	*	0.0031

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Line3D / Build"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 10)

C2D::FilePath("..\Data\Object\L3D\")	; default path

C2D::Line3DInit(#ID_CUBE,			@"Cube.l3d");,				60.0)
C2D::Line3DInit(#ID_DISKETTE,		@"Amiga_Hand3D.l3d");,		11.0)
C2D::Line3DInit(#ID_PARANOIMIA,	@"Paranoimia.l3d");,		11.3)
C2D::Line3DInit(#ID_PYRAMID,		@"Worldmap.l3d");,			60.0)
C2D::Line3DInit(#ID_QUESTION,		@"Question_Double.l3d");,	17.0)
C2D::Line3DInit(#ID_SEB,			@"Skull&Bones.l3d");,					11.0)
C2D::Line3DInit(#ID_STARWARS,		@"StarWars.l3d");,			8.0)
C2D::Line3DInit(#ID_TESTAWARE,	@"Testaware.l3d");,			10.0)
C2D::Line3DInit(#ID_TORUS,			@"Flugzeug.l3d");,				20.4)
C2D::Line3DInit(#ID_WILDCOPPER,	@"WildCopper.l3d");,		8.0)

For	ID	=	#ID_MIN	To	#ID_MAX
	C2D::Line3DAngle(ID, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))
Next

ID		=	Random(#ID_MAX)
z		=	C2D::Line3DSquare(ID, #ID_Z)
Time	=	C2D::MA_TIME()	+	#TIME_WAIT	>>	1

Repeat
	Select	WindowEvent()

		Case	#Null

			If	C2D::Start()

				C2D::Line3DRotate(ID, ax, ay, az)
				C2D::Line3DDraw(ID, 0, 0, z, z)

				If	C2D::C2D\Time	>=	Time	And	IsNext	=	#False

					IsNext	=	#True

					C2D::Line3DBuild(ID, -1, 60)

				ElseIf	IsNext	And	C2D::Line3DIsBuild(ID)	=	#Null

					IsNext	=	#False
					
					ID	+	1	:	If	ID	>	#ID_MAX	:	ID	=	#ID_MIN	:	EndIf

					C2D::Line3DBuild(ID, 1, 60)
					z	=	C2D::Line3DSquare(ID, #ID_Z)

					ax	=	C2D::MA_RMP(798)	*	0.0045
					ay	=	C2D::MA_RMP(798)	*	0.0048
					az	=	C2D::MA_RMP(798)	*	0.0061

					Time	=	C2D::MA_TIME()	+	#TIME_WAIT

				EndIf

				C2D::Stop()

			EndIf

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE	:	Break
			EndSelect

	EndSelect
ForEver

C2D::Free()
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; Folding = 5
; Executable = ..\Executables\C2D_Line3D_Build_x86.exe
; DisableDebugger
; CompileSourceDirectory