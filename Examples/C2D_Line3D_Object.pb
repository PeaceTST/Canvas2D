; C2D::Line3D / Object - Purebasic v5.70

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Line3D	=	1
	#IsC2D_Bitmap	=	0
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Line3D / Object"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 6, #White)

C2D::Line3DInit(0, ?l_3d, 10.0 * #C2D_Z)
C2D::Line3DAngle(0, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))
C2D::Line3DColor(0, $FF000000)

Define	ax.f	=	MA_GSinI(Random(C2D::#MAX_SIN))
Define	ay.f	=	MA_GCosI(Random(C2D::#MAX_SIN))
Define	az.f	=	MA_GCosI(Random(C2D::#MAX_SIN))

Repeat
	Select	WindowEvent()
			
		Case	#Null
			
			If	C2D::Start()

				C2D::Line3DRotate(0, ax, ay, az)
				C2D::Line3DDraw(0, 0, 0)
				
				C2D::Stop()

			EndIf

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf

	EndSelect
ForEver

C2D::Free()

DataSection
	l_3d:	:	IncludeBinary	"..\Data\Object\L3D\Amiga_Hand3D.l3d"
EndDataSection
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = -
; Executable = ..\Executables\C2D_Line3D_Object_x86.exe
; DisableDebugger
; CompileSourceDirectory