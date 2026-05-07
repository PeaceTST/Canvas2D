; C2D::Bitmap / Shade - Purebasic v5.72

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Bitmap		=	2	; -> BitmapAdd()
	#IsC2D_BitmapColor=	1
	#IsC2D_Clear		=	0
	#IsC2D_File			=	1
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0		; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#POS_X	=	20.0	*	#C2D_Z
#POS_Y	=	16.0	*	#C2D_Z

Procedure.l	xRGB()
	ProcedureReturn	(Random($FF) << 16 | Random($FF) << 8 | Random($FF)) | $FF101010
EndProcedure

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Bitmap / Shade"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 1500)
C2D::Quality(#PB_Image_Smooth)

C2D::BitmapInit(0, @"..\Data\Logo\Psygnosis.bmp")
C2D::BitmapScale(0, 0.75 * #C2D_Z)

C2D::BitmapAdd(1, C2D::BitmapImage(0))
C2D::BitmapAdd(2, C2D::BitmapImage(0))
C2D::BitmapAdd(3, C2D::BitmapImage(0))

Repeat
	Select	WindowEvent()

		Case	#Null

			If	C2D::Start()
				
				C2D::BitmapDraw(0,  #POS_X,  #POS_Y, 255, C2D::#C2F_Left)
				
				C2D::BitmapDraw(1, -#POS_X,  #POS_Y, 255, C2D::#C2F_Right)
				C2D::BitmapDraw(2,  #POS_X, -#POS_Y, 255, C2D::#C2F_Bottom)
				C2D::BitmapDraw(3, -#POS_X, -#POS_Y, 255, C2D::#C2F_Right|C2D::#C2F_Bottom)

				C2D::Stop()

				C2D::BitmapAdd(1, C2D::BitmapImage(0))
				C2D::BitmapAdd(2, C2D::BitmapImage(0))
				C2D::BitmapAdd(3, C2D::BitmapImage(0))

				C2D::BitmapShade(1, xRGB())
				C2D::BitmapShade(2, xRGB())
				C2D::BitmapShade(3, xRGB())

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
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = 5
; Executable = ..\Executables\C2D_Bitmap_Shade.exe
; CompileSourceDirectory