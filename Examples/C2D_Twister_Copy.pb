; C2D::Twister / Copy - Purebasic v5.72 (x86-64)

EnableExplicit

;***************************************************
; *** IsC2D the MUST Init-Module, always needed! ***
;***************************************************
IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"
	;#IsC2D_Music	=	#XMU_SCA	; music?
	
	#IsC2D_Clear	=	2
	#IsC2D_Twister	=	1

	;#IsC2D_Help	=	1
	
	XIncludeFile	"C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;***************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1
CompilerEndIf

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Zoomed width
#C2D_H	=	340	*	#C2D_Z	; Zoomed height

Procedure	_Colorize(ID)

	C2D::TwisterColor(ID,
	                  RGBA(Random(255),Random(255),Random(255),255),
	                  RGBA(Random(255),Random(255),Random(255),255),
	                  RGBA(Random(255),Random(255),Random(255),255),
	                  RGBA(Random(255),Random(255),Random(255),255))
	
	C2D::TwisterAlpha(ID, Random(255))
	C2D::TwisterFX(ID, 0.15 * Random(20,1), (2.3 + Sin(C2D::C2D\Time * 0.0018)))

EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Twister / Copy - Press Spacebar"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)

	CompilerIf	IsC2D::#IsC2D_Music

		Protected	Music$	=	"..\Data\Music\MOD\Hollywood - Trance.mod"

		CompilerSelect	IsC2D::#IsC2D_Music

			CompilerCase	IsC2D::#XMU_AMP
				If	C2D::MusicInit()			; <- Set path to AmpMaster or default -> C:\Users\Public\Documents\AmpMaster\
					C2D::MusicPlay(@Music$)	; <- Ptr to filename
				EndIf

			CompilerCase	IsC2D::#XMU_SCA
				C2D::MusicInit("..\Tools\SCAL\")	; <- Set default-path to scal_x86/x64.dll
				C2D::MusicPlay(@Music$)

			CompilerDefault
				C2D::MusicPlay(@Music$, 0, 0)

		CompilerEndSelect

	CompilerEndIf
	
	C2D::TwisterInit(0, 32 * #C2D_Z, 1.7, 2.4 * #C2D_Z)
	C2D::TwisterInit(1, 28 * #C2D_Z, 1.5, 2.8 * #C2D_Z, C2D::#C2F_HORIZONTAL)

EndProcedure
Procedure	C2D_Update()

	C2D::TwisterDraw(0, #C2D_W * 0.50, #C2D_H/2)
	C2D::TwisterDraw(1, #C2D_W/2, #C2D_H * 0.50)
	
	C2D::TwisterCopy(0, #C2D_W * 0.20, #C2D_H/2)
	C2D::TwisterCopy(0, #C2D_W * 0.80, #C2D_H/2)
	
	C2D::TwisterCopy(1, #C2D_W/2, #C2D_H * 0.20)
	C2D::TwisterCopy(1, #C2D_W/2, #C2D_H * 0.80)

EndProcedure

C2D_Init()	; Must always called before Update

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE
					Break
				Case	#VK_SPACE
					_Colorize(0)
					_Colorize(1)
			EndSelect
		Case	#PB_Event_CloseWindow
			Break
	EndSelect
ForEver

C2D::Free()
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; Folding = A+
; Executable = ..\Executables\C2D_Twister_Copy_x86.exe
; CompileSourceDirectory