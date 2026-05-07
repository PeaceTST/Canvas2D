; C2D::Copper / Bars - Purebasic v6.04 (x86-64)

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Copper	=	1
	#IsC2D_Clear	=	2
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#Orange	=	$008CFF

#C_NUM	=	6
#C_MAX	=	3	*	7	-	1
#C_H		=	#C2D_H	/	12.0

#C2D_C	=	(#C2D_H - #C_H) * 0.5

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Copper / Bars"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 8)

For	i	=	0	To	#C_NUM
	C2D::CopperInit(i, #C_H, ?l_cbow + i * 4 * SizeOf(Long))
Next

Repeat
	Select	WindowEvent()

		Case	#PB_Event_CloseWindow
			Break
			
		Case	#WM_KEYDOWN
			If	EventwParam()	=	#VK_ESCAPE
				Break
			EndIf
			
		Default
			
			If	C2D::Start()
				For	i	=	0	To	#C_MAX
					C2D::CopperDraw(i % (#C_NUM + 1), #C2D_C + MA_GSin(C2D::C2D\Time * 0.40 + #C_H * (1.5 * i) / #C2D_Z) * #C_H * 5.5);, 255.0 / #C_MAX * i)
				Next
				C2D::Stop()
			EndIf
			
	EndSelect
ForEver

C2D::Free()

DataSection
	l_cbow:
	Data.l	3,	$FF000000,	$FF000000|#Magenta,	$FF000000
	Data.l	3,	$FF000000,	$FF000000|#Blue,		$FF000000
	Data.l	3,	$FF000000,	$FF000000|#Cyan,		$FF000000
	Data.l	3,	$FF000000,	$FF000000|#Green,		$FF000000
	Data.l	3,	$FF000000,	$FF000000|#Yellow,	$FF000000
	Data.l	3,	$FF000000,	$FF000000|#Orange,	$FF000000
	Data.l	3,	$FF000000,	$FF000000|#Red,		$FF000000
	
; 	l_cbow0:	:	Data.l	15,
; 	        	 	      	#Red,			$FF000000|#Red,
; 	        	 	      	#Orange,		$FF000000|#Orange,
; 	        	 	      	#Yellow,		$FF000000|#Yellow,
; 	        	 	      	#Green,		$FF000000|#Green,
; 	        	 	      	#Cyan,		$FF000000|#Cyan,
; 	        	 	      	#Blue,		$FF000000|#Blue,
; 	        	 	      	#Magenta,	$FF000000|#Magenta,
; 	        	 	      	#Red
; 	
; 	l_cbow1:	:	Data.l	11,
; 	       	 	      	#Red,		$FF000000|#Red,
; 	       	 	      	#Orange,	$FF000000|#Orange,
; 	       	 	      	#Yellow,	$FF000000|#Yellow,
; 	       	 	      	#Green,	$FF000000|#Green,
; 	       	 	      	#Cyan,	$FF000000|#Cyan,
; 	       	 	      	#Red
; 	
; 	l_cbow2:	:	Data.l	8,
; 	       	 	      	$FF000000|#Red,
; 	       	 	      	$FF000000|#Orange,
; 	       	 	      	$FF000000|#Yellow,
; 	       	 	      	$FF000000|#Green,
; 	       	 	      	$FF000000|#Cyan,
; 	       	 	      	$FF000000|#Blue,
; 	       	 	      	$FF000000|#Magenta,
; 	       	 	      	$FF000000|#Red
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = -
; Executable = ..\Executables\C2D_Copper_Bars_x86.exe
; DisableDebugger
; CompileSourceDirectory