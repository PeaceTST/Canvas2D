; C2D::DefaultExample how to initialize CD2_Module

;***************************************************
; *** IsC2D the MUST Init-Module, always needed! ***
;***************************************************
IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D	; Defaults -> all on!

	XIncludeFile	"C2D_Types.pbi"	; Music, Gui, XUnPack predefined #Types

	; #IsC2D_[?] -> first set your switches ...
	#IsC2D_Music	=	#XMU_SCA
	
	; ... than include set of all (unused) default switches
	XIncludeFile	"C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;***************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1
CompilerEndIf

; CanvasGadget, Width & Height
#C2D_G	=	0						; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Zoomed width
#C2D_H	=	340	*	#C2D_Z	; Zoomed height

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Title / Info"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 5)	; update every 5ms (default)

	;************************************************
	;- *** First initialize program here ***
	;************************************************

	; your code...

	;************************************************
	;- *** Last play music
	;************************************************
	CompilerIf	IsC2D::#IsC2D_Music

		Protected	Music$	=	"..\Data\Music\MOD\Estrayk - Mirror.mod"

		CompilerSelect	IsC2D::#IsC2D_Music

			CompilerCase	IsC2D::#XMU_AMP
				If	C2D::MusicInit()			; <- Set path to AmpMaster or default -> C:\Users\Public\Documents\AmpMaster\
					C2D::MusicPlay(@Music$)	; <- Ptr to filename or *Memory / Length > 0
				EndIf

			CompilerCase	IsC2D::#XMU_SCA
				C2D::MusicInit("..\Tools\SCAL\")	; <- Set default-path to scal_x86/x64.dll
				C2D::MusicPlay(@Music$)

			CompilerDefault
				C2D::MusicPlay(@Music$, 0, 0)

		CompilerEndSelect

	CompilerEndIf

EndProcedure
Procedure	C2D_Update()

	;***********************************************************
	;- *** Update here -> NO! StartDrawing() / StopDrawing() ***
	;***********************************************************
	
	Static	t$	=	"HELLO WORLD"
	
	; your updates
	
	DrawText((#C2D_W - TextWidth(t$)) / 2, (#C2D_H - TextHeight(t$)) / 2, t$)
	
EndProcedure

C2D_Init()	; Must always called before Update

Repeat
	Select	WindowEvent()

		;************************************************
		;- *** Mainloop ***
		;************************************************
		Case	#Null	; or Default
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf

; 		Case	#PB_Event_Gadget
; 			Gadget	=	EventGadget()
; 			Select	C2D::GuiEvent(Gadget)
; 				Case	#Gadget
; 			EndSelect

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
; 				Case	#VK_F1
; 					C2D::ScreenShot()
				Case	#VK_ESCAPE
					Break
			EndSelect
; 			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
; 				Break
; 			EndIf

	EndSelect
ForEver

C2D::Free()
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = --
; UseIcon = ..\Data\Icon\ProjectSmall.ico
; Executable = ..\Executables\C2D_DefaultExample.exe
; CompileSourceDirectory