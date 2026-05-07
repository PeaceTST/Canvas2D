; C2D::Checker / Move + SysFont- Purebasic v6.04

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Bitmap	=	0
	#IsC2D_Clear	=	0
	#IsC2D_Checker	=	1
	#IsC2D_Copper	=	1
	#IsC2D_SysFont	=	1
	#IsC2D_File		=	1
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#Z_VP		=	96 * #C2D_Z	; viewpoint
#Y_POS	=	#C2D_H	*	0.5

#X_SPEED	=	5.0
#Y_SPEED	=	5.0

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Checker / Move + SysFont"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 10)

; checkboard
C2D::CheckerInit(#Y_POS, #C2D_H * 0.5, #Z_VP, 6)

; fog
C2D::CopperInit(0, #C2D_H * 0.5, ?c_fog)

; system font
C2D::SysFontInit(0, "Razor 1911 Retro", @"..\Data\Font\SYS\Razor_r.ttf", 0, 18)

Define	i=#VK_F1, f, x, vp=#Z_VP
Define	t$="F1 to F7 change direction"

; pre-draw textmessage
StartDrawing(CanvasOutput(#C2D_G))
C2D::SysFontSet(0)
x	=	(#C2D_W - TextWidth(t$))	*	0.5	; center by maxlen
DrawText(x, 30 * #C2D_Z	+	0*20, t$)
DrawText(x, 30 * #C2D_Z	+	1*20, "F8 (copper) fog on / off")
DrawText(x, 30 * #C2D_Z	+	2*20, "F9 random checker color")
DrawText(x, 30 * #C2D_Z	+	3*20, "F11 / F12 add / sub view")
StopDrawing()

Repeat
	Select	WindowEvent()

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_F1 To #VK_F7, #VK_F11, #VK_F12
					i_alt	=	i
					i		=	EventwParam()
				Case	#VK_F8
					f	!	1
				Case	#VK_F9
					C2D::CheckerColor(RGB(Random($FF), Random($FF), Random($FF)))
				Case	#VK_ESCAPE
					Break
			EndSelect
			
		Case	#PB_Event_CloseWindow
			Break
			
		Default
			
			If	C2D::Start()

				; draw checker (direction)
				Select	i
					Case	#VK_F1
						C2D::CheckerDraw(#X_SPEED, 0)
					Case	#VK_F2
						C2D::CheckerDraw(-#X_SPEED, 0)
					Case	#VK_F3
						C2D::CheckerDraw(0, #Y_SPEED)
					Case	#VK_F4
						C2D::CheckerDraw(0, -#Y_SPEED)
					Case	#VK_F5
						C2D::CheckerDraw(#X_SPEED, #Y_SPEED * MA_GSin(C2D::C2D\Time))
					Case	#VK_F6
						C2D::CheckerDraw(#X_SPEED * MA_GCos(C2D::C2D\Time), #Y_SPEED)
					Case	#VK_F7
						C2D::CheckerDraw(#X_SPEED * MA_GCos(C2D::C2D\Time), #Y_SPEED * MA_GSin(C2D::C2D\Time))
					Case	#VK_F11
						vp	+	2	:	C2D::CheckerInit(#Y_POS, #C2D_H * 0.5, vp, 6)	:	i=i_alt
					Case	#VK_F12
						vp	-	2	:	C2D::CheckerInit(#Y_POS, #C2D_H * 0.5, vp, 6)	:	i=i_alt
				EndSelect
				
				; draw fog?
				If	f
					DrawingMode(#PB_2DDrawing_AlphaBlend)
					C2D::CopperDraw(0, #C2D_H * 0.5 - 2)
				EndIf

				C2D::Stop()
				
			EndIf

	EndSelect
ForEver

C2D::Free()

DataSection
	c_fog:	:	Data.l	2,	$FF000000, $00000000
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = 9
; Executable = ..\Executables\C2D_Checker_Move_x86.exe
; DisableDebugger
; CompileSourceDirectory