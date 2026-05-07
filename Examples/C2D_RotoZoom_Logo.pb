; C2D::RotoZoom / Logo - Purebasic v5.72

;***************************************************
; *** IsC2D the MUST Init-Module, always needed! ***
IncludePath	"..\Include\"
DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"	; Music, Gui, XUnPack predefined #Types

	#IsC2D_Music		=	#XMU_SCA
	#IsC2D_Clear		=	0	; cleared by buffer
	#IsC2D_Bitmap		=	1
	#IsC2D_Buffer		=	1
	#IsC2D_File			=	1
	#IsC2D_RotoZoom	=	1
	#IsC2D_GdiPlus		=	1
	#IsC2D_ScrollText	=	2	; 2 = {Control,Codes}
	
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

#C2D_X	=	0	*	#C2D_Z
#C2D_Y	=	64	*	#C2D_Z

#FONT_Z	=	32	*	#C2D_Z
#TEXT_Y	=	(#C2D_H	-	#FONT_Z)	*	0.5

Procedure	C2D_Music()
	CompilerIf	IsC2D::#IsC2D_Music
		
		Static	IsPlay
		
		IsPlay	!	1
		
		If	IsPlay	=	0
			
			C2D::MusicFree()
			
		Else
			
			Protected	Music$	=	"..\Data\Music\MOD\Estrayk - Mirror.mod"
			
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
			
		EndIf
		
	CompilerEndIf
EndProcedure
Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("RotoZoom / Logo / SCA"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 10)
	C2D::Quality(0)
	
	CompilerIf	IsC2D::#IsC2D_ScrollText
		C2D::BitmapInit(0, @"..\Data\Font\PNG\RedSector32x32.png")
		C2D::FontInit(0, C2D::BitmapImage(0))
		C2D::FontZoom(0, #FONT_Z, #FONT_Z)
		C2D::FontInit(1, C2D::BitmapImage(0))
		C2D::FontZoom(1, #FONT_Z * 0.72, #FONT_Z)
		C2D::ScrollTextInit(0, ?t_0)
		C2D::ScrollTextSpeed(0, 0.1 * #FONT_Z)
	CompilerEndIf

	;C2D::BitmapInit(0, @"..\Data\Logo\Testaware_Logo.png")
	C2D::BitmapInit(0, @"..\Data\Logo\Psygnosis.bmp")
	C2D::RotoZoomInit(C2D::BitmapImage(0), 224, #Black)
	C2D::RotoZoomSet(15, 3, 140, 2100)
	C2D::RotoZoomClip(#C2D_X, #C2D_Y, #C2D_W - #C2D_X * 2, #C2D_H - #C2D_Y * 2)
	
	;C2D::RotoZoomBlend(100)
	;C2D::RotoZoomAlpha(255)
	
	; create buffered background
	StartDrawing(CanvasOutput(#C2D_G))
	Box(#C2D_X, #C2D_Y, #C2D_W - #C2D_X * 2, #C2D_H - #C2D_Y * 2, $4F0000)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()
	
	C2D::BitmapFree(0)

EndProcedure
Procedure	C2D_Update()

	C2D::BufferBackDraw()
	C2D::RotoZoomDraw(500, 1780)
	
	CompilerIf	IsC2D::#IsC2D_ScrollText
		C2D::ScrollTextDraw(0, #TEXT_Y)
	CompilerEndIf

EndProcedure

C2D_Init()
C2D_Music()

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
				Case	#VK_M			:	C2D_Music()
				Case	#VK_ESCAPE	:	Break
			EndSelect

	EndSelect
ForEver

C2D::Free()

CompilerIf	IsC2D::#IsC2D_ScrollText
	DataSection
		t_0:	:	Data.s	"{1}{5}ROTOZOOM{5}{2,2500}{3}USING THE TINY{3}{5}C2D V"	+
		    	 	      	MA_XC2D()	+
		    	 	      	"{5}{2,2500}{3}CODED IN{3}{5}PUREBASIC V"	+
		    	 	      	MA_XPB()	+
		    	 	      	"{5}{2,2500}{3}{5}M MUSIC ON OFF{5}{2,2500}{3}VISIT US AT{1,1}{3}{5}TESTAWARE.WORDPRESS.COM{5}{2,2500}"
	EndDataSection
CompilerEndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; Folding = Aw
; Executable = ..\Executables\C2D_RotoZoom_Logo_x86.exe
; DisableDebugger
; CompileSourceDirectory