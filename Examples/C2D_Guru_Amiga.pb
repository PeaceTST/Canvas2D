; C2D::Guru / Amiga - Purebasic v5.70

DeclareModule	IsC2D
	#IsC2D_Bitmap			=	1
	#IsC2D_Buffer			=	1	; wave-logo
	#IsC2D_File				=	1	; @file-access 
	#IsC2D_FontRaw			=	1	; guru-text
	#IsC2D_GdiPlus			=	1
	#IsC2D_Guru				=	1
	XIncludeFile	"..\Include\C2D_Defaults.pbi"	; include unused #IsC2D_(Effects)
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"	; adapt path of include

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

#C2D_G	=	0
#C2D_W	=	550	*	#C2D_Z
#C2D_H	=	340	*	#C2D_Z

#IMG_W	=	260	*	#C2D_Z	; ImageWidth
#IMG_H	=	262	*	#C2D_Z	; ImageHeight

#WAV_X	=	24	*	#C2D_Z	; WavingWidth
#WAV_S	=	16					; WavingSpeed
#WAV_F	=	14					; WavingFrequency

#POS_X	=	(#C2D_W	-	#IMG_W)	*	0.5	-	#WAV_X
#POS_W	=	#POS_X	+	#IMG_W	+	#WAV_X
#POS_Y	=	(#C2D_H	-	#IMG_H)	*	0.5
#POS_H	=	#POS_Y	+	#IMG_H

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Guru / Amiga") + " - RIGHT GURU ON / LEFT GURU OFF", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 10, #White)

C2D::BitmapInit(0, @"..\Data\Logo\AmigaHand.png")
C2D::BitmapScale(0, #C2D_Z)

Repeat
	
	Select	WindowEvent()
			
		Case	#Null
			If	C2D::Start()
				
				C2D::BitmapDraw(0, #POS_X + #WAV_X, #POS_Y)
				C2D::BufferSinX(#POS_X, #POS_Y, #POS_W, #POS_H, #WAV_X, #WAV_F * MA_GCosI(C2D::C2D\Count) / #C2D_Z, #WAV_S)
				
				;DrawingMode(#PB_2DDrawing_Outlined)	:	Box(#POS_X, #POS_Y, #IMG_W + #WAV_X * 2, #IMG_H, #Red)
				
				C2D::Stop()	; <- *** here the Guru is drawn! *** <-
				
			EndIf
			
		Case	#WM_RBUTTONUP	; right mousebutton guru on
			
			t$	=	"|SOFTWARE FAILURE.	PRESS LEFT MOUSE BUTTON TO CONTINUE."	+
			  	 	"||"	+
			  	 	"GURU MEDITATION: #"	+
			  	 	LSet(Hex(Random($FF)),	4, "0")	+
			  	 	RSet(Hex(Random($F)),	4, "0")	+
			  	 	"."	+
			  	 	RSet(Hex(Random($FFFF)),8, "0")	+
			  	 	"|"
			
			C2D::GuruInit(@t$, Random($FFFFFF))

		Case	#WM_LBUTTONDOWN	; left mousebutton guru off
			C2D::GuruFree()
			
		Case	#PB_Event_CloseWindow
			Break
			
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf
			
	EndSelect
	
ForEver

C2D::Free()
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = 9
; Executable = ..\Executables\C2D_Guru_Amiga_x86.exe
; CompileSourceDirectory