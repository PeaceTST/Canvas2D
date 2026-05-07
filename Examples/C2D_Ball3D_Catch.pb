; C2D::Ball3D / CatchTheme + Merge - Purebasic v5.72

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	
	XIncludeFile	"..\Include\C2D_Types.pbi"

	#IsC2D_Music	=	#XMU_MCI	; ^^

	#IsC2D_Bitmap	=	0
	#IsC2D_GdiPlus	=	2			; 2 -> API-Decoder PNG only!

	#IsC2D_Ball3D	=	2			; 2 -> Merge, Explode, Starfield
	#IsC2D_File		=	2			; 2 -> Parent

	XIncludeFile	"..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0		; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Ball3D / Theme + Stars + Merge + MCI"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 10)

C2D::Quality(#PB_Image_Smooth)

C2D::Ball3DCatchTheme(?b3d_table)	; Remark ;)

C2D::Ball3DInit(0, ?b3d_object, 10 * #C2D_Z)
C2D::Ball3DStars(1, 640, 28, 7 * #C2D_Z, -1, 8.3)

C2D::Ball3DMerge(1, 0)	; Merge Stars to Enterprise (do not free Stars coz images used by Enterprise)

C2D::Ball3DAngle(0, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))

CompilerIf	IsC2D::#IsC2D_Music
	Music$	=	C2D::FileParent()	+	"Data\Music\MID\Startrek - Judgement Rites intro.mid"	;"Star Trek 25th Anniversary (title).xm"
	C2D::MusicPlay(@Music$)
CompilerEndIf

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D::Ball3DRotate(0, MA_GSin(C2D::C2D\Time * 0.02), MA_GCos(C2D::C2D\Time * 0.03), MA_GCos(C2D::C2D\Time * 0.025))
				C2D::Ball3DDraw(0, 0, 0, 230, 25)
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
	
	IncludePath	"..\Data\Object\B3D\"
	b3d_object:		:	IncludeBinary	"Enterprise.b3d"
	
	;IncludePath	"..\Data\Ball\Amiga\"
	;IncludePath	"..\Data\Ball\Test\"
	IncludePath	"..\Data\Ball\Pearl\"
	b0:	:	IncludeBinary	"0.png"	; Red
	b1:	:	IncludeBinary	"1.png"	; Orange
	b2:	:	IncludeBinary	"2.png"	; Yellow
	b3:	:	IncludeBinary	"3.png"	; Green
	b4:	:	IncludeBinary	"4.png"	; Blue
	b5:	:	IncludeBinary	"5.png"	; Magenta
	b6:	:	IncludeBinary	"6.png"	; White
	b7:	:	IncludeBinary	"7.png"	; Black
	b3d_table:
	Data.i	?b0, ?b1,
	      	?b1, ?b2,			
	      	?b2, ?b3,
	      	?b3, ?b4,
	      	?b4, ?b5,
	      	?b5, ?b6,
	      	?b6, ?b7,
	      	?b7, ?b3d_table

EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = 5
; Executable = ..\Executables\C2D_Ball3D_Catch_x86.exe
; CompileSourceDirectory