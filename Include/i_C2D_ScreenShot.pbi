;************************************************
;- *** C2D ScreenShot / 10.09.2018 **************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	XIncludeFile	"C2D_Enums.pbi"
	XIncludeFile	"C2D_Macros.pbi"

CompilerEndIf

Procedure	ScreenShot()
	
	Protected	i
	
	StartDrawing(CanvasOutput(C2D\Gadget))
	i	=	GrabDrawingImage(#PB_Any, 0, 0, OutputWidth(), OutputHeight())
	DrawingMode(#PB_2DDrawing_XOr)
	Box(0, 0, OutputWidth(), OutputHeight(), $FFFFFFFF)
	StopDrawing()
	
	SetClipboardImage(i)
	
	Delay(300)
	
	FreeImage(i)
	
EndProcedure
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = 9
; CompileSourceDirectory